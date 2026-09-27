import SwiftUI

extension ChemistryData {

    // ============================================================
    // ДОПОЛНИТЕЛЬНЫЕ РЕАКЦИИ
    // (разложения, редкие, соединения + соединения, NH4-соли,
    //  амфотерные, CO-восстановление, HNO3, органика 10 кл.)
    // ============================================================
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
        ChemicalReaction(reagents: ["H2CO3"], products: ["H2O","CO2"], productNames: ["Вода","Оксид углерода(IV)"],
            equation: "H₂CO₃ → H₂O + CO₂↑", effect: .gas, effectColorHex: "#94A3B8"),
        ChemicalReaction(reagents: ["H2SiO3"], products: ["SiO2","H2O"], productNames: ["Оксид кремния","Вода"],
            equation: "H₂SiO₃ → SiO₂ + H₂O", effect: .glow, effectColorHex: "#A8A29E"),
        ChemicalReaction(reagents: ["KMnO4"], products: ["K2MnO4","MnO2","O2"], productNames: ["Манганат калия","Оксид марганца(IV)","Кислород"],
            equation: "2KMnO₄ → K₂MnO₄ + MnO₂ + O₂↑", effect: .gas, effectColorHex: "#7E22CE",
            warning: "⚠️ Перманганат калия — сильный окислитель."),
        ChemicalReaction(reagents: ["KClO3"], products: ["KCl","O2"], productNames: ["Хлорид калия","Кислород"],
            equation: "2KClO₃ → 2KCl + 3O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["KNO3"], products: ["KNO2","O2"], productNames: ["Нитрит калия","Кислород"],
            equation: "2KNO₃ → 2KNO₂ + O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["NaNO3"], products: ["NaNO2","O2"], productNames: ["Нитрит натрия","Кислород"],
            equation: "2NaNO₃ → 2NaNO₂ + O₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["AgNO3"], products: ["Ag","NO2","O2"], productNames: ["Серебро","Оксид азота(IV)","Кислород"],
            equation: "2AgNO₃ → 2Ag + 2NO₂↑ + O₂↑", effect: .gas, effectColorHex: "#F59E0B"),
        ChemicalReaction(reagents: ["NaHCO3"], products: ["Na2CO3","H2O","CO2"], productNames: ["Карбонат натрия","Вода","Оксид углерода(IV)"],
            equation: "2NaHCO₃ → Na₂CO₃ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
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

        // ==================== NH4-СОЛИ + ЩЁЛОЧИ (получение аммиака) ====================
        ChemicalReaction(reagents: ["NH4Cl","NaOH"], products: ["NaCl","NH3","H2O"], productNames: ["Хлорид натрия","Аммиак","Вода"],
            equation: "NH₄Cl + NaOH → NaCl + NH₃↑ + H₂O", effect: .gas, effectColorHex: "#A5B4FC",
            warning: "⚠️ Выделяется аммиак — резкий запах, работать под тягой."),
        ChemicalReaction(reagents: ["NH4Cl","KOH"], products: ["KCl","NH3","H2O"], productNames: ["Хлорид калия","Аммиак","Вода"],
            equation: "NH₄Cl + KOH → KCl + NH₃↑ + H₂O", effect: .gas, effectColorHex: "#A5B4FC"),
        ChemicalReaction(reagents: ["NH4Cl","Ca(OH)2"], products: ["CaCl2","NH3","H2O"], productNames: ["Хлорид кальция","Аммиак","Вода"],
            equation: "2NH₄Cl + Ca(OH)₂ → CaCl₂ + 2NH₃↑ + 2H₂O", effect: .gas, effectColorHex: "#A5B4FC",
            warning: "⚠️ Лабораторный способ получения аммиака!"),
        ChemicalReaction(reagents: ["NH4NO3","NaOH"], products: ["NaNO3","NH3","H2O"], productNames: ["Нитрат натрия","Аммиак","Вода"],
            equation: "NH₄NO₃ + NaOH → NaNO₃ + NH₃↑ + H₂O", effect: .gas, effectColorHex: "#A5B4FC"),
        ChemicalReaction(reagents: ["(NH4)2SO4","NaOH"], products: ["Na2SO4","NH3","H2O"], productNames: ["Сульфат натрия","Аммиак","Вода"],
            equation: "(NH₄)₂SO₄ + 2NaOH → Na₂SO₄ + 2NH₃↑ + 2H₂O", effect: .gas, effectColorHex: "#A5B4FC"),
        ChemicalReaction(reagents: ["(NH4)2SO4","BaCl2"], products: ["BaSO4","NH4Cl"], productNames: ["Сульфат бария","Хлорид аммония"],
            equation: "(NH₄)₂SO₄ + BaCl₂ → BaSO₄↓ + 2NH₄Cl", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["NH4Cl","AgNO3"], products: ["AgCl","NH4NO3"], productNames: ["Хлорид серебра","Нитрат аммония"],
            equation: "NH₄Cl + AgNO₃ → AgCl↓ + NH₄NO₃", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),

        // ==================== АММИАК И ЕГО РЕАКЦИИ ====================
        ChemicalReaction(reagents: ["NH3","HCl"], products: ["NH4Cl"], productNames: ["Хлорид аммония"],
            equation: "NH₃ + HCl → NH₄Cl", effect: .precipitateWhite, effectColorHex: "#F1F5F9",
            warning: "⚠️ Образуется белый дым — типичный опыт «дым без огня»."),
        ChemicalReaction(reagents: ["NH3","H2O"], products: ["NH4OH"], productNames: ["Гидроксид аммония"],
            equation: "NH₃ + H₂O ⇄ NH₄OH", effect: .glow, effectColorHex: "#C7D2FE"),

        // ==================== КИСЛОТА + ОСНОВАНИЕ (расширение) ====================
        ChemicalReaction(reagents: ["Fe(OH)3","HCl"], products: ["FeCl3","H2O"], productNames: ["Хлорид железа(III)","Вода"],
            equation: "Fe(OH)₃ + 3HCl → FeCl₃ + 3H₂O", effect: .colorChange, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["Fe(OH)3","H2SO4"], products: ["Fe2(SO4)3","H2O"], productNames: ["Сульфат железа(III)","Вода"],
            equation: "2Fe(OH)₃ + 3H₂SO₄ → Fe₂(SO₄)₃ + 6H₂O", effect: .colorChange, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["Fe(OH)3","HNO3"], products: ["Fe(NO3)3","H2O"], productNames: ["Нитрат железа(III)","Вода"],
            equation: "Fe(OH)₃ + 3HNO₃ → Fe(NO₃)₃ + 3H₂O", effect: .colorChange, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["Fe(OH)2","HCl"], products: ["FeCl2","H2O"], productNames: ["Хлорид железа(II)","Вода"],
            equation: "Fe(OH)₂ + 2HCl → FeCl₂ + 2H₂O", effect: .colorChange, effectColorHex: "#365314"),
        ChemicalReaction(reagents: ["Cu(OH)2","HCl"], products: ["CuCl2","H2O"], productNames: ["Хлорид меди(II)","Вода"],
            equation: "Cu(OH)₂ + 2HCl → CuCl₂ + 2H₂O", effect: .colorChange, effectColorHex: "#0891B2"),
        ChemicalReaction(reagents: ["Cu(OH)2","H2SO4"], products: ["CuSO4","H2O"], productNames: ["Сульфат меди(II)","Вода"],
            equation: "Cu(OH)₂ + H₂SO₄ → CuSO₄ + 2H₂O", effect: .colorChange, effectColorHex: "#06B6D4"),
        ChemicalReaction(reagents: ["Cu(OH)2","HNO3"], products: ["Cu(NO3)2","H2O"], productNames: ["Нитрат меди(II)","Вода"],
            equation: "Cu(OH)₂ + 2HNO₃ → Cu(NO₃)₂ + 2H₂O", effect: .colorChange, effectColorHex: "#0E7490"),
        ChemicalReaction(reagents: ["Mg(OH)2","HCl"], products: ["MgCl2","H2O"], productNames: ["Хлорид магния","Вода"],
            equation: "Mg(OH)₂ + 2HCl → MgCl₂ + 2H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Mg(OH)2","H2SO4"], products: ["MgSO4","H2O"], productNames: ["Сульфат магния","Вода"],
            equation: "Mg(OH)₂ + H₂SO₄ → MgSO₄ + 2H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Zn(OH)2","HCl"], products: ["ZnCl2","H2O"], productNames: ["Хлорид цинка","Вода"],
            equation: "Zn(OH)₂ + 2HCl → ZnCl₂ + 2H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Zn(OH)2","H2SO4"], products: ["ZnSO4","H2O"], productNames: ["Сульфат цинка","Вода"],
            equation: "Zn(OH)₂ + H₂SO₄ → ZnSO₄ + 2H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Al(OH)3","HCl"], products: ["AlCl3","H2O"], productNames: ["Хлорид алюминия","Вода"],
            equation: "Al(OH)₃ + 3HCl → AlCl₃ + 3H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Al(OH)3","H2SO4"], products: ["Al2(SO4)3","H2O"], productNames: ["Сульфат алюминия","Вода"],
            equation: "2Al(OH)₃ + 3H₂SO₄ → Al₂(SO₄)₃ + 6H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Al(OH)3","HNO3"], products: ["Al(NO3)3","H2O"], productNames: ["Нитрат алюминия","Вода"],
            equation: "Al(OH)₃ + 3HNO₃ → Al(NO₃)₃ + 3H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["Ca(OH)2","H2SO4"], products: ["CaSO4","H2O"], productNames: ["Сульфат кальция","Вода"],
            equation: "Ca(OH)₂ + H₂SO₄ → CaSO₄↓ + 2H₂O", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),

        // ==================== АМФОТЕРНЫЕ ГИДРОКСИДЫ И ОКСИДЫ + ЩЁЛОЧИ ====================
        ChemicalReaction(reagents: ["Al(OH)3","NaOH"], products: ["NaAlO2","H2O"], productNames: ["Алюминат натрия","Вода"],
            equation: "Al(OH)₃ + NaOH → NaAlO₂ + 2H₂O", effect: .colorChange, effectColorHex: "#A78BFA",
            warning: "⚠️ Амфотерность: осадок растворяется в избытке щёлочи."),
        ChemicalReaction(reagents: ["Al(OH)3","KOH"], products: ["KAlO2","H2O"], productNames: ["Алюминат калия","Вода"],
            equation: "Al(OH)₃ + KOH → KAlO₂ + 2H₂O", effect: .colorChange, effectColorHex: "#C084FC"),
        ChemicalReaction(reagents: ["Zn(OH)2","NaOH"], products: ["Na2ZnO2","H2O"], productNames: ["Цинкат натрия","Вода"],
            equation: "Zn(OH)₂ + 2NaOH → Na₂ZnO₂ + 2H₂O", effect: .colorChange, effectColorHex: "#A78BFA"),
        ChemicalReaction(reagents: ["Al2O3","NaOH"], products: ["NaAlO2","H2O"], productNames: ["Алюминат натрия","Вода"],
            equation: "Al₂O₃ + 2NaOH → 2NaAlO₂ + H₂O", effect: .glow, effectColorHex: "#A78BFA"),
        ChemicalReaction(reagents: ["ZnO","NaOH"], products: ["Na2ZnO2","H2O"], productNames: ["Цинкат натрия","Вода"],
            equation: "ZnO + 2NaOH → Na₂ZnO₂ + H₂O", effect: .glow, effectColorHex: "#A78BFA"),

        // ==================== AgNO3 + ХЛОРИДЫ ====================
        ChemicalReaction(reagents: ["AlCl3","AgNO3"], products: ["AgCl","Al(NO3)3"], productNames: ["Хлорид серебра","Нитрат алюминия"],
            equation: "AlCl₃ + 3AgNO₃ → 3AgCl↓ + Al(NO₃)₃", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["FeCl3","AgNO3"], products: ["AgCl","Fe(NO3)3"], productNames: ["Хлорид серебра","Нитрат железа(III)"],
            equation: "FeCl₃ + 3AgNO₃ → 3AgCl↓ + Fe(NO₃)₃", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["FeCl2","AgNO3"], products: ["AgCl","Fe(NO3)2"], productNames: ["Хлорид серебра","Нитрат железа(II)"],
            equation: "FeCl₂ + 2AgNO₃ → 2AgCl↓ + Fe(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["ZnCl2","AgNO3"], products: ["AgCl","Zn(NO3)2"], productNames: ["Хлорид серебра","Нитрат цинка"],
            equation: "ZnCl₂ + 2AgNO₃ → 2AgCl↓ + Zn(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["MgCl2","AgNO3"], products: ["AgCl","Mg(NO3)2"], productNames: ["Хлорид серебра","Нитрат магния"],
            equation: "MgCl₂ + 2AgNO₃ → 2AgCl↓ + Mg(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["CuCl2","AgNO3"], products: ["AgCl","Cu(NO3)2"], productNames: ["Хлорид серебра","Нитрат меди(II)"],
            equation: "CuCl₂ + 2AgNO₃ → 2AgCl↓ + Cu(NO₃)₂", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["LiCl","AgNO3"], products: ["AgCl","LiNO3"], productNames: ["Хлорид серебра","Нитрат лития"],
            equation: "LiCl + AgNO₃ → AgCl↓ + LiNO₃", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),

        // ==================== BaCl2 / Ba(OH)2 + СУЛЬФАТЫ ====================
        ChemicalReaction(reagents: ["BaCl2","FeSO4"], products: ["BaSO4","FeCl2"], productNames: ["Сульфат бария","Хлорид железа(II)"],
            equation: "BaCl₂ + FeSO₄ → BaSO₄↓ + FeCl₂", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["BaCl2","Fe2(SO4)3"], products: ["BaSO4","FeCl3"], productNames: ["Сульфат бария","Хлорид железа(III)"],
            equation: "3BaCl₂ + Fe₂(SO₄)₃ → 3BaSO₄↓ + 2FeCl₃", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["BaCl2","NiSO4"], products: ["BaSO4","NiCl2"], productNames: ["Сульфат бария","Хлорид никеля"],
            equation: "BaCl₂ + NiSO₄ → BaSO₄↓ + NiCl₂", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Ba(OH)2","Na2SO4"], products: ["BaSO4","NaOH"], productNames: ["Сульфат бария","Гидроксид натрия"],
            equation: "Ba(OH)₂ + Na₂SO₄ → BaSO₄↓ + 2NaOH", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Ba(OH)2","K2SO4"], products: ["BaSO4","KOH"], productNames: ["Сульфат бария","Гидроксид калия"],
            equation: "Ba(OH)₂ + K₂SO₄ → BaSO₄↓ + 2KOH", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Ba(OH)2","CuSO4"], products: ["BaSO4","Cu(OH)2"], productNames: ["Сульфат бария","Гидроксид меди(II)"],
            equation: "Ba(OH)₂ + CuSO₄ → BaSO₄↓ + Cu(OH)₂↓", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Ba(OH)2","MgSO4"], products: ["BaSO4","Mg(OH)2"], productNames: ["Сульфат бария","Гидроксид магния"],
            equation: "Ba(OH)₂ + MgSO₄ → BaSO₄↓ + Mg(OH)₂↓", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),

        // ==================== ЩЁЛОЧИ + СОЛИ ЖЕЛЕЗА И МЕДИ ====================
        ChemicalReaction(reagents: ["Fe2(SO4)3","NaOH"], products: ["Fe(OH)3","Na2SO4"], productNames: ["Гидроксид железа(III)","Сульфат натрия"],
            equation: "Fe₂(SO₄)₃ + 6NaOH → 2Fe(OH)₃↓ + 3Na₂SO₄", effect: .precipitateBrown, effectColorHex: "#92400E"),
        ChemicalReaction(reagents: ["FeSO4","NaOH"], products: ["Fe(OH)2","Na2SO4"], productNames: ["Гидроксид железа(II)","Сульфат натрия"],
            equation: "FeSO₄ + 2NaOH → Fe(OH)₂↓ + Na₂SO₄", effect: .precipitateBrown, effectColorHex: "#365314"),
        ChemicalReaction(reagents: ["FeSO4","KOH"], products: ["Fe(OH)2","K2SO4"], productNames: ["Гидроксид железа(II)","Сульфат калия"],
            equation: "FeSO₄ + 2KOH → Fe(OH)₂↓ + K₂SO₄", effect: .precipitateBrown, effectColorHex: "#365314"),
        ChemicalReaction(reagents: ["ZnSO4","NaOH"], products: ["Zn(OH)2","Na2SO4"], productNames: ["Гидроксид цинка","Сульфат натрия"],
            equation: "ZnSO₄ + 2NaOH → Zn(OH)₂↓ + Na₂SO₄", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["MgSO4","NaOH"], products: ["Mg(OH)2","Na2SO4"], productNames: ["Гидроксид магния","Сульфат натрия"],
            equation: "MgSO₄ + 2NaOH → Mg(OH)₂↓ + Na₂SO₄", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),

        // ==================== КАРБОНАТЫ + КИСЛОТЫ (расширение) ====================
        ChemicalReaction(reagents: ["Na2CO3","HNO3"], products: ["NaNO3","H2O","CO2"], productNames: ["Нитрат натрия","Вода","Оксид углерода(IV)"],
            equation: "Na₂CO₃ + 2HNO₃ → 2NaNO₃ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["K2CO3","H2SO4"], products: ["K2SO4","H2O","CO2"], productNames: ["Сульфат калия","Вода","Оксид углерода(IV)"],
            equation: "K₂CO₃ + H₂SO₄ → K₂SO₄ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["CaCO3","HNO3"], products: ["Ca(NO3)2","H2O","CO2"], productNames: ["Нитрат кальция","Вода","Оксид углерода(IV)"],
            equation: "CaCO₃ + 2HNO₃ → Ca(NO₃)₂ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["BaCO3","H2SO4"], products: ["BaSO4","H2O","CO2"], productNames: ["Сульфат бария","Вода","Оксид углерода(IV)"],
            equation: "BaCO₃ + H₂SO₄ → BaSO₄↓ + H₂O + CO₂↑", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["CuCO3","HCl"], products: ["CuCl2","H2O","CO2"], productNames: ["Хлорид меди(II)","Вода","Оксид углерода(IV)"],
            equation: "CuCO₃ + 2HCl → CuCl₂ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),

        // ==================== КАРБОНАТЫ + СОЛИ ====================
        ChemicalReaction(reagents: ["Na2CO3","CuCl2"], products: ["CuCO3","NaCl"], productNames: ["Карбонат меди(II)","Хлорид натрия"],
            equation: "Na₂CO₃ + CuCl₂ → CuCO₃↓ + 2NaCl", effect: .precipitateBlue, effectColorHex: "#0E7490"),
        ChemicalReaction(reagents: ["Na2CO3","FeCl2"], products: ["FeCO3","NaCl"], productNames: ["Карбонат железа(II)","Хлорид натрия"],
            equation: "Na₂CO₃ + FeCl₂ → FeCO₃↓ + 2NaCl", effect: .precipitateBrown, effectColorHex: "#365314"),
        ChemicalReaction(reagents: ["Na2CO3","BaCl2"], products: ["BaCO3","NaCl"], productNames: ["Карбонат бария","Хлорид натрия"],
            equation: "Na₂CO₃ + BaCl₂ → BaCO₃↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),

        // ==================== КИСЛОТА + СОЛЬ (расширение) ====================
        ChemicalReaction(reagents: ["Na2S","H2SO4"], products: ["Na2SO4","H2S"], productNames: ["Сульфат натрия","Сероводород"],
            equation: "Na₂S + H₂SO₄ → Na₂SO₄ + H₂S↑", effect: .gas, effectColorHex: "#FACC15",
            warning: "⚠️ Выделяется токсичный сероводород!"),
        ChemicalReaction(reagents: ["FeS","H2SO4"], products: ["FeSO4","H2S"], productNames: ["Сульфат железа(II)","Сероводород"],
            equation: "FeS + H₂SO₄ → FeSO₄ + H₂S↑", effect: .gas, effectColorHex: "#FACC15"),
        ChemicalReaction(reagents: ["Na2SiO3","CO2"], products: ["H2SiO3","Na2CO3"], productNames: ["Кремниевая кислота","Карбонат натрия"],
            equation: "Na₂SiO₃ + CO₂ + H₂O → H₂SiO₃↓ + Na₂CO₃", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["NaHCO3","NaOH"], products: ["Na2CO3","H2O"], productNames: ["Карбонат натрия","Вода"],
            equation: "NaHCO₃ + NaOH → Na₂CO₃ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),

        // ==================== ОКСИД + ОКСИД ====================
        ChemicalReaction(reagents: ["CaO","CO2"], products: ["CaCO3"], productNames: ["Карбонат кальция"],
            equation: "CaO + CO₂ → CaCO₃", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["BaO","CO2"], products: ["BaCO3"], productNames: ["Карбонат бария"],
            equation: "BaO + CO₂ → BaCO₃", effect: .precipitateWhite, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["Na2O","CO2"], products: ["Na2CO3"], productNames: ["Карбонат натрия"],
            equation: "Na₂O + CO₂ → Na₂CO₃", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["K2O","CO2"], products: ["K2CO3"], productNames: ["Карбонат калия"],
            equation: "K₂O + CO₂ → K₂CO₃", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["CaO","SO2"], products: ["CaSO3"], productNames: ["Сульфит кальция"],
            equation: "CaO + SO₂ → CaSO₃", effect: .glow, effectColorHex: "#FEF3C7"),

        // ==================== SO2 / NO + O2 ====================
        ChemicalReaction(reagents: ["SO2","O"], products: ["SO3"], productNames: ["Оксид серы(VI)"],
            equation: "2SO₂ + O₂ ⇄ 2SO₃ (кат., t°)", effect: .glow, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["NO","O"], products: ["NO2"], productNames: ["Оксид азота(IV)"],
            equation: "2NO + O₂ → 2NO₂", effect: .colorChange, effectColorHex: "#92400E"),

        // ==================== ВОССТАНОВЛЕНИЕ ОКСИДОВ УГАРНЫМ ГАЗОМ (CO) ====================
        ChemicalReaction(reagents: ["Fe2O3","CO"], products: ["Fe","CO2"], productNames: ["Железо","Оксид углерода(IV)"],
            equation: "Fe₂O₃ + 3CO → 2Fe + 3CO₂", effect: .glow, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["CuO","CO"], products: ["Cu","CO2"], productNames: ["Медь","Оксид углерода(IV)"],
            equation: "CuO + CO → Cu + CO₂", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["FeO","CO"], products: ["Fe","CO2"], productNames: ["Железо","Оксид углерода(IV)"],
            equation: "FeO + CO → Fe + CO₂", effect: .glow, effectColorHex: "#B45309"),
        ChemicalReaction(reagents: ["PbO","CO"], products: ["Pb","CO2"], productNames: ["Свинец","Оксид углерода(IV)"],
            equation: "PbO + CO → Pb + CO₂", effect: .glow, effectColorHex: "#64748B"),

        // ==================== ВОССТАНОВЛЕНИЕ ОКСИДОВ ВОДОРОДОМ И УГЛЕРОДОМ (расширение) ====================
        ChemicalReaction(reagents: ["ZnO","H"], products: ["Zn","H2O"], productNames: ["Цинк","Вода"],
            equation: "ZnO + H₂ → Zn + H₂O", effect: .glow, effectColorHex: "#94A3B8"),
        ChemicalReaction(reagents: ["WO3","H"], products: ["W","H2O"], productNames: ["Вольфрам","Вода"],
            equation: "WO₃ + 3H₂ → W + 3H₂O", effect: .glow, effectColorHex: "#64748B"),

        // ==================== АЛЮМИНОТЕРМИЯ (расширение) ====================
        ChemicalReaction(reagents: ["Fe3O4","Al"], products: ["Fe","Al2O3"], productNames: ["Железо","Оксид алюминия"],
            equation: "3Fe₃O₄ + 8Al → 9Fe + 4Al₂O₃", effect: .explosion, effectColorHex: "#F97316",
            warning: "🚨 Алюминотермия — температура до 2500°C!"),

        // ==================== МЕТАЛЛ + ГАЛОГЕН (расширение) ====================
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

        // ==================== АКТИВНЫЕ МЕТАЛЛЫ + ВОДА (расширение) ====================
        ChemicalReaction(reagents: ["Sr","H2O"], products: ["Sr(OH)2","H2"], productNames: ["Гидроксид стронция","Водород"],
            equation: "Sr + 2H₂O → Sr(OH)₂ + H₂↑", effect: .gas, effectColorHex: "#E0F2FE"),

        // ==================== ОКСИДЫ + HNO3 ====================
        ChemicalReaction(reagents: ["BaO","HNO3"], products: ["Ba(NO3)2","H2O"], productNames: ["Нитрат бария","Вода"],
            equation: "BaO + 2HNO₃ → Ba(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["CaO","HNO3"], products: ["Ca(NO3)2","H2O"], productNames: ["Нитрат кальция","Вода"],
            equation: "CaO + 2HNO₃ → Ca(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["MgO","HNO3"], products: ["Mg(NO3)2","H2O"], productNames: ["Нитрат магния","Вода"],
            equation: "MgO + 2HNO₃ → Mg(NO₃)₂ + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["CuO","H3PO4"], products: ["Cu3(PO4)2","H2O"], productNames: ["Фосфат меди(II)","Вода"],
            equation: "3CuO + 2H₃PO₄ → Cu₃(PO₄)₂ + 3H₂O", effect: .glow, effectColorHex: "#FEF3C7"),

        // ==================== АЗОТНАЯ КИСЛОТА + МЕТАЛЛЫ ====================
        ChemicalReaction(reagents: ["Cu","HNO3"], products: ["Cu(NO3)2","NO2","H2O"], productNames: ["Нитрат меди(II)","Оксид азота(IV)","Вода"],
            equation: "Cu + 4HNO₃(конц.) → Cu(NO₃)₂ + 2NO₂↑ + 2H₂O", effect: .gas, effectColorHex: "#92400E",
            warning: "⚠️ Выделяется токсичный NO₂ — работать под тягой!"),
        ChemicalReaction(reagents: ["Ag","HNO3"], products: ["AgNO3","NO2","H2O"], productNames: ["Нитрат серебра","Оксид азота(IV)","Вода"],
            equation: "Ag + 2HNO₃(конц.) → AgNO₃ + NO₂↑ + H₂O", effect: .gas, effectColorHex: "#92400E"),
        ChemicalReaction(reagents: ["Zn","HNO3"], products: ["Zn(NO3)2","NO","H2O"], productNames: ["Нитрат цинка","Оксид азота(II)","Вода"],
            equation: "3Zn + 8HNO₃(разб.) → 3Zn(NO₃)₂ + 2NO↑ + 4H₂O", effect: .gas, effectColorHex: "#3B82F6"),

        // ==================== СЕРНАЯ КИСЛОТА (конц.) + МЕТАЛЛЫ И НЕМЕТАЛЛЫ ====================
        ChemicalReaction(reagents: ["Cu","H2SO4"], products: ["CuSO4","SO2","H2O"], productNames: ["Сульфат меди(II)","Оксид серы(IV)","Вода"],
            equation: "Cu + 2H₂SO₄(конц.) → CuSO₄ + SO₂↑ + 2H₂O", effect: .gas, effectColorHex: "#CBD5E1",
            warning: "⚠️ Концентрированная серная кислота — сильный окислитель!"),
        ChemicalReaction(reagents: ["C","H2SO4"], products: ["CO2","SO2","H2O"], productNames: ["Оксид углерода(IV)","Оксид серы(IV)","Вода"],
            equation: "C + 2H₂SO₄(конц.) → CO₂↑ + 2SO₂↑ + 2H₂O", effect: .gas, effectColorHex: "#CBD5E1"),

        // ==================== ГАЛОГЕН-ОБМЕННЫЕ (расширение) ====================
        ChemicalReaction(reagents: ["Cl","NaBr"], products: ["NaCl","Br"], productNames: ["Хлорид натрия","Бром"],
            equation: "Cl₂ + 2NaBr → 2NaCl + Br₂", effect: .colorChange, effectColorHex: "#B91C1C"),
        ChemicalReaction(reagents: ["Cl","KI"], products: ["KCl","I"], productNames: ["Хлорид калия","Иод"],
            equation: "Cl₂ + 2KI → 2KCl + I₂", effect: .colorChange, effectColorHex: "#7C3AED"),
        ChemicalReaction(reagents: ["Cl","NaI"], products: ["NaCl","I"], productNames: ["Хлорид натрия","Иод"],
            equation: "Cl₂ + 2NaI → 2NaCl + I₂", effect: .colorChange, effectColorHex: "#7C3AED"),
        ChemicalReaction(reagents: ["Br","KI"], products: ["KBr","I"], productNames: ["Бромид калия","Иод"],
            equation: "Br₂ + 2KI → 2KBr + I₂", effect: .colorChange, effectColorHex: "#7C3AED"),
        ChemicalReaction(reagents: ["Br","NaI"], products: ["NaBr","I"], productNames: ["Бромид натрия","Иод"],
            equation: "Br₂ + 2NaI → 2NaBr + I₂", effect: .colorChange, effectColorHex: "#7C3AED"),

        // ==================== ОРГАНИКА: ЗАМЕЩЕНИЕ, ПРИСОЕДИНЕНИЕ, ЭТЕРИФИКАЦИЯ ====================
        ChemicalReaction(reagents: ["CH4","Br"], products: ["CH3Br"], productNames: ["Бромметан"],
            equation: "CH₄ + Br₂ → CH₃Br + HBr (свет)", effect: .glow, effectColorHex: "#FEE2E2"),
        ChemicalReaction(reagents: ["C2H4","HCl"], products: ["C2H5Cl"], productNames: ["Хлорэтан"],
            equation: "CH₂=CH₂ + HCl → CH₃–CH₂Cl", effect: .glow, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["C2H2","HCl"], products: ["C2H3Cl"], productNames: ["Винилхлорид"],
            equation: "CH≡CH + HCl → CH₂=CHCl (Hg²⁺)", effect: .glow, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["C6H6","HNO3"], products: ["C6H5NO2","H2O"], productNames: ["Нитробензол","Вода"],
            equation: "C₆H₆ + HNO₃ → C₆H₅NO₂ + H₂O (H₂SO₄)", effect: .colorChange, effectColorHex: "#FDE68A"),
        ChemicalReaction(reagents: ["C6H5OH","Na"], products: ["C6H5ONa","H2"], productNames: ["Фенолят натрия","Водород"],
            equation: "2C₆H₅OH + 2Na → 2C₆H₅ONa + H₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["CH3COOH","Mg"], products: ["(CH3COO)2Mg","H2"], productNames: ["Ацетат магния","Водород"],
            equation: "2CH₃COOH + Mg → (CH₃COO)₂Mg + H₂↑", effect: .gas, effectColorHex: "#E0F2FE"),
        ChemicalReaction(reagents: ["CH3COOH","CaCO3"], products: ["(CH3COO)2Ca","H2O","CO2"], productNames: ["Ацетат кальция","Вода","Оксид углерода(IV)"],
            equation: "2CH₃COOH + CaCO₃ → (CH₃COO)₂Ca + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["CH3COOH","NaHCO3"], products: ["CH3COONa","H2O","CO2"], productNames: ["Ацетат натрия","Вода","Оксид углерода(IV)"],
            equation: "CH₃COOH + NaHCO₃ → CH₃COONa + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),

        // ==================== СИЛИКАТЫ И ПРОЧИЕ РЕАКЦИИ ====================
        ChemicalReaction(reagents: ["Na2SiO3","H2SO4"], products: ["H2SiO3","Na2SO4"], productNames: ["Кремниевая кислота","Сульфат натрия"],
            equation: "Na₂SiO₃ + H₂SO₄ → H₂SiO₃↓ + Na₂SO₄", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["Na2SiO3","CaCl2"], products: ["CaSiO3","NaCl"], productNames: ["Силикат кальция","Хлорид натрия"],
            equation: "Na₂SiO₃ + CaCl₂ → CaSiO₃↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["Na3PO4","AgNO3"], products: ["Ag3PO4","NaNO3"], productNames: ["Фосфат серебра","Нитрат натрия"],
            equation: "Na₃PO₄ + 3AgNO₃ → Ag₃PO₄↓ + 3NaNO₃", effect: .precipitateYellow, effectColorHex: "#FEF08A"),

        // ==================== ДОПОЛНИТЕЛЬНЫЕ ОКИСЛИТЕЛЬНО-ВОССТАНОВИТЕЛЬНЫЕ ====================
        ChemicalReaction(reagents: ["KMnO4","HCl"], products: ["KCl","MnCl2","Cl2","H2O"], productNames: ["Хлорид калия","Хлорид марганца(II)","Хлор","Вода"],
            equation: "2KMnO₄ + 16HCl → 2KCl + 2MnCl₂ + 5Cl₂↑ + 8H₂O", effect: .gas, effectColorHex: "#4ADE80",
            warning: "⚠️ Выделяется токсичный хлор!"),
        ChemicalReaction(reagents: ["K2Cr2O7","HCl"], products: ["KCl","CrCl3","Cl2","H2O"], productNames: ["Хлорид калия","Хлорид хрома(III)","Хлор","Вода"],
            equation: "K₂Cr₂O₇ + 14HCl → 2KCl + 2CrCl₃ + 3Cl₂↑ + 7H₂O", effect: .gas, effectColorHex: "#4ADE80"),
        ChemicalReaction(reagents: ["H2S","O"], products: ["SO2","H2O"], productNames: ["Оксид серы(IV)","Вода"],
            equation: "2H₂S + 3O₂ → 2SO₂ + 2H₂O", effect: .gas, effectColorHex: "#CBD5E1",
            warning: "⚠️ H₂S очень токсичен!"),
        ChemicalReaction(reagents: ["NH3","O"], products: ["NO","H2O"], productNames: ["Оксид азота(II)","Вода"],
            equation: "4NH₃ + 5O₂ → 4NO + 6H₂O (кат.)", effect: .gas, effectColorHex: "#3B82F6"),
    ]

    // ============================================================
    // ИНДЕКС РЕАКЦИЙ (O(1) поиск по паре реагентов)
    // Строится один раз при первом обращении, ищет в ОБОИХ массивах
    // ============================================================

    private static let reactionIndex: [String: ChemicalReaction] = {
        var idx: [String: ChemicalReaction] = [:]
        // Основная база приоритетнее
        for r in reactions where r.reagents.count == 2 {
            let key = r.reagents.sorted().joined(separator: "|")
            if idx[key] == nil { idx[key] = r }
        }
        for r in extraReactions where r.reagents.count == 2 {
            let key = r.reagents.sorted().joined(separator: "|")
            if idx[key] == nil { idx[key] = r }
        }
        return idx
    }()

    private static let decompositionIndex: [String: ChemicalReaction] = {
        var idx: [String: ChemicalReaction] = [:]
        for r in reactions where r.reagents.count == 1 {
            if let s = r.reagents.first { idx[s] = r }
        }
        for r in extraReactions where r.reagents.count == 1 {
            if let s = r.reagents.first, idx[s] == nil { idx[s] = r }
        }
        return idx
    }()

    // ============================================================
    // БЫСТРЫЙ ПОИСК: пара реагентов → реакция (ищет в reactions + extraReactions)
    // ============================================================
    static func findReaction(_ a: String, _ b: String) -> ChemicalReaction? {
        let key = [a, b].sorted().joined(separator: "|")
        return reactionIndex[key]
    }

    // ============================================================
    // БЫСТРЫЙ ПОИСК: разложение одного реагента
    // ============================================================
    static func findDecomposition(_ a: String) -> ChemicalReaction? {
        return decompositionIndex[a]
    }

    // ============================================================
    // Совместимость: старое имя, ищет и в reactions, и в extraReactions
    // ============================================================
    static func findAnyReaction(_ a: String, _ b: String) -> ChemicalReaction? {
        return findReaction(a, b)
    }
}
