import SwiftUI

extension ChemistryData {

    // Дополнительные реакции (разложения, редкие, с новыми соединениями)
    static let extraReactions: [ChemicalReaction] = [

        // ==================== РАЗЛОЖЕНИЕ (один реагент) ====================
        ChemicalReaction(reagents: ["CaCO3"], products: ["CaO","CO2"], productNames: ["Оксид кальция","Оксид углерода(IV)"],
            equation: "CaCO₃ → CaO + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["BaCO3"], products: ["BaO","CO2"], productNames: ["Оксид бария","Оксид углерода(IV)"],
            equation: "BaCO₃ → BaO + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["MgCO3"], products: ["MgO","CO2"], productNames: ["Оксид магния","Оксид углерода(IV)"],
            equation: "MgCO₃ → MgO + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["CuCO3"], products: ["CuO","CO2"], productNames: ["Оксид меди(II)","Оксид углерода(IV)"],
            equation: "CuCO₃ → CuO + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["KMnO4"], products: ["K2MnO4","MnO2","O2"], productNames: ["Манганат калия","Оксид марганца(IV)","Кислород"],
            equation: "2KMnO₄ → K₂MnO₄ + MnO₂ + O₂↑", effect: .gas, effectColorHex: "#7E22CE",
            warning: "⚠️ Перманганат калия — сильный окислитель. Работать аккуратно."),
        ChemicalReaction(reagents: ["H2CO3"], products: ["H2O","CO2"], productNames: ["Вода","Оксид углерода(IV)"],
            equation: "H₂CO₃ → H₂O + CO₂↑", effect: .gas, effectColorHex: "#94A3B8"),
        ChemicalReaction(reagents: ["H2SiO3"], products: ["SiO2","H2O"], productNames: ["Оксид кремния","Вода"],
            equation: "H₂SiO₃ → SiO₂ + H₂O", effect: .glow, effectColorHex: "#A8A29E"),
        ChemicalReaction(reagents: ["Cu(OH)2"], products: ["CuO","H2O"], productNames: ["Оксид меди(II)","Вода"],
            equation: "Cu(OH)₂ → CuO + H₂O", effect: .colorChange, effectColorHex: "#1F2937"),
        ChemicalReaction(reagents: ["Fe(OH)3"], products: ["Fe2O3","H2O"], productNames: ["Оксид железа(III)","Вода"],
            equation: "2Fe(OH)₃ → Fe₂O₃ + 3H₂O", effect: .colorChange, effectColorHex: "#92400E"),
        ChemicalReaction(reagents: ["Fe(OH)2"], products: ["FeO","H2O"], productNames: ["Оксид железа(II)","Вода"],
            equation: "Fe(OH)₂ → FeO + H₂O", effect: .colorChange, effectColorHex: "#1C1917"),
        ChemicalReaction(reagents: ["Al(OH)3"], products: ["Al2O3","H2O"], productNames: ["Оксид алюминия","Вода"],
            equation: "2Al(OH)₃ → Al₂O₃ + 3H₂O", effect: .colorChange, effectColorHex: "#D4D4D8"),
        ChemicalReaction(reagents: ["Mg(OH)2"], products: ["MgO","H2O"], productNames: ["Оксид магния","Вода"],
            equation: "Mg(OH)₂ → MgO + H₂O", effect: .colorChange, effectColorHex: "#FCD34D"),
        ChemicalReaction(reagents: ["Zn(OH)2"], products: ["ZnO","H2O"], productNames: ["Оксид цинка","Вода"],
            equation: "Zn(OH)₂ → ZnO + H₂O", effect: .colorChange, effectColorHex: "#E5E7EB"),

        // ==================== МЕТАЛЛ + ГАЛОГЕН ====================
        ChemicalReaction(reagents: ["Au","Cl"], products: ["AuCl3"], productNames: ["Хлорид золота(III)"],
            equation: "2Au + 3Cl₂ → 2AuCl₃ (t°)", effect: .glow, effectColorHex: "#FBBF24"),
        ChemicalReaction(reagents: ["Pt","Cl"], products: ["PtCl4"], productNames: ["Хлорид платины(IV)"],
            equation: "Pt + 2Cl₂ → PtCl₄ (t°)", effect: .glow, effectColorHex: "#E2E8F0"),
        ChemicalReaction(reagents: ["Hg","Cl"], products: ["HgCl2"], productNames: ["Хлорид ртути(II)"],
            equation: "Hg + Cl₂ → HgCl₂", effect: .glow, effectColorHex: "#A1A1AA",
            warning: "🚨 Ртуть и её соединения очень токсичны!"),
        ChemicalReaction(reagents: ["Cd","Cl"], products: ["CdCl2"], productNames: ["Хлорид кадмия"],
            equation: "Cd + Cl₂ → CdCl₂", effect: .glow, effectColorHex: "#71717A"),
        ChemicalReaction(reagents: ["W","Cl"], products: ["WCl6"], productNames: ["Хлорид вольфрама(VI)"],
            equation: "W + 3Cl₂ → WCl₆", effect: .flash, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["Mo","Cl"], products: ["MoCl5"], productNames: ["Хлорид молибдена(V)"],
            equation: "2Mo + 5Cl₂ → 2MoCl₅", effect: .flash, effectColorHex: "#FEF08A"),

        // ==================== АКТИВНЫЕ МЕТАЛЛЫ + ВОДА ====================
        ChemicalReaction(reagents: ["Sr","H2O"], products: ["Sr(OH)2","H2"], productNames: ["Гидроксид стронция","Водород"],
            equation: "Sr + 2H₂O → Sr(OH)₂ + H₂↑", effect: .gas, effectColorHex: "#E0F2FE"),

        // ==================== ОКСИДЫ + КИСЛОТЫ ====================
        ChemicalReaction(reagents: ["BaO","HNO3"], products: ["Ba(NO3)2","H2O"], productNames: ["Нитрат бария","Вода"],
            equation: "BaO + 2HNO₃ → Ba(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["CaO","HNO3"], products: ["Ca(NO3)2","H2O"], productNames: ["Нитрат кальция","Вода"],
            equation: "CaO + 2HNO₃ → Ca(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["MgO","HNO3"], products: ["Mg(NO3)2","H2O"], productNames: ["Нитрат магния","Вода"],
            equation: "MgO + 2HNO₃ → Mg(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["CuO","H3PO4"], products: ["Cu3(PO4)2","H2O"], productNames: ["Фосфат меди(II)","Вода"],
            equation: "3CuO + 2H₃PO₄ → Cu₃(PO₄)₂ + 3H₂O", effect: .glow, effectColorHex: "#FEF3C7"),

        // ==================== КИСЛОТА + ОСНОВАНИЕ (с водой) ====================
        ChemicalReaction(reagents: ["NaOH","H3PO4"], products: ["Na3PO4","H2O"], productNames: ["Фосфат натрия","Вода"],
            equation: "3NaOH + H₃PO₄ → Na₃PO₄ + 3H₂O", effect: .glow, effectColorHex: "#FEF3C7"),

        // ==================== РАЗЛОЖЕНИЕ ОСНОВАНИЙ ====================
        ChemicalReaction(reagents: ["Fe(OH)3"], products: ["Fe2O3","H2O"], productNames: ["Оксид железа(III)","Вода"],
            equation: "2Fe(OH)₃ →t°→ Fe₂O₃ + 3H₂O", effect: .colorChange, effectColorHex: "#92400E"),

        // ==================== ВОССТАНОВЛЕНИЕ ОКСИДОВ С ПОЛНЫМИ ПРОДУКТАМИ ====================
        ChemicalReaction(reagents: ["Fe2O3","H"], products: ["Fe","H2O"], productNames: ["Железо","Вода"],
            equation: "Fe₂O₃ + 3H₂ → 2Fe + 3H₂O", effect: .glow, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["CuO","H"], products: ["Cu","H2O"], productNames: ["Медь","Вода"],
            equation: "CuO + H₂ → Cu + H₂O", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["FeO","H"], products: ["Fe","H2O"], productNames: ["Железо","Вода"],
            equation: "FeO + H₂ → Fe + H₂O", effect: .glow, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["Fe2O3","C"], products: ["Fe","CO2"], productNames: ["Железо","Оксид углерода(IV)"],
            equation: "2Fe₂O₃ + 3C → 4Fe + 3CO₂↑", effect: .glow, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["CuO","C"], products: ["Cu","CO2"], productNames: ["Медь","Оксид углерода(IV)"],
            equation: "2CuO + C → 2Cu + CO₂↑", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["ZnO","C"], products: ["Zn","CO"], productNames: ["Цинк","Оксид углерода(II)"],
            equation: "ZnO + C → Zn + CO↑", effect: .glow, effectColorHex: "#94A3B8"),
        ChemicalReaction(reagents: ["PbO","C"], products: ["Pb","CO"], productNames: ["Свинец","Оксид углерода(II)"],
            equation: "PbO + C → Pb + CO↑", effect: .glow, effectColorHex: "#64748B"),
        ChemicalReaction(reagents: ["SnO2","C"], products: ["Sn","CO"], productNames: ["Олово","Оксид углерода(II)"],
            equation: "SnO₂ + 2C → Sn + 2CO↑", effect: .glow, effectColorHex: "#D4D4D8"),
        ChemicalReaction(reagents: ["MnO2","C"], products: ["Mn","CO"], productNames: ["Марганец","Оксид углерода(II)"],
            equation: "MnO₂ + 2C → Mn + 2CO↑", effect: .glow, effectColorHex: "#7E22CE"),
        ChemicalReaction(reagents: ["Cr2O3","C"], products: ["Cr","CO"], productNames: ["Хром","Оксид углерода(II)"],
            equation: "Cr₂O₃ + 3C → 2Cr + 3CO↑", effect: .glow, effectColorHex: "#065F46"),

        // ==================== АЛЮМИНОТЕРМИЯ (с полными продуктами) ====================
        ChemicalReaction(reagents: ["Fe2O3","Al"], products: ["Fe","Al2O3"], productNames: ["Железо","Оксид алюминия"],
            equation: "Fe₂O₃ + 2Al → 2Fe + Al₂O₃", effect: .explosion, effectColorHex: "#F97316",
            warning: "🚨 Алюминотермия — температура до 2500°C!"),
        ChemicalReaction(reagents: ["Cr2O3","Al"], products: ["Cr","Al2O3"], productNames: ["Хром","Оксид алюминия"],
            equation: "Cr₂O₃ + 2Al → 2Cr + Al₂O₃", effect: .explosion, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["MnO2","Al"], products: ["Mn","Al2O3"], productNames: ["Марганец","Оксид алюминия"],
            equation: "3MnO₂ + 4Al → 3Mn + 2Al₂O₃", effect: .explosion, effectColorHex: "#EA580C"),

        // ==================== РАЗЛОЖЕНИЕ КАРБОНАТОВ ====================
        ChemicalReaction(reagents: ["K2CO3"], products: ["K2O","CO2"], productNames: ["Оксид калия","Оксид углерода(IV)"],
            equation: "K₂CO₃ → K₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["Na2CO3"], products: ["Na2O","CO2"], productNames: ["Оксид натрия","Оксид углерода(IV)"],
            equation: "Na₂CO₃ → Na₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),

        // ==================== РАЗЛОЖЕНИЕ НИТРАТОВ ====================
        ChemicalReaction(reagents: ["KNO3"], products: ["KNO2","O2"], productNames: ["Нитрит калия","Кислород"],
            equation: "2KNO₃ → 2KNO₂ + O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["NaNO3"], products: ["NaNO2","O2"], productNames: ["Нитрит натрия","Кислород"],
            equation: "2NaNO₃ → 2NaNO₂ + O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["AgNO3"], products: ["Ag","NO2","O2"], productNames: ["Серебро","Оксид азота(IV)","Кислород"],
            equation: "2AgNO₃ → 2Ag + 2NO₂↑ + O₂↑", effect: .gas, effectColorHex: "#F59E0B"),

        // ==================== РАЗЛОЖЕНИЕ ПЕРМАНГАНАТА ====================
        ChemicalReaction(reagents: ["KMnO4"], products: ["K2MnO4","MnO2","O2"], productNames: ["Манганат калия","Оксид марганца(IV)","Кислород"],
            equation: "2KMnO₄ →t°→ K₂MnO₄ + MnO₂ + O₂↑", effect: .gas, effectColorHex: "#7E22CE"),

        // ==================== РАЗЛОЖЕНИЕ БЕРТОЛЕТОВОЙ СОЛИ ====================
        ChemicalReaction(reagents: ["KClO3"], products: ["KCl","O2"], productNames: ["Хлорид калия","Кислород"],
            equation: "2KClO₃ →t°,MnO₂→ 2KCl + 3O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),

        // ==================== ХЛОРИДЫ + ЩЁЛОЧИ ====================
        ChemicalReaction(reagents: ["MgCl2","NaOH"], products: ["Mg(OH)2"], productNames: ["Гидроксид магния"],
            equation: "MgCl₂ + 2NaOH → Mg(OH)₂↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["AlCl3","NaOH"], products: ["Al(OH)3"], productNames: ["Гидроксид алюминия"],
            equation: "AlCl₃ + 3NaOH → Al(OH)₃↓ + 3NaCl", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["ZnCl2","NaOH"], products: ["Zn(OH)2"], productNames: ["Гидроксид цинка"],
            equation: "ZnCl₂ + 2NaOH → Zn(OH)₂↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),

        // ==================== ОСАДКИ С НОВЫМИ СОЛЯМИ ====================
        ChemicalReaction(reagents: ["CaCl2","AgNO3"], products: ["AgCl","Ca(NO3)2"], productNames: ["Хлорид серебра","Нитрат кальция"],
            equation: "CaCl₂ + 2AgNO₃ → 2AgCl↓ + Ca(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["BaCl2","AgNO3"], products: ["AgCl","Ba(NO3)2"], productNames: ["Хлорид серебра","Нитрат бария"],
            equation: "BaCl₂ + 2AgNO₃ → 2AgCl↓ + Ba(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),

        // ==================== СУЛЬФАТЫ + БАРИЙ ====================
        ChemicalReaction(reagents: ["Na2SO4","BaCl2"], products: ["BaSO4","NaCl"], productNames: ["Сульфат бария","Хлорид натрия"],
            equation: "Na₂SO₄ + BaCl₂ → BaSO₄↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["K2SO4","BaCl2"], products: ["BaSO4","KCl"], productNames: ["Сульфат бария","Хлорид калия"],
            equation: "K₂SO₄ + BaCl₂ → BaSO₄↓ + 2KCl", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["ZnSO4","BaCl2"], products: ["BaSO4","ZnCl2"], productNames: ["Сульфат бария","Хлорид цинка"],
            equation: "ZnSO₄ + BaCl₂ → BaSO₄↓ + ZnCl₂", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["NiSO4","BaCl2"], products: ["BaSO4","NiCl2"], productNames: ["Сульфат бария","Хлорид никеля"],
            equation: "NiSO₄ + BaCl₂ → BaSO₄↓ + NiCl₂", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),

        // ==================== КАРБОНАТЫ + КИСЛОТЫ ====================
        ChemicalReaction(reagents: ["K2CO3","HNO3"], products: ["KNO3","H2O","CO2"], productNames: ["Нитрат калия","Вода","Оксид углерода(IV)"],
            equation: "K₂CO₃ + 2HNO₃ → 2KNO₃ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["Na2CO3","H2SO4"], products: ["Na2SO4","H2O","CO2"], productNames: ["Сульфат натрия","Вода","Оксид углерода(IV)"],
            equation: "Na₂CO₃ + H₂SO₄ → Na₂SO₄ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["NaHCO3"], products: ["Na2CO3","H2O","CO2"], productNames: ["Карбонат натрия","Вода","Оксид углерода(IV)"],
            equation: "2NaHCO₃ → Na₂CO₃ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),

        // ==================== ОРГАНИКА (полные продукты) ====================
        ChemicalReaction(reagents: ["C2H5OH","O"], products: ["CO2","H2O"], productNames: ["Оксид углерода(IV)","Вода"],
            equation: "C₂H₅OH + 3O₂ → 2CO₂ + 3H₂O", effect: .explosion, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["C2H2","O"], products: ["CO2","H2O"], productNames: ["Оксид углерода(IV)","Вода"],
            equation: "2C₂H₂ + 5O₂ → 4CO₂ + 2H₂O", effect: .explosion, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["C6H12O6","O"], products: ["CO2","H2O"], productNames: ["Оксид углерода(IV)","Вода"],
            equation: "C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O", effect: .glow, effectColorHex: "#FDE68A"),

        // ==================== ХЛОР + ВОДОРОД ====================
        ChemicalReaction(reagents: ["H2","Cl2"], products: ["HCl"], productNames: ["Хлороводород"],
            equation: "H₂ + Cl₂ → 2HCl", effect: .explosion, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["H2","O2"], products: ["H2O"], productNames: ["Вода"],
            equation: "2H₂ + O₂ → 2H₂O", effect: .explosion, effectColorHex: "#FCD34D"),
        ChemicalReaction(reagents: ["H2","N2"], products: ["NH3"], productNames: ["Аммиак"],
            equation: "N₂ + 3H₂ ⇄ 2NH₃", effect: .gas, effectColorHex: "#A5B4FC"),

        // ==================== ОРГАНИКА: ГОРЕНИЕ ====================
        ChemicalReaction(reagents: ["CH4","O2"], products: ["CO2","H2O"], productNames: ["Оксид углерода(IV)","Вода"],
            equation: "CH₄ + 2O₂ → CO₂ + 2H₂O", effect: .explosion, effectColorHex: "#F97316",
            warning: "🚨 Метан с кислородом — гремучая смесь!"),
    ]

    // Обновлённая функция поиска: сначала основная база, потом extra
    static func findAnyReaction(_ a: String, _ b: String) -> ChemicalReaction? {
        let pair: Set<String> = [a, b]
        if let r = reactions.first(where: { $0.reagents == pair }) { return r }
        if let r = extraReactions.first(where: { $0.reagents == pair }) { return r }
        return nil
    }

    // Поиск разложения (один реагент слева)
    static func findDecomposition(_ a: String) -> ChemicalReaction? {
        let single: Set<String> = [a]
        if let r = reactions.first(where: { $0.reagents == single }) { return r }
        if let r = extraReactions.first(where: { $0.reagents == single }) { return r }
        return nil
    }
}
