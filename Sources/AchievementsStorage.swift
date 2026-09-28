import Foundation

struct Achievement: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let goal: Int
}

final class AchievementsStorage: ObservableObject {
    static let shared = AchievementsStorage()

    let all: [Achievement] = [
        .init(id: "first_reaction", icon: "sparkles", title: "Первая реакция", description: "Запустить первую реакцию", goal: 1),
        .init(id: "explosionist",   icon: "flame.fill", title: "Взрывник", description: "10 реакций со взрывом", goal: 10),
        .init(id: "analyst",        icon: "drop.triangle.fill", title: "Аналитик", description: "5 реакций с осадком", goal: 5),
        .init(id: "gas_master",     icon: "wind", title: "Газовик", description: "10 реакций с выделением газа", goal: 10),
        .init(id: "chemist_50",     icon: "flask.fill", title: "50 реакций", description: "Провести 50 реакций", goal: 50),
        .init(id: "chemist_100",    icon: "flask.fill", title: "100 реакций", description: "Провести 100 реакций", goal: 100),
        .init(id: "theorist",       icon: "graduationcap.fill", title: "Химик-теоретик", description: "5/5 в экзамене", goal: 5),
        .init(id: "diary_20",       icon: "book.closed.fill", title: "Дневник", description: "20 записей в дневнике", goal: 20),
        .init(id: "atom_explorer",  icon: "atom", title: "Атомщик", description: "Изучить 10 атомов", goal: 10),
        .init(id: "solute_master",  icon: "square.grid.3x3.fill", title: "Растворитель", description: "Открыть таблицу растворимости", goal: 1),
        .init(id: "indicator_pro",  icon: "paintpalette.fill", title: "Индикатор", description: "Проверить все 3 индикатора", goal: 3),
        .init(id: "quiz_ace",       icon: "crown.fill", title: "Знаток элементов", description: "10 правильных в викторине", goal: 10)
    ]

    @Published private(set) var progress: [String: Int] = [:]
    @Published private(set) var unlocked: Set<String> = []

    private let progressKey = "chemlab.ach.progress.v1"
    private let unlockedKey = "chemlab.ach.unlocked.v1"

    // 🚀 Debounce: пишем в UserDefaults не чаще раза в 0.8 секунды
    private var saveTimer: Timer?
    private let saveDelay: TimeInterval = 0.8

    private init() { load() }

    func add(_ id: String, by amount: Int = 1) {
        let new = (progress[id] ?? 0) + amount
        progress[id] = new
        if let a = all.first(where: { $0.id == id }), new >= a.goal {
            if !unlocked.contains(id) {
                unlocked.insert(id)
            }
        }
        scheduleSave()
    }

    func set(_ id: String, to value: Int) {
        progress[id] = value
        if let a = all.first(where: { $0.id == id }), value >= a.goal {
            unlocked.insert(id)
        }
        scheduleSave()
    }

    func progressValue(_ id: String) -> Int { progress[id] ?? 0 }
    func isUnlocked(_ id: String) -> Bool { unlocked.contains(id) }

    // MARK: - Persistence с debounce

    private func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: saveDelay, repeats: false) { [weak self] _ in
            self?.save()
        }
    }

    private func save() {
        UserDefaults.standard.set(progress, forKey: progressKey)
        UserDefaults.standard.set(Array(unlocked), forKey: unlockedKey)
    }

    private func load() {
        if let p = UserDefaults.standard.dictionary(forKey: progressKey) as? [String: Int] {
            progress = p
        }
        if let u = UserDefaults.standard.array(forKey: unlockedKey) as? [String] {
            unlocked = Set(u)
        }
    }
}
