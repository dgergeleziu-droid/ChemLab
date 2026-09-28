import SwiftUI

struct IndicatorsView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Indicator: String, CaseIterable {
        case litmus = "Лакмус"
        case methyl = "Метилоранж"
        case phenol = "Фенолфталеин"
    }

    private enum Solution: String, CaseIterable {
        case acid = "HCl"
        case base = "NaOH"
        case neutral = "H₂O"
    }

    @State private var indicator: Indicator = .litmus
    @State private var solution: Solution? = nil
    @State private var revealed: Bool = false
    @State private var tried: Set<String> = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 16) {
                    Spacer().frame(height: 8)

                    // Пробирка с индикатором
                    ZStack {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 45)
                                    .strokeBorder(Color.white.opacity(0.55), lineWidth: 2)
                            )

                        // Жидкость
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 30)
                                .fill(liquidColor)
                                .frame(width: 100, height: 150)
                                .padding(.bottom, 6)
                                .animation(.easeInOut(duration: 0.5), value: liquidColor)
                        }
                        .frame(width: 110, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 45))

                        // Подпись
                        Text(indicator.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(Color.black.opacity(0.55)))
                            .offset(y: -130)
                    }

                    // Выбор индикатора
                    Picker("", selection: $indicator) {
                        ForEach(Indicator.allCases, id: \.self) { i in
                            Text(i.rawValue).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .onChange(of: indicator) { _ in
                        revealed = false
                        solution = nil
                    }

                    // Кнопки растворов
                    HStack(spacing: 10) {
                        ForEach(Solution.allCases, id: \.self) { s in
                            Button {
                                solution = s
                                withAnimation { revealed = true }
                                SoundManager.shared.click()
                                tried.insert("\(indicator.rawValue)-\(s.rawValue)")
                                AchievementsStorage.shared.set("indicator_pro", to: tried.count)
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: iconFor(s))
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(s.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorFor(s))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if revealed, let s = solution {
                        Text(explanation(for: s))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                    }

                    Spacer()
                }
            }
            .navigationTitle("🌈 Индикаторы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var liquidColor: Color {
        guard revealed, let s = solution else { return Color(hex: "#94A3B8").opacity(0.35) }
        switch (indicator, s) {
        case (.litmus, .acid):    return Color(hex: "#DC2626")
        case (.litmus, .base):    return Color(hex: "#2563EB")
        case (.litmus, .neutral): return Color(hex: "#7C3AED")
        case (.methyl, .acid):    return Color(hex: "#F97316")
        case (.methyl, .base):    return Color(hex: "#FBBF24")
        case (.methyl, .neutral): return Color(hex: "#F59E0B")
        case (.phenol, .acid):    return Color(hex: "#E5E7EB").opacity(0.4)
        case (.phenol, .base):    return Color(hex: "#EC4899")
        case (.phenol, .neutral): return Color(hex: "#E5E7EB").opacity(0.4)
        }
    }

    private func iconFor(_ s: Solution) -> String {
        switch s {
        case .acid: return "drop.fill"
        case .base: return "drop.triangle.fill"
        case .neutral: return "drop"
        }
    }

    private func colorFor(_ s: Solution) -> Color {
        switch s {
        case .acid: return Color(hex: "#DC2626")
        case .base: return Color(hex: "#2563EB")
        case .neutral: return Color(hex: "#64748B")
        }
    }

    private func explanation(for s: Solution) -> String {
        switch (indicator, s) {
        case (.litmus, .acid):    return "Лакмус в кислоте — красный"
        case (.litmus, .base):    return "Лакмус в щёлочи — синий"
        case (.litmus, .neutral): return "Лакмус в нейтральной среде — фиолетовый"
        case (.methyl, .acid):    return "Метилоранж в кислоте — красный/розовый"
        case (.methyl, .base):    return "Метилоранж в щёлочи — жёлтый"
        case (.methyl, .neutral): return "Метилоранж в нейтральной — оранжевый"
        case (.phenol, .acid):    return "Фенолфталеин в кислоте — бесцветный"
        case (.phenol, .base):    return "Фенолфталеин в щёлочи — малиновый"
        case (.phenol, .neutral): return "Фенолфталеин в нейтральной — бесцветный"
        }
    }
}
