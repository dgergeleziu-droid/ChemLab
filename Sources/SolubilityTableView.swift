import SwiftUI

struct SolubilityTableView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Sol: String {
        case P = "P"   // растворимо
        case M = "M"   // малорастворимо
        case N = "Н"   // нерастворимо
        case D = "—"   // разлагается / нет данных
    }

    private let cations = ["H⁺","K⁺","Na⁺","NH₄⁺","Ca²⁺","Mg²⁺","Al³⁺","Fe²⁺","Fe³⁺","Cu²⁺","Ag⁺","Ba²⁺","Zn²⁺","Pb²⁺"]
    private let anions  = ["OH⁻","Cl⁻","Br⁻","I⁻","NO₃⁻","SO₄²⁻","CO₃²⁻","SiO₃²⁻","PO₄³⁻","S²⁻"]

    private let table: [String: [String: Sol]] = [
        "H⁺": ["OH⁻":.P,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.D,"SiO₃²⁻":.N,"PO₄³⁻":.P,"S²⁻":.D],
        "K⁺": ["OH⁻":.P,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.P,"SiO₃²⁻":.P,"PO₄³⁻":.P,"S²⁻":.P],
        "Na⁺":["OH⁻":.P,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.P,"SiO₃²⁻":.P,"PO₄³⁻":.P,"S²⁻":.P],
        "NH₄⁺":["OH⁻":.D,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.P,"SiO₃²⁻":.P,"PO₄³⁻":.P,"S²⁻":.P],
        "Ca²⁺":["OH⁻":.M,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.M,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.P],
        "Mg²⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.P],
        "Al³⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.D,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.D],
        "Fe²⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.N],
        "Fe³⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.D,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.D,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.D],
        "Cu²⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.D,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.N],
        "Ag⁺": ["OH⁻":.D,"Cl⁻":.N,"Br⁻":.N,"I⁻":.N,"NO₃⁻":.P,"SO₄²⁻":.M,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.N],
        "Ba²⁺":["OH⁻":.P,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.N,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.P],
        "Zn²⁺":["OH⁻":.N,"Cl⁻":.P,"Br⁻":.P,"I⁻":.P,"NO₃⁻":.P,"SO₄²⁻":.P,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.N],
        "Pb²⁺":["OH⁻":.N,"Cl⁻":.M,"Br⁻":.M,"I⁻":.N,"NO₃⁻":.P,"SO₄²⁻":.N,"CO₃²⁻":.N,"SiO₃²⁻":.N,"PO₄³⁻":.N,"S²⁻":.N]
    ]

    @State private var selectedCation: String? = nil
    @State private var selectedAnion: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 2) {
                        headerRow
                        ForEach(cations, id: \.self) { c in
                            row(cation: c)
                        }
                        legend
                    }
                    .padding(12)
                }
            }
            .navigationTitle("🔲 Растворимость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
            .overlay(alignment: .bottom) {
                if let c = selectedCation, let a = selectedAnion {
                    hint(cation: c, anion: a)
                        .padding(.bottom, 24)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            AchievementsStorage.shared.set("solute_master", to: 1)
        }
    }

    private var headerRow: some View {
        HStack(spacing: 2) {
            cell(text: "", bg: Color(hex: "#0F172A"), w: 54)
            ForEach(anions, id: \.self) { a in
                cell(text: a, bg: Color(hex: "#1E293B"), w: 56)
            }
        }
    }

    private func row(cation: String) -> some View {
        HStack(spacing: 2) {
            cell(text: cation, bg: Color(hex: "#1E293B"), w: 54)
            ForEach(anions, id: \.self) { a in
                let sol = table[cation]?[a] ?? .D
                Button {
                    selectedCation = cation
                    selectedAnion = a
                    SoundManager.shared.click()
                } label: {
                    cell(text: sol.rawValue, bg: color(sol), w: 56)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func cell(text: String, bg: Color, w: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .frame(width: w, height: 34)
            .background(RoundedRectangle(cornerRadius: 4).fill(bg))
    }

    private func color(_ s: Sol) -> Color {
        switch s {
        case .P: return Color(hex: "#166534")
        case .M: return Color(hex: "#92400E")
        case .N: return Color(hex: "#7F1D1D")
        case .D: return Color(hex: "#334155")
        }
    }

    private var legend: some View {
        HStack(spacing: 12) {
            Text("P — растворимо").foregroundColor(Color(hex: "#22C55E"))
            Text("M — мало").foregroundColor(Color(hex: "#F59E0B"))
            Text("Н — нераств.").foregroundColor(Color(hex: "#EF4444"))
            Text("— — нет / разл.").foregroundColor(Color(hex: "#94A3B8"))
        }
        .font(.system(size: 11, weight: .medium))
        .padding(.top, 10)
    }

    private func hint(cation: String, anion: String) -> some View {
        let sol = table[cation]?[anion] ?? .D
        let text: String = {
            switch sol {
            case .P: return "\(cation)\(anion) — растворимое соединение"
            case .M: return "\(cation)\(anion) — малорастворимое (выпадает осадок)"
            case .N: return "\(cation)\(anion) — нерастворимое, осадок"
            case .D: return "\(cation)\(anion) — не существует / разлагается"
            }
        }()
        return Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
            .shadow(color: .black.opacity(0.5), radius: 10)
    }
}
