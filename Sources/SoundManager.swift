import Foundation
import AudioToolbox

final class SoundManager {
    static let shared = SoundManager()

    var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "chemlab.sound") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "chemlab.sound") }
    }

    private init() {}

    func click()     { play(1104) }   // Tock
    func bubble()    { play(1114) }   // Pop
    func explode()   { play(1025) }   // Blow
    func success()   { play(1057) }   // Tink
    func error()     { play(1053) }   // Error
    func flame()     { play(1103) }   // Sparkle

    private func play(_ id: SystemSoundID) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}
