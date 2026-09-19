import SwiftUI

struct CanvasView: View {
    @Binding var items: [WorldItem]
    @Binding var effects: [EffectAnimation]
    let canvasScale: CGFloat
    let canvasOffset: CGSize
    let screenSize: CGSize
    let onDragEnd: () -> Void
    let onDelete: (UUID) -> Void
    let onItemDragChange: (Bool) -> Void

    var body: some View {
        ZStack {
            GridCanvas(scale: canvasScale, offset: canvasOffset).allowsHitTesting(false)
            ForEach($items) { $item in
                DraggableItemView(
                    item: $item, scale: canvasScale,
                    onDragEnd: onDragEnd,
                    onDelete: { onDelete(item.id) },
                    onDragChange: onItemDragChange
                )
                .position(
                    x: screenSize.width/2 + item.worldPosition.x * canvasScale + canvasOffset.width,
                    y: screenSize.height/2 + item.worldPosition.y * canvasScale + canvasOffset.height
                )
            }
            ForEach(effects) { effect in
                ReactionEffectView(effect: effect)
                    .position(
                        x: screenSize.width/2 + effect.position.x * canvasScale + canvasOffset.width,
                        y: screenSize.height/2 + effect.position.y * canvasScale + canvasOffset.height
                    )
                    .allowsHitTesting(false)
            }
        }
    }
}

struct GridCanvas: View {
    let scale: CGFloat; let offset: CGSize
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 50 * scale
            guard spacing > 4 else { return }
            let originX = size.width/2 + offset.width
            let originY = size.height/2 + offset.height
            let lineColor = Color(hex: "#1E293B").opacity(0.6)
            var x = originX.truncatingRemainder(dividingBy: spacing)
            if x < 0 { x += spacing }
            while x < size.width {
                var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(p, with: .color(lineColor), lineWidth: 0.5); x += spacing
            }
            var y = originY.truncatingRemainder(dividingBy: spacing)
            if y < 0 { y += spacing }
            while y < size.height {
                var p = Path(); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(p, with: .color(lineColor), lineWidth: 0.5); y += spacing
            }
        }
    }
}

// MARK: - ПЕРЕТАСКИВАЕМЫЙ ЭЛЕМЕНТ (БАГ УДАЛЕНИЯ ИСПРАВЛЕН)
struct DraggableItemView: View {
    @Binding var item: WorldItem
    let scale: CGFloat
    let onDragEnd: () -> Void
    let onDelete: () -> Void
    let onDragChange: (Bool) -> Void

    @State private var dragStart: CGPoint? = nil
    @State private var isDragging = false

    var body: some View {
        Group {
            if item.kind == .equation { equationView } else { reagentView }
        }
        .scaleEffect(scale)
        .contentShape(Rectangle())
        // Жест перетаскивания с высоким приоритетом
        .highPriorityGesture(
            DragGesture(minimumDistance: 2, coordinateSpace: .global)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        dragStart = item.worldPosition
                        onDragChange(true)
                    }
                    guard let start = dragStart else { return }
                    item.worldPosition = CGPoint(
                        x: start.x + value.translation.width / scale,
                        y: start.y + value.translation.height / scale
                    )
                }
                .onEnded { _ in
                    isDragging = false
                    dragStart = nil
                    onDragChange(false)
                    onDragEnd()
                }
        )
        // Двойной тап — удаление (simultaneousGesture, чтобы не конфликтовал с drag)
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { onDelete() }
        )
    }

    var reagentView: some View {
        Text(item.symbol)
            .font(.system(size: item.symbol.count > 3 ? 14 : (item.symbol.count > 2 ? 18 : 24), weight: .bold))
            .foregroundColor(.white)
            .minimumScaleFactor(0.4).lineLimit(1)
            .padding(.horizontal, 6)
            .frame(width: 72, height: 72)
            .background(Circle().fill(RadialGradient(
                gradient: Gradient(colors: [Color(hex: item.colorHex).opacity(0.95), Color(hex: item.colorHex).opacity(0.55)]),
                center: .topLeading, startRadius: 4, endRadius: 65)))
            .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1.5))
            .shadow(color: Color(hex: item.colorHex).opacity(0.7), radius: 12, x: 0, y: 4)
    }

    var equationView: some View {
        Text(item.equationText ?? "")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E3A8A").opacity(0.92)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#60A5FA"), lineWidth: 1))
            .shadow(color: Color(hex: "#3B82F6").opacity(0.6), radius: 8, x: 0, y: 2)
            .fixedSize()
    }
}

// MARK: - ЭФФЕКТ РЕАКЦИИ (без изменений)
struct ReactionEffectView: View {
    let effect: EffectAnimation
    @State private var animate = false
    var body: some View {
        ZStack {
            if effect.type == .explosion || effect.type == .flash {
                Circle().fill(effect.color).frame(width: 60, height: 60)
                    .scaleEffect(animate ? 3.2 : 0.2).opacity(animate ? 0 : 0.9)
                    .animation(.easeOut(duration: 1.0), value: animate)
                ForEach(0..<8, id: \.self) { i in
                    let a = Double(i)/8 * 2 * .pi
                    Circle().fill(effect.color).frame(width: 8, height: 8)
                        .offset(x: animate ? CGFloat(cos(a)) * 70 : 0, y: animate ? CGFloat(sin(a)) * 70 : 0)
                        .opacity(animate ? 0 : 1).animation(.easeOut(duration: 1.0), value: animate)
                }
            } else if effect.type == .gas {
                ForEach(0..<8, id: \.self) { i in
                    Circle().fill(effect.color.opacity(0.75)).frame(width: 10, height: 10)
                        .offset(x: CGFloat.random(in: -35...35), y: animate ? -90 : 0)
                        .opacity(animate ? 0 : 1)
                        .animation(.easeOut(duration: 1.4).delay(Double(i)*0.08), value: animate)
                }
            } else if effect.type == .precipitateWhite || effect.type == .precipitateBlue ||
                      effect.type == .precipitateBrown || effect.type == .precipitateYellow {
                ForEach(0..<10, id: \.self) { i in
                    Circle().fill(effect.color.opacity(0.8)).frame(width: 7, height: 7)
                        .offset(x: CGFloat.random(in: -35...35), y: animate ? 70 : -10)
                        .opacity(animate ? 0 : 1)
                        .animation(.easeIn(duration: 1.3).delay(Double(i)*0.05), value: animate)
                }
            } else if effect.type == .colorChange {
                Circle().fill(effect.color.opacity(0.6)).frame(width: 90, height: 90)
                    .scaleEffect(animate ? 1.6 : 0.7).opacity(animate ? 0 : 0.85)
                    .animation(.easeOut(duration: 1.2), value: animate)
            } else {
                Circle().fill(effect.color.opacity(0.5)).frame(width: 80, height: 80)
                    .scaleEffect(animate ? 1.7 : 0.6).opacity(animate ? 0 : 0.8)
                    .animation(.easeOut(duration: 1.2), value: animate)
            }
        }.onAppear { animate = true }
    }
}
