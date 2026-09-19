import SwiftUI
import UIKit

struct EquationEditorView: View {
    @State private var equation: String = ""
    @State private var selectedTab: KeyboardTab = .digits
    @State private var copied = false

    enum KeyboardTab: String, CaseIterable {
        case digits = "Цифры"
        case elements = "Элементы"
        case signs = "Знаки"
        case common = "Готовое"
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
            Spacer(minLength: 0)
            keyboard
        }
        .background(Color(hex: "#0B1020").ignoresSafeArea())
    }

    // MARK: - Верхнее поле вывода
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

            HStack(spacing: 10) {
                Button {
                    if !equation.isEmpty { equation.removeLast() }
                } label: {
                    Label("Удалить", systemImage: "delete.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Color(hex: "#334155")).cornerRadius(10)
                }
                Button {
                    equation = ""
                } label: {
                    Label("Очистить", systemImage: "trash")
                        .font(.system(size: 13, weight: .semibold))
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
                    Label(copied ? "Готово!" : "Копировать",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Color(hex: copied ? "#16A34A" : "#3B82F6")).cornerRadius(10)
                }
            }
            .padding(.horizontal, 12)
        }
    }

    // MARK: - Клавиатура
    var keyboard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(KeyboardTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? .white : Color(hex: "#94A3B8"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color(hex: "#3B82F6") : Color(hex: "#1E293B"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 8).padding(.top, 8)

            ScrollView {
                VStack(spacing: 6) {
                    if selectedTab == .digits {
                        ForEach(0..<numberKeys.count, id: \.self) { row in keyRow(numberKeys[row]) }
                    } else if selectedTab == .elements {
                        ForEach(0..<elementKeys.count, id: \.self) { row in keyRow(elementKeys[row]) }
                    } else if selectedTab == .signs {
                        ForEach(0..<signKeys.count, id: \.self) { row in keyRow(signKeys[row]) }
                    } else {
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
                    }
                }
                .padding(.horizontal, 8).padding(.vertical, 10)
            }
            .frame(maxHeight: 300)
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
}
