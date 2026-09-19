import SwiftUI

struct ElementInfo {
    let number: Int
    let symbol: String
    let name: String
    let mass: String
    let isMetal: Bool
}

struct PeriodicTableView: View {
    let onSelect: (Reagent) -> Void
    let onClose: () -> Void

    @State private var tappedSymbol: String? = nil
    @State private var lastAddedName: String? = nil
    @State private var addedCount: Int = 0

    static let metalBlue = "#2563EB"
    static let nonMetalOrange = "#F97316"

    // MARK: - Таблица (визуальные ряды 0..13, столбцы 0..9)
    // Столбцы: 0=I, 1=II, 2=III, 3=IV, 4=V, 5=VI, 6=VII, 7=VIII-1, 8=VIII-2, 9=VIII-3

    static let grid: [[ElementInfo?]] = [
        // Ряд 0: Период 1
        [
            el(1,"H","Водород","1.008",false),
            nil, nil, nil, nil, nil, nil,
            nil, nil,
            el(2,"He","Гелий","4.003",false)
        ],
        // Ряд 1: Период 2
        [
            el(3,"Li","Литий","6.94",true),
            el(4,"Be","Бериллий","9.012",true),
            el(5,"B","Бор","10.81",false),
            el(6,"C","Углерод","12.011",false),
            el(7,"N","Азот","14.007",false),
            el(8,"O","Кислород","15.999",false),
            el(9,"F","Фтор","18.998",false),
            nil, nil,
            el(10,"Ne","Неон","20.180",false)
        ],
        // Ряд 2: Период 3
        [
            el(11,"Na","Натрий","22.990",true),
            el(12,"Mg","Магний","24.305",true),
            el(13,"Al","Алюминий","26.982",true),
            el(14,"Si","Кремний","28.085",false),
            el(15,"P","Фосфор","30.974",false),
            el(16,"S","Сера","32.06",false),
            el(17,"Cl","Хлор","35.45",false),
            nil, nil,
            el(18,"Ar","Аргон","39.948",false)
        ],
        // Ряд 3: Период 4 — A-подгруппа (K, Ca, Sc..Mn) + Fe Co Ni
        [
            el(19,"K","Калий","39.098",true),
            el(20,"Ca","Кальций","40.078",true),
            el(21,"Sc","Скандий","44.956",true),
            el(22,"Ti","Титан","47.867",true),
            el(23,"V","Ванадий","50.942",true),
            el(24,"Cr","Хром","51.996",true),
            el(25,"Mn","Марганец","54.938",true),
            el(26,"Fe","Железо","55.845",true),
            el(27,"Co","Кобальт","58.933",true),
            el(28,"Ni","Никель","58.693",true)
        ],
        // Ряд 4: Период 4 — B-подгруппа (Cu, Zn, Ga..Br) + Kr
        [
            el(29,"Cu","Медь","63.546",true),
            el(30,"Zn","Цинк","65.38",true),
            el(31,"Ga","Галлий","69.723",true),
            el(32,"Ge","Германий","72.630",true),
            el(33,"As","Мышьяк","74.922",false),
            el(34,"Se","Селен","78.971",false),
            el(35,"Br","Бром","79.904",false),
            nil, nil,
            el(36,"Kr","Криптон","83.798",false)
        ],
        // Ряд 5: Период 5 — A-подгруппа
        [
            el(37,"Rb","Рубидий","85.468",true),
            el(38,"Sr","Стронций","87.62",true),
            el(39,"Y","Иттрий","88.906",true),
            el(40,"Zr","Цирконий","91.224",true),
            el(41,"Nb","Ниобий","92.906",true),
            el(42,"Mo","Молибден","95.95",true),
            el(43,"Tc","Технеций","(98)",true),
            el(44,"Ru","Рутений","101.07",true),
            el(45,"Rh","Родий","102.91",true),
            el(46,"Pd","Палладий","106.42",true)
        ],
        // Ряд 6: Период 5 — B-подгруппа
        [
            el(47,"Ag","Серебро","107.87",true),
            el(48,"Cd","Кадмий","112.41",true),
            el(49,"In","Индий","114.82",true),
            el(50,"Sn","Олово","118.71",true),
            el(51,"Sb","Сурьма","121.76",false),
            el(52,"Te","Теллур","127.60",false),
            el(53,"I","Иод","126.90",false),
            nil, nil,
            el(54,"Xe","Ксенон","131.29",false)
        ],
        // Ряд 7: Период 6 — A-подгруппа
        [
            el(55,"Cs","Цезий","132.91",true),
            el(56,"Ba","Барий","137.33",true),
            el(57,"La","Лантан","138.91",true),
            el(72,"Hf","Гафний","178.49",true),
            el(73,"Ta","Тантал","180.95",true),
            el(74,"W","Вольфрам","183.84",true),
            el(75,"Re","Рений","186.21",true),
            el(76,"Os","Осмий","190.23",true),
            el(77,"Ir","Иридий","192.22",true),
            el(78,"Pt","Платина","195.08",true)
        ],
        // Ряд 8: Период 6 — B-подгруппа
        [
            el(79,"Au","Золото","196.97",true),
            el(80,"Hg","Ртуть","200.59",true),
            el(81,"Tl","Таллий","204.38",true),
            el(82,"Pb","Свинец","207.2",true),
            el(83,"Bi","Висмут","208.98",true),
            el(84,"Po","Полоний","(209)",true),
            el(85,"At","Астат","(210)",false),
            nil, nil,
            el(86,"Rn","Радон","(222)",false)
        ],
        // Ряд 9: Период 7 — A-подгруппа
        [
            el(87,"Fr","Франций","(223)",true),
            el(88,"Ra","Радий","(226)",true),
            el(89,"Ac","Актиний","(227)",true),
            el(104,"Rf","Резерфордий","(267)",true),
            el(105,"Db","Дубний","(268)",true),
            el(106,"Sg","Сиборгий","(269)",true),
            el(107,"Bh","Борий","(270)",true),
            el(108,"Hs","Хассий","(269)",true),
            el(109,"Mt","Мейтнерий","(278)",true),
            el(110,"Ds","Дармштадтий","(281)",true)
        ],
        // Ряд 10: Период 7 — B-подгруппа
        [
            el(111,"Rg","Рентгений","(282)",true),
            el(112,"Cn","Коперниций","(285)",true),
            el(113,"Nh","Нихоний","(286)",true),
            el(114,"Fl","Флеровий","(289)",true),
            el(115,"Mc","Московий","(290)",true),
            el(116,"Lv","Ливерморий","(293)",true),
            el(117,"Ts","Теннессин","(294)",false),
            nil, nil,
            el(118,"Og","Оганесон","(294)",false)
        ],
        // Ряд 11: пустой
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
        // Ряд 12: Лантаноиды (La уже в основной таблице, тут Ce..Lu)
        [
            nil, nil,
            el(58,"Ce","Церий","140.12",true),
            el(59,"Pr","Празеодим","140.91",true),
            el(60,"Nd","Неодим","144.24",true),
            el(61,"Pm","Прометий","(145)",true),
            el(62,"Sm","Самарий","150.36",true),
            el(63,"Eu","Европий","151.96",true),
            el(64,"Gd","Гадолиний","157.25",true),
            el(65,"Tb","Тербий","158.93",true)
        ],
        // Ряд 13: продолжение лантаноидов + актиноиды начала
        [
            el(66,"Dy","Диспрозий","162.50",true),
            el(67,"Ho","Гольмий","164.93",true),
            el(68,"Er","Эрбий","167.26",true),
            el(69,"Tm","Тулий","168.93",true),
            el(70,"Yb","Иттербий","173.05",true),
            el(71,"Lu","Лютеций","174.97",true),
            nil, nil, nil, nil
        ],
        // Ряд 14: Актиноиды (Ac уже в основной таблице, тут Th..Lr)
        [
            nil, nil,
            el(90,"Th","Торий","232.04",true),
            el(91,"Pa","Протактиний","231.04",true),
            el(92,"U","Уран","238.03",true),
            el(93,"Np","Нептуний","(237)",true),
            el(94,"Pu","Плутоний","(244)",true),
            el(95,"Am","Америций","(243)",true),
            el(96,"Cm","Кюрий","(247)",true),
            el(97,"Bk","Берклий","(247)",true)
        ],
        // Ряд 15: продолжение актиноидов
        [
            el(98,"Cf","Калифорний","(251)",true),
            el(99,"Es","Эйнштейний","(252)",true),
            el(100,"Fm","Фермий","(257)",true),
            el(101,"Md","Менделевий","(258)",true),
            el(102,"No","Нобелий","(259)",true),
            el(103,"Lr","Лоуренсий","(266)",true),
            nil, nil, nil, nil
        ]
    ]

    static func el(_ n: Int, _ s: String, _ name: String, _ m: String, _ metal: Bool) -> ElementInfo {
        ElementInfo(number: n, symbol: s, name: name, mass: m, isMetal: metal)
    }

    // Подписи групп сверху
    let groupHeaders = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "", ""]

    // Подписи периодов слева
    let periodLabels: [String] = [
        "1", "2", "3", "4", "4", "5", "5", "6", "6", "7", "7", "", "6*", "6*", "7*", "7*"
    ]

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
                        Text("Д. И. Менделеева · 8 групп")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    Spacer()
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
                .padding(.bottom, 8)

                // Легенда
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: Self.metalBlue))
                            .frame(width: 14, height: 14)
                        Text("Металл")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: Self.nonMetalOrange))
                            .frame(width: 14, height: 14)
                        Text("Неметалл")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Таблица
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    tableGrid
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }

                // Подсказка
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
                    .padding(.bottom, 16)
                    .transition(.opacity)
                } else if addedCount > 0 {
                    Text("Всего добавлено: \(addedCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Сетка
    let cellW: CGFloat = 50
    let cellH: CGFloat = 46
    let gap: CGFloat = 3
    let leftColW: CGFloat = 34

    var tableGrid: some View {
        VStack(spacing: gap) {
            // Номера групп сверху
            HStack(spacing: gap) {
                Color.clear.frame(width: leftColW, height: 20)
                ForEach(0..<10, id: \.self) { i in
                    Text(groupHeaders[i])
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(i < 7 ? Color(hex: "#CBD5E1") : Color(hex: "#94A3B8"))
                        .frame(width: i >= 7 ? cellW * 0.72 : cellW, height: 20)
                }
            }

            // Ряды таблицы
            ForEach(0..<Self.grid.count, id: \.self) { rowIndex in
                // Пустой ряд-разделитель перед лантаноидами
                if rowIndex == 11 {
                    Color.clear.frame(height: 14)
                }
                HStack(spacing: gap) {
                    // Номер периода
                    ZStack {
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#1E293B"))
                        Text(periodLabels[rowIndex])
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                    .frame(width: leftColW, height: cellH)

                    // 10 ячеек
                    ForEach(0..<10, id: \.self) { colIndex in
                        let cell = Self.grid[rowIndex][colIndex]
                        if let element = cell {
                            cellView(element, isNarrow: colIndex >= 7)
                        } else {
                            Color.clear.frame(
                                width: colIndex >= 7 ? cellW * 0.72 : cellW,
                                height: cellH
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Ячейка
    func cellView(_ element: ElementInfo, isNarrow: Bool) -> some View {
        let w = isNarrow ? cellW * 0.72 : cellW
        let h = cellH
        let isTapped = tappedSymbol == element.symbol
        let bgColor = Color(hex: element.isMetal ? Self.metalBlue : Self.nonMetalOrange)

        return Button {
            handleTap(element)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(bgColor.opacity(isTapped ? 1.0 : 0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isTapped ? Color.white : Color.white.opacity(0.2),
                                    lineWidth: isTapped ? 2 : 0.5)
                    )

                VStack(spacing: 0) {
                    // Порядковый номер сверху слева
                    HStack {
                        Text("\(element.number)")
                            .font(.system(size: isNarrow ? 7 : 8, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.9))
                        Spacer()
                    }
                    .padding(.horizontal, 3).padding(.top, 2)

                    Spacer(minLength: 0)

                    // Символ по центру
                    Text(element.symbol)
                        .font(.system(size: isNarrow ? 13 : (element.symbol.count > 1 ? 16 : 18), weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    // Атомная масса снизу
                    Text(element.mass)
                        .font(.system(size: isNarrow ? 6 : 7, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.8))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                }
                .padding(.horizontal, 2)
            }
            .frame(width: w, height: h)
            .scaleEffect(isTapped ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
    }

    func handleTap(_ element: ElementInfo) {
        let color = element.isMetal ? Self.metalBlue : Self.nonMetalOrange
        if let reagent = ChemistryData.findReagent(by: element.symbol) {
            onSelect(reagent)
        } else {
            let fallback = Reagent(symbol: element.symbol, name: element.name,
                                   colorHex: color, group: .elements)
            onSelect(fallback)
        }

        tappedSymbol = element.symbol
        addedCount += 1
        withAnimation(.easeOut(duration: 0.15)) { lastAddedName = element.name }

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
