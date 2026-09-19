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

// MARK: - ЭФФЕКТЫ
struct ReactionEffectView: View {
    let effect: EffectAnimation
    @State private var startDate = Date()

    let totalDuration: Double = 10.0

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            let remaining = max(0, totalDuration - elapsed)
            let intensity = min(1.0, remaining / 1.5)

            ZStack {
                switch effect.type {
                case .liquid:
                    LiquidEffect(color: effect.color, date: context.date, intensity: intensity)
                case .gas:
                    GasEffect(color: effect.color, date: context.date, intensity: intensity)
                case .explosion, .flash:
                    let burstP = min(1.0, elapsed / 1.2)
                    if burstP < 1.0 {
                        explosionBurst(progress: burstP)
                    } else {
                        GasEffect(color: effect.color, date: context.date, intensity: intensity * 0.7)
                    }
                case .precipitateWhite, .precipitateBlue,
                     .precipitateBrown, .precipitateYellow:
                    PrecipitateEffect(color: effect.color, date: context.date, intensity: intensity)
                case .colorChange, .glow:
                    GlowEffect(color: effect.color, date: context.date, intensity: intensity)
                case .none:
                    EmptyView()
                }
            }
        }
    }

    func explosionBurst(progress: Double) -> some View {
        ZStack {
            Circle()
                .fill(effect.color)
                .frame(width: 60, height: 60)
                .scaleEffect(0.3 + progress * 3.0)
                .opacity(1.0 - progress)
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) / 12 * 2 * .pi
                Circle()
                    .fill(effect.color)
                    .frame(width: 10, height: 10)
                    .offset(x: CGFloat(cos(angle)) * CGFloat(progress) * 100,
                            y: CGFloat(sin(angle)) * CGFloat(progress) * 100)
                    .opacity(1.0 - progress)
            }
        }
    }
}

// МАРК: Жидкость — струя течёт вниз
struct LiquidEffect: View {
    let color: Color
    let date: Date
    let intensity: Double

    var body: some View {
        let now = date.timeIntervalSinceReferenceDate
        let cycle: Double = 1.8
        let dropCount = 14

        return ZStack {
            // Свечение лужи внизу
            Ellipse()
                .fill(color.opacity(0.35 * intensity))
                .frame(width: 60, height: 16)
                .blur(radius: 8)
                .offset(y: 130)

            // Центральная струя
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.9 * intensity), color.opacity(0.3 * intensity)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 6, height: 140)
                .offset(y: 70)
                .blur(radius: 1)

            // Капли
            ForEach(0..<dropCount, id: \.self) { i in
                let phase = ((now + Double(i) * (cycle / Double(dropCount)))
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let y = CGFloat(phase * 150)
                let op = (1.0 - phase * 0.5) * intensity
                let size = 5.0 + phase * 6.0
                let xo = CGFloat((i * 37) % 20) - 10

                Ellipse()
                    .fill(color.opacity(op))
                    .frame(width: size, height: size * 1.4)
                    .offset(x: xo, y: y)
            }

            // Дополнительные брызги
            ForEach(0..<8, id: \.self) { i in
                let phase = ((now + Double(i) * 0.25 + 0.7)
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let y = CGFloat(phase * 120)
                let op = (1.0 - phase) * intensity * 0.7
                let size = 2.5 + phase * 3.0
                let xo = CGFloat((i * 53) % 30) - 15

                Circle()
                    .fill(color.opacity(op))
                    .frame(width: size, height: size)
                    .offset(x: xo, y: y)
            }
        }
    }
}

// MARK: - Газ — клубочки дыма поднимаются вверх
struct GasEffect: View {
    let color: Color
    let date: Date
    let intensity: Double

    var body: some View {
        let now = date.timeIntervalSinceReferenceDate
        let cycle: Double = 2.5
        let puffCount = 10

        return ZStack {
            // Струя свечения у основания
            Circle()
                .fill(color.opacity(0.3 * intensity))
                .frame(width: 60, height: 60)
                .blur(radius: 16)

            // Клубы дыма
            ForEach(0..<puffCount, id: \.self) { i in
                let phase = ((now + Double(i) * (cycle / Double(puffCount)))
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let y = CGFloat(-phase * 140)
                let op = (1.0 - phase) * intensity * 0.75
                let size = 25.0 + phase * 45.0
                let xo = CGFloat((i * 47) % 40) - 20
                let wobble = sin(now * 1.5 + Double(i)) * 6.0

                Circle()
                    .fill(color.opacity(op))
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.25)
                    .offset(x: xo + CGFloat(wobble), y: y)
            }

            // Мелкие частички
            ForEach(0..<6, id: \.self) { i in
                let phase = ((now + Double(i) * 0.4 + 1.0)
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let y = CGFloat(-phase * 120)
                let op = (1.0 - phase) * intensity * 0.5
                let size = 8.0 + phase * 12.0

                Circle()
                    .fill(color.opacity(op))
                    .frame(width: size, height: size)
                    .blur(radius: 4)
                    .offset(
                        x: CGFloat((i * 61) % 50) - 25,
                        y: y
                    )
            }
        }
    }
}

// MARK: - Осадок — твёрдые частицы падают
struct PrecipitateEffect: View {
    let color: Color
    let date: Date
    let intensity: Double

    var body: some View {
        let now = date.timeIntervalSinceReferenceDate
        let cycle: Double = 1.8
        let particleCount = 18

        return ZStack {
            // Свечение
            Circle()
                .fill(color.opacity(0.25 * intensity))
                .frame(width: 60, height: 60)
                .blur(radius: 14)

            // Твёрдые крупинки падают
            ForEach(0..<particleCount, id: \.self) { i in
                let phase = ((now + Double(i) * (cycle / Double(particleCount)))
                             .truncatingRemainder(dividingBy: cycle)) / cycle
                let y = CGFloat(phase * 130)
                let op = intensity * 0.9
                let size = 4.0 + Double((i * 13) % 6)
                let xo = CGFloat((i * 31) % 50) - 25

                Circle()
                    .fill(color.opacity(op))
                    .frame(width: size, height: size)
                    .offset(x: xo, y: y)
            }
        }
    }
}

// MARK: - Свечение / изменение цвета
struct GlowEffect: View {
    let color: Color
    let date: Date
    let intensity: Double

    var body: some View {
        let phase = (date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.4)) / 1.4
        let scale = 0.85 + phase * 0.8
        let opacity = (1.0 - phase) * 0.6 * intensity

        return ZStack {
            Circle()
                .fill(color.opacity(opacity * 0.7))
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .blur(radius: 12)

            Circle()
                .fill(color.opacity(opacity))
                .frame(width: 60, height: 60)
                .blur(radius: 8)
        }
    }
}
