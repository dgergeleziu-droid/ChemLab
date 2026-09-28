import SwiftUI

struct MoleculeBuilderView: View {
    @Environment(\.dismiss) private var dismiss

    struct Target: Identifiable {
        let id = UUID()
        let name: String
        let formula: String
        let atoms: [String]   // какие атомы нужны
    }

    private let targets: [Target] = [
        .init(name: "Вода", formula: "H2O", atoms: ["H","H","O"]),
        .init(name: "Метан", formula: "CH4", atoms: ["C","H","H","H","H"]),
        .init(name: "Углекислый газ", formula: "CO2", atoms: ["C","O","O"]),
        .init(name: "Аммиак", formula: "NH3", atoms: ["N","H","H","H"])
    ]

    @State private var target: Target? = nil
    @State private var placed: [String] = []
    @State private var score: Int = 0
    @State private var flash: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                if let t = target {
                    VStack(spacing: 16) {
                        header(t)
                        canvas(t)
                        palette(t)
                        controls(t)
                        Spacer()
                    }
                    .padding(.top, 8)
                } else {
                    startScreen
                }
                flashOverlay
            }
            .navigationTitle("🔬 Конструктор молекул")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { if target == nil { start() } }
    }

    private func header(_ t: Target) -> some View {
        VStack(spacing: 4) {
            Text("Собери: \(t.name)")
                .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text(t.formula)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: "#FBBF24"))
        }
    }

    private func canvas(_ t: Target) -> some View {
        ZStack {
            // Палочки-связи от центра
            ForEach(0..<t.atoms.count, id: \.self) { i in
                let angle = (Double(i) / Double(t.atoms.count)) * 2 * .pi
                let r: CGFloat = 80
                Capsule()
                    .fill(Color.white.opacity(i < placed.count ? 0.6 : 0.10))
                    .frame(width: 3, height: r)
                    .offset(y: -r/2)
                    .rotationEffect(.radians(angle))
            }
            // Атомы
            ForEach(0..<t.atoms.count, id: \.self) { i in
                let angle = (Double(i) / Double(t.atoms.count)) * 2 * .pi
                let r: CGFloat = 90
                if i < placed.count {
                    atomView(placed[i])
                        .offset(x: cos(angle) * r, y: sin(angle) * r)
                } else {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [3,3]))
                        .frame(width: 34, height: 34)
                        .offset(x: cos(angle) * r, y: sin(angle) * r)
                }
            }
            // Центр
            if let first = t.atoms.first {
                atomView(first)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
            }
        }
        .frame(height: 260)
    }

    private func atomView(_ s: String) -> some View {
        let color = ChemistryData.findReagent(by: s)?.colorHex ?? "#94A3B8"
        return ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: color), Color(hex: color).opacity(0.55)],
                    center: .topLeading, startRadius: 2, endRadius: 24))
                .frame(width: 46, height: 46)
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))
            Text(s)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    private func palette(_ t: Target) -> some View {
        // Набор "чужих" атомов + недостающие
        let needed = Dictionary(grouping: t.atoms, by: { $0 }).mapValues { $0.count }
        let extras = ["Cl","S","N","O","H","C"].filter { needed[$0, default: 0] == 0 }.prefix(2)
        let pool = Array(needed.keys) + extras
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(pool, id: \.self) { s in
                    Button {
                        place(s, t: t)
                    } label: {
                        atomView(s)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
    }

    private func controls(_ t: Target) -> some View {
        HStack(spacing: 12) {
            Button { start() } label: {
                Label("Ещё", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
            Button {
                placed.removeAll()
            } label: {
                Label("Очистить", systemImage: "trash")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private var startScreen: some View {
        VStack(spacing: 20) {
            Text("🔬").font(.system(size: 70))
            Text("Собери молекулу").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
            Button { start() } label: {
                Text("Начать").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 12)
                    .background(Color(hex: "#3B82F6")).cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var flashOverlay: some View {
        if let f = flash {
            VStack {
                Spacer().frame(height: 100)
                Text(f).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.85)))
                Spacer()
            }
            .transition(.opacity)
        }
    }

    private func place(_ s: String, t: Target) {
        let needed = Dictionary(grouping: t.atoms, by: { $0 }).mapValues { $0.count }
        let used = Dictionary(grouping: placed, by: { $0 }).mapValues { $0.count }
        if needed[s, default: 0] > used[s, default: 0] {
            placed.append(s)
            SoundManager.shared.click()
            if placed.count == t.atoms.count { verify(t) }
        } else {
            SoundManager.shared.error()
            showFlash("Лишний атом \(s)")
        }
    }

    private func verify(_ t: Target) {
        let target = Dictionary(grouping: t.atoms, by: { $0 }).mapValues { $0.count }
        let got    = Dictionary(grouping: placed, by: { $0 }).mapValues { $0.count }
        if target == got {
            score += 1
            SoundManager.shared.success()
            AchievementsStorage.shared.add("first_reaction")
            showFlash("✅ \(t.formula) собрана!")
        } else {
            SoundManager.shared.error()
            showFlash("❌ Не то")
        }
    }

    private func showFlash(_ m: String) {
        withAnimation { flash = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { flash = nil }
        }
    }

    private func start() {
        target = targets.randomElement()
        placed = []
        flash = nil
    }
}
