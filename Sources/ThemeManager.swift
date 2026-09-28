import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "Системная"
    case dark   = "Тёмная"
    case light  = "Светлая"

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .dark:   return "moon.fill"
        case .light:  return "sun.max.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark:   return .dark
        case .light:  return .light
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: "chemlab.theme") }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "chemlab.theme") ?? AppTheme.dark.rawValue
        self.theme = AppTheme(rawValue: saved) ?? .dark
    }
}
