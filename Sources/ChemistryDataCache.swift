import Foundation

// ============================================================
// MARK: - Кэш реагентов по группам и агрегатным состояниям
// ============================================================

final class ChemistryDataCache {
    static let shared = ChemistryDataCache()

    // Реагенты по группам (элементы / соединения / органика)
    let byGroup: [ReagentGroup: [Reagent]]

    // Реагенты по агрегатным состояниям (для пробирки)
    let byState: [AggregateState: [Reagent]]

    // Агрегатное состояние по символу (O(1))
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
            let st = ChemistryData.aggregateState(of: r.symbol)
            stateDict[st, default: []].append(r)
            symbolState[r.symbol] = st
        }
        self.byState = stateDict
        self.stateOf = symbolState
    }
}
