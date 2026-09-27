import SwiftUI

// ============================================================
// MARK: - Агрегатное состояние
// ============================================================

enum AggregateState: String, CaseIterable {
    case liquid = "Жидкости"
    case solid  = "Твёрдые"
    case gas    = "Газы"

    var icon: String {
        switch self {
        case .liquid: return "drop.fill"
        case .solid:  return "cube.fill"
        case .gas:    return "wind"
        }
    }
}

extension ChemistryData {
    static func aggregateState(of symbol: String) -> AggregateState {
        let gases: Set<String> = [
            "H","O","N","F","Cl","He","Ne","Ar","Kr","Xe","Rn",
            "CO","CO2","SO2","SO3","NO","NO2","N2O5","NH3","H2S",
            "CH4","C2H2","C2H4","C2H6","C3H8","C4H10","PH3","SiH4","B2H6"
        ]
        let liquids: Set<String> = [
            "H2O","H2SO4","HNO3","HCl","HBr","HI","HF",
            "C2H5OH","CH3OH","C6H6","C6H5OH","CH3COOH",
            "C2H5Br","CH3Cl","C2H5Cl","Br","Hg"
        ]
        if gases.contains(symbol)   { return .gas }
        if liquids.contains(symbol) { return .liquid }
        return .solid
    }
}

// ============================================================
// MARK: - Содержимое пробирки
// ============================================================

struct TubeContent: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let colorHex: String
    let state: AggregateState
    var amount: CGFloat  // 0...1 только для жидкостей
}

// ============================================================
// MARK: - Кастомные фигуры
// ============================================================

/// Поверхность жидкости ВСЕГДА горизонтальна в мире.
/// Когда пробирку наклоняют, эта фигура внутри локальных координат
/// получает наклон -angle, что компенсирует поворот пробирки.
struct TiltedLiquidShape: Shape {
    var fillLevel: CGFloat
    var tubeAngle: Angle

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(fillLevel, CGFloat(tubeAngle.degrees)) }
        set {
            fillLevel  = newValue.first
            tubeAngle  = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let rad = tubeAngle.radians
        let W = rect.width
        let H = rect.height
        let clampedFill = min(max(fillLevel, 0), 1)
        let surfaceY = H * (1 - clampedFill)
        let slope = -tan(rad)            // ← поверхность остаётся горизонтальной
        let halfExtent = W * 0.9

        let leftY  = surfaceY - halfExtent * slope
        let rightY = surfaceY + halfExtent * slope

        path.move(to: CGPoint(x: -20, y: leftY))
        path.addLine(to: CGPoint(x: W + 20, y: rightY))
        path.addLine(to: CGPoint(x: W + 20, y: H + 20))
        path.addLine(to: CGPoint(x: -20, y: H + 20))
        path.closeSubpath()
        return path
    }
}

/// Форма пламени — капля с острым верхом
struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height

        path.move(to: CGPoint(x: w/2, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.95, y: h * 0.60),
                          control: CGPoint(x: w * 1.05, y: h * 0.25))
        path.addQuadCurve(to: CGPoint(x: w/2, y: h),
                          control: CGPoint(x: w * 0.90, y: h))
        path.addQuadCurve(to: CGPoint(x: w * 0.05, y: h * 0.60),
                          control: CGPoint(x: w * 0.10, y: h))
        path.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                          control: CGPoint(x: -w * 0.05, y: h * 0.25))
        path.closeSubpath()
        return path
    }
}

// ============================================================
// MARK: - Стеклянная пробирка (тело)
// ============================================================

struct GlassTubeBody: View {
    let tubeW: CGFloat
    let tubeH: CGFloat
    let liquid: TubeContent?
    let solids: [TubeContent]
    let gasCount: Int
    let temperature: Double
    let tubeAngle: Angle

    @State private var bubblePhase: CGFloat = 0
    @State private var steamPhase: CGFloat = 0

    var body: some View {
        ZStack {

            // 1. Внутренняя тёмная подложка стекла
            RoundedRectangle(cornerRadius: tubeW/2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.02),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            // 2. Жидкость (полусфера с горизонтальной поверхностью)
            if let liquid = liquid {
                TiltedLiquidShape(fillLevel: liquid.amount, tubeAngle: tubeAngle)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: liquid.colorHex).opacity(0.90),
                                Color(hex: liquid.colorHex).opacity(0.55)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: tubeW/2))

                // Блик на поверхности жидкости
                TiltedLiquidShape(fillLevel: liquid.amount, tubeAngle: tubeAngle)
                    .fill(Color.white.opacity(0.10))
                    .blendMode(.plusLighter)
                    .clipShape(RoundedRectangle(cornerRadius: tubeW/2))
            }

            // 3. Твёрдые частицы на дне
            if !solids.isEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(Array(solids.enumerated()), id: \.element.id) { idx, solid in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: solid.colorHex),
                                            Color(hex: solid.colorHex).opacity(0.65)
                                        ],
                                        center: .topLeading,
                                        startRadius: 1, endRadius: 12
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color.white.opacity(0.40), lineWidth: 0.7))
                                .offset(y: CGFloat(idx % 2) * 3)
                        }
                    }
                    .padding(.bottom, 22)
                    .padding(.horizontal, 14)
                }
            }

            // 4. Пузырьки газа
            if gasCount > 0 {
                ZStack {
                    ForEach(0..<min(gasCount * 4, 14), id: \.self) { i in
                        BubbleView(index: i, phase: bubblePhase,
                                   tubeW: tubeW, tubeH: tubeH, tubeAngle: tubeAngle)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: tubeW/2))
            }

            // 5. Блики стекла
            GlassHighlights(tubeW: tubeW, tubeH: tubeH)

            // 6. Свечение дна при нагреве
            if temperature > 35 {
                let t = min((temperature - 35) / 65, 1.0)
                VStack {
                    Spacer()
                    RadialGradient(
                        colors: [
                            Color(hex: "#F97316").opacity(t * 0.75),
                            Color(hex: "#DC2626").opacity(t * 0.30),
                            Color.clear
                        ],
                        center: .bottom,
                        startRadius: 0,
                        endRadius: tubeW * 1.0
                    )
                    .frame(height: tubeH * 0.55)
                    .blendMode(.plusLighter)
                }
                .clipShape(RoundedRectangle(cornerRadius: tubeW/2))
                .allowsHitTesting(false)
            }

            // 7. Пар (струйка из горлышка при нагреве)
            if temperature > 55 {
                let opacity = min((temperature - 55) / 45, 1.0) * 0.55
                VStack {
                    ZStack {
                        ForEach(0..<5, id: \.self) { i in
                            let wobble = sin(steamPhase + Double(i) * 0.7) * 8
                            Circle()
                                .fill(Color.white.opacity(opacity * (1.0 - Double(i) * 0.15)))
                                .frame(width: 12 + CGFloat(i) * 4, height: 12 + CGFloat(i) * 4)
                                .blur(radius: 4)
                                .offset(x: wobble, y: -CGFloat(i) * 18 - 8)
                        }
                    }
                    Spacer()
                }
                .frame(width: tubeW, height: tubeH)
                .offset(y: -20)
                .allowsHitTesting(false)
            }

            // 8. Основная окантовка стекла
            RoundedRectangle(cornerRadius: tubeW/2)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.60)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.8
                )

            // 9. Верхний эллипс горлышка
            Ellipse()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.85), Color.white.opacity(0.40)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .frame(width: tubeW - 8, height: 12)
                .offset(y: -tubeH/2 + 6)
        }
        .frame(width: tubeW, height: tubeH)
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                bubblePhase = 2 * .pi
            }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                steamPhase = 2 * .pi
            }
        }
    }
}

// ============================================================
// MARK: - Блики стекла
// ============================================================

struct GlassHighlights: View {
    let tubeW: CGFloat
    let tubeH: CGFloat

    var body: some View {
        ZStack {
            // Левая вертикальная полоса блика
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: tubeW * 0.14, height: tubeH * 0.68)
                .blur(radius: 2)
                .offset(x: -tubeW * 0.27, y: -tubeH * 0.04)

            // Тонкая полоска справа
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: tubeW * 0.05, height: tubeH * 0.50)
                .blur(radius: 1.5)
                .offset(x: tubeW * 0.30, y: tubeH * 0.05)

            // Мягкое свечение сверху
            Ellipse()
                .fill(Color.white.opacity(0.18))
                .frame(width: tubeW * 0.6, height: 6)
                .blur(radius: 3)
                .offset(y: -tubeH/2 + 10)
        }
        .allowsHitTesting(false)
    }
}

// ============================================================
// MARK: - Пузырёк
// ============================================================

struct BubbleView: View {
    let index: Int
    let phase: CGFloat
    let tubeW: CGFloat
    let tubeH: CGFloat
    let tubeAngle: Angle

    var body: some View {
        let size: CGFloat = CGFloat(3 + (index * 2) % 5)
        let xBase = CGFloat((index * 41) % 60) - 30
        let wobble = sin(phase * 1.4 + CGFloat(index) * 0.9) * 5
        let progress = (phase / (2 * .pi) + CGFloat(index) * 0.13)
            .truncatingRemainder(dividingBy: 1.0)
        let y = tubeH * (0.82 - progress * 0.72)

        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.85),
                        Color.white.opacity(0.25)
                    ],
                    center: .topLeading,
                    startRadius: 0.5, endRadius: size
                )
            )
            .frame(width: size, height: size)
            .offset(x: xBase + wobble, y: y - tubeH/2)
            .opacity(1.0 - Double(progress) * 0.65)
    }
}

// ============================================================
// MARK: - Спиртовка
// ============================================================

struct AlcoholLampView: View {
    let lit: Bool
    let flameTipOffset: CGPoint   // в локальных коорд. относительно центра свечи
    let onTap: () -> Void

    @State private var flicker: CGFloat = 0
    @State private var innerFlicker: CGFloat = 0

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                // Пламя над горлышком
                ZStack {
                    // Внешнее свечение
                    if lit {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#F97316").opacity(0.35),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0, endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .offset(y: -46)
                            .blendMode(.plusLighter)

                        // Внешнее пламя
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#F97316").opacity(0.95),
                                        Color(hex: "#FBBF24").opacity(0.75),
                                        Color(hex: "#EF4444").opacity(0.35)
                                    ],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .frame(width: 34, height: 60)
                            .scaleEffect(y: 0.94 + flicker * 0.08)
                            .offset(y: -46)
                            .shadow(color: Color(hex: "#F97316").opacity(0.7), radius: 12)

                        // Среднее пламя
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FBBF24"),
                                        Color(hex: "#FEF3C7")
                                    ],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .frame(width: 20, height: 40)
                            .scaleEffect(y: 0.94 + innerFlicker * 0.08)
                            .offset(y: -38)

                        // Ядро
                        FlameShape()
                            .fill(Color(hex: "#DBEAFE"))
                            .frame(width: 10, height: 20)
                            .offset(y: -30)
                    } else {
                        // Потухшая: маленькая искорка
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 6, height: 6)
                            .blur(radius: 2)
                            .offset(y: -14)
                    }
                }

                // Сам корпус свечи
                VStack(spacing: -2) {
                    // Фитиль
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#3F1D0A"))
                        .frame(width: 3, height: 12)

                    // Металлическое кольцо
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#94A3B8"), Color(hex: "#475569")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 32, height: 10)

                    // Стеклянный корпус
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.20),
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 66, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.5)
                            )

                        // Спирт внутри
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#60A5FA").opacity(0.35),
                                        Color(hex: "#3B82F6").opacity(0.55)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 56, height: 42)
                            .offset(y: 12)

                        // Блик
                        Capsule()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 5, height: 30)
                            .blur(radius: 1.5)
                            .offset(x: -22, y: -4)
                    }
                }
                .offset(y: 20)
            }
            .frame(width: 120, height: 190)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.24).repeatForever(autoreverses: true)) {
                flicker = 1
            }
            withAnimation(.easeInOut(duration: 0.16).repeatForever(autoreverses: true)) {
                innerFlicker = 1
            }
        }
    }
}

// ============================================================
// MARK: - Чип реагента (без Button — для drag)
// ============================================================

struct InlineChip: View {
    let reagent: Reagent
    let size: CGFloat

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: reagent.colorHex).opacity(0.95),
                                Color(hex: reagent.colorHex).opacity(0.65)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: Color(hex: reagent.colorHex).opacity(0.35),
                            radius: 4, x: 0, y: 2)

                Circle()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: size * 0.22, height: size * 0.22)
                    .blur(radius: 3)
                    .offset(x: -size * 0.15, y: -size * 0.18)

                Text(reagent.symbol)
                    .font(.system(size: size >= 50 ? 16 : 13,
                                  weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.30), radius: 1, x: 0, y: 1)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }
            .frame(width: size, height: size)

            Text(reagent.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color(hex: "#94A3B8"))
                .lineLimit(1)
                .frame(width: 68)
        }
        .frame(width: size + 12)
    }
}

// ============================================================
// MARK: - ОСНОВНОЙ ЭКРАН ПРОБИРКИ
// ============================================================

struct TestTubeLabView: View {
    @Environment(\.dismiss) private var dismiss

    // Физика пробирки
    @State private var tubeTopAnchor: CGPoint = .zero
    @State private var tubeAngle: Angle = .degrees(0)
    @State private var isDraggingTube: Bool = false
    @State private var dragStartAnchor: CGPoint = .zero

    // Содержимое
    @State private var contents: [TubeContent] = []

    // Нагрев
    @State private var temperature: Double = 20
    @State private var lampLit = false
    @State private var isHeatingNow = false

    // Реагенты (панель)
    @State private var selectedState: AggregateState = .liquid

    // Drag реагента из панели в пробирку
    @State private var draggingReagent: Reagent? = nil
    @State private var dragPosition: CGPoint = .zero

    // Реакции
    @State private var reactionResult: ChemicalReaction? = nil
    @State private var showReactionCard = false

    // Вспомогательные
    @State private var toastMessage: String? = nil
    @State private var flashOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var spillCooldown: Double = 0

    // Таймер физики
    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // Размеры
    private let tubeW: CGFloat = 108
    private let tubeH: CGFloat = 260

    var body: some View {
        GeometryReader { geo in
            let lampPos = CGPoint(x: geo.size.width / 2, y: geo.size.height - 210)
            let lampFlameTip = CGPoint(x: lampPos.x, y: lampPos.y - 40)

            ZStack {
                background
                lampLayer(lampPos: lampPos)
                tubeLayer(geo: geo)
                heatingIndicator(flameTip: lampFlameTip)
                dragPreview
                hudLayer(geo: geo)
                reagentPanel(geo: geo)
                reactionLayer

                if let msg = toastMessage {
                    toastView(msg)
                }
            }
            .onAppear {
                tubeTopAnchor = CGPoint(x: geo.size.width * 0.68,
                                        y: geo.size.height * 0.16)
            }
        }
        .onReceive(ticker) { _ in
            physicsTick()
        }
    }

    // ============================================================
    // MARK: - Слои
    // ============================================================

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0B1020"), Color(hex: "#0F1A2E")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            // Стол
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1E293B"), Color(hex: "#0B1020")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: 220)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 1),
                        alignment: .top
                    )
                    .shadow(color: .black.opacity(0.7), radius: 20, y: -4)
            }
        }
    }

    private func lampLayer(lampPos: CGPoint) -> some View {
        AlcoholLampView(
            lit: lampLit,
            flameTipOffset: .zero,
            onTap: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    lampLit.toggle()
                }
                showToast(lampLit ? "🔥 Спиртовка горит" : "Спиртовка потушена")
            }
        )
        .position(x: lampPos.x, y: lampPos.y - 30)
    }

    private func tubeLayer(geo: GeometryProxy) -> some View {
        let liquid = contents.last(where: { $0.state == .liquid })
        let solids = contents.filter { $0.state == .solid }
        let gasCount = contents.filter { $0.state == .gas }.count

        return GlassTubeBody(
            tubeW: tubeW,
            tubeH: tubeH,
            liquid: liquid,
            solids: solids,
            gasCount: gasCount,
            temperature: temperature,
            tubeAngle: tubeAngle
        )
        .rotationEffect(tubeAngle, anchor: .top)
        .offset(x: shakeOffset)
        .shadow(color: .black.opacity(0.5), radius: 18, x: 6, y: 10)
        .gesture(tubeDragGesture)
        .position(x: tubeTopAnchor.x, y: tubeTopAnchor.y + tubeH / 2)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: tubeTopAnchor)
        .animation(.spring(response: 0.30, dampingFraction: 0.72), value: tubeAngle)
    }

    private var tubeDragGesture: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged { value in
                if !isDraggingTube {
                    isDraggingTube = true
                    dragStartAnchor = tubeTopAnchor
                }
                tubeTopAnchor = CGPoint(
                    x: dragStartAnchor.x + value.translation.width,
                    y: dragStartAnchor.y + value.translation.height
                )
            }
            .onEnded { _ in
                isDraggingTube = false
            }
    }

    private func heatingIndicator(flameTip: CGPoint) -> some View {
        Group {
            if isHeatingNow {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#F97316").opacity(0.6), lineWidth: 2)
                        .frame(width: 90, height: 90)
                        .blur(radius: 3)
                    Circle()
                        .stroke(Color(hex: "#FBBF24").opacity(0.85), lineWidth: 1)
                        .frame(width: 60, height: 60)
                    Text("🔥")
                        .font(.system(size: 22))
                        .offset(y: -70)
                }
                .position(flameTip)
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private var dragPreview: some View {
        if let r = draggingReagent {
            ZStack {
                Circle()
                    .fill(Color(hex: r.colorHex).opacity(0.4))
                    .frame(width: 90, height: 90)
                    .blur(radius: 14)
                InlineChip(reagent: r, size: 62)
            }
            .position(dragPosition)
            .allowsHitTesting(false)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private func hudLayer(geo: GeometryProxy) -> some View {
        VStack {
            // Верхняя панель
            HStack(spacing: 10) {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color(hex: "#1E293B"))
                    .clipShape(Capsule())
                }

                Spacer()

                Text("🧪 Пробирка")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        contents.removeAll()
                        lampLit = false
                        temperature = 20
                        tubeAngle = .degrees(0)
                    }
                    showToast("Опустошено")
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(hex: "#1E293B"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Шкала температуры
            temperatureGauge
                .padding(.horizontal, 16)
                .padding(.top, 8)

            Spacer()

            // Кнопки поворота
            HStack(spacing: 10) {
                rotateButton(degrees: -15, icon: "rotate.left", label: "-15°")
                rotateButton(degrees: 15, icon: "rotate.right", label: "+15°")
                rotateButton(degrees: -45, icon: "arrow.uturn.backward", label: "-45°")
                rotateButton(degrees: 45, icon: "arrow.uturn.forward", label: "+45°")
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 16)

            // Угол + тряска кнопок
            HStack {
                Text("Угол: \(Int(tubeAngle.degrees))°")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#94A3B8"))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(hex: "#1E293B").opacity(0.7))
                    .cornerRadius(10)
                Spacer()
                if !contents.isEmpty {
                    Text("Внутри: \(contents.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color(hex: "#1E293B").opacity(0.7))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)

            Spacer().frame(height: 165)
        }
    }

    private var temperatureGauge: some View {
        HStack(spacing: 8) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(gaugeColor)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "#1E293B"))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#3B82F6"), gaugeColor],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: g.size.width * CGFloat(temperature / 100))
                        .animation(.easeOut(duration: 0.2), value: temperature)
                }
            }
            .frame(height: 8)

            Text("\(Int(temperature))°C")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#0F172A").opacity(0.85))
        .cornerRadius(10)
    }

    private var gaugeColor: Color {
        if temperature < 40 { return Color(hex: "#60A5FA") }
        if temperature < 70 { return Color(hex: "#F59E0B") }
        return Color(hex: "#EF4444")
    }

    private func rotateButton(degrees: Double, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                tubeAngle += .degrees(degrees)
                let d = tubeAngle.degrees
                if d > 90 { tubeAngle = .degrees(90) }
                if d < -90 { tubeAngle = .degrees(-90) }
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(width: 52, height: 40)
            .background(Color(hex: "#1E293B"))
            .cornerRadius(10)
        }
    }

    private func reagentPanel(geo: GeometryProxy) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                // Вкладки состояний
                HStack(spacing: 8) {
                    ForEach(AggregateState.allCases, id: \.self) { st in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedState = st }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: st.icon).font(.system(size: 10))
                                Text(st.rawValue).font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(selectedState == st ? .white : Color(hex: "#94A3B8"))
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(
                                Capsule().fill(selectedState == st
                                               ? Color(hex: "#3B82F6")
                                               : Color(hex: "#1E293B"))
                            )
                        }
                    }
                    Spacer()
                    Text("Держи и тащи в пробирку")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#64748B"))
                }
                .padding(.horizontal, 12)

                // Полоса чипов
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(filteredReagents, id: \.symbol) { r in
                            InlineChip(reagent: r, size: 52)
                                .gesture(reagentDragGesture(for: r))
                                .opacity(draggingReagent?.symbol == r.symbol ? 0.35 : 1)
                                .scaleEffect(draggingReagent?.symbol == r.symbol ? 0.9 : 1)
                                .animation(.spring(response: 0.25), value: draggingReagent?.symbol)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
                .frame(height: 92)
            }
            .padding(.top, 10)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#0B1020")],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
    }

    private var filteredReagents: [Reagent] {
        ChemistryData.reagents.filter {
            ChemistryData.aggregateState(of: $0.symbol) == selectedState
        }
    }

    private func reagentDragGesture(for r: Reagent) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .onChanged { value in
                if draggingReagent == nil {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        draggingReagent = r
                    }
                }
                dragPosition = value.location
            }
            .onEnded { value in
                defer {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        draggingReagent = nil
                    }
                }
                dropReagent(r, at: value.location)
            }
    }

    @ViewBuilder
    private var reactionLayer: some View {
        Color.white
            .opacity(flashOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)

        if showReactionCard, let r = reactionResult {
            reactionCardView(r)
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
        }
    }

    private func toastView(_ msg: String) -> some View {
        VStack {
            Spacer()
            Text(msg)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.black.opacity(0.85))
                .cornerRadius(16)
                .padding(.bottom, 210)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    // ============================================================
    // MARK: - Логика физики
    // ============================================================

    private func physicsTick() {
        // Нагрев
        let bottom = tubeBottomWorld()
        let lampX = UIScreen.main.bounds.width / 2
        let lampFlameY = UIScreen.main.bounds.height - 210 - 40 - 30
        let flameTip = CGPoint(x: lampX, y: lampFlameY)

        let dx = bottom.x - flameTip.x
        let dy = bottom.y - flameTip.y
        let dist = sqrt(dx*dx + dy*dy)
        let heating = lampLit && dist < 75
        isHeatingNow = heating

        if heating {
            temperature = min(100, temperature + 1.4)
        } else {
            temperature = max(20, temperature - 0.4)
        }

        // Спирт испаряется? Нет. Просто остывает.

        // Спил (слишком наклонено — жидкость вытекает)
        if let idx = contents.lastIndex(where: { $0.state == .liquid }) {
            let tilt = abs(tubeAngle.degrees)
            if tilt > 55 && contents[idx].amount > 0.05 {
                let rate = (tilt - 55) / 100.0 * 0.06
                contents[idx].amount = max(0, contents[idx].amount - rate)
                if contents[idx].amount <= 0.01 {
                    contents.remove(at: idx)
                    showToast("💧 Жидкость вылилась")
                } else if spillCooldown <= 0 {
                    spillCooldown = 3.0
                    showToast("💧 Жидкость выливается — выпрями пробирку!")
                }
            }
        }
        spillCooldown = max(0, spillCooldown - 0.1)

        // Реакция при достаточной температуре
        if temperature > 55 {
            tryReaction(requireHeat: true)
        }
    }

    private func tubeBottomWorld() -> CGPoint {
        let rad = tubeAngle.radians
        return CGPoint(
            x: tubeTopAnchor.x - tubeH * sin(rad),
            y: tubeTopAnchor.y + tubeH * cos(rad)
        )
    }

    // ============================================================
    // MARK: - Работа с реагентами
    // ============================================================

    private func dropReagent(_ r: Reagent, at point: CGPoint) {
        // Куда попал палец? Близко к устью?
        let dx = point.x - tubeTopAnchor.x
        let dy = point.y - tubeTopAnchor.y
        let dist = sqrt(dx*dx + dy*dy)

        if dist < 70 {
            addToTube(r)
        } else {
            showToast("Промахнулся — тащи точнее к устью пробирки")
        }
    }

    private func addToTube(_ r: Reagent) {
        guard contents.count < 5 else {
            showToast("Пробирка полная")
            return
        }

        let state = ChemistryData.aggregateState(of: r.symbol)
        let liquidCount = contents.filter { $0.state == .liquid }.count
        let newAmount: CGFloat = state == .liquid
            ? min(0.80, 0.40 + CGFloat(liquidCount) * 0.20)
            : 1.0

        let item = TubeContent(
            symbol: r.symbol,
            name: r.name,
            colorHex: r.colorHex,
            state: state,
            amount: newAmount
        )

        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            contents.append(item)
        }
        showToast("Добавлено: \(r.name)")

        // Пробуем реакцию через мгновение
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            tryReaction(requireHeat: nil)
        }
    }

    private func tryReaction(requireHeat: Bool?) {
        let symbols = contents.map { $0.symbol }
        guard symbols.count >= 2 else { return }

        for i in 0..<symbols.count {
            for j in (i+1)..<symbols.count {
                if let r = ChemistryData.findReaction(symbols[i], symbols[j]) {
                    // Если реакция требует нагрева
                    let needsHeat = !r.requiredConditions.isEmpty
                    if needsHeat && temperature < 50 {
                        // Мягкая подсказка
                        if requireHeat == nil {
                            showToast("Подсказка: подожги спиртовку и нагрей")
                        }
                        return
                    }
                    fireReaction(r)
                    return
                }
            }
        }
    }

    // ============================================================
    // MARK: - Реакция
    // ============================================================

    private func fireReaction(_ r: ChemicalReaction) {
        reactionResult = r

        // Тряска
        withAnimation(.default) { shakeOffset = 6 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            withAnimation(.default) { shakeOffset = -6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.default) { shakeOffset = 3 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
            withAnimation(.default) { shakeOffset = 0 }
        }

        // Вспышка
        if r.effect == .explosion || r.effect == .flash {
            withAnimation(.easeOut(duration: 0.15)) { flashOpacity = 0.65 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.easeOut(duration: 0.4)) { flashOpacity = 0 }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showReactionCard = true
            }
        }
    }

    private func reactionCardView(_ r: ChemicalReaction) -> some View {
        ZStack {
            Color.black.opacity(0.70).ignoresSafeArea()
                .onTapGesture { closeReaction() }

            VStack(spacing: 14) {
                Text("⚗️ Реакция идёт!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(r.equation)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#FBBF24"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Продукты:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#94A3B8"))
                    ForEach(Array(r.products.enumerated()), id: \.offset) { idx, p in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: ChemistryData.findReagent(by: p)?.colorHex ?? "#94A3B8"))
                                .frame(width: 10, height: 10)
                            Text(r.productNames.indices.contains(idx) ? r.productNames[idx] : p)
                                .font(.system(size: 13)).foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#0F172A")))

                if let warning = r.warning {
                    Text(warning)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#F59E0B"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button { closeReaction() } label: {
                    Text("Готово")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#3B82F6"))
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(hex: "#1E293B")))
            .padding(.horizontal, 30)
        }
    }

    private func closeReaction() {
        withAnimation(.easeOut(duration: 0.25)) { showReactionCard = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            withAnimation {
                contents.removeAll()
                reactionResult = nil
                temperature = 20
            }
        }
    }

    private func showToast(_ m: String) {
        withAnimation { toastMessage = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toastMessage = nil }
        }
    }
}
