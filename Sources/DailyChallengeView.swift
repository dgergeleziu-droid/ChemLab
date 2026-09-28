import SwiftUI

struct DailyChallengeView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("chemlab.daily.lastDate") private var lastDateString: String = ""
    @AppStorage("chemlab.daily.streak") private var streak: Int = 0
    @AppStorage("chemlab.daily.doneToday") private var doneToday: Bool = false

    @State private var task: DailyTask? = nil
    @State private var picked: String? = nil

    struct DailyTask {
        let question: String
        let options: [String]
        let correct: String
        let explanation: String
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 20) {
                    streakCard
                    if doneToday {
                        doneCard
                    } else if let t = task {
                        questionCard(t)
                    } else {
                        startCard
                    }
                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle("📅 Задание дня")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { refresh() }
    }

    private var streakCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: "#F97316").opacity(0.2)).frame(width: 50, height: 50)
                Text("🔥").font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Серия: \(streak)").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Text(streak == 0 ? "Начни серию сегодня!" : "Так держать! Продолжай")
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
            }
            Spacer()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
        .padding(.horizontal, 16)
    }

    private var startCard: some View {
        VStack(spacing: 16) {
            Text("📝").font(.system(size: 60))
            Text("Сегодняшнее задание готово").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
            Button {
                task = dailyTask()
            } label: {
                Text("Начать").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 12)
                    .background(Color(hex: "#3B82F6")).cornerRadius(12)
            }
        }
    }

    private func questionCard(_ t: DailyTask) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(t.question)
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                ForEach(t.options, id: \.self) { o in
                    Button {
                        answer(o, t: t)
                    } label: {
                        HStack {
                            Text(o).font(.system(size: 14)).foregroundColor(.white)
                            Spacer()
                            if picked == o {
                                Image(systemName: o == t.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(o == t.correct ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(picked == nil ? Color(hex: "#1E293B") :
                                    (o == t.correct ? Color(hex: "#166534") :
                                        (o == picked ? Color(hex: "#7F1D1D") : Color(hex: "#1E293B")))))
                    }
                    .disabled(picked != nil)
                }
            }

            if picked != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 \(t.explanation)").font(.system(size: 12)).foregroundColor(Color(hex: "#CBD5E1"))
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#0F172A")))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
        .padding(.horizontal, 16)
    }

    private var doneCard: some View {
        VStack(spacing: 12) {
            Text("✅").font(.system(size: 60))
            Text("Задание дня выполнено!").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text("Заходи завтра — будет новое.").font(.system(size: 13)).foregroundColor(Color(hex: "#94A3B8"))
        }
    }

    private func answer(_ o: String, t: DailyTask) {
        picked = o
        if o == t.correct {
            SoundManager.shared.success()
            markDone()
        } else {
            SoundManager.shared.error()
        }
    }

    private func markDone() {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())

        if lastDateString == today { return }

        let yesterday = f.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        if lastDateString == yesterday { streak += 1 } else { streak = 1 }
        lastDateString = today
        doneToday = true
    }

    private func refresh() {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        doneToday = (lastDateString == f.string(from: Date()))
    }

    private func dailyTask() -> DailyTask {
        let all: [DailyTask] = [
            .init(question: "Сколько протонов в атоме углерода?",
                  options: ["6","12","14","2"], correct: "6",
                  explanation: "Углерод имеет атомный номер 6, значит 6 протонов."),
            .init(question: "Какой газ выделяется при реакции Na с H₂O?",
                  options: ["O₂","H₂","Cl₂","CO₂"], correct: "H₂",
                  explanation: "2Na + 2H₂O → 2NaOH + H₂↑"),
            .init(question: "Какой индикатор краснеет в кислоте?",
                  options: ["Лакмус","Фенолфталеин","Метилоранж","Все три"], correct: "Все три",
                  explanation: "Все три индикатора меняют цвет в кислой среде."),
            .init(question: "Молярная масса воды (H₂O)?",
                  options: ["16 г/моль","18 г/моль","20 г/моль","22 г/моль"], correct: "18 г/моль",
                  explanation: "M(H₂O) = 2×1 + 16 = 18 г/моль."),
            .init(question: "Что такое катализатор?",
                  options: ["Ускоряет реакцию","Замедляет реакцию","Участвует в реакции","Не влияет"], correct: "Ускоряет реакцию",
                  explanation: "Катализатор ускоряет реакцию, но сам не расходуется.")
        ]
        return all.randomElement()!
    }
}
