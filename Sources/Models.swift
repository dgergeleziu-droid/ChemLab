import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: 1)
    }
}

enum ItemKind {
    case reagent
    case product
    case equation
}

struct WorldItem: Identifiable, Equatable {
    let id: UUID
    var symbol: String
    var displayName: String
    var worldPosition: CGPoint
    var kind: ItemKind
    var colorHex: String
    var equationText: String?

    init(id: UUID = UUID(),
         symbol: String,
         displayName: String,
         worldPosition: CGPoint,
         kind: ItemKind,
         colorHex: String,
         equationText: String? = nil) {
        self.id = id
        self.symbol = symbol
        self.displayName = displayName
        self.worldPosition = worldPosition
        self.kind = kind
        self.colorHex = colorHex
        self.equationText = equationText
    }

    static func == (lhs: WorldItem, rhs: WorldItem) -> Bool {
        lhs.id == rhs.id && lhs.worldPosition == rhs.worldPosition
    }
}

struct Reagent: Identifiable, Hashable {
    var id: String { symbol }
    let symbol: String
    let name: String
    let colorHex: String
    let group: ReagentGroup
}

enum ReagentGroup: String, CaseIterable {
    case elements = "Элементы"
    case compounds = "Соединения"
    case organic = "Органика"
}

enum EffectType {
    case explosion
    case flash
    case gas
    case precipitateWhite
    case precipitateBlue
    case precipitateBrown
    case precipitateYellow
    case colorChange
    case glow
    case none
}

struct ChemicalReaction {
    let reagents: Set<String>
    let products: [String]
    let productNames: [String]
    let equation: String
    let effect: EffectType
    let effectColorHex: String
    let warning: String?  // ← новое поле

    init(reagents: Set<String>,
         products: [String],
         productNames: [String],
         equation: String,
         effect: EffectType,
         effectColorHex: String,
         warning: String? = nil) {
        self.reagents = reagents
        self.products = products
        self.productNames = productNames
        self.equation = equation
        self.effect = effect
        self.effectColorHex = effectColorHex
        self.warning = warning
    }
}

struct EffectAnimation: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let type: EffectType
}

// Для отложенной реакции после предупреждения
struct PendingReaction: Identifiable {
    let id = UUID()
    let reaction: ChemicalReaction
    let aID: UUID
    let bID: UUID
    let aSymbol: String
    let bSymbol: String
    let aPos: CGPoint
    let bPos: CGPoint
}
