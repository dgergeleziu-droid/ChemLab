import SwiftUI

struct ElementInfo {
    let number: Int
    let symbol: String
    let name: String
    let mass: String
    let category: ElementCategory
    let row: Int  // Период / подуровень (0-8)
    let col: Int  // Группа (1-18)
}

enum ElementCategory {
    case alkaliMetal     // Щелочные металлы
    case alkalineEarth   // Щёлочноземельные
    case transitionMetal // Переходные металлы
    case postTransition  // Постпереходные металлы
    case metalloid       // Полуметаллы
    case nonmetal        // Неметаллы
    case halogen         // Галогены
    case nobleGas        // Благородные газы
    case lanthanide      // Лантаноиды
    case actinide        // Актиноиды
    case unknown         // Неизвестные

    var color: String {
        switch self {
        case .alkaliMetal:     return "#F87171"  // светло-красный
        case .alkalineEarth:   return "#FB923C"  // оранжевый
        case .transitionMetal: return "#3B82F6"  // синий
        case .postTransition:  return "#60A5FA"  // голубой
        case .metalloid:       return "#FBBF24"  // жёлтый
        case .nonmetal:        return "#F97316"  // оранжево-красный
        case .halogen:         return "#F43F5E"  // розово-красный
        case .nobleGas:        return "#A78BFA"  // фиолетовый
        case .lanthanide:      return "#22D3EE"  // голубой
        case .actinide:        return "#2DD4BF"  // бирюзовый
        case .unknown:         return "#94A3B8"  // серый
        }
    }

    var label: String {
        switch self {
        case .alkaliMetal:     return "Щелочные"
        case .alkalineEarth:   return "Щёлочнозем."
        case .transitionMetal: return "Переходные"
        case .postTransition:  return "Постпереход."
        case .metalloid:       return "Полуметаллы"
        case .nonmetal:        return "Неметаллы"
        case .halogen:         return "Галогены"
        case .nobleGas:        return "Благородные"
        case .lanthanide:      return "Лантаноиды"
        case .actinide:        return "Актиноиды"
        case .unknown:         return "Прочие"
        }
    }
}

struct PeriodicTableView: View {
    let onSelect: (Reagent) -> Void
    let onClose: () -> Void

    @State private var tappedSymbol: String? = nil
    @State private var lastAddedName: String? = nil
    @State private var addedCount: Int = 0
    @State private var showLegend = true

    // Все элементы с правильными данными
    static let elements: [ElementInfo] = [
        // Период 1
        ElementInfo(number: 1, symbol: "H", name: "Водород", mass: "1.008", category: .nonmetal, row: 0, col: 1),
        ElementInfo(number: 2, symbol: "He", name: "Гелий", mass: "4.003", category: .nobleGas, row: 0, col: 18),

        // Период 2
        ElementInfo(number: 3, symbol: "Li", name: "Литий", mass: "6.94", category: .alkaliMetal, row: 1, col: 1),
        ElementInfo(number: 4, symbol: "Be", name: "Бериллий", mass: "9.012", category: .alkalineEarth, row: 1, col: 2),
        ElementInfo(number: 5, symbol: "B", name: "Бор", mass: "10.81", category: .metalloid, row: 1, col: 13),
        ElementInfo(number: 6, symbol: "C", name: "Углерод", mass: "12.011", category: .nonmetal, row: 1, col: 14),
        ElementInfo(number: 7, symbol: "N", name: "Азот", mass: "14.007", category: .nonmetal, row: 1, col: 15),
        ElementInfo(number: 8, symbol: "O", name: "Кислород", mass: "15.999", category: .nonmetal, row: 1, col: 16),
        ElementInfo(number: 9, symbol: "F", name: "Фтор", mass: "18.998", category: .halogen, row: 1, col: 17),
        ElementInfo(number: 10, symbol: "Ne", name: "Неон", mass: "20.180", category: .nobleGas, row: 1, col: 18),

        // Период 3
        ElementInfo(number: 11, symbol: "Na", name: "Натрий", mass: "22.990", category: .alkaliMetal, row: 2, col: 1),
        ElementInfo(number: 12, symbol: "Mg", name: "Магний", mass: "24.305", category: .alkalineEarth, row: 2, col: 2),
        ElementInfo(number: 13, symbol: "Al", name: "Алюминий", mass: "26.982", category: .postTransition, row: 2, col: 13),
        ElementInfo(number: 14, symbol: "Si", name: "Кремний", mass: "28.085", category: .metalloid, row: 2, col: 14),
        ElementInfo(number: 15, symbol: "P", name: "Фосфор", mass: "30.974", category: .nonmetal, row: 2, col: 15),
        ElementInfo(number: 16, symbol: "S", name: "Сера", mass: "32.06", category: .nonmetal, row: 2, col: 16),
        ElementInfo(number: 17, symbol: "Cl", name: "Хлор", mass: "35.45", category: .halogen, row: 2, col: 17),
        ElementInfo(number: 18, symbol: "Ar", name: "Аргон", mass: "39.948", category: .nobleGas, row: 2, col: 18),

        // Период 4
        ElementInfo(number: 19, symbol: "K", name: "Калий", mass: "39.098", category: .alkaliMetal, row: 3, col: 1),
        ElementInfo(number: 20, symbol: "Ca", name: "Кальций", mass: "40.078", category: .alkalineEarth, row: 3, col: 2),
        ElementInfo(number: 21, symbol: "Sc", name: "Скандий", mass: "44.956", category: .transitionMetal, row: 3, col: 3),
        ElementInfo(number: 22, symbol: "Ti", name: "Титан", mass: "47.867", category: .transitionMetal, row: 3, col: 4),
        ElementInfo(number: 23, symbol: "V", name: "Ванадий", mass: "50.942", category: .transitionMetal, row: 3, col: 5),
        ElementInfo(number: 24, symbol: "Cr", name: "Хром", mass: "51.996", category: .transitionMetal, row: 3, col: 6),
        ElementInfo(number: 25, symbol: "Mn", name: "Марганец", mass: "54.938", category: .transitionMetal, row: 3, col: 7),
        ElementInfo(number: 26, symbol: "Fe", name: "Железо", mass: "55.845", category: .transitionMetal, row: 3, col: 8),
        ElementInfo(number: 27, symbol: "Co", name: "Кобальт", mass: "58.933", category: .transitionMetal, row: 3, col: 9),
        ElementInfo(number: 28, symbol: "Ni", name: "Никель", mass: "58.693", category: .transitionMetal, row: 3, col: 10),
        ElementInfo(number: 29, symbol: "Cu", name: "Медь", mass: "63.546", category: .transitionMetal, row: 3, col: 11),
        ElementInfo(number: 30, symbol: "Zn", name: "Цинк", mass: "65.38", category: .transitionMetal, row: 3, col: 12),
        ElementInfo(number: 31, symbol: "Ga", name: "Галлий", mass: "69.723", category: .postTransition, row: 3, col: 13),
        ElementInfo(number: 32, symbol: "Ge", name: "Германий", mass: "72.630", category: .metalloid, row: 3, col: 14),
        ElementInfo(number: 33, symbol: "As", name: "Мышьяк", mass: "74.922", category: .metalloid, row: 3, col: 15),
        ElementInfo(number: 34, symbol: "Se", name: "Селен", mass: "78.971", category: .nonmetal, row: 3, col: 16),
        ElementInfo(number: 35, symbol: "Br", name: "Бром", mass: "79.904", category: .halogen, row: 3, col: 17),
        ElementInfo(number: 36, symbol: "Kr", name: "Криптон", mass: "83.798", category: .nobleGas, row: 3, col: 18),

        // Период 5
        ElementInfo(number: 37, symbol: "Rb", name: "Рубидий", mass: "85.468", category: .alkaliMetal, row: 4, col: 1),
        ElementInfo(number: 38, symbol: "Sr", name: "Стронций", mass: "87.62", category: .alkalineEarth, row: 4, col: 2),
        ElementInfo(number: 39, symbol: "Y", name: "Иттрий", mass: "88.906", category: .transitionMetal, row: 4, col: 3),
        ElementInfo(number: 40, symbol: "Zr", name: "Цирконий", mass: "91.224", category: .transitionMetal, row: 4, col: 4),
        ElementInfo(number: 41, symbol: "Nb", name: "Ниобий", mass: "92.906", category: .transitionMetal, row: 4, col: 5),
        ElementInfo(number: 42, symbol: "Mo", name: "Молибден", mass: "95.95", category: .transitionMetal, row: 4, col: 6),
        ElementInfo(number: 43, symbol: "Tc", name: "Технеций", mass: "(98)", category: .transitionMetal, row: 4, col: 7),
        ElementInfo(number: 44, symbol: "Ru", name: "Рутений", mass: "101.07", category: .transitionMetal, row: 4, col: 8),
        ElementInfo(number: 45, symbol: "Rh", name: "Родий", mass: "102.91", category: .transitionMetal, row: 4, col: 9),
        ElementInfo(number: 46, symbol: "Pd", name: "Палладий", mass: "106.42", category: .transitionMetal, row: 4, col: 10),
        ElementInfo(number: 47, symbol: "Ag", name: "Серебро", mass: "107.87", category: .transitionMetal, row: 4, col: 11),
        ElementInfo(number: 48, symbol: "Cd", name: "Кадмий", mass: "112.41", category: .transitionMetal, row: 4, col: 12),
        ElementInfo(number: 49, symbol: "In", name: "Индий", mass: "114.82", category: .postTransition, row: 4, col: 13),
        ElementInfo(number: 50, symbol: "Sn", name: "Олово", mass: "118.71", category: .postTransition, row: 4, col: 14),
        ElementInfo(number: 51, symbol: "Sb", name: "Сурьма", mass: "121.76", category: .metalloid, row: 4, col: 15),
        ElementInfo(number: 52, symbol: "Te", name: "Теллур", mass: "127.60", category: .metalloid, row: 4, col: 16),
        ElementInfo(number: 53, symbol: "I", name: "Иод", mass: "126.90", category: .halogen, row: 4, col: 17),
        ElementInfo(number: 54, symbol: "Xe", name: "Ксенон", mass: "131.29", category: .nobleGas, row: 4, col: 18),

        // Период 6
        ElementInfo(number: 55, symbol: "Cs", name: "Цезий", mass: "132.91", category: .alkaliMetal, row: 5, col: 1),
        ElementInfo(number: 56, symbol: "Ba", name: "Барий", mass: "137.33", category: .alkalineEarth, row: 5, col: 2),
        ElementInfo(number: 57, symbol: "La", name: "Лантан", mass: "138.91", category: .lanthanide, row: 7, col: 3),
        ElementInfo(number: 58, symbol: "Ce", name: "Церий", mass: "140.12", category: .lanthanide, row: 7, col: 4),
        ElementInfo(number: 59, symbol: "Pr", name: "Празеодим", mass: "140.91", category: .lanthanide, row: 7, col: 5),
        ElementInfo(number: 60, symbol: "Nd", name: "Неодим", mass: "144.24", category: .lanthanide, row: 7, col: 6),
        ElementInfo(number: 61, symbol: "Pm", name: "Прометий", mass: "(145)", category: .lanthanide, row: 7, col: 7),
        ElementInfo(number: 62, symbol: "Sm", name: "Самарий", mass: "150.36", category: .lanthanide, row: 7, col: 8),
        ElementInfo(number: 63, symbol: "Eu", name: "Европий", mass: "151.96", category: .lanthanide, row: 7, col: 9),
        ElementInfo(number: 64, symbol: "Gd", name: "Гадолиний", mass: "157.25", category: .lanthanide, row: 7, col: 10),
        ElementInfo(number: 65, symbol: "Tb", name: "Тербий", mass: "158.93", category: .lanthanide, row: 7, col: 11),
        ElementInfo(number: 66, symbol: "Dy", name: "Диспрозий", mass: "162.50", category: .lanthanide, row: 7, col: 12),
        ElementInfo(number: 67, symbol: "Ho", name: "Гольмий", mass: "164.93", category: .lanthanide, row: 7, col: 13),
        ElementInfo(number: 68, symbol: "Er", name: "Эрбий", mass: "167.26", category: .lanthanide, row: 7, col: 14),
        ElementInfo(number: 69, symbol: "Tm", name: "Тулий", mass: "168.93", category: .lanthanide, row: 7, col: 15),
        ElementInfo(number: 70, symbol: "Yb", name: "Иттербий", mass: "173.05", category: .lanthanide, row: 7, col: 16),
        ElementInfo(number: 71, symbol: "Lu", name: "Лютеций", mass: "174.97", category: .lanthanide, row: 7, col: 17),
        ElementInfo(number: 72, symbol: "Hf", name: "Гафний", mass: "178.49", category: .transitionMetal, row: 5, col: 4),
        ElementInfo(number: 73, symbol: "Ta", name: "Тантал", mass: "180.95", category: .transitionMetal, row: 5, col: 5),
        ElementInfo(number: 74, symbol: "W", name: "Вольфрам", mass: "183.84", category: .transitionMetal, row: 5, col: 6),
        ElementInfo(number: 75, symbol: "Re", name: "Рений", mass: "186.21", category: .transitionMetal, row: 5, col: 7),
        ElementInfo(number: 76, symbol: "Os", name: "Осмий", mass: "190.23", category: .transitionMetal, row: 5, col: 8),
        ElementInfo(number: 77, symbol: "Ir", name: "Иридий", mass: "192.22", category: .transitionMetal, row: 5, col: 9),
        ElementInfo(number: 78, symbol: "Pt", name: "Платина", mass: "195.08", category: .transitionMetal, row: 5, col: 10),
        ElementInfo(number: 79, symbol: "Au", name: "Золото", mass: "196.97", category: .transitionMetal, row: 5, col: 11),
        ElementInfo(number: 80, symbol: "Hg", name: "Ртуть", mass: "200.59", category: .transitionMetal, row: 5, col: 12),
        ElementInfo(number: 81, symbol: "Tl", name: "Таллий", mass: "204.38", category: .postTransition, row: 5, col: 13),
        ElementInfo(number: 82, symbol: "Pb", name: "Свинец", mass: "207.2", category: .postTransition, row: 5, col: 14),
        ElementInfo(number: 83, symbol: "Bi", name: "Висмут", mass: "208.98", category: .postTransition, row: 5, col: 15),
        ElementInfo(number: 84, symbol: "Po", name: "Полоний", mass: "(209)", category: .postTransition, row: 5, col: 16),
        ElementInfo(number: 85, symbol: "At", name: "Астат", mass: "(210)", category: .halogen, row: 5, col: 17),
        ElementInfo(number: 86, symbol: "Rn", name: "Радон", mass: "(222)", category: .nobleGas, row: 5, col: 18),

        // Период 7
        ElementInfo(number: 87, symbol: "Fr", name: "Франций", mass: "(223)", category: .alkaliMetal, row: 6, col: 1),
        ElementInfo(number: 88, symbol: "Ra", name: "Радий", mass: "(226)", category: .alkalineEarth, row: 6, col: 2),
        ElementInfo(number: 89, symbol: "Ac", name: "Актиний", mass: "(227)", category: .actinide, row: 8, col: 3),
        ElementInfo(number: 90, symbol: "Th", name: "Торий", mass: "232.04", category: .actinide, row: 8, col: 4),
        ElementInfo(number: 91, symbol: "Pa", name: "Протактиний", mass: "231.04", category: .actinide, row: 8, col: 5),
        ElementInfo(number: 92, symbol: "U", name: "Уран", mass: "238.03", category: .actinide, row: 8, col: 6),
        ElementInfo(number: 93, symbol: "Np", name: "Нептуний", mass: "(237)", category: .actinide, row: 8, col: 7),
        ElementInfo(number: 94, symbol: "Pu", name: "Плутоний", mass: "(244)", category: .actinide, row: 8, col: 8),
        ElementInfo(number: 95, symbol: "Am", name: "Америций", mass: "(243)", category: .actinide, row: 8, col: 9),
        ElementInfo(number: 96, symbol: "Cm", name: "Кюрий", mass: "(247)", category: .actinide, row: 8, col: 10),
        ElementInfo(number: 97, symbol: "Bk", name: "Берклий", mass: "(247)", category: .actinide, row: 8, col: 11),
        ElementInfo(number: 98, symbol: "Cf", name: "Калифорний", mass: "(251)", category: .actinide, row: 8, col: 12),
        ElementInfo(number: 99, symbol: "Es", name: "Эйнштейний", mass: "(252)", category: .actinide, row: 8, col: 13),
        ElementInfo(number: 100, symbol: "Fm", name: "Фермий", mass: "(257)", category: .actinide, row: 8, col: 14),
        ElementInfo(number: 101, symbol: "Md", name: "Менделевий", mass: "(258)", category: .actinide, row: 8, col: 15),
        ElementInfo(number: 102, symbol: "No", name: "Нобелий", mass: "(259)", category: .actinide, row: 8, col: 16),
        ElementInfo(number: 103, symbol: "Lr", name: "Лоуренсий", mass: "(266)", category: .actinide, row: 8, col: 17),
        ElementInfo(number: 104, symbol: "Rf", name: "Резерфордий", mass: "(267)", category: .transitionMetal, row: 6, col: 4),
        ElementInfo(number: 105, symbol: "Db", name: "Дубний", mass: "(268)", category: .transitionMetal, row: 6, col: 5),
        ElementInfo(number: 106, symbol: "Sg", name: "Сиборгий", mass: "(269)", category: .transitionMetal, row: 6, col: 6),
        ElementInfo(number: 107, symbol: "Bh", name: "Борий", mass: "(270)", category: .transitionMetal, row: 6, col: 7),
        ElementInfo(number: 108, symbol: "Hs", name: "Хассий", mass: "(269)", category: .transitionMetal, row: 6, col: 8),
        ElementInfo(number: 109, symbol: "Mt", name: "Мейтнерий", mass: "(278)", category: .unknown, row: 6, col: 9),
        ElementInfo(number: 110, symbol: "Ds", name: "Дармштадтий", mass: "(281)", category: .unknown, row: 6, col: 10),
        ElementInfo(number: 111, symbol: "Rg", name: "Рентгений", mass: "(282)", category: .unknown, row: 6, col: 11),
        ElementInfo(number: 112, symbol: "Cn", name: "Коперниций", mass: "(285)", category: .transitionMetal, row: 6, col: 12),
        ElementInfo(number: 113, symbol: "Nh", name: "Нихоний", mass: "(286)", category: .unknown, row: 6, col: 13),
        ElementInfo(number: 114, symbol: "Fl", name: "Флеровий", mass: "(289)", category: .unknown, row: 6, col: 14),
        ElementInfo(number: 115, symbol: "Mc", name: "Московий", mass: "(290)", category: .unknown, row: 6, col: 15),
        ElementInfo(number: 116, symbol: "Lv", name: "Ливерморий", mass: "(293)", category: .unknown, row: 6, col: 16),
        ElementInfo(number: 117, symbol: "Ts", name: "Теннессин", mass: "(294)", category: .halogen, row: 6, col: 17),
        ElementInfo(number: 118, symbol: "Og", name: "Оганесон", mass: "(294)", category: .nobleGas, row: 6, col: 18)
    ]

    static let cellSize: CGFloat = 46
    static let gap: CGFloat = 3

    // Быстрый поиск
    static let elementMap: [Int: ElementInfo] = {
        var map: [Int: ElementInfo] = [:]
        for e in elements {
            map[e.row * 100 + e.col] = e
        }
        return map
    }()

    var body: some View {
        ZStack {
            Color(hex: "#0B1020").ignoresSafeArea()

            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Периодическая система")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Д. И. Менделеева · 118 элементов")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showLegend.toggle() }
                    } label: {
                        Image(systemName: showLegend ? "eye.slash" : "eye")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "#1E293B"))
                            .clipShape(Circle())
                    }
                    Button(action: onClose) {
                        ZStack {
                            Circle().fill(Color(hex: "#1E293B")).frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

                // Легенда (сворачиваемая)
                if showLegend {
                    legendView
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Таблица
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    periodicTableGrid
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }

                // Подсказка снизу
                if let name = lastAddedName {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#22C55E"))
                        Text("Добавлено: \(name)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B"))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                    .transition(.opacity)
                } else if addedCount > 0 {
                    Text("Всего добавлено: \(addedCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Легенда
    var legendView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                legendItem(.alkaliMetal)
                legendItem(.alkalineEarth)
                legendItem(.transitionMetal)
                legendItem(.postTransition)
                legendItem(.metalloid)
                legendItem(.nonmetal)
                legendItem(.halogen)
                legendItem(.nobleGas)
                legendItem(.lanthanide)
                legendItem(.actinide)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    func legendItem(_ cat: ElementCategory) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: cat.color))
                .frame(width: 12, height: 12)
            Text(cat.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "#94A3B8"))
        }
    }

    // MARK: - Сетка таблицы
    var periodicTableGrid: some View {
        let totalCols = 18
        let cellSize = Self.cellSize
        let gap = Self.gap

        return VStack(spacing: gap) {
            // Номера групп сверху
            HStack(spacing: gap) {
                // Пустой угол
                Color.clear.frame(width: 30, height: 18)
                ForEach(1...totalCols, id: \.self) { col in
                    Text("\(col)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#64748B"))
                        .frame(width: cellSize, height: 18)
                }
            }

            // Периоды 1-7
            ForEach(0...6, id: \.self) { row in
                HStack(spacing: gap) {
                    // Номер периода слева
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#1E293B"))
                        Text("\(row + 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    .frame(width: 30, height: cellSize)

                    ForEach(1...totalCols, id: \.self) { col in
                        if let element = Self.elementMap[row * 100 + col] {
                            cellView(element)
                        } else {
                            Color.clear.frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }

            // Разделитель
            Color.clear.frame(height: 12)

            // Лантаноиды (строка 7)
            HStack(spacing: gap) {
                // Пустой угол с "*"
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#1E293B"))
                    Text("6*")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "#22D3EE"))
                }
                .frame(width: 30, height: cellSize)

                ForEach(1...totalCols, id: \.self) { col in
                    if let element = Self.elementMap[7 * 100 + col] {
                        cellView(element)
                    } else {
                        Color.clear.frame(width: cellSize, height: cellSize)
                    }
                }
            }

            // Актиноиды (строка 8)
            HStack(spacing: gap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#1E293B"))
                    Text("7*")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "#2DD4BF"))
                }
                .frame(width: 30, height: cellSize)

                ForEach(1...totalCols, id: \.self) { col in
                    if let element = Self.elementMap[8 * 100 + col] {
                        cellView(element)
                    } else {
                        Color.clear.frame(width: cellSize, height: cellSize)
                    }
                }
            }

            // Подписи периодов снизу
            HStack(spacing: gap) {
                Color.clear.frame(width: 30, height: 18)
                Text("← Группы →")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#475569"))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Ячейка элемента
    func cellView(_ element: ElementInfo) -> some View {
        let cellSize = Self.cellSize
        let isTapped = tappedSymbol == element.symbol
        let bgColor = Color(hex: element.category.color)
        // Определяем, светлый ли цвет — для читабельности текста
        let isLight = [ElementCategory.metalloid, ElementCategory.alkalineEarth].contains(element.category)

        return Button {
            handleTap(element)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(bgColor.opacity(isTapped ? 1.0 : 0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isTapped ? Color.white : Color.white.opacity(0.25),
                                    lineWidth: isTapped ? 2 : 0.5)
                    )
                    .shadow(color: bgColor.opacity(0.4), radius: isTapped ? 6 : 2)

                // Содержимое ячейки
                VStack(spacing: 0) {
                    // Порядковый номер (сверху слева)
                    HStack {
                        Text("\(element.number)")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(isLight ? Color.black.opacity(0.7) : Color.white.opacity(0.85))
                        Spacer()
                    }
                    .padding(.horizontal, 3)
                    .padding(.top, 2)

                    Spacer(minLength: 0)

                    // Символ (по центру)
                    Text(element.symbol)
                        .font(.system(size: element.symbol.count > 1 ? 16 : 18, weight: .bold))
                        .foregroundColor(isLight ? .black : .white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    // Атомная масса (снизу)
                    Text(element.mass)
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(isLight ? Color.black.opacity(0.65) : Color.white.opacity(0.75))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                }
                .padding(.horizontal, 2)
            }
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(isTapped ? 1.18 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isTapped)
        }
        .buttonStyle(.plain)
    }

    func handleTap(_ element: ElementInfo) {
        // Ищем в базе реагентов
        if let reagent = ChemistryData.findReagent(by: element.symbol) {
            onSelect(reagent)
        } else {
            // Если нет в базе — создаём временный
            let fallback = Reagent(symbol: element.symbol, name: element.name,
                                   colorHex: element.category.color, group: .elements)
            onSelect(fallback)
        }

        tappedSymbol = element.symbol
        addedCount += 1

        withAnimation(.easeOut(duration: 0.15)) {
            lastAddedName = element.name
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if tappedSymbol == element.symbol {
                withAnimation(.easeOut(duration: 0.2)) { tappedSymbol = nil }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                if lastAddedName == element.name { lastAddedName = nil }
            }
        }
    }
}
