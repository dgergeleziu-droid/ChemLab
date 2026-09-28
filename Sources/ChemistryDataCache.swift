import Foundation

// ============================================================
// MARK: - Агрегатное состояние (чистая функция, без кэша)
// ============================================================

enum AggregateState: String, CaseIterable {
    case liquid = "Жидкости"
    case solid  = "Твёрдые"
    case gas    = "Газы"

    var icon: String {
        switch self {
        case .liquid: return "drop.fill"
        case .solid:  return "cube.fill"
        case .gas:    return "wind"
        }
    }
}

extension ChemistryData {
    /// ⚠️ ЧИСТАЯ функция — не обращается к кэшу, чтобы не было цикла инициализации.
    static func aggregateState(of symbol: String) -> AggregateState {
        let gases: Set<String> = [
            "H","O","N","F","Cl","He","Ne","Ar","Kr","Xe","Rn",
            "CO","CO2","SO2","SO3","NO","NO2","N2O5","NH3","H2S",
            "CH4","C2H2","C2H4","C2H6","C3H8","C4H10","PH3","SiH4","B2H6"
        ]
        let liquids: Set<String> = [
            "H2O","H2SO4","HNO3","HCl","HBr","HI","HF",
            "C2H5OH","CH3OH","C6H6","C6H5OH","CH3COOH",
            "C2H5Br","CH3Cl","C2H5Cl","Br","Hg"
        ]
        if gases.contains(symbol)   { return .gas }
        if liquids.contains(symbol) { return .liquid }
        return .solid
    }
}

// ============================================================
// MARK: - Кэш реагентов по группам и состояниям
// ============================================================

final class ChemistryDataCache {
    static let shared = ChemistryDataCache()

    /// Реагенты по группам (элементы / соединения / органика)
    let byGroup: [ReagentGroup: [Reagent]]

    /// Реагенты по агрегатным состояниям (для пробирки)
    let byState: [AggregateState: [Reagent]]

    /// Агрегатное состояние по символу (O(1) lookup)
    let stateOf: [String: AggregateState]

    private init() {
        // Группы
        var groupDict: [ReagentGroup: [Reagent]] = [:]
        for g in ReagentGroup.allCases {
            groupDict[g] = ChemistryData.reagents.filter { $0.group == g }
        }
        self.byGroup = groupDict

        // Состояния
        var stateDict: [AggregateState: [Reagent]] = [:]
        var symbolState: [String: AggregateState] = [:]

        for r in ChemistryData.reagents {
            // ⚠️ Вызываем ЧИСТУЮ функцию напрямую, без обращения к .shared
            let st = ChemistryData.aggregateState(of: r.symbol)
            stateDict[st, default: []].append(r)
            symbolState[r.symbol] = st
        }
        self.byState = stateDict
        self.stateOf = symbolState
    }
}
