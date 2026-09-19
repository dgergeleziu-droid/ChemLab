import Foundation

// Условия, которые можно включать в лаборатории
enum ConditionType: String, CaseIterable, Hashable {
    case heating  = "Нагревание (t°)"
    case catalyst = "Катализатор"
    case light    = "Свет (hv)"
    case pressure = "Высокое давление"

    var shortLabel: String {
        switch self {
        case .heating:  return "t°"
        case .catalyst: return "кат."
        case .light:    return "hv"
        case .pressure: return "p"
        }
    }

    var icon: String {
        switch self {
        case .heating:  return "flame.fill"
        case .catalyst: return "atom"
        case .light:    return "sun.max.fill"
        case .pressure: return "gauge.with.dots.needle.67percent"
        }
    }
}

// Автоопределение необходимых условий из текста уравнения
extension ChemicalReaction {
    var requiredConditions: Set<ConditionType> {
        var result: Set<ConditionType> = []
        let eq = equation.lowercased()

        // Нагревание
        if eq.contains("t°") || eq.contains("→t°→") { result.insert(.heating) }

        // Катализатор (разные формулировки)
        let catalystMarkers = [
            "кат.", "кат,", "катализатор",
            "hg²⁺", "h₃po₄", "febr₃",
            "nio", "(ni", "ni,", "pt)", "(cu,", "cu)",
            "mno₂", "h₂so₄, t°"
        ]
        for m in catalystMarkers {
            if eq.contains(m) { result.insert(.catalyst); break }
        }

        // Свет
        if eq.contains("hv") || eq.contains("свет") { result.insert(.light) }

        // Давление
        if eq.contains("давл") || eq.contains(", p)") || eq.contains("(p,") {
            result.insert(.pressure)
        }

        return result
    }

    // Человеческое описание, что нужно
    var conditionsHint: String {
        let missing = requiredConditions
        if missing.isEmpty { return "" }
        return "Для этой реакции нужно: " + missing.map { $0.rawValue }.joined(separator: ", ")
    }
}
