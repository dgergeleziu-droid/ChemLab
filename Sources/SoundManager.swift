import Foundation
import AudioToolbox

final class SoundManager {
    static let shared = SoundManager()

    var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "chemlab.sound") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "chemlab.sound") }
    }

    // Кулдаун отдельно для каждой группы звуков
    private var lastPlayed: [SystemSoundID: Date] = [:]

    // Разные пороги: клики можно чаще, громкие — реже
    private let cooldown: [SystemSoundID: TimeInterval] = [
        1104: 0.05,   // click — почти без ограничения
        1114: 0.15,   // bubble
        1025: 1.5,    // explode — не чаще 1.5 сек
        1057: 0.5,    // success
        1053: 0.5,    // error
        1103: 0.3     // flame
    ]

    private init() {}

    func click()   { play(1104) }
    func bubble()  { play(1114) }
    func explode() { play(1025) }
    func success() { play(1057) }
    func error()   { play(1053) }
    func flame()   { play(1103) }

    private func play(_ id: SystemSoundID) {
        guard enabled else { return }

        let cd = cooldown[id] ?? 0.3
        if let last = lastPlayed[id],
           Date().timeIntervalSince(last) < cd {
            return
        }
        lastPlayed[id] = Date()
        AudioServicesPlaySystemSound(id)
    }
}
