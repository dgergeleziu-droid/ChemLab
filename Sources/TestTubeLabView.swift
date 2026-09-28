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
    var amount: CGFloat
}

// ============================================================
// MARK: - Таймер физики
// ============================================================

final class PhysicsTicker: ObservableObject {
    @Published var tick: Int = 0
    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick &+= 1
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

// ============================================================
// MARK: - Фигуры
// ============================================================

struct TiltedLiquidShape: Shape {
    var fillLevel: CGFloat
    var tubeAngle: Angle

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(fillLevel, CGFloat(tubeAngle.degrees)) }
        set {
            fillLevel = newValue.first
            tubeAngle = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let rad = tubeAngle.radians
        let W = rect.width
        let H = rect.height
        let clamped = min(max(fillLevel, 0), 1)
        let surfaceY = H * (1 - clamped)
        let slope = -tan(rad)
        let halfW = W * 1.2

        let leftY  = surfaceY - halfW * slope
        let rightY = surfaceY + halfW * slope

        path.move(to: CGPoint(x: -W, y: leftY))
        path.addLine(to: CGPoint(x: W * 2, y: rightY))
        path.addLine(to: CGPoint(x: W * 2, y: H + 40))
        path.addLine(to: CGPoint(x: -W, y: H + 40))
        path.closeSubpath()
        return path
    }
}

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height

        path.move(to: CGPoint(x: w/2, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.62),
                          control: CGPoint(x: w * 1.05, y: h * 0.28))
        path.addQuadCurve(to: CGPoint(x: w/2, y: h),
                          control: CGPoint(x: w * 0.92, y: h))
        path.addQuadCurve(to: CGPoint(x: w * 0.02, y: h * 0.62),
                          control: CGPoint(x: w * 0.08, y: h))
        path.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                          control: CGPoint(x: -w * 0.05, y: h * 0.28))
        path.closeSubpath()
        return path
    }
}

// ============================================================
// MARK: - Стеклянное тело пробирки
// ============================================================

struct GlassTubeBody: View {
    let tubeW: CGFloat
    let tubeH: CGFloat
    let liquid: TubeContent?
    let solids: [TubeContent]
    let gasCount: Int
    let temperature: Double
    let tubeAngle: Angle
    let litFlameNearby: Bool

    @State private var bubblePhase: CGFloat = 0
    @State private var steamPhase: CGFloat = 0
    @State private var surfaceShimmer: CGFloat = 0

    private var cornerRadius: CGFloat { tubeW / 2 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.02),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            if let liquid = liquid {
                ZStack {
                    TiltedLiquidShape(fillLevel: liquid.amount, tubeAngle: tubeAngle)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: liquid.colorHex).opacity(0.92),
                                    Color(hex: liquid.colorHex).opacity(0.55)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                    TiltedLiquidShape(fillLevel: liquid.amount, tubeAngle: tubeAngle)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                    TiltedLiquidShape(fillLevel: liquid.amount + 0.06, tubeAngle: tubeAngle)
                        .fill(Color.white.opacity(0.10))
                        .blendMode(.plusLighter)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .opacity(0.5 + Double(sin(surfaceShimmer)) * 0.15)
                }
            }

            if !solids.isEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(Array(solids.enumerated()), id: \.element.id) { idx, solid in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: solid.colorHex),
                                            Color(hex: solid.colorHex).opacity(0.55)
                                        ],
                                        center: .topLeading,
                                        startRadius: 1, endRadius: 10
                                    )
                                )
                                .frame(width: 10, height: 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
                                )
                                .rotationEffect(.degrees(Double((idx * 37) % 45) - 20))
                                .offset(y: CGFloat(idx % 2) * 3)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 12)
                }
            }

            if gasCount > 0 {
                ZStack {
                    ForEach(0..<min(gasCount * 4, 16), id: \.self) { i in
                        BubbleView(index: i, phase: bubblePhase,
                                   tubeW: tubeW, tubeH: tubeH)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }

            GlassHighlights(tubeW: tubeW, tubeH: tubeH)

            if temperature > 35 {
                let t = min((temperature - 35) / 65, 1.0)
                VStack {
                    Spacer()
                    RadialGradient(
                        colors: [
                            Color(hex: "#F97316").opacity(t * 0.75),
                            Color(hex: "#DC2626").opacity(t * 0.28),
                            Color.clear
                        ],
                        center: .bottom,
                        startRadius: 0,
                        endRadius: tubeW * 1.1
                    )
                    .frame(height: tubeH * 0.55)
                    .blendMode(.plusLighter)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .allowsHitTesting(false)
            }

            if temperature > 55 {
                let opacity = min((temperature - 55) / 45, 1.0) * 0.6
                VStack {
                    ZStack {
                        ForEach(0..<6, id: \.self) { i in
                            let wobble = sin(steamPhase + Double(i) * 0.8) * 10
                            Circle()
                                .fill(Color.white.opacity(opacity * (1.0 - Double(i) * 0.14)))
                                .frame(width: 10 + CGFloat(i) * 5, height: 10 + CGFloat(i) * 5)
                                .blur(radius: 5)
                                .offset(x: wobble, y: -CGFloat(i) * 20 - 10)
                        }
                    }
                    Spacer()
                }
                .frame(width: tubeW, height: tubeH)
                .offset(y: -22)
                .allowsHitTesting(false)
            }

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.65)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.8
                )

            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                .padding(3)

            Ellipse()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.90), Color.white.opacity(0.35)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1.6
                )
                .frame(width: tubeW - 10, height: 12)
                .offset(y: -tubeH/2 + 7)

            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: tubeW - 16, height: 8)
                .offset(y: -tubeH/2 + 7)
                .blur(radius: 2)
        }
        .frame(width: tubeW, height: tubeH)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.05), lineWidth: 6)
                .blur(radius: 3)
                .allowsHitTesting(false)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                bubblePhase = 2 * .pi
            }
            withAnimation(.linear(duration: 3.2).repeatForever(autoreverses: false)) {
                steamPhase = 2 * .pi
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                surfaceShimmer = .pi
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
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.60),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: tubeW * 0.13, height: tubeH * 0.72)
                .blur(radius: 2)
                .offset(x: -tubeW * 0.28, y: -tubeH * 0.02)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: tubeW * 0.05, height: tubeH * 0.50)
                .blur(radius: 1.5)
                .offset(x: tubeW * 0.30, y: tubeH * 0.06)

            Ellipse()
                .fill(Color.white.opacity(0.45))
                .frame(width: tubeW * 0.20, height: 5)
                .blur(radius: 2)
                .offset(x: -tubeW * 0.15, y: -tubeH * 0.36)

            Ellipse()
                .fill(Color.white.opacity(0.15))
                .frame(width: tubeW * 0.55, height: 8)
                .blur(radius: 4)
                .offset(y: -tubeH/2 + 12)
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

    var body: some View {
        let size: CGFloat = CGFloat(3 + (index * 3) % 6)
        let xBase = CGFloat((index * 41) % 60) - 30
        let wobble = sin(phase * 1.5 + CGFloat(index) * 0.9) * 6
        let progress = (phase / (2 * .pi) + CGFloat(index) * 0.13)
            .truncatingRemainder(dividingBy: 1.0)
        let y = tubeH * (0.85 - progress * 0.75)

        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.90),
                        Color.white.opacity(0.30),
                        Color.white.opacity(0.10)
                    ],
                    center: .topLeading,
                    startRadius: 0.5, endRadius: size
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.6)
            )
            .frame(width: size, height: size)
            .offset(x: xBase + wobble, y: y - tubeH/2)
            .opacity(1.0 - Double(progress) * 0.6)
    }
}

// ============================================================
// MARK: - Спиртовка
// ============================================================

struct AlcoholLampView: View {
    let lit: Bool
    let onTap: () -> Void

    @State private var flicker: CGFloat = 0
    @State private var innerFlicker: CGFloat = 0

    private let lampW: CGFloat = 62
    private let lampH: CGFloat = 78

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    if lit {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#F97316").opacity(0.30),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0, endRadius: 55
                                )
                            )
                            .frame(width: 110, height: 110)
                            .offset(y: -6)
                            .blendMode(.plusLighter)

                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#F97316").opacity(0.95),
                                        Color(hex: "#FBBF24").opacity(0.65),
                                        Color(hex: "#EF4444").opacity(0.20)
                                    ],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .frame(width: 30, height: 54)
                            .scaleEffect(y: 0.94 + flicker * 0.10)
                            .offset(y: -6)
                            .shadow(color: Color(hex: "#F97316").opacity(0.7), radius: 12)

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
                            .frame(width: 18, height: 36)
                            .scaleEffect(y: 0.94 + innerFlicker * 0.10)
                            .offset(y: 0)

                        FlameShape()
                            .fill(Color(hex: "#EFF6FF"))
                            .frame(width: 9, height: 18)
                            .offset(y: 8)
                    } else {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: 5, height: 5)
                            .blur(radius: 2)
                            .offset(y: 22)
                    }
                }
                .frame(width: 100, height: 74)
                .offset(y: 2)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "#3F1D0A"))
                    .frame(width: 3, height: 10)
                    .offset(y: -2)

                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#94A3B8"), Color(hex: "#334155")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 28, height: 8)
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 24, height: 1)
                        .offset(y: -2)
                }
                .offset(y: -2)

                ZStack {
                    LampBodyShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: lampW, height: lampH)
                        .overlay(
                            LampBodyShape()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.55),
                                            Color.white.opacity(0.20)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.4
                                )
                                .frame(width: lampW, height: lampH)
                        )

                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#60A5FA").opacity(0.35),
                                        Color(hex: "#3B82F6").opacity(0.55)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: lampW - 16, height: 32)
                            .padding(.bottom, 8)
                    }
                    .frame(width: lampW, height: lampH)

                    Capsule()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 4, height: 32)
                        .blur(radius: 1.5)
                        .offset(x: -lampW * 0.28, y: 4)
                }
            }
            .frame(width: 110, height: 200)
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

struct LampBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let neckW = w * 0.55
        let neckH = h * 0.22
        let shoulderH = h * 0.12

        p.move(to: CGPoint(x: (w - neckW)/2, y: 0))
        p.addLine(to: CGPoint(x: (w + neckW)/2, y: 0))
        p.addQuadCurve(
            to: CGPoint(x: w, y: neckH + shoulderH),
            control: CGPoint(x: w * 0.95, y: neckH + shoulderH * 0.4)
        )
        p.addLine(to: CGPoint(x: w, y: h - 6))
        p.addQuadCurve(
            to: CGPoint(x: w - 6, y: h),
            control: CGPoint(x: w, y: h)
        )
        p.addLine(to: CGPoint(x: 6, y: h))
        p.addQuadCurve(
            to: CGPoint(x: 0, y: h - 6),
            control: CGPoint(x: 0, y: h)
        )
        p.addLine(to: CGPoint(x: 0, y: neckH + shoulderH))
        p.addQuadCurve(
            to: CGPoint(x: (w - neckW)/2, y: 0),
            control: CGPoint(x: w * 0.05, y: neckH + shoulderH * 0.4)
        )
        p.closeSubpath()
        return p
    }
}

// ============================================================
// MARK: - Чип реагента
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
// MARK: - ОСНОВНОЙ ЭКРАН
// ============================================================

struct TestTubeLabView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var ticker = PhysicsTicker()

    @State private var tubeTopAnchor: CGPoint = .zero
    @State private var tubeAngle: Angle = .degrees(0)
    @State private var isDraggingTube: Bool = false
    @State private var dragStartAnchor: CGPoint = .zero

    @State private var contents: [TubeContent] = []

    @State private var temperature: Double = 20
    @State private var lampLit = false
    @State private var isHeatingNow = false

    @State private var selectedState: AggregateState = .liquid
    @State private var draggingReagent: Reagent? = nil
    @State private var dragPosition: CGPoint = .zero

    @State private var reactionResult: ChemicalReaction? = nil
    @State private var showReactionCard = false

    @State private var toastMessage: String? = nil
    @State private var flashOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var spillCooldown: Double = 0
    @State private var screenSize: CGSize = .zero

    private let tubeW: CGFloat = 96
    private let tubeH: CGFloat = 240

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background
                table
                lampLayer(geo: geo)
                tubeLayer(geo: geo)
                heatingIndicator(geo: geo)
                dragPreview
                hudLayer(geo: geo)
                reagentPanel(geo: geo)
                reactionOverlay

                if let msg = toastMessage {
                    toastView(msg)
                }
            }
            .onAppear {
                screenSize = geo.size
                if tubeTopAnchor == .zero {
                    tubeTopAnchor = CGPoint(
                        x: geo.size.width * 0.66,
                        y: geo.size.height * 0.18
                    )
                }
                ticker.start()
            }
            .onDisappear {
                ticker.stop()
            }
        }
        .onReceive(ticker.$tick) { _ in
            physicsTick()
        }
    }

    // ============================================================
    // MARK: - Слои
    // ============================================================

    private var background: some View {
        LinearGradient(
            colors: [Color(hex: "#0B1020"), Color(hex: "#101A2E")],
            startPoint: .top, endPoint: .bottom
        ).ignoresSafeArea()
    }

    private var table: some View {
        VStack {
            Spacer()
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#2A1E14"),
                                Color(hex: "#1A120A")
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: 200)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#7C5A3A").opacity(0.55),
                                Color.clear
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                VStack(spacing: 26) {
                    ForEach(0..<6, id: \.self) { i in
                        Rectangle()
                            .fill(Color.black.opacity(0.08 + Double(i) * 0.015))
                            .frame(height: 1)
                            .padding(.horizontal, 30)
                    }
                }
                .padding(.top, 20)
            }
            .shadow(color: .black.opacity(0.7), radius: 20, y: -4)
        }
    }

    private func lampPosition(geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height - 155)
    }

    private func flameTipPosition(geo: GeometryProxy) -> CGPoint {
        let lamp = lampPosition(geo: geo)
        return CGPoint(x: lamp.x, y: lamp.y - 132)
    }

    private func flameTipPositionFromScreen() -> CGPoint {
        let lamp = CGPoint(x: screenSize.width / 2, y: screenSize.height - 155)
        return CGPoint(x: lamp.x, y: lamp.y - 132)
    }

    private func lampLayer(geo: GeometryProxy) -> some View {
        let pos = lampPosition(geo: geo)
        return AlcoholLampView(
            lit: lampLit,
            onTap: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    lampLit.toggle()
                }
                if lampLit { SoundManager.shared.flame() }
                showToast(lampLit ? "🔥 Спиртовка горит" : "Спиртовка потушена")
            }
        )
        .position(x: pos.x, y: pos.y - 30)
    }

    private func tubeLayer(geo: GeometryProxy) -> some View {
        let liquid = contents.last(where: { $0.state == .liquid })
        let solids = contents.filter { $0.state == .solid }
        let gasCount = contents.filter { $0.state == .gas }.count

        let bottom = tubeBottomWorld()
        let flame = flameTipPosition(geo: geo)
        let dx = bottom.x - flame.x
        let dy = bottom.y - flame.y
        let dist = sqrt(dx*dx + dy*dy)
        let litNearby = lampLit && dist < 90

        return GlassTubeBody(
            tubeW: tubeW,
            tubeH: tubeH,
            liquid: liquid,
            solids: solids,
            gasCount: gasCount,
            temperature: temperature,
            tubeAngle: tubeAngle,
            litFlameNearby: litNearby
        )
        .rotationEffect(tubeAngle, anchor: .top)
        .offset(x: shakeOffset)
        .shadow(color: .black.opacity(0.55), radius: 16, x: 6, y: 12)
        .gesture(tubeDragGesture(geo: geo))
        .position(x: tubeTopAnchor.x, y: tubeTopAnchor.y + tubeH / 2)
        .animation(.spring(response: 0.28, dampingFraction: 0.80), value: tubeTopAnchor)
        .animation(.spring(response: 0.30, dampingFraction: 0.72), value: tubeAngle)
    }

    private func tubeDragGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged { value in
                if !isDraggingTube {
                    isDraggingTube = true
                    dragStartAnchor = tubeTopAnchor
                }
                let newX = dragStartAnchor.x + value.translation.width
                let newY = dragStartAnchor.y + value.translation.height

                let minX = tubeW / 2 + 8
                let maxX = geo.size.width - tubeW / 2 - 8
                let minY: CGFloat = 80
                let maxY = geo.size.height - 240

                tubeTopAnchor = CGPoint(
                    x: min(max(newX, minX), maxX),
                    y: min(max(newY, minY), maxY)
                )
            }
            .onEnded { _ in
                isDraggingTube = false
            }
    }

    private func heatingIndicator(geo: GeometryProxy) -> some View {
        Group {
            if isHeatingNow {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#F97316").opacity(0.55), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .blur(radius: 3)
                    Circle()
                        .stroke(Color(hex: "#FBBF24").opacity(0.85), lineWidth: 1)
                        .frame(width: 52, height: 52)
                    Text("🔥")
                        .font(.system(size: 22))
                        .offset(y: -62)
                }
                .position(flameTipPosition(geo: geo))
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
                    .fill(Color(hex: r.colorHex).opacity(0.45))
                    .frame(width: 88, height: 88)
                    .blur(radius: 14)
                InlineChip(reagent: r, size: 62)
            }
            .position(dragPosition)
            .allowsHitTesting(false)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private func hudLayer(geo: GeometryProxy) -> some View {
        VStack(spacing: 8) {
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

            temperatureGauge

            Spacer()

            HStack(spacing: 10) {
                rotateButton(degrees: -15, icon: "rotate.left", label: "-15°")
                rotateButton(degrees: 15, icon: "rotate.right", label: "+15°")
                rotateButton(degrees: -45, icon: "arrow.uturn.backward", label: "-45°")
                rotateButton(degrees: 45, icon: "arrow.uturn.forward", label: "+45°")
            }
            .padding(.bottom, 6)

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

            Spacer().frame(height: 170)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
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
                let next = tubeAngle.degrees + degrees
                tubeAngle = .degrees(min(max(next, -90), 90))
            }
            SoundManager.shared.click()
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
                    Text("Тащи в пробирку")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#64748B"))
                }
                .padding(.horizontal, 12)

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
    private var reactionOverlay: some View {
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
    // MARK: - Физика
    // ============================================================

    private func physicsTick() {
        guard screenSize != .zero else { return }

        let bottom = tubeBottomWorld()
        let flame = flameTipPositionFromScreen()
        let dx = bottom.x - flame.x
        let dy = bottom.y - flame.y
        let dist = sqrt(dx*dx + dy*dy)
        let heating = lampLit && dist < 75
        isHeatingNow = heating

        if heating {
            temperature = min(100, temperature + 1.6)
        } else {
            temperature = max(20, temperature - 0.5)
        }

        if let idx = contents.lastIndex(where: { $0.state == .liquid }) {
            let tilt = abs(tubeAngle.degrees)
            if tilt > 55 && contents[idx].amount > 0.05 {
                let rate = (tilt - 55) / 100.0 * 0.07
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
        let dx = point.x - tubeTopAnchor.x
        let dy = point.y - tubeTopAnchor.y
        let dist = sqrt(dx*dx + dy*dy)

        if dist < 75 {
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
        SoundManager.shared.bubble()

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
                    let needsHeat = !r.requiredConditions.isEmpty
                    if needsHeat && temperature < 50 {
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

        // Ачивки и дневник
        AchievementsStorage.shared.add("first_reaction")
        AchievementsStorage.shared.add("chemist_50")
        AchievementsStorage.shared.add("chemist_100")
        if r.effect == .explosion || r.effect == .flash {
            AchievementsStorage.shared.add("explosionist")
        }
        if r.effect == .precipitateWhite || r.effect == .precipitateBlue
            || r.effect == .precipitateBrown || r.effect == .precipitateYellow {
            AchievementsStorage.shared.add("analyst")
        }
        if r.effect == .gas { AchievementsStorage.shared.add("gas_master") }
        DiaryStorage.shared.add(equation: r.equation,
                                products: r.productNames,
                                warning: r.warning)
        AchievementsStorage.shared.set("diary_20", to: DiaryStorage.shared.entries.count)
        SoundManager.shared.explode()
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
