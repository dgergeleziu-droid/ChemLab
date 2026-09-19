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
                    .scaleEffect(canvasScale)
                    .allowsHitTesting(false)
                    .zIndex(100)
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

struct DraggableItemView: View {
    @Binding var item: WorldItem
    let scale: CGFloat
    let onDragEnd: () -> Void
    let onDelete: () -> Void
    let onDragChange: (Bool) -> Void

    @State private var dragStart: CGPoint? = nil
    @State private var isDragging = false
    @State private var lastTapTime: Date = .distantPast

    var body: some View {
        Group {
            if item.kind == .equation { equationView } else { reagentView }
        }
        .scaleEffect(scale)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    let dist = hypot(value.translation.width, value.translation.height)
                    guard dist >= 6 else { return }
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
                .onEnded { value in
                    let dist = hypot(value.translation.width, value.translation.height)
                    if dist < 6 {
                        let now = Date()
                        if now.timeIntervalSince(lastTapTime) < 0.45 {
                            onDelete(); lastTapTime = .distantPast
                        } else { lastTapTime = now }
                    } else {
                        isDragging = false; dragStart = nil
                        onDragChange(false); onDragEnd()
                    }
                }
        )
    }

    var reagentView: some View {
        Text(item.symbol)
            .font(.system(size: item.symbol.count > 3 ? 14 : (item.symbol.count > 2 ? 18 : 24), weight: .bold))
            .foregroundColor(.white).minimumScaleFactor(0.4).lineLimit(1)
            .padding(.horizontal, 6).frame(width: 72, height: 72)
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

// MARK: - ЭФФЕКТ РЕАКЦИИ — 10 СЕКУНД
struct ReactionEffectView: View {
    let effect: EffectAnimation
    @State private var startDate = Date()

    // Эффект длится 10 секунд
    let totalDuration: Double = 10.0

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            let remaining = max(0, totalDuration - elapsed)
            let intensity = min(1.0, remaining / 2.0)

            ZStack {
                switch effect.type {

                case .explosion, .flash:
                    // 0-1.5 сек: яркая вспышка
                    let burstP = min(1.0, elapsed / 1.5)
                    if burstP < 1.0 {
                        explosionBurst(progress: burstP, intensity: 1.0)
                    }
                    // После вспышки: частицы падают вниз (вода, ржавчина, порошок)
                    if remaining > 0 && burstP >= 1.0 {
                        streamParticles(date: context.date, up: false, intensity: intensity)
                    }

                case .gas:
                    // Поток вверх (газ)
                    streamParticles(date: context.date, up: true, intensity: intensity)

                case .precipitateWhite, .precipitateBlue, .precipitateBrown, .precipitateYellow:
                    // Поток вниз (осадок)
                    streamParticles(date: context.date, up: false, intensity: intensity)

                case .colorChange, .glow:
                    // Пульсирующее свечение + лёгкий поток вниз
                    gentleGlow(date: context.date, intensity: intensity)
                    streamParticles(date: context.date, up: false, intensity: intensity * 0.5)

                case .none:
                    EmptyView()
                }
            }
        }
    }

    // Поток частиц (вверх или вниз)
    func streamParticles(date: Date, up: Bool, intensity: Double) -> some View {
        let now = date.timeIntervalSinceReferenceDate
        let particleCount = 20
        let cycle: Double = 1.6

        return ZStack {
            // Свечение у основания
            Circle()
                .fill(effect.color.opacity(0.35 * intensity))
                .frame(width: 60, height: 60)
                .blur(radius: 12)

            ForEach(0..<particleCount, id: \.self) { i in
                let phase = ((now + Double(i) * (cycle / Double(particleCount)))
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let directionMultiplier = up ? -1.0 : 1.0
                let y = CGFloat(directionMultiplier * phase * 160)
                let opacity = (1.0 - phase) * intensity
                let size = 6.0 + phase * 12.0
                let xo = CGFloat((i * 41) % 56) - 28

                Circle()
                    .fill(effect.color.opacity(opacity * 0.85))
                    .frame(width: size, height: size)
                    .offset(x: xo, y: y)
            }

            // Дополнительные мелкие капли
            ForEach(0..<10, id: \.self) { i in
                let phase = ((now + Double(i) * 0.22 + 0.5)
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let directionMultiplier = up ? -1.0 : 1.0
                let y = CGFloat(directionMultiplier * phase * 130)
                let opacity = (1.0 - phase) * intensity
                let size = 3.0 + phase * 6.0
                let xo = CGFloat((i * 67) % 44) - 22

                Circle()
                    .fill(effect.color.opacity(opacity * 0.7))
                    .frame(width: size, height: size)
                    .offset(x: xo, y: y)
            }
        }
    }

    // Пульсирующее свечение
    func gentleGlow(date: Date, intensity: Double) -> some View {
        let phase = (date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.4)) / 1.4
        let scale = 0.7 + phase * 1.0
        let opacity = (1.0 - phase) * 0.7 * intensity
        return ZStack {
            Circle().fill(effect.color.opacity(opacity)).frame(width: 100, height: 100).scaleEffect(scale)
            Circle().fill(effect.color.opacity(opacity * 0.5)).frame(width: 140, height: 140).scaleEffect(scale * 1.2)
        }
    }

    // Первоначальный взрыв
    func explosionBurst(progress: Double, intensity: Double) -> some View {
        ZStack {
            Circle()
                .fill(effect.color)
                .frame(width: 60, height: 60)
                .scaleEffect(0.3 + progress * 3.0)
                .opacity((1.0 - progress) * 0.9 * intensity)

            ForEach(0..<10, id: \.self) { i in
                let angle = Double(i) / 10 * 2 * .pi
                Circle()
                    .fill(effect.color)
                    .frame(width: 8, height: 8)
                    .offset(x: CGFloat(cos(angle)) * CGFloat(progress) * 90,
                            y: CGFloat(sin(angle)) * CGFloat(progress) * 90)
                    .opacity((1.0 - progress) * intensity)
            }
        }
    }
}
