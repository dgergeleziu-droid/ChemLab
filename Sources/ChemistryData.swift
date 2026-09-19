import SwiftUI

enum ChemistryData {

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
        Reagent(symbol: "CaO",     name: "Оксид кальция",     colorHex: "#FCD34D", group: .compounds),
        Reagent(symbol: "CO2",     name: "Оксид углерода(IV)",colorHex: "#94A3B8", group: .compounds),

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

    // MARK: - БАЗА РЕАКЦИЙ
    static let reactions: [ChemicalReaction] = [

        // ================== 1. ВОДА + КИСЛОТА (ОПАСНО!) ==================
        ChemicalReaction(
            reagents: ["H2O", "H2SO4"], products: ["H2SO4"], productNames: ["Серная кислота (разбавленная)"],
            equation: "H₂SO₄ + H₂O → H₂SO₄ (разб.) + Q",
            effect: .explosion, effectColorHex: "#F97316",
            warning: "⚠️ НЕЛЬЗЯ добавлять воду в серную кислоту! Из-за сильного разогрева вода мгновенно вскипает, и кислота разбрызгивается. Правильно: кислоту тонкой струйкой льют В воду при перемешивании."
        ),
        ChemicalReaction(
            reagents: ["H2O", "HCl"], products: ["HCl"], productNames: ["Соляная кислота (разбавленная)"],
            equation: "HCl + H₂O → HCl (разб.) + Q",
            effect: .glow, effectColorHex: "#FCD34D",
            warning: "⚠️ Нельзя лить воду в концентрированную кислоту — бурное выделение тепла может привести к разбрызгиванию. Кислоту добавляют в воду, а не наоборот."
        ),
        ChemicalReaction(
            reagents: ["H2O", "NaOH"], products: ["NaOH"], productNames: ["Гидроксид натрия (раствор)"],
            equation: "NaOH + H₂O → NaOH (р-р) + Q",
            effect: .glow, effectColorHex: "#A78BFA",
            warning: "⚠️ При растворении щёлочи в воде выделяется много тепла. Нельзя добавлять щёлочь в горячую воду — раствор может закипеть и выплеснуться."
        ),
        ChemicalReaction(
            reagents: ["H2O", "KOH"], products: ["KOH"], productNames: ["Гидроксид калия (раствор)"],
            equation: "KOH + H₂O → KOH (р-р) + Q",
            effect: .glow, effectColorHex: "#C084FC",
            warning: "⚠️ Растворение щёлочи в воде сильно экзотермично. Работай в защитных очках, добавляй щёлочь в воду небольшими порциями."
        ),

        // ================== 2. АКТИВНЫЕ МЕТАЛЛЫ + ВОДА (ОПАСНО!) ==================
        ChemicalReaction(
            reagents: ["Na", "H2O"], products: ["NaOH"], productNames: ["Гидроксид натрия"],
            equation: "2Na + 2H₂O → 2NaOH + H₂↑",
            effect: .explosion, effectColorHex: "#F97316",
            warning: "⚠️ Натрий бурно реагирует с водой с выделением водорода. Водород может воспламениться! Опыт проводят только с маленьким кусочком металла под тягой."
        ),
        ChemicalReaction(
            reagents: ["K", "H2O"], products: ["KOH"], productNames: ["Гидроксид калия"],
            equation: "2K + 2H₂O → 2KOH + H₂↑",
            effect: .explosion, effectColorHex: "#DC2626",
            warning: "🚨 ВНИМАНИЕ! Калий реагирует с водой со ВЗРЫВОМ! Реакция сопровождается воспламенением выделяющегося водорода. Опыт крайне опасен."
        ),
        ChemicalReaction(
            reagents: ["Ca", "H2O"], products: ["Ca(OH)2"], productNames: ["Гидроксид кальция"],
            equation: "Ca + 2H₂O → Ca(OH)₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE",
            warning: "⚠️ Кальций реагирует с водой с выделением водорода и тепла. Нельзя брать крупные куски — возможен разогрев и воспламенение газа."
        ),
        ChemicalReaction(
            reagents: ["Ba", "H2O"], products: ["Ba(OH)2"], productNames: ["Гидроксид бария"],
            equation: "Ba + 2H₂O → Ba(OH)₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE",
            warning: "⚠️ Барий — активный металл. Соединения бария ядовиты! Работай под тягой в перчатках."
        ),

        // ================== 3. МЕТАЛЛ + КИСЛОТА ==================
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
            reagents: ["Mg", "HCl"], products: ["MgCl2"], productNames: ["Хлорид магния"],
            equation: "Mg + 2HCl → MgCl₂ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Al", "HCl"], products: ["AlCl3"], productNames: ["Хлорид алюминия"],
            equation: "2Al + 6HCl → 2AlCl₃ + 3H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Zn", "H2SO4"], products: ["ZnSO4"], productNames: ["Сульфат цинка"],
            equation: "Zn + H₂SO₄ → ZnSO₄ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Fe", "H2SO4"], products: ["FeSO4"], productNames: ["Сульфат железа(II)"],
            equation: "Fe + H₂SO₄ → FeSO₄ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),
        ChemicalReaction(
            reagents: ["Mg", "H2SO4"], products: ["MgSO4"], productNames: ["Сульфат магния"],
            equation: "Mg + H₂SO₄ → MgSO₄ + H₂↑",
            effect: .gas, effectColorHex: "#E0F2FE"
        ),

        // ================== 4. МЕТАЛЛ + КИСЛОРОД ==================
        ChemicalReaction(reagents: ["H", "O"], products: ["H2O"], productNames: ["Вода"],
            equation: "2H₂ + O₂ → 2H₂O", effect: .explosion, effectColorHex: "#FCD34D",
            warning: "⚠️ Гремучий газ! Смесь водорода и кислорода взрывается от искры. Опыт очень опасен."),
        ChemicalReaction(reagents: ["Na", "O"], products: ["Na2O"], productNames: ["Оксид натрия"],
            equation: "4Na + O₂ → 2Na₂O", effect: .flash, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["K", "O"], products: ["K2O"], productNames: ["Оксид калия"],
            equation: "4K + O₂ → 2K₂O", effect: .flash, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["Mg", "O"], products: ["MgO"], productNames: ["Оксид магния"],
            equation: "2Mg + O₂ → 2MgO", effect: .flash, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Ca", "O"], products: ["CaO"], productNames: ["Оксид кальция"],
            equation: "2Ca + O₂ → 2CaO", effect: .glow, effectColorHex: "#FCD34D"),
        ChemicalReaction(reagents: ["Al", "O"], products: ["Al2O3"], productNames: ["Оксид алюминия"],
            equation: "4Al + 3O₂ → 2Al₂O₃", effect: .flash, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["Fe", "O"], products: ["Fe2O3"], productNames: ["Оксид железа(III)"],
            equation: "4Fe + 3O₂ → 2Fe₂O₃", effect: .explosion, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["Cu", "O"], products: ["CuO"], productNames: ["Оксид меди(II)"],
            equation: "2Cu + O₂ → 2CuO", effect: .colorChange, effectColorHex: "#1F2937"),
        ChemicalReaction(reagents: ["Zn", "O"], products: ["ZnO"], productNames: ["Оксид цинка"],
            equation: "2Zn + O₂ → 2ZnO", effect: .glow, effectColorHex: "#E5E7EB"),
        ChemicalReaction(reagents: ["S", "O"], products: ["SO2"], productNames: ["Оксид серы(IV)"],
            equation: "S + O₂ → SO₂", effect: .gas, effectColorHex: "#CBD5E1"),
        ChemicalReaction(reagents: ["C", "O"], products: ["CO2"], productNames: ["Оксид углерода(IV)"],
            equation: "C + O₂ → CO₂", effect: .glow, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["P", "O"], products: ["P2O5"], productNames: ["Оксид фосфора(V)"],
            equation: "4P + 5O₂ → 2P₂O₅", effect: .flash, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["N", "O"], products: ["NO"], productNames: ["Оксид азота(II)"],
            equation: "N₂ + O₂ → 2NO", effect: .glow, effectColorHex: "#3B82F6"),

        // ================== 5. С ХЛОРОМ ==================
        ChemicalReaction(reagents: ["Na", "Cl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "2Na + Cl₂ → 2NaCl", effect: .flash, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["H", "Cl"], products: ["HCl"], productNames: ["Соляная кислота"],
            equation: "H₂ + Cl₂ → 2HCl", effect: .explosion, effectColorHex: "#FEF08A"),
        ChemicalReaction(reagents: ["Fe", "Cl"], products: ["FeCl3"], productNames: ["Хлорид железа(III)"],
            equation: "2Fe + 3Cl₂ → 2FeCl₃", effect: .flash, effectColorHex: "#F97316"),
        ChemicalReaction(reagents: ["Cu", "Cl"], products: ["CuCl2"], productNames: ["Хлорид меди(II)"],
            equation: "Cu + Cl₂ → CuCl₂", effect: .glow, effectColorHex: "#0891B2"),

        // ================== 6. С СЕРОЙ ==================
        ChemicalReaction(reagents: ["Fe", "S"], products: ["FeS"], productNames: ["Сульфид железа(II)"],
            equation: "Fe + S → FeS", effect: .glow, effectColorHex: "#7C2D12"),
        ChemicalReaction(reagents: ["Cu", "S"], products: ["CuS"], productNames: ["Сульфид меди(II)"],
            equation: "Cu + S → CuS", effect: .glow, effectColorHex: "#0F172A"),
        ChemicalReaction(reagents: ["Zn", "S"], products: ["ZnS"], productNames: ["Сульфид цинка"],
            equation: "Zn + S → ZnS", effect: .glow, effectColorHex: "#E5E7EB"),

        // ================== 7. КИСЛОТА + ОСНОВАНИЕ ==================
        ChemicalReaction(reagents: ["NaOH", "HCl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "NaOH + HCl → NaCl + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["KOH", "HCl"], products: ["KCl"], productNames: ["Хлорид калия"],
            equation: "KOH + HCl → KCl + H₂O", effect: .glow, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["NaOH", "H2SO4"], products: ["Na2SO4"], productNames: ["Сульфат натрия"],
            equation: "2NaOH + H₂SO₄ → Na₂SO₄ + 2H₂O", effect: .glow, effectColorHex: "#FEF3C7"),

        // ================== 8. КАРБОНАТЫ + КИСЛОТЫ ==================
        ChemicalReaction(reagents: ["CaCO3", "HCl"], products: ["CaCl2"], productNames: ["Хлорид кальция"],
            equation: "CaCO₃ + 2HCl → CaCl₂ + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
        ChemicalReaction(reagents: ["Na2CO3", "HCl"], products: ["NaCl"], productNames: ["Хлорид натрия"],
            equation: "Na₂CO₃ + 2HCl → 2NaCl + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),

        // ================== 9. ОСАДКИ (ионный обмен) ==================
        ChemicalReaction(reagents: ["CuSO4", "NaOH"], products: ["Cu(OH)2"], productNames: ["Гидроксид меди(II)"],
            equation: "CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄", effect: .precipitateBlue, effectColorHex: "#3B82F6"),
        ChemicalReaction(reagents: ["AgNO3", "NaCl"], products: ["AgCl"], productNames: ["Хлорид серебра"],
            equation: "AgNO₃ + NaCl → AgCl↓ + NaNO₃", effect: .precipitateWhite, effectColorHex: "#F8FAFC"),
        ChemicalReaction(reagents: ["BaCl2", "Na2SO4"], products: ["BaSO4"], productNames: ["Сульфат бария"],
            equation: "BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["FeCl3", "NaOH"], products: ["Fe(OH)3"], productNames: ["Гидроксид железа(III)"],
            equation: "FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl", effect: .precipitateBrown, effectColorHex: "#92400E"),
        ChemicalReaction(reagents: ["AgNO3", "HCl"], products: ["AgCl"], productNames: ["Хлорид серебра"],
            equation: "AgNO₃ + HCl → AgCl↓ + HNO₃", effect: .precipitateWhite, effectColorHex: "#FFFFFF"),
        ChemicalReaction(reagents: ["CuCl2", "NaOH"], products: ["Cu(OH)2"], productNames: ["Гидроксид меди(II)"],
            equation: "CuCl₂ + 2NaOH → Cu(OH)₂↓ + 2NaCl", effect: .precipitateBlue, effectColorHex: "#3B82F6"),

        // ================== 10. ЗАМЕЩЕНИЕ ==================
        ChemicalReaction(reagents: ["Fe", "CuSO4"], products: ["Cu"], productNames: ["Медь"],
            equation: "Fe + CuSO₄ → FeSO₄ + Cu", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["Zn", "CuSO4"], products: ["Cu"], productNames: ["Медь"],
            equation: "Zn + CuSO₄ → ZnSO₄ + Cu", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["Cu", "AgNO3"], products: ["Ag"], productNames: ["Серебро"],
            equation: "Cu + 2AgNO₃ → Cu(NO₃)₂ + 2Ag", effect: .colorChange, effectColorHex: "#CBD5E1"),
        ChemicalReaction(reagents: ["Al", "CuCl2"], products: ["AlCl3"], productNames: ["Хлорид алюминия"],
            equation: "2Al + 3CuCl₂ → 2AlCl₃ + 3Cu", effect: .colorChange, effectColorHex: "#DC2626"),

        // ================== 11. ВОССТАНОВЛЕНИЕ ОКСИДОВ ==================
        ChemicalReaction(reagents: ["CuO", "H"], products: ["Cu"], productNames: ["Медь"],
            equation: "CuO + H₂ → Cu + H₂O", effect: .colorChange, effectColorHex: "#EA580C"),
        ChemicalReaction(reagents: ["Fe2O3", "H"], products: ["Fe"], productNames: ["Железо"],
            equation: "Fe₂O₃ + 3H₂ → 2Fe + 3H₂O", effect: .glow, effectColorHex: "#B45309"),

        // ================== 12. ОКСИД + ВОДА ==================
        ChemicalReaction(reagents: ["CaO", "H2O"], products: ["Ca(OH)2"], productNames: ["Гидроксид кальция"],
            equation: "CaO + H₂O → Ca(OH)₂ + Q", effect: .glow, effectColorHex: "#FCD34D",
            warning: "⚠️ Реакция очень экзотическая — «гашение извести». Выделяется много тепла, вода может вскипеть. Не трогай получившийся раствор руками."),
        ChemicalReaction(reagents: ["CO2", "H2O"], products: ["H2CO3"], productNames: ["Угольная кислота"],
            equation: "CO₂ + H₂O ⇄ H₂CO₃", effect: .glow, effectColorHex: "#94A3B8"),

        // ================== 13. ОРГАНИКА (10 класс) ==================
        ChemicalReaction(reagents: ["C2H4", "Br"], products: ["C2H4Br2"], productNames: ["1,2-дибромэтан"],
            equation: "CH₂=CH₂ + Br₂ → CH₂Br–CH₂Br", effect: .colorChange, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["C2H2", "Br"], products: ["C2H2Br2"], productNames: ["1,2-дибромэтен"],
            equation: "CH≡CH + Br₂ → CHBr=CHBr", effect: .colorChange, effectColorHex: "#FEF3C7"),
        ChemicalReaction(reagents: ["C2H5OH", "CuO"], products: ["CH3CHO"], productNames: ["Ацетальдегид"],
            equation: "C₂H₅OH + CuO → CH₃CHO + Cu + H₂O", effect: .colorChange, effectColorHex: "#DC2626"),
        ChemicalReaction(reagents: ["C2H5OH", "Na"], products: ["C2H5ONa"], productNames: ["Этилат натрия"],
            equation: "2C₂H₅OH + 2Na → 2C₂H₅ONa + H₂↑", effect: .gas, effectColorHex: "#E0F2FE",
            warning: "⚠️ Натрий с этанолом реагирует так же бурно, как с водой! Может воспламениться водород. Работай с маленькими кусочками."),
        ChemicalReaction(reagents: ["CH4", "O"], products: ["CO2"], productNames: ["Оксид углерода(IV)"],
            equation: "CH₄ + 2O₂ → CO₂ + 2H₂O", effect: .explosion, effectColorHex: "#F97316",
            warning: "🚨 ВНИМАНИЕ! Метан с кислородом образует взрывоопасную смесь — гремучий газ! При поджигании — сильнейший взрыв."),
        ChemicalReaction(reagents: ["C2H4", "H"], products: ["C2H6"], productNames: ["Этан"],
            equation: "CH₂=CH₂ + H₂ → CH₃–CH₃", effect: .glow, effectColorHex: "#84CC16"),
        ChemicalReaction(reagents: ["CH3COOH", "NaOH"], products: ["CH3COONa"], productNames: ["Ацетат натрия"],
            equation: "CH₃COOH + NaOH → CH₃COONa + H₂O", effect: .glow, effectColorHex: "#BEF264"),
        ChemicalReaction(reagents: ["CH3COOH", "Na2CO3"], products: ["CH3COONa"], productNames: ["Ацетат натрия"],
            equation: "2CH₃COOH + Na₂CO₃ → 2CH₃COONa + H₂O + CO₂↑", effect: .gas, effectColorHex: "#F1F5F9"),
    ]

    static func findReaction(_ a: String, _ b: String) -> ChemicalReaction? {
        let pair: Set<String> = [a, b]
        return reactions.first { $0.reagents == pair }
    }
}
