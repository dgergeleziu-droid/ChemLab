import SwiftUI

struct PeriodicTableView: View {
    let onSelect: (Reagent) -> Void
    let onClose: () -> Void

    @State private var tappedSymbol: String? = nil
    @State private var lastAddedName: String? = nil
    @State private var addedCount: Int = 0

    // Позиции элементов: символ → (строка, столбец)
    // Строки 0-6 = периоды 1-7, строка 7 = лантаноиды, 8 = актиноиды
    static let positions: [String: (row: Int, col: Int)] = [
        // Период 1
        "H": (0, 1), "He": (0, 18),
        // Период 2
        "Li": (1, 1), "Be": (1, 2),
        "B": (1, 13), "C": (1, 14), "N": (1, 15), "O": (1, 16), "F": (1, 17), "Ne": (1, 18),
        // Период 3
        "Na": (2, 1), "Mg": (2, 2),
        "Al": (2, 13), "Si": (2, 14), "P": (2, 15), "S": (2, 16), "Cl": (2, 17), "Ar": (2, 18),
        // Период 4
        "K": (3, 1), "Ca": (3, 2),
        "Sc": (3, 3), "Ti": (3, 4), "V": (3, 5), "Cr": (3, 6), "Mn": (3, 7),
        "Fe": (3, 8), "Co": (3, 9), "Ni": (3, 10), "Cu": (3, 11), "Zn": (3, 12),
        "Ga": (3, 13), "Ge": (3, 14), "As": (3, 15), "Se": (3, 16), "Br": (3, 17), "Kr": (3, 18),
        // Период 5
        "Rb": (4, 1), "Sr": (4, 2),
        "Y": (4, 3), "Zr": (4, 4), "Nb": (4, 5), "Mo": (4, 6), "Tc": (4, 7),
        "Ru": (4, 8), "Rh": (4, 9), "Pd": (4, 10), "Ag": (4, 11), "Cd": (4, 12),
        "In": (4, 13), "Sn": (4, 14), "Sb": (4, 15), "Te": (4, 16), "I": (4, 17), "Xe": (4, 18),
        // Период 6 (без лантаноидов)
        "Cs": (5, 1), "Ba": (5, 2),
        "Hf": (5, 4), "Ta": (5, 5), "W": (5, 6), "Re": (5, 7),
        "Os": (5, 8), "Ir": (5, 9), "Pt": (5, 10), "Au": (5, 11), "Hg": (5, 12),
        "Tl": (5, 13), "Pb": (5, 14), "Bi": (5, 15), "Po": (5, 16), "At": (5, 17), "Rn": (5, 18),
        // Период 7 (без актиноидов)
        "Fr": (6, 1), "Ra": (6, 2),
        "Rf": (6, 4), "Db": (6, 5), "Sg": (6, 6), "Bh": (6, 7),
        "Hs": (6, 8), "Mt": (6, 9), "Ds": (6, 10), "Rg": (6, 11), "Cn": (6, 12),
        "Nh": (6, 13), "Fl": (6, 14), "Mc": (6, 15), "Lv": (6, 16), "Ts": (6, 17), "Og": (6, 18),
        // Лантаноиды (строка 7)
        "La": (7, 3), "Ce": (7, 4), "Pr": (7, 5), "Nd": (7, 6), "Pm": (7, 7),
        "Sm": (7, 8), "Eu": (7, 9), "Gd": (7, 10), "Tb": (7, 11), "Dy": (7, 12),
        "Ho": (7, 13), "Er": (7, 14), "Tm": (7, 15), "Yb": (7, 16), "Lu": (7, 17),
        // Актиноиды (строка 8)
        "Ac": (8, 3), "Th": (8, 4), "Pa": (8, 5), "U": (8, 6), "Np": (8, 7),
        "Pu": (8, 8), "Am": (8, 9), "Cm": (8, 10), "Bk": (8, 11), "Cf": (8, 12),
        "Es": (8, 13), "Fm": (8, 14), "Md": (8, 15), "No": (8, 16), "Lr": (8, 17)
    ]

    // Быстрый поиск: index = row * 100 + col → символ
    static let cellToSymbol: [Int: String] = {
        var dict: [Int: String] = [:]
        for (sym, pos) in positions {
            dict[pos.row * 100 + pos.col] = sym
        }
        return dict
    }()

    var body: some View {
        ZStack {
            Color(hex: "#0B1020").ignoresSafeArea()

            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Таблица Менделеева")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Тапни по элементу — добавится на холст")
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
                .padding(.bottom, 10)

                // Легенда
                HStack(spacing: 12) {
                    legendDot(color: "#F97316", label: "Металлы")
                    legendDot(color: "#EF4444", label: "Неметаллы")
                    legendDot(color: "#A78BFA", label: "Благородные")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Таблица
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(spacing: 3) {
                        ForEach(0..<9, id: \.self) { row in
                            // Пустая строка-разделитель между периодом 7 и лантаноидами
                            if row == 7 {
                                Color.clear.frame(height: 6)
                            }
                            HStack(spacing: 3) {
                                ForEach(1...18, id: \.self) { col in
                                    if let sym = Self.cellToSymbol[row * 100 + col],
                                       let reagent = ChemistryData.findReagent(by: sym) {
                                        elementCell(reagent)
                                    } else {
                                        Color.clear.frame(width: 42, height: 42)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }

                // Всплывающая подсказка снизу
                if let name = lastAddedName {
                    Text("✓ Добавлено: \(name)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color(hex: "#22C55E").opacity(0.9))
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                        .transition(.opacity)
                }

                // Счётчик добавленных
                if addedCount > 0 {
                    Text("Добавлено элементов: \(addedCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .padding(.bottom, 20)
                }
            }
        }
    }

    func legendDot(color: String, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(Color(hex: color)).frame(width: 8, height: 8)
            Text(label).font(.system(size: 10)).foregroundColor(Color(hex: "#94A3B8"))
        }
    }

    func elementCell(_ r: Reagent) -> some View {
        let isTapped = tappedSymbol == r.symbol

        return Button {
            handleTap(r)
        } label: {
            VStack(spacing: 0) {
                Text(r.symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: r.colorHex).opacity(isTapped ? 1.0 : 0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isTapped ? Color.white : Color.white.opacity(0.2), lineWidth: isTapped ? 2 : 0.5)
            )
            .scaleEffect(isTapped ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
    }

    func handleTap(_ r: Reagent) {
        onSelect(r)
        tappedSymbol = r.symbol
        addedCount += 1

        withAnimation(.easeOut(duration: 0.15)) {
            lastAddedName = r.name
        }

        // Убираем подсветку через 0.35 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if tappedSymbol == r.symbol {
                withAnimation(.easeOut(duration: 0.2)) {
                    tappedSymbol = nil
                }
            }
        }
        // Скрываем подсказку через 1.5 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                if lastAddedName == r.name { lastAddedName = nil }
            }
        }
    }
}
