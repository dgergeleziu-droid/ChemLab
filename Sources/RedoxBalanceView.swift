import SwiftUI

struct RedoxBalanceView: View {
    @Environment(\.dismiss) private var dismiss

    struct Task: Identifiable {
        let id = UUID()
        let equation: String         // с коэффициентами
        let oxidizer: String         // кто окислитель
        let reducer: String
        let oxidizerTransition: String   // "Mn⁺⁷ → Mn⁺²"
        let reducerTransition: String
        let accept: [String]         // правильный ответ: сначала окислитель, потом восстановитель
    }

    private let bank: [Task] = [
        .init(equation: "2KMnO₄ + 16HCl → 2KCl + 2MnCl₂ + 5Cl₂ + 8H₂O",
              oxidizer: "Mn", reducer: "Cl",
              oxidizerTransition: "Mn⁺⁷ → Mn⁺²",
              reducerTransition: "Cl⁻¹ → Cl⁰",
              accept: ["Mn","Cl"]),
        .init(equation: "Cu + 4HNO₃(конц.) → Cu(NO₃)₂ + 2NO₂ + 2H₂O",
              oxidizer: "N", reducer: "Cu",
              oxidizerTransition: "N⁺⁵ → N⁺⁴",
              reducerTransition: "Cu⁰ → Cu⁺²",
              accept: ["N","Cu"]),
        .init(equation: "2Na + 2H₂O → 2NaOH + H₂↑",
              oxidizer: "H", reducer: "Na",
              oxidizerTransition: "H⁺¹ → H⁰",
              reducerTransition: "Na⁰ → Na⁺¹",
              accept: ["H","Na"])
    ]

    @State private var task: Task? = nil
    @State private var picked: [String] = []
    @State private var flash: String? = nil
    @State private var score: Int = 0
    @State private var showHint = false

    private let elements = ["Mn","Cl","Cu","N","H","Na","O","Fe"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                if let t = task {
                    VStack(spacing: 18) {
                        header(t)
                        equationCard(t)
                        picker
                        hintBox(t)
                        controls(t)
                        Spacer()
                    }
                    .padding(.top, 8)
                } else {
                    startScreen
                }
                flashOverlay
            }
            .navigationTitle("⚖️ ОВР баланс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { if task == nil { start() } }
    }

    private func header(_ t: Task) -> some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundColor(Color(hex: "#FBBF24"))
            Spacer()
            Text("Определи окислитель и восстановитель")
                .font(.system(size: 11)).foregroundColor(Color(hex: "#94A3B8"))
        }
        .font(.system(size: 13, weight: .semibold))
        .padding(.horizontal, 20).padding(.top, 8)
    }

    private func equationCard(_ t: Task) -> some View {
        Text(t.equation)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
            .padding(.horizontal, 16)
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Окислитель:").font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#94A3B8"))
                chip(picked.first)
                Spacer()
                Text("Восстановитель:").font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#94A3B8"))
                chip(picked.count > 1 ? picked[1] : nil)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(elements, id: \.self) { e in
                        Button {
                            pick(e)
                        } label: {
                            Text(e)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color(hex: "#3B82F6")))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func chip(_ s: String?) -> some View {
        Text(s ?? "—")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 54, height: 40)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E3A8A")))
    }

    private func hintBox(_ t: Task) -> some View {
        Group {
            if showHint {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Подсказка").font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#F59E0B"))
                    Text("Окислитель: \(t.oxidizerTransition)  (\(t.oxidizer))")
                        .font(.system(size: 12)).foregroundColor(.white)
                    Text("Восстановитель: \(t.reducerTransition)  (\(t.reducer))")
                        .font(.system(size: 12)).foregroundColor(.white)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E293B")))
                .padding(.horizontal, 20)
                .transition(.opacity)
            }
        }
    }

    private func controls(_ t: Task) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { showHint.toggle() }
            } label: {
                Label(showHint ? "Скрыть" : "Подсказка", systemImage: "lightbulb")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
            Button { start() } label: {
                Label("Ещё", systemImage: "arrow.clockwise")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private var startScreen: some View {
        VStack(spacing: 20) {
            Text("⚖️").font(.system(size: 70))
            Text("ОВР баланс").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
            Button { start() } label: {
                Text("Начать").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 12)
                    .background(Color(hex: "#3B82F6")).cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var flashOverlay: some View {
        if let f = flash {
            VStack {
                Spacer().frame(height: 100)
                Text(f).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.85)))
                Spacer()
            }.transition(.opacity)
        }
    }

    private func pick(_ e: String) {
        guard let t = task else { return }
        guard picked.count < 2 else { picked = []; return }
        picked.append(e)
        SoundManager.shared.click()
        if picked.count == 2 {
            if picked == t.accept {
                score += 1
                SoundManager.shared.success()
                AchievementsStorage.shared.add("first_reaction")
                showFlash("✅ Верно!")
            } else {
                SoundManager.shared.error()
                showFlash("❌ Не так. Попробуй ещё")
            }
        }
    }

    private func showFlash(_ m: String) {
        withAnimation { flash = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { flash = nil; picked = [] }
        }
    }

    private func start() {
        task = bank.randomElement()
        picked = []
        flash = nil
        showHint = false
    }
}
