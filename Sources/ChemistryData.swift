import SwiftUI

enum ChemistryData {

    // MARK: - Реагенты (элементы и соединения)
    static let reagents: [Reagent] = [
        // Элементы
        Reagent(symbol: "H",   name: "Водород",        colorHex: "#FF6B6B", group: .elements),
        Reagent(symbol: "O",   name: "Кислород",       colorHex: "#EF4444", group: .elements),
        Reagent(symbol: "C",   name: "Углерод",        colorHex: "#4B5563", group: .elements),
        Reagent(symbol: "N",   name: "Азот",           colorHex: "#3B82F6", group: .elements),
        Reagent(symbol: "Na",  name: "Натрий",         colorHex: "#F97316", group: .elements),
        Reagent(symbol: "K",   name: "Калий",          colorHex: "#EA580C", group: .elements),
        Reagent(symbol: "Ca",  name: "Кальций",        colorHex: "#FCD34D", group: .elements),
        Reagent(symbol: "Mg",  name: "Магний",         colorHex: "#FACC15", group: .elements),
        Reagent(symbol: "Al",  name: "Алюминий",       colorHex: "#9CA3AF", group: .elements),
        Reagent(symbol: "Fe",  name: "Железо",         colorHex: "#B45309", group: .elements),
        Reagent(symbol: "Cu",  name: "Медь",           colorHex: "#EA580C", group: .elements),
        Reagent(symbol: "Zn",  name: "Цинк",           colorHex: "#94A3B8", group: .elements),
        Reagent(symbol: "S",   name: "Сера",           colorHex: "#FACC15", group: .elements),
        Reagent(symbol: "Cl",  name: "Хлор",           colorHex: "#4ADE80", group: .elements),
        Reagent(symbol: "Br",  name: "Бром",           colorHex: "#B91C1C", group: .elements),
        Reagent(symbol: "I",   name: "Иод",            colorHex: "#7C3AED", group: .elements),
        Reagent(symbol: "P",   name: "Фосфор",         colorHex: "#F97316", group: .elements),
        Reagent(symbol: "Ag",  name: "Серебро",        colorHex: "#CBD5E1", group: .elements),
        Reagent(symbol: "Ba",  name: "Барий",          colorHex: "#22D3EE", group: .elements),

        // Соединения
        Reagent(symbol: "H2O",     name: "Вода",              colorHex: "#60A5FA", group: .compounds),
        Reagent(symbol: "HCl",     name: "Соляная кислота",   colorHex: "#FCD34D", group: .compounds),
        Reagent(symbol: "H2SO4",   name: "Серная кислота",    colorHex: "#FBBF24", group: .compounds),
        Reagent(symbol: "NaOH",    name: "Гидроксид натрия",  colorHex: "#A78BFA", group: .compounds),
        Reagent(symbol: "KOH",     name: "Гидроксид калия",   colorHex: "#C084FC", group: .compounds),
        Reagent(symbol: "CuSO4",   name: "Сульфат меди(II)",  colorHex: "#06B6D4", group: .compounds),
        Reagent(symbol: "CuCl2",   name: "Хлорид меди(II)",   colorHex: "#0891B2", group: .compounds),
        Reagent(symbol: "AgNO3",   name: "Нитрат серебра",    colorHex: "#E5E7EB", group: .compounds),
        Reagent(symbol: "NaCl",    name: "Хлорид натрия",     colorHex: "#E5E7EB", group: .compounds),
        Reagent(symbol: "Na2CO3",  name: "Карбонат натрия",   colorHex: "#E5E7EB", group: .compounds),
        Reagent(symbol: "Na2SO4",  name: "Сульфат натрия",    colorHex: "#E5E7EB", group: .compounds),
        Reagent(symbol: "BaCl2",   name: "Хлорид бария",      colorHex: "#E5E7EB", group: .compounds),
        Reagent(symbol: "CaCO3",   name: "Карбонат кальция",  colorHex: "#F1F5F9", group: .compounds),
        Reagent(symbol: "FeCl3",   name: "Хлорид железа(III)",colorHex: "#B45309", group: .compounds),
        Reagent(symbol: "CuO",     name: "Оксид меди(II)",    colorHex: "#1F2937", group: .compounds),
        Reagent(symbol: "Fe2O3",   name: "Оксид железа(III)", colorHex: "#92400E", group: .compounds),

        // Органика
        Reagent(symbol: "CH4",     name: "Метан",             colorHex: "#84CC16", group: .organic),
        Reagent(symbol: "C2H4",    name: "Этилен",            colorHex: "#65A30D", group: .organic),
        Reagent(symbol: "C2H2",    name: "Ацетилен",          colorHex: "#4D7C0F", group: .organic),
        Reagent(symbol: "C2H5OH",  name: "Этанол",            colorHex: "#A3E635", group: .organic),
        Reagent(symbol: "CH3COOH", name: "Уксусная кислота",  colorHex: "#BEF264", group: .organic),
    ]

    static func findReagent(by symbol: String) -> Reagent? {
        return reagents.first { $0.symbol == symbol }
    }

    // MARK: - База реакций (8–10 класс)
    static let reactions: [ChemicalReaction] = [
        // ================== 8 КЛАСС ==================
        ChemicalReaction(
            reagents: ["H", "O"], products: ["H2O"], productNames: ["Вода"],
            equation: "2H₂ + O₂ → 2H₂O",
            effect: .explosion, effectColorHex: "#FCD34D"
        ),
        ChemicalReaction(
            reagents: ["Na", "Cl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "2Na + Cl₂ → 2NaCl",
            effect: .flash, effectColorHex: "#FEF08A"
        ),
        ChemicalReaction(
            reagents: ["Mg", "O"], products: ["MgO"], productNames: ["Оксид магния"],
            equation: "2Mg + O₂ → 2MgO",
            effect: .flash, effectColorHex: "#FFFFFF"
        ),
        ChemicalReaction(
            reagents: ["S", "O"], products: ["SO2"], productNames: ["Оксид серы(IV)"],
            equation: "S + O₂ → SO₂",
            effect: .gas, effectColorHex: "#CBD5E1"
        ),
        ChemicalReaction(
            reagents: ["C", "O"], products: ["CO2"], productNames: ["Оксид углерода(IV)"],
            equation: "C + O₂ → CO₂",
            effect: .glow, effectColorHex: "#F97316"
        ),
        ChemicalReaction(
            reagents: ["Fe", "S"], products: ["FeS"], productNames: ["Сульфид железа(II)"],
            equation: "Fe + S → FeS",
            effect: .glow, effectColorHex: "#7C2D12"
        ),
        ChemicalReaction(
            reagents: ["Cu", "O"], products: ["CuO"], productNames: ["Оксид меди(II)"],
            equation: "2Cu + O₂ → 2CuO",
            effect: .colorChange, effectColorHex: "#1F2937"
        ),
        ChemicalReaction(
            reagents: ["Zn", "HCl"], products: ["ZnCl2"], productNames: ["Хлорид цинка"],
            equation: "Zn + 2HCl → ZnCl₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Fe", "HCl"], products: ["FeCl2"], productNames: ["Хлорид железа(II)"],
            equation: "Fe + 2HCl → FeCl₂ + H₂↑",
            effect: .gas, effectColorHex: "#DCFCE7"
        ),
        ChemicalReaction(
            reagents: ["NaOH", "HCl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "NaOH + HCl → NaCl + H₂O",
            effect: .glow, effectColorHex: "#FEF3C7"
        ),
        ChemicalReaction(
            reagents: ["CaCO3", "HCl"], products: ["CaCl2"], productNames: ["Хлорид кальция"],
            equation: "CaCO₃ + 2HCl → CaCl₂ + H₂O + CO₂↑",
            effect: .gas, effectColorHex: "#F1F5F9"
        ),
        ChemicalReaction(
            reagents: ["CuSO4", "NaOH"], products: ["Cu(OH)2"], productNames: ["Гидроксид меди(II)"],
            equation: "CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄",
            effect: .precipitateBlue, effectColorHex: "#3B82F6"
        ),
        ChemicalReaction(
            reagents: ["AgNO3", "NaCl"], products: ["AgCl"], productNames: ["Хлорид серебра"],
            equation: "AgNO₃ + NaCl → AgCl↓ + NaNO₃",
            effect: .precipitateWhite, effectColorHex: "#F8FAFC"
        ),
        ChemicalReaction(
            reagents: ["Fe", "CuSO4"], products: ["Cu"], productNames: ["Медь"],
            equation: "Fe + CuSO₄ → FeSO₄ + Cu",
            effect: .colorChange, effectColorHex: "#EA580C"
        ),

        // ================== 9 КЛАСС ==================
        ChemicalReaction(
            reagents: ["BaCl2", "Na2SO4"], products: ["BaSO4"], productNames: ["Сульфат бария"],
            equation: "BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl",
            effect: .precipitateWhite, effectColorHex: "#FFFFFF"
        ),
        ChemicalReaction(
            reagents: ["FeCl3", "NaOH"], products: ["Fe(OH)3"], productNames: ["Гидроксид железа(III)"],
            equation: "FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl",
            effect: .precipitateBrown, effectColorHex: "#92400E"
        ),
        ChemicalReaction(
            reagents: ["Na2CO3", "HCl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "Na₂CO₃ + 2HCl → 2NaCl + H₂O + CO₂↑",
            effect: .gas, effectColorHex: "#F1F5F9"
        ),
        ChemicalReaction(
            reagents: ["Al", "CuCl2"], products: ["AlCl3"], productNames: ["Хлорид алюминия"],
            equation: "2Al + 3CuCl₂ → 2AlCl₃ + 3Cu",
            effect: .colorChange, effectColorHex: "#DC2626"
        ),
        ChemicalReaction(
            reagents: ["Ba", "H2O"], products: ["Ba(OH)2"], productNames: ["Гидроксид бария"],
            equation: "Ba + 2H₂O → Ba(OH)₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Ca", "H2O"], products: ["Ca(OH)2"], productNames: ["Гидроксид кальция"],
            equation: "Ca + 2H₂O → Ca(OH)₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),

        // ================== 10 КЛАСС (органика) ==================
        ChemicalReaction(
            reagents: ["C2H4", "Br"], products: ["C2H4Br2"], productNames: ["1,2-дибромэтан"],
            equation: "CH₂=CH₂ + Br₂ → CH₂Br–CH₂Br",
            effect: .colorChange, effectColorHex: "#FEF3C7"
        ),
        ChemicalReaction(
            reagents: ["C2H2", "Br"], products: ["C2H2Br2"], productNames: ["1,2-дибромэтен"],
            equation: "CH≡CH + Br₂ → CHBr=CHBr",
            effect: .colorChange, effectColorHex: "#FEF3C7"
        ),
        ChemicalReaction(
            reagents: ["C2H5OH", "CuO"], products: ["CH3CHO"], productNames: ["Ацетальдегид"],
            equation: "C₂H₅OH + CuO → CH₃CHO + Cu + H₂O",
            effect: .colorChange, effectColorHex: "#DC2626"
        ),
        ChemicalReaction(
            reagents: ["C2H5OH", "Na"], products: ["C2H5ONa"], productNames: ["Этилат натрия"],
            equation: "2C₂H₅OH + 2Na → 2C₂H₅ONa + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["CH4", "O"], products: ["CO2"], productNames: ["Оксид углерода(IV)"],
            equation: "CH₄ + 2O₂ → CO₂ + 2H₂O",
            effect: .explosion, effectColorHex: "#F97316"
        ),
    ]

    static func findReaction(_ a: String, _ b: String) -> ChemicalReaction? {
        let pair: Set<String> = [a, b]
        return reactions.first { $0.reagents == pair }
    }
}