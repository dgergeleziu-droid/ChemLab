import SwiftUI

// MARK: - Агрегатное состояние

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

// MARK: - Содержимое пробирки

struct TubeContent: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let colorHex: String
    let state: AggregateState
    var amount: CGFloat
}

// MARK: - Форма жидкости с волной

struct LiquidShape: Shape {
    var fillLevel: CGFloat
    var wavePhase: CGFloat
    var waveHeight: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(fillLevel, wavePhase) }
        set {
            fillLevel = newValue.first
            wavePhase = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = rect.height * (1 - fillLevel)

        path.move(to: CGPoint(x: 0, y: top))
        let wavelength: CGFloat = rect.width / 1.4
        let steps = 50
        for i in 0...steps {
            let x = rect.width * CGFloat(i) / CGFloat(steps)
            let y = top + sin((x / wavelength) * 2 * .pi + wavePhase) * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Пробирка

struct TestTubeView: View {
    let contents: [TubeContent]
    let lit: Bool

    @State private var wavePhase: CGFloat = 0
    @State private var bubblePhase: CGFloat = 0

    private let tubeWidth: CGFloat = 110
    private let tubeHeight: CGFloat = 300

    var body: some View {
        ZStack(alignment: .bottom) {
            // Стекло
            RoundedRectangle(cornerRadius: 40)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: tubeWidth, height: tubeHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.20)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                )

            // Жидкость
            if let liquid = contents.last(where: { $0.state == .liquid }) {
                LiquidShape(fillLevel: liquid.amount, wavePhase: wavePhase, waveHeight: 3.5)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: liquid.colorHex).opacity(0.95),
                                Color(hex: liquid.colorHex).opacity(0.60)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: tubeWidth - 8, height: tubeHeight - 8)
                    .clipShape(RoundedRectangle(cornerRadius: 36))
                    .overlay(
                        LiquidShape(fillLevel: liquid.amount, wavePhase: wavePhase, waveHeight: 3.5)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: tubeWidth - 8, height: tubeHeight - 8)
                            .clipShape(RoundedRectangle(cornerRadius: 36))
                            .blendMode(.screen)
                    )
            }

            // Твёрдые частицы
            let solids = contents.filter { $0.state == .solid }
            if !solids.isEmpty {
                ZStack(alignment: .bottom) {
                    ForEach(Array(solids.enumerated()), id: \.element.id) { idx, solid in
                        let xOffset = CGFloat((idx % 5) - 2) * 12
                        let yOffset = CGFloat(idx / 5) * 8
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: solid.colorHex),
                                        Color(hex: solid.colorHex).opacity(0.55)
                                    ],
                                    center: .topLeading, startRadius: 1, endRadius: 12
                                )
                            )
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 0.8))
                            .offset(x: xOffset, y: -16 - yOffset)
                    }
                }
                .frame(maxWidth: tubeWidth - 20)
                .padding(.bottom, 12)
            }

            // Газовые пузырьки
            let gasCount = contents.filter { $0.state == .gas }.count
            if gasCount > 0 {
                ForEach(0..<min(gasCount * 5, 14), id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: CGFloat.random(in: 3...7))
                        .offset(
                            x: CGFloat.random(in: -32...32),
                            y: -100 - CGFloat.random(in: -80...130)
                                + sin(bubblePhase + CGFloat(i) * 0.8) * 6
                        )
                }
                .frame(width: tubeWidth - 24, height: tubeHeight - 50, alignment: .bottom)
                .allowsHitTesting(false)
            }

            // Пар (когда лит спиртовка)
            if lit {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: CGFloat.random(in: 12...22))
                        .offset(
                            x: CGFloat.random(in: -25...25),
                            y: -tubeHeight - CGFloat.random(in: -10...50)
                        )
                        .blur(radius: 4)
                }
                .allowsHitTesting(false)
            }
        }
        .frame(width: tubeWidth, height: tubeHeight)
        .onAppear {
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                wavePhase = 2 * .pi
            }
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                bubblePhase = 2 * .pi
            }
        }
    }
}

// MARK: - Форма пламени

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w/2, y: 0))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.65),
                          control: CGPoint(x: w * 0.95, y: h * 0.30))
        path.addQuadCurve(to: CGPoint(x: w/2, y: h),
                          control: CGPoint(x: w * 0.90, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.65),
                          control: CGPoint(x: w * 0.10, y: h))
        path.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                          control: CGPoint(x: w * 0.05, y: h * 0.30))
        path.closeSubpath()
        return path
    }
}

// MARK: - Спиртовая свечка

struct AlcoholLampView: View {
    let lit: Bool
    let onTap: () -> Void

    @State private var flamePhase: CGFloat = 0

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: -4) {
                // Пламя
                ZStack {
                    if lit {
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FBBF24").opacity(0.95),
                                        Color(hex: "#F97316").opacity(0.55)
                                    ],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .frame(width: 36, height: 62)
                            .scaleEffect(y: 0.95 + sin(flamePhase) * 0.05)
                            .shadow(color: Color(hex: "#F97316").opacity(0.55), radius: 10, y: 2)
                        
                        FlameShape()
                            .fill(Color(hex: "#FEF3C7"))
                            .frame(width: 16, height: 32)
                            .offset(y: 6)
                            .scaleEffect(y: 0.95 + sin(flamePhase + 1) * 0.05)
                    } else {
                        // Искра потухшая — тень
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 8, height: 8)
                            .blur(radius: 3)
                    }
                }
                .frame(height: 62)

                // Фитиль
                Rectangle()
                    .fill(Color(hex: "#7C2D12"))
                    .frame(width: 4, height: 12)

                // Горлышко
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "#475569"))
                    .frame(width: 28, height: 14)

                // Стекло
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.40), lineWidth: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#60A5FA").opacity(0.30))
                            .frame(width: 50, height: 34)
                            .padding(.top, 22)
                    )
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                flamePhase = .pi
            }
        }
    }
}

// MARK: - Основной экран "Пробирка"

struct TestTubeLabView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var contents: [TubeContent] = []
    @State private var lampLit = false
    @State private var selectedState: AggregateState = .liquid
    @State private var reactionResult: ChemicalReaction? = nil
    @State private var showReactionCard = false
    @State private var tubeShake: CGFloat = 0
    @State private var flashOpacity: Double = 0
    @State private var toastMessage: String? = nil

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0B1020"), Color(hex: "#0F1A2E")],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    // Сцена
                    ZStack {
                        // Стол
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#1E293B"), Color(hex: "#0F172A")],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .frame(height: 5)
                                .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                                .padding(.bottom, 130)
                        }

                        // Пробирка над спиртовкой
                        VStack(spacing: 10) {
                            TestTubeView(contents: contents, lit: lampLit)
                                .rotationEffect(.degrees(tubeShake))

                            AlcoholLampView(lit: lampLit) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    lampLit.toggle()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)

                    reagentPanel(isLandscape: isLandscape)
                }

                // Вспышка
                Color.white
                    .opacity(flashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // Карточка реакции
                if showReactionCard, let r = reactionResult {
                    reactionCard(r)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(100)
                }

                // Тост
                if let msg = toastMessage {
                    VStack {
                        Spacer()
                        Text(msg)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(16)
                            .padding(.bottom, 190)
                    }
                    .transition(.opacity)
                    .zIndex(50)
                }
            }
        }
    }

    // MARK: Верхняя панель

    var topBar: some View {
        HStack {
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
                }
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
        .padding(.bottom, 4)
    }

    // MARK: Нижняя панель реагентов

    func reagentPanel(isLandscape: Bool) -> some View {
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
            }
            .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(filteredReagents, id: \.symbol) { r in
                        ReagentChip(reagent: r, size: isLandscape ? 40 : 52) {
                            addToTube(r)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
            }
            .frame(height: isLandscape ? 70 : 90)
        }
        .padding(.top, 8)
        .background(Color(hex: "#0F172A"))
    }

    var filteredReagents: [Reagent] {
        ChemistryData.reagents.filter {
            ChemistryData.aggregateState(of: $0.symbol) == selectedState
        }
    }

    // MARK: Добавление реагента

    func addToTube(_ r: Reagent) {
        let state = ChemistryData.aggregateState(of: r.symbol)

        guard contents.count < 4 else {
            showToast("Пробирка полная — нажми «↻», чтобы опустошить")
            return
        }

        let liquidCount = contents.filter { $0.state == .liquid }.count
        let newAmount = state == .liquid
            ? min(0.75, 0.35 + CGFloat(liquidCount) * 0.20)
            : 1.0

        let item = TubeContent(
            symbol: r.symbol,
            name: r.name,
            colorHex: r.colorHex,
            state: state,
            amount: newAmount
        )

        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            contents.append(item)
        }

        // Проверить реакцию через 0.6 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            checkTubeReaction()
        }
    }

    func checkTubeReaction() {
        let symbols = contents.map { $0.symbol }
        guard symbols.count >= 2 else { return }

        for i in 0..<symbols.count {
            for j in (i+1)..<symbols.count {
                if let r = ChemistryData.findReaction(symbols[i], symbols[j]) {
                    // Условия: если реакции нужны особые условия и спиртовка не горит — подсказка
                    if !r.requiredConditions.isEmpty && !lampLit {
                        showToast("Подсказка: подожги спиртовку — нужны особые условия")
                        return
                    }
                    fireReaction(r)
                    return
                }
            }
        }
    }

    func fireReaction(_ r: ChemicalReaction) {
        reactionResult = r

        // Тряска
        withAnimation(.default) { tubeShake = 3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) { tubeShake = -3 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.default) { tubeShake = 0 }
        }

        // Вспышка
        if r.effect == .explosion || r.effect == .flash {
            withAnimation(.easeOut(duration: 0.15)) { flashOpacity = 0.7 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.35)) { flashOpacity = 0 }
            }
        }

        // Показать карточку через мгновение
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showReactionCard = true
            }
        }
    }

    // MARK: Карточка реакции

    func reactionCard(_ r: ChemicalReaction) -> some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
                .onTapGesture { closeReaction() }

            VStack(spacing: 14) {
                Text("⚗️ Реакция!")
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
                                .font(.system(size: 13))
                                .foregroundColor(.white)
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
                        .multilineTextAlignment(.leading)
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

    func closeReaction() {
        withAnimation(.easeOut(duration: 0.25)) {
            showReactionCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            withAnimation {
                contents.removeAll()
                reactionResult = nil
            }
        }
    }

    func showToast(_ m: String) {
        withAnimation { toastMessage = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { toastMessage = nil }
        }
    }
}
