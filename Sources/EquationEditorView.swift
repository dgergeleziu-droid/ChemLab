import SwiftUI
import UIKit

extension Notification.Name {
    static let openInLab = Notification.Name("openInLabNotification")
}

struct EquationEditorView: View {
    @State private var equation: String = ""
    @State private var selectedTab: KeyboardTab = .digits
    @State private var copied = false
    @State private var resultMessage: ResultMessage? = nil
    @State private var savedEquations: [String] = UserDefaults.standard.stringArray(forKey: "savedEquations") ?? []

    enum KeyboardTab: String, CaseIterable {
        case digits = "Цифры"
        case elements = "Элементы"
        case signs = "Знаки"
        case common = "Готовое"
        case notebook = "Блокнот"
    }

    struct ResultMessage: Identifiable {
        let id = UUID()
        let isSuccess: Bool
        let title: String
        let message: String
        let productsList: [String]
    }

    let numberKeys: [[String]] = [
        ["1","2","3","4","5"],
        ["6","7","8","9","0"],
        ["(",")","+","−","="],
        ["₀","₁","₂","₃","₄"],
        ["₅","₆","₇","₈","₉"],
        ["⁰","¹","²","³","⁴"],
        ["⁵","⁶","⁷","⁸","⁹"]
    ]

    let elementKeys: [[String]] = [
        ["H","He","Li","Be","B","C","N","O","F","Ne"],
        ["Na","Mg","Al","Si","P","S","Cl","Ar","K","Ca"],
        ["Fe","Cu","Zn","Ag","Ba","Mn","Cr","Ni","Co","Pb"],
        ["Br","I","Sn","Hg","Au","Pt","Sb","Bi","Sr","Rb"],
        ["H₂O","CO₂","SO₂","SO₃","NO","NO₂","NH₃","HCl","H₂SO₄","HNO₃"],
        ["NaOH","KOH","Ca(OH)₂","H₃PO₄","CH₄","C₂H₅OH","CH₃COOH","C₂H₄","C₂H₂","NaCl"]
    ]

    let signKeys: [[String]] = [
        ["→","⇄","⇌","↓","↑"],
        ["+","−","=","·","/"],
        ["(s)","(l)","(g)","(aq)","(р-р)"],
        ["t°","кат.","hv","Δ","°C"],
        ["Q","↑↓","⟶","⟵","⟷"]
    ]

    let commonTemplates: [String] = [
        "2H₂ + O₂ → 2H₂O",
        "2Na + 2H₂O → 2NaOH + H₂↑",
        "CaCO₃ → CaO + CO₂↑",
        "AgNO₃ + NaCl → AgCl↓ + NaNO₃",
        "NaOH + HCl → NaCl + H₂O",
        "2KMnO₄ → K₂MnO₄ + MnO₂ + O₂↑",
        "Fe₂O₃ + 3H₂ → 2Fe + 3H₂O",
        "N₂ + 3H₂ ⇄ 2NH₃",
        "CH₄ + 2O₂ → CO₂ + 2H₂O",
        "CaO + H₂O → Ca(OH)₂",
        "CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄",
        "BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl",
        "Fe + 2HCl → FeCl₂ + H₂↑",
        "Zn + CuSO₄ → ZnSO₄ + Cu"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            display
            actionButtons
            Spacer(minLength: 0)
            keyboard
        }
        .background(Color(hex: "#0B1020").ignoresSafeArea())
        .sheet(item: $resultMessage) { rm in
            ResultOverlay(message: rm) { resultMessage = nil }
        }
    }

    var display: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text(equation.isEmpty ? "Напиши уравнение здесь..." : equation)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(equation.isEmpty ? Color(hex: "#475569") : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 26)
                        .frame(minWidth: 280, alignment: .leading)
                    Spacer(minLength: 0)
                }
            }
            .frame(minHeight: 110)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#1E293B"))
                    .padding(.horizontal, 12)
            )
        }
    }

    var actionButtons: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    if !equation.isEmpty { equation.removeLast() }
                } label: {
                    Label("Удалить", systemImage: "delete.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 10)
                        .background(Color(hex: "#334155")).cornerRadius(10)
                }
                Button { equation = "" } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Color(hex: "#7F1D1D")).cornerRadius(10)
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = equation
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Color(hex: copied ? "#16A34A" : "#475569")).cornerRadius(10)
                }
            }

            HStack(spacing: 8) {
                Button { checkEquation() } label: {
                    Label("Вывод", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(hex: "#16A34A")).cornerRadius(10)
                }
                Button { openInLab() } label: {
                    Label("В лабораторию", systemImage: "flask.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(hex: "#3B82F6")).cornerRadius(10)
                }
                Button { saveToNotebook() } label: {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        .background(Color(hex: "#F59E0B")).cornerRadius(10)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 10)
    }

    var keyboard: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(KeyboardTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .white : Color(hex: "#94A3B8"))
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(selectedTab == tab ? Color(hex: "#3B82F6") : Color(hex: "#1E293B"))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 8).padding(.top, 8)
            }
            ScrollView {
                VStack(spacing: 6) {
                    if selectedTab == .digits {
                        ForEach(0..<numberKeys.count, id: \.self) { row in keyRow(numberKeys[row]) }
                    } else if selectedTab == .elements {
                        ForEach(0..<elementKeys.count, id: \.self) { row in keyRow(elementKeys[row]) }
                    } else if selectedTab == .signs {
                        ForEach(0..<signKeys.count, id: \.self) { row in keyRow(signKeys[row]) }
                    } else if selectedTab == .common {
                        ForEach(commonTemplates, id: \.self) { t in
                            Button {
                                equation += (equation.isEmpty ? "" : " ") + t
                            } label: {
                                Text(t)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12).padding(.vertical, 10)
                                    .background(Color(hex: "#1E293B")).cornerRadius(8)
                            }
                        }
                    } else {
                        if savedEquations.isEmpty {
                            Text("Пока ничего не сохранено")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#64748B"))
                                .padding(20)
                        } else {
                            ForEach(savedEquations, id: \.self) { eq in
                                HStack {
                                    Button {
                                        equation += (equation.isEmpty ? "" : " ") + eq
                                    } label: {
                                        Text(eq)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 12).padding(.vertical, 10)
                                            .background(Color(hex: "#1E293B")).cornerRadius(8)
                                    }
                                    Button {
                                        savedEquations.removeAll { $0 == eq }
                                        UserDefaults.standard.set(savedEquations, forKey: "savedEquations")
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: "#EF4444"))
                                            .padding(10)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8).padding(.vertical, 10)
            }
            .frame(maxHeight: 260)
            .background(Color(hex: "#0F172A"))
        }
    }

    func keyRow(_ keys: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(keys, id: \.self) { key in
                Button { equation += key } label: {
                    Text(key)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#1E293B")))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#334155"), lineWidth: 0.5))
                }
            }
        }
    }

    // MARK: - === ПАРСЕР (полностью переделан) ===

    // Разбить строку по стрелке (первая слева — конец левой части, последняя — начало правой)
    func splitByArrow(_ s: String) -> (left: String, right: String) {
        let arrowChars: Set<Character> = ["→","⇄","⇌","⟶","⟷","="]
        var firstArrowIdx: Int? = nil
        var lastArrowIdx: Int? = nil
        for (i, char) in s.enumerated() {
            if arrowChars.contains(char) {
                if firstArrowIdx == nil { firstArrowIdx = i }
                lastArrowIdx = i
            }
        }
        guard let first = firstArrowIdx, let last = lastArrowIdx else {
            return (s, "")
        }
        let left = String(s.prefix(first))
        let right = String(s.dropFirst(last + 1))
        return (left, right)
    }

    // Нормализовать символ: убрать коэффициенты, нижние индексы, состояния, значки, элементарные индексы
    func normalizePiece(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespaces)

        // Убираем начальные цифры (коэффициенты)
        while let first = s.first, first.isNumber {
            s.removeFirst()
        }
        s = s.trimmingCharacters(in: .whitespaces)

        // Заменяем нижние индексы на обычные цифры
        let subs: [Character: Character] = [
            "₀":"0","₁":"1","₂":"2","₃":"3","₄":"4",
            "₅":"5","₆":"6","₇":"7","₈":"8","₉":"9"
        ]
        var normalized = ""
        for c in s {
            if let sub = subs[c] { normalized.append(sub) } else { normalized.append(c) }
        }

        // Убираем состояния, значки, пробелы
        for r in ["(s)","(l)","(g)","(aq)","(р-р)","↓","↑"," ","·"] {
            normalized = normalized.replacingOccurrences(of: r, with: "")
        }

        // Убираем "Q" (теплота), "hv" (свет)
        normalized = normalized.replacingOccurrences(of: "Q", with: "")
        normalized = normalized.replacingOccurrences(of: "hv", with: "")

        // Нормализация элементарных газов: H2 → H, O2 → O и т.д.
        let elemMap: [String: String] = [
            "H2":"H", "O2":"O", "N2":"N", "Cl2":"Cl", "F2":"F",
            "Br2":"Br", "I2":"I", "P4":"P", "S8":"S"
        ]
        if let v = elemMap[normalized] { return v }

        return normalized
    }

    // Полный парсинг уравнения → (реагенты, продукты)
    func parseEquation(_ raw: String) -> (reactants: [String], products: [String]) {
        let (left, right) = splitByArrow(raw)
        let reactants = left.components(separatedBy: "+")
            .map { normalizePiece($0) }
            .filter { !$0.isEmpty }
        let products = right.components(separatedBy: "+")
            .map { normalizePiece($0) }
            .filter { !$0.isEmpty && $0 != "Q" }
        return (reactants, products)
    }

    // MARK: - Проверка
    func checkEquation() {
        guard !equation.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false, title: "🤔 Поле пустое",
                message: "Сначала напиши уравнение реакции.", productsList: [])
            return
        }

        let parsed = parseEquation(equation)

        guard !parsed.reactants.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false, title: "🤔 Не вижу реагентов",
                message: "Проверь, что слева от стрелки есть вещества и они разделены знаком «+».",
                productsList: [])
            return
        }

        guard !parsed.products.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false, title: "🤔 Не вижу продуктов",
                message: "Проверь, что справа от стрелки есть вещества.",
                productsList: [])
            return
        }

        // Ищем реакцию
        var found: ChemicalReaction? = nil

        if parsed.reactants.count == 1 {
            // Разложение
            found = ChemistryData.findDecomposition(parsed.reactants[0])
        } else if parsed.reactants.count == 2 {
            found = ChemistryData.findAnyReaction(parsed.reactants[0], parsed.reactants[1])
        }

        guard let reaction = found else {
            resultMessage = ResultMessage(isSuccess: false, title: "🚫 Такой реакции нет в базе",
                message: """
                Эти вещества не взаимодействуют при обычных условиях, либо пары нет в нашей базе.

                Подсказка:
                • Проверь, правильно ли записаны формулы
                • Возможно, нужны специальные условия (t°, кат., свет)
                • Проверь, реагируют ли эти вещества в принципе
                """, productsList: [])
            return
        }

        // Сравнение продуктов (нормализованных)
        let dbProducts = Set(reaction.products.map { normalizePiece($0) })
        let userProducts = Set(parsed.products)

        if dbProducts == userProducts {
            resultMessage = ResultMessage(isSuccess: true, title: "✓ Верно!",
                message: "Реакция протекает. Полученные продукты:",
                productsList: reaction.products)
        } else if dbProducts.isSubset(of: userProducts) {
            // Пользователь написал все продукты базы + что-то лишнее
            let extra = userProducts.subtracting(dbProducts)
            resultMessage = ResultMessage(isSuccess: false, title: "⚠️ Есть лишнее",
                message: "Ты написал(а) все продукты, которые образуются, но добавил(а) ещё лишние: \(extra.joined(separator: ", ")).\n\nПроверь правую часть уравнения.",
                productsList: [])
        } else {
            // Пользователь что-то забыл
            var hint = "Уравнение неверное.\n\nПодсказки:\n"
            if !dbProducts.subtracting(userProducts).isEmpty {
                hint += "• Ты забыл(а) некоторые продукты реакции (проверь, что все элементы слева нашли себя справа).\n"
            }
            if !userProducts.subtracting(dbProducts).isEmpty {
                hint += "• Некоторые вещества в правой части не образуются.\n"
            }
            hint += "• Вспомни правило сохранения атомов: сколько атомов каждого элемента слева — столько и справа."

            resultMessage = ResultMessage(isSuccess: false,
                title: "❌ Уравнение неправильное",
                message: hint, productsList: [])
        }
    }

    // MARK: - В лабораторию
    func openInLab() {
        let parsed = parseEquation(equation)
        guard !parsed.reactants.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false, title: "🤔 Не распознал реагенты",
                message: "Убедись, что реагенты слева от стрелки записаны символами и разделены знаком +",
                productsList: [])
            return
        }
        NotificationCenter.default.post(name: .openInLab, object: parsed.reactants)
    }

    // MARK: - Блокнот
    func saveToNotebook() {
        guard !equation.isEmpty else { return }
        guard !savedEquations.contains(equation) else { return }
        savedEquations.append(equation)
        UserDefaults.standard.set(savedEquations, forKey: "savedEquations")
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
    }
}

// MARK: - Окно результата
struct ResultOverlay: View {
    let message: EquationEditorView.ResultMessage
    let onClose: () -> Void

    var body: some View {
        ZStack {
            (message.isSuccess ? Color(hex: "#0B1020") : Color.black.opacity(0.9)).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle().fill((message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444")).opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: message.isSuccess ? "checkmark.seal.fill" : "xmark.octagon.fill")
                        .font(.system(size: 46))
                        .foregroundColor(message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                }
                Text(message.title).font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white).multilineTextAlignment(.center)
                Text(message.message).font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#CBD5E1"))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true).lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if message.isSuccess && !message.productsList.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧪 Получившиеся вещества:")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#22C55E"))
                        ForEach(message.productsList, id: \.self) { symbol in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(hex: ChemistryData.findReagent(by: symbol)?.colorHex ?? "#94A3B8"))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(symbol).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                    Text(ChemistryData.findReagent(by: symbol)?.name ?? "—")
                                        .font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E293B")))
                        }
                    }
                    .padding(.top, 8)
                }

                Button(action: onClose) {
                    Text(message.isSuccess ? "Отлично!" : "Понял")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                        .cornerRadius(12)
                }.padding(.top, 4)
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(hex: "#1E293B"))
                .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12))
            .padding(.horizontal, 20)
        }
    }
}
