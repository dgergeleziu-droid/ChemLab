import SwiftUI

struct ExamHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [SavedExamResult] = []
    @State private var showClearConfirm = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                Group {
                    if history.isEmpty {
                        emptyState
                    } else {
                        listView
                    }
                }
            }
            .navigationTitle("История экзаменов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !history.isEmpty {
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color(hex: "#EF4444"))
                        }
                    }
                }
            }
            .alert("Очистить историю?", isPresented: $showClearConfirm) {
                Button("Отмена", role: .cancel) {}
                Button("Очистить", role: .destructive) {
                    ExamResultStorage.shared.clear()
                    history = []
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            history = ExamResultStorage.shared.loadAll()
        }
    }

    // MARK: - Пустое состояние

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#475569"))
            Text("Пока нет результатов")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text("Пройди пробный экзамен —\nздесь появится статистика.")
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#94A3B8"))
                .font(.system(size: 14))
        }
        .padding()
    }

    // MARK: - Список

    private var listView: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryBlock

                VStack(alignment: .leading, spacing: 10) {
                    Text("Последние попытки")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)

                    ForEach(history) { item in
                        row(for: item)
                    }
                }
            }
            .padding(16)
        }
    }

    private var summaryBlock: some View {
        let count = max(history.count, 1)
        let avg = history.map { Double($0.score) }.reduce(0, +) / Double(count)
        let best = history.map { $0.score }.max() ?? 0
        let lastGrade = history.first?.grade ?? 0

        return HStack(spacing: 8) {
            statBlock(title: "Попыток", value: "\(history.count)")
            statBlock(title: "Средний", value: String(format: "%.1f", avg))
            statBlock(title: "Лучший", value: "\(best)")
            statBlock(title: "Оценка", value: "\(lastGrade)")
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#94A3B8"))
        }
        .frame(maxWidth: .infinity)
    }

    private func row(for item: SavedExamResult) -> some View {
        HStack(spacing: 12) {
            gradeBadge(item.grade)
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString(item.date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("Баллы: \(item.score) • Верно: \(item.correctCount)/\(item.totalTasks)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#94A3B8"))
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
    }

    private func gradeBadge(_ grade: Int) -> some View {
        Text("\(grade)")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(gradeColor(grade))
            .clipShape(Circle())
    }

    private func gradeColor(_ grade: Int) -> Color {
        switch grade {
        case 5: return Color(hex: "#22C55E")
        case 4: return Color(hex: "#3B82F6")
        case 3: return Color(hex: "#F59E0B")
        default: return Color(hex: "#EF4444")
        }
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f.string(from: date)
    }
}
