import SwiftUI

struct AtomStructureView: View {
    @Environment(\.dismiss) private var dismiss

    // Атомные номера для первых 30
    private let atomicNumbers: [String: Int] = [
        "H":1,"He":2,"Li":3,"Be":4,"B":5,"C":6,"N":7,"O":8,"F":9,"Ne":10,
        "Na":11,"Mg":12,"Al":13,"Si":14,"P":15,"S":16,"Cl":17,"Ar":18,
        "K":19,"Ca":20,"Sc":21,"Ti":22,"V":23,"Cr":24,"Mn":25,"Fe":26,
        "Co":27,"Ni":28,"Cu":29,"Zn":30
    ]

    @State private var selected: String = "C"
    @State private var rotation: Double = 0

    private let symbols: [String] = ["H","He","Li","Be","B","C","N","O","F","Ne",
                                     "Na","Mg","Al","Si","P","S","Cl","Ar",
                                     "K","Ca","Fe","Cu","Zn"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 12) {
                    picker
                    atomCanvas
                        .frame(height: 340)
                    info
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle("⚛️ Строение атома")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private var picker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(symbols, id: \.self) { s in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selected = s
                        }
                        AchievementsStorage.shared.add("atom_explorer")
                        SoundManager.shared.click()
                    } label: {
                        Text(s)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(selected == s ? .white : Color(hex: "#94A3B8"))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle().fill(selected == s
                                              ? Color(hex: "#3B82F6")
                                              : Color(hex: "#1E293B"))
                            )
                    }
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var atomCanvas: some View {
        let n = atomicNumbers[selected] ?? 6
        let layers = electronLayers(for: n)
        let symbol = selected

        return ZStack {
            // Орбиты
            ForEach(Array(layers.enumerated()), id: \.offset) { idx, count in
                let radius: CGFloat = 40 + CGFloat(idx) * 44
                Circle()
                    .stroke(Color(hex: "#334155").opacity(0.6), lineWidth: 1)
                    .frame(width: radius * 2, height: radius * 2)

                // Электроны
                ForEach(0..<count, id: \.self) { e in
                    let angle = (Double(e) / Double(count)) * 2 * .pi
                        + rotation * .pi / 180 * (Double(idx) + 1) * 0.4
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#60A5FA"), Color(hex: "#1E40AF")],
                                center: .topLeading, startRadius: 1, endRadius: 8
                            )
                        )
                        .frame(width: 8, height: 8)
                        .offset(x: cos(angle) * radius, y: sin(angle) * radius)
                }
            }

            // Ядро
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#F97316"), Color(hex: "#7C2D12")],
                            center: .topLeading, startRadius: 2, endRadius: 32
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "#F97316").opacity(0.6), radius: 12)

                Text(symbol)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }

    private var info: some View {
        let n = atomicNumbers[selected] ?? 6
        let layers = electronLayers(for: n)
        let protons = n
        let neutrons = max(n - 1, 0)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Протоны: \(protons)  •  Нейтроны (прибл.): \(neutrons)  •  Электроны: \(protons)")
                .font(.system(size: 12)).foregroundColor(Color(hex: "#CBD5E1"))
            HStack(spacing: 6) {
                Text("Слои:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#94A3B8"))
                ForEach(Array(layers.enumerated()), id: \.offset) { idx, c in
                    Text("\(c)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 24)
                        .background(Capsule().fill(Color(hex: "#1E3A8A")))
                }
                Spacer()
            }
            Text("Электронная формула: \(electronConfig(layers))")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(hex: "#FBBF24"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
        .padding(.horizontal, 16)
    }

    // Распределение по слоям (упрощённо по правилу 2n²)
    private func electronLayers(for n: Int) -> [Int] {
        if n <= 0 { return [] }
        let caps = [2, 8, 8, 18]
        var remaining = n
        var result: [Int] = []
        for cap in caps {
            if remaining <= 0 { break }
            let put = min(remaining, cap)
            result.append(put)
            remaining -= put
        }
        return result
    }

    private func electronConfig(_ layers: [Int]) -> String {
        let subs = ["1s","2s","2p","3s","3p","4s","3d","4p"]
        var result: [String] = []
        var idx = 0
        for count in layers {
            if idx >= subs.count { break }
            result.append("\(subs[idx])\(count)")
            idx += 1
        }
        return result.joined(separator: " ")
    }
}
