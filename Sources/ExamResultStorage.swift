import Foundation

// MARK: - Модель сохранённого результата

struct SavedExamResult: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let totalTasks: Int
    let correctCount: Int
    let score: Int
    let grade: Int

    init(id: UUID = UUID(),
         date: Date = Date(),
         totalTasks: Int,
         correctCount: Int,
         score: Int,
         grade: Int) {
        self.id = id
        self.date = date
        self.totalTasks = totalTasks
        self.correctCount = correctCount
        self.score = score
        self.grade = grade
    }
}

// MARK: - Хранилище истории экзаменов

final class ExamResultStorage {
    static let shared = ExamResultStorage()

    private let key = "chemlab.exam.history.v1"
    private let maxRecords = 50

    private init() {}

    func save(_ result: SavedExamResult) {
        var history = loadAll()
        history.insert(result, at: 0)
        if history.count > maxRecords {
            history = Array(history.prefix(maxRecords))
        }
        persist(history)
    }

    func save(from result: ExamResult) {
        let saved = SavedExamResult(
            totalTasks: result.totalTasks,
            correctCount: result.correctCount,
            score: result.score,
            grade: result.grade
        )
        save(saved)
    }

    func loadAll() -> [SavedExamResult] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([SavedExamResult].self, from: data)) ?? []
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func persist(_ items: [SavedExamResult]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
