import SwiftUI

struct ExamHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [SavedExamResult] = []
    @State private var showClearConfirm = false

    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    emptyState
                } else {
                    listView
                }
            }
            .navigationTitle("История экзаменов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !history.isEmpty {
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
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
                .foregroundColor(.secondary)
            Text("Пока нет результатов")
                .font(.headline)
            Text("Пройди пробный экзамен —\nздесь появится статистика.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Список

    private var listView: some View {
        List {
            Section {
                summaryBlock
            }
            Section("Последние попытки") {
                ForEach(history) { item in
                    row(for: item)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var summaryBlock: some View {
        let count = max(history.count, 1)
        let avg = history.map { Double($0.score) }.reduce(0, +) / Double(count)
        let best = history.map { $0.score }.max() ?? 0
        let lastGrade = history.first?.grade ?? 0

        return HStack(spacing: 12) {
            statBlock(title: "Попыток", value: "\(history.count)")
            statBlock(title: "Средний", value: String(format: "%.1f", avg))
            statBlock(title: "Лучший", value: "\(best)")
            statBlock(title: "Оценка", value: "\(lastGrade)")
        }
        .padding(.vertical, 4)
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(for item: SavedExamResult) -> some View {
        HStack(spacing: 12) {
            gradeBadge(item.grade)
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString(item.date))
                    .font(.subheadline).bold()
                Text("Баллы: \(item.score) • Верно: \(item.correctCount)/\(item.totalTasks)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func gradeBadge(_ grade: Int) -> some View {
        Text("\(grade)")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(gradeColor(grade))
            .clipShape(Circle())
    }

    private func gradeColor(_ grade: Int) -> Color {
        switch grade {
        case 5: return .green
        case 4: return .blue
        case 3: return .orange
        default: return .red
        }
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f.string(from: date)
    }
}
