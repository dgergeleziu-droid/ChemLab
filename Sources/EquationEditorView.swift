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
        let productsList: [String]   // пустой, если неправильно
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
        "CaCO₃ →t°→ CaO + CO₂↑",
        "AgNO₃ + NaCl → AgCl↓ + NaNO₃",
        "NaOH + HCl → NaCl + H₂O",
        "2KMnO₄ →t°→ K₂MnO₄ + MnO₂ + O₂↑",
        "Fe₂O₃ + 3H₂ → 2Fe + 3H₂O",
        "N₂ + 3H₂ ⇄ 2NH₃",
        "CH₄ + 2O₂ → CO₂ + 2H₂O",
        "CaO + H₂O → Ca(OH)₂ + Q",
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

    // MARK: - Поле вывода
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

    // MARK: - Кнопки
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
                Button {
                    checkEquation()
                } label: {
                    Label("Вывод", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(hex: "#16A34A")).cornerRadius(10)
                }

                Button {
                    openInLab()
                } label: {
                    Label("В лабораторию", systemImage: "flask.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(hex: "#3B82F6")).cornerRadius(10)
                }

                Button {
                    saveToNotebook()
                } label: {
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

    // MARK: - Клавиатура
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
                Button {
                    equation += key
                } label: {
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

    // MARK: - Логика парсинга

    // Разбирает строку на реагенты и продукты
    func parseEquation(_ raw: String) -> (reactants: [String], products: [String]) {
        // Определяем стрелку
        let arrowStrings = ["→", "⇄", "⇌", "⟶", "⟷", "="]
        var leftPart = raw
        var rightPart = ""
        for a in arrowStrings {
            if let range = raw.range(of: a) {
                leftPart = String(raw[raw.startIndex..<range.lowerBound])
                rightPart = String(raw[range.upperBound...])
                break
            }
        }
        return (extractSymbols(leftPart), extractSymbols(rightPart))
    }

    // Разбирает часть на отдельные символы (убирает коэффициенты, состояния, условия)
    func extractSymbols(_ s: String) -> [String] {
        // Убираем условия после стрелки (t°, кат., hv и т.д.) — они уже отрезаны

        // Разбиваем по плюсу (и русскому «+», и обычному)
        let parts = s.components(separatedBy: "+")
        var result: [String] = []
        for var piece in parts {
            piece = piece.trimmingCharacters(in: .whitespaces)
            // Убираем начальные цифры (коэффициенты)
            while let first = piece.first, first.isNumber {
                piece.removeFirst()
            }
            piece = piece.trimmingCharacters(in: .whitespaces)
            // Убираем состояния (s)(l)(g)(aq)
            for st in ["(s)","(l)","(g)","(aq)","(р-р)"] {
                piece = piece.replacingOccurrences(of: st, with: "")
            }
            piece = piece.trimmingCharacters(in: .whitespaces)
            // Убираем значки осадка и газа
            piece = piece.replacingOccurrences(of: "↓", with: "")
            piece = piece.replacingOccurrences(of: "↑", with: "")
            piece = piece.trimmingCharacters(in: .whitespaces)
            if !piece.isEmpty {
                result.append(piece)
            }
        }
        return result
    }

    // MARK: - Проверка уравнения и вывод
    func checkEquation() {
        guard !equation.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false,
                title: "🤔 Поле пустое",
                message: "Сначала напиши уравнение реакции.",
                productsList: [])
            return
        }

        let parsed = parseEquation(equation)

        guard !parsed.reactants.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false,
                title: "🤔 Не вижу реагентов",
                message: "Проверь, что слева от стрелки есть вещества и они разделены знаком «+».",
                productsList: [])
            return
        }

        guard !parsed.products.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false,
                title: "🤔 Не вижу продуктов",
                message: "Проверь, что справа от стрелки есть вещества.\nЕсли реакция не идёт — так и должно быть, но тогда уравнение писать не нужно.",
                productsList: [])
            return
        }

        // Ищем реакцию по реагентам
        var found: ChemicalReaction? = nil
        if parsed.reactants.count == 2 {
            found = ChemistryData.findReaction(parsed.reactants[0], parsed.reactants[1])
        } else if parsed.reactants.count == 1 {
            // Разложение — ищем по продуктам в базе реакций как fallback
            // (в базе не все разложения есть, но некоторые да)
            for r in ChemistryData.reactions {
                if r.reagents.count == 1 && r.reagents.contains(parsed.reactants[0]) {
                    found = r
                    break
                }
            }
        }

        guard let reaction = found else {
            resultMessage = ResultMessage(isSuccess: false,
                title: "🚫 Такой реакции нет в базе",
                message: """
                Эти вещества не взаимодействуют при обычных условиях, либо пары нет в нашей базе.

                Подсказка:
                • Проверь, правильно ли записаны формулы
                • Возможно, нужны специальные условия (t°, кат., свет, давление)
                • Проверь, реагируют ли эти вещества в принципе
                """,
                productsList: [])
            return
        }

        // Сравниваем продукты (по множеству, без коэффициентов)
        let dbProducts = Set(reaction.products)
        let userProducts = Set(parsed.products)

        if dbProducts == userProducts {
            // Правильно!
            resultMessage = ResultMessage(isSuccess: true,
                title: "✓ Верно!",
                message: "Реакция протекает. Полученные продукты:",
                productsList: reaction.products)
        } else {
            // Неправильно — но НЕ раскрываем ответ
            let extraInUser = userProducts.subtracting(dbProducts)
            let missingInUser = dbProducts.subtracting(userProducts)

            var hint = "Уравнение неверное.\n\nПодсказки:\n"
            if !missingInUser.isEmpty {
                hint += "• Ты забыл(а) некоторые продукты реакции (проверь, что все элементы слева нашли себя справа).\n"
            }
            if !extraInUser.isEmpty {
                hint += "• Некоторые вещества в правой части не образуются (убери лишнее или проверь формулы).\n"
            }
            if missingInUser.isEmpty && extraInUser.isEmpty {
                hint += "• Проверь коэффициенты — они могут быть не сбалансированы.\n"
            }
            hint += "• Вспомни правило сохранения атомов: сколько атомов каждого элемента слева — столько и справа."

            resultMessage = ResultMessage(isSuccess: false,
                title: "❌ Уравнение неправильное",
                message: hint,
                productsList: [])
        }
    }

    func effectDescription(_ e: EffectType) -> String {
        switch e {
        case .explosion: return "взрыв / вспышка"
        case .flash: return "яркая вспышка"
        case .gas: return "выделение газа ↑"
        case .precipitateWhite: return "белый осадок ↓"
        case .precipitateBlue: return "синий осадок ↓"
        case .precipitateBrown: return "бурый осадок ↓"
        case .precipitateYellow: return "жёлтый осадок ↓"
        case .colorChange: return "изменение цвета"
        case .glow: return "свечение / нагрев"
        case .none: return "без эффекта"
        }
    }

    func openInLab() {
        let parsed = parseEquation(equation)
        guard !parsed.reactants.isEmpty else {
            resultMessage = ResultMessage(isSuccess: false,
                title: "🤔 Не распознал реагенты",
                message: "Убедись, что реагенты слева от стрелки записаны символами из таблицы и разделены знаком +",
                productsList: [])
            return
        }
        NotificationCenter.default.post(name: .openInLab, object: parsed.reactants)
    }

    func saveToNotebook() {
        guard !equation.isEmpty else { return }
        guard !savedEquations.contains(equation) else { return }
        savedEquations.append(equation)
        UserDefaults.standard.set(savedEquations, forKey: "savedEquations")
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
    }
}

// MARK: - Окно вывода результата
struct ResultOverlay: View {
    let message: EquationEditorView.ResultMessage
    let onClose: () -> Void

    var body: some View {
        ZStack {
            (message.isSuccess ? Color(hex: "#0B1020") : Color.black.opacity(0.9))
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Иконка
                ZStack {
                    Circle()
                        .fill((message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444")).opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: message.isSuccess ? "checkmark.seal.fill" : "xmark.octagon.fill")
                        .font(.system(size: 46))
                        .foregroundColor(message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                }

                Text(message.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(message.message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#CBD5E1"))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Список продуктов (только если правильно)
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
                                    Text(symbol)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(ChemistryData.findReagent(by: symbol)?.name ?? "—")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#94A3B8"))
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(message.isSuccess ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                        .cornerRadius(12)
                }
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "#1E293B"))
                    .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 20)
        }
    }
}
