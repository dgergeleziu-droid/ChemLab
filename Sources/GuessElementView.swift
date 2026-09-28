import SwiftUI

struct GuessElementView: View {
    @Environment(\.dismiss) private var dismiss

    private struct Question {
        let hint: String
        let correct: String
        let options: [String]
    }

    private let bank: [Question] = [
        .init(hint: "Самый лёгкий элемент", correct: "H", options: ["H","He","Li","C"]),
        .init(hint: "Щелочной металл 3 периода", correct: "Na", options: ["Li","Na","K","Mg"]),
        .init(hint: "Самый активный неметалл", correct: "F", options: ["Cl","F","O","N"]),
        .init(hint: "Благородный газ, 1 период", correct: "He", options: ["He","Ne","Ar","Kr"]),
        .init(hint: "Основа всей органической химии", correct: "C", options: ["C","N","O","Si"]),
        .init(hint: "Газ, поддерживающий горение", correct: "O", options: ["H","O","N","CO2"]),
        .init(hint: "Металл, жидкий при н.у.", correct: "Hg", options: ["Hg","Br","Au","Pb"]),
        .init(hint: "Жёлтый неметалл, 3 период", correct: "S", options: ["P","S","Cl","Se"]),
        .init(hint: "Главный элемент костей", correct: "Ca", options: ["Ca","Na","K","Mg"]),
        .init(hint: "Металл с валентностью II, в ядре Земли", correct: "Fe", options: ["Cu","Fe","Zn","Ni"]),
        .init(hint: "Галоген, использующийся для дезинфекции воды", correct: "Cl", options: ["F","Cl","Br","I"]),
        .init(hint: "Металл, из которого делают провода", correct: "Cu", options: ["Cu","Al","Fe","Ag"]),
        .init(hint: "Неметалл, красный при н.у. (один из аллотропов)", correct: "P", options: ["P","S","Se","As"]),
        .init(hint: "Щелочной металл 4 периода, взрывается с водой", correct: "K", options: ["Na","K","Ca","Li"]),
        .init(hint: "Благородный газ с массой 40", correct: "Ar", options: ["Ne","Ar","Kr","Xe"])
    ]

    @State private var current: Question? = nil
    @State private var score: Int = 0
    @State private var attempts: Int = 0
    @State private var selected: String? = nil
    @State private var showResult: Bool = false
    @State private var bestScore: Int = UserDefaults.standard.integer(forKey: "chemlab.quiz.best")

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 20) {
                    HStack {
                        Label("\(score)", systemImage: "star.fill")
                            .foregroundColor(Color(hex: "#FBBF24"))
                        Spacer()
                        Text("Рекорд: \(bestScore)")
                            .foregroundColor(Color(hex: "#94A3B8"))
                            .font(.system(size: 13))
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 8)

                    if let q = current {
                        VStack(spacing: 20) {
                            Text(q.hint)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)

                            VStack(spacing: 10) {
                                ForEach(q.options, id: \.self) { opt in
                                    Button {
                                        select(opt, correct: q.correct)
                                    } label: {
                                        HStack {
                                            Text(opt)
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            Spacer()
                                            if selected == opt {
                                                Image(systemName: opt == q.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .foregroundColor(opt == q.correct ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                                            }
                                        }
                                        .padding(.horizontal, 20).padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(bgColor(opt, correct: q.correct))
                                        )
                                    }
                                    .disabled(selected != nil)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer()

                        Button {
                            next()
                        } label: {
                            Text(selected == nil ? "Выбери ответ" : "Дальше →")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(selected == nil ? Color(hex: "#475569") : Color(hex: "#3B82F6"))
                                .cornerRadius(14)
                        }
                        .disabled(selected == nil)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        Spacer()
                        Button {
                            start()
                        } label: {
                            Text("Начать игру")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40).padding(.vertical, 14)
                                .background(Color(hex: "#3B82F6"))
                                .cornerRadius(14)
                        }
                        Spacer()
                    }
                }
                .padding(.top, 12)
            }
            .navigationTitle("🎯 Угадай элемент")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { if current == nil { start() } }
    }

    private func start() {
        current = bank.randomElement()
        selected = nil
        score = 0
        attempts = 0
    }

    private func select(_ opt: String, correct: String) {
        selected = opt
        attempts += 1
        if opt == correct {
            score += 1
            SoundManager.shared.success()
            if score > bestScore {
                bestScore = score
                UserDefaults.standard.set(bestScore, forKey: "chemlab.quiz.best")
            }
            AchievementsStorage.shared.add("quiz_ace")
        } else {
            SoundManager.shared.error()
        }
    }

    private func next() {
        if attempts >= 10 {
            current = nil
            return
        }
        current = bank.randomElement()
        selected = nil
    }

    private func bgColor(_ opt: String, correct: String) -> Color {
        guard selected != nil else { return Color(hex: "#1E293B") }
        if opt == correct { return Color(hex: "#166534") }
        if opt == selected { return Color(hex: "#7F1D1D") }
        return Color(hex: "#1E293B")
    }
}
