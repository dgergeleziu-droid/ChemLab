import Foundation

struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let equation: String
    let products: [String]
    let warning: String?

    init(equation: String, products: [String], warning: String?) {
        self.id = UUID()
        self.date = Date()
        self.equation = equation
        self.products = products
        self.warning = warning
    }
}

final class DiaryStorage: ObservableObject {
    static let shared = DiaryStorage()
    private let key = "chemlab.diary.v1"
    private let maxRecords = 200

    @Published private(set) var entries: [DiaryEntry] = []

    // 🚀 Debounce
    private var saveTimer: Timer?
    private let saveDelay: TimeInterval = 1.0

    private init() { load() }

    func add(equation: String, products: [String], warning: String?) {
        let e = DiaryEntry(equation: equation, products: products, warning: warning)
        entries.insert(e, at: 0)
        if entries.count > maxRecords {
            entries = Array(entries.prefix(maxRecords))
        }
        scheduleSave()
    }

    func clear() {
        entries.removeAll()
        scheduleSave()
    }

    private func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: saveDelay, repeats: false) { [weak self] _ in
            self?.save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let list = try? JSONDecoder().decode([DiaryEntry].self, from: data) {
            entries = list
        }
    }
}
