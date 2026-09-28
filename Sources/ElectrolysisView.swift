import SwiftUI

struct ElectrolysisView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var voltage: Double = 3
    @State private var running = false
    @State private var cathodeFill: CGFloat = 0
    @State private var anodeFill: CGFloat = 0
    @State private var bubbles: Int = 0
    @State private var selectedLiquid: String = "CuCl2"
    @State private var timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    private let liquids = ["CuCl2", "NaCl", "H2O"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 14) {
                    liquidPicker
                    bath
                    voltageSlider
                    controls
                    if cathodeFill > 0.15 || anodeFill > 0.15 {
                        resultText
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle("⚡ Электролиз")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onReceive(timer) { _ in tick() }
    }

    private var liquidPicker: some View {
        HStack(spacing: 8) {
            ForEach(liquids, id: \.self) { l in
                Button {
                    selectedLiquid = l
                    cathodeFill = 0; anodeFill = 0; bubbles = 0; running = false
                } label: {
                    Text(l)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(selectedLiquid == l ? .white : Color(hex: "#94A3B8"))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Capsule().fill(selectedLiquid == l
                                                   ? Color(hex: "#3B82F6")
                                                   : Color(hex: "#1E293B")))
                }
            }
        }
    }

    private var bath: some View {
        ZStack(alignment: .bottom) {
            // Ванна
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .frame(width: 280, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.5)
                )

            // Жидкость
            RoundedRectangle(cornerRadius: 12)
                .fill(liquidColor.opacity(0.55))
                .frame(width: 270, height: 120)
                .padding(.bottom, 6)

            // Электроды
            HStack(spacing: 180) {
                electrode(color: anodeFill > 0.3 ? Color(hex: "#EF4444") : Color(hex: "#334155"))
                    .overlay(alignment: .bottom) {
                        if anodeFill > 0.05 {
                            Rectangle()
                                .fill(Color(hex: "#7F1D1D"))
                                .frame(height: anodeFill * 100)
                        }
                    }
                electrode(color: cathodeFill > 0.3 ? Color(hex: "#FBBF24") : Color(hex: "#334155"))
                    .overlay(alignment: .bottom) {
                        if cathodeFill > 0.05 {
                            Rectangle()
                                .fill(metalColor)
                                .frame(height: cathodeFill * 100)
                        }
                    }
            }

            // Пузырьки
            if bubbles > 0 {
                ForEach(0..<min(bubbles, 12), id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: CGFloat.random(in: 3...6))
                        .offset(x: -90 + CGFloat(i % 2) * 180,
                                y: -50 - CGFloat(i * 7))
                }
            }

            // Подписи
            HStack(spacing: 180) {
                Text("A").font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "#EF4444"))
                Text("K").font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "#FBBF24"))
            }
            .offset(y: -170)
        }
        .frame(height: 220)
    }

    private func electrode(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 10, height: 140)
    }

    private var voltageSlider: some View {
        HStack(spacing: 10) {
            Image(systemName: "bolt.fill").foregroundColor(Color(hex: "#FBBF24"))
            Slider(value: $voltage, in: 1...12, step: 0.5)
                .tint(Color(hex: "#3B82F6"))
            Text("\(String(format: "%.1f", voltage)) В")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60)
        }
        .padding(.horizontal, 20)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                running.toggle()
                SoundManager.shared.click()
            } label: {
                Label(running ? "Стоп" : "Пуск", systemImage: running ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22).padding(.vertical, 10)
                    .background(running ? Color(hex: "#EF4444") : Color(hex: "#22C55E"))
                    .cornerRadius(10)
            }

            Button {
                cathodeFill = 0; anodeFill = 0; bubbles = 0
            } label: {
                Label("Сброс", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private var resultText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(equationText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#FBBF24"))
            if anodeFill > 0.05 {
                Text("На аноде: \(anodeProduct)")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "#CBD5E1"))
            }
            if cathodeFill > 0.05 {
                Text("На катоде: \(cathodeProduct)")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "#CBD5E1"))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E293B")))
        .padding(.horizontal, 20)
    }

    private var liquidColor: Color {
        switch selectedLiquid {
        case "CuCl2": return Color(hex: "#06B6D4")
        case "NaCl":  return Color(hex: "#94A3B8")
        default:      return Color(hex: "#60A5FA")
        }
    }
    private var metalColor: Color {
        selectedLiquid == "CuCl2" ? Color(hex: "#B45309") : Color(hex: "#CBD5E1")
    }
    private var equationText: String {
        switch selectedLiquid {
        case "CuCl2": return "CuCl₂ → Cu + Cl₂↑"
        case "NaCl":  return "2NaCl + 2H₂O → 2NaOH + H₂↑ + Cl₂↑"
        default:      return "2H₂O → 2H₂↑ + O₂↑"
        }
    }
    private var anodeProduct: String {
        switch selectedLiquid {
        case "CuCl2", "NaCl": return "Cl₂ (газ)"
        default: return "O₂ (газ)"
        }
    }
    private var cathodeProduct: String {
        switch selectedLiquid {
        case "CuCl2": return "Cu (металл)"
        case "NaCl":  return "H₂ (газ)"
        default:      return "H₂ (газ)"
        }
    }

    private func tick() {
        guard running else { return }
        let speed = voltage / 12.0
        if selectedLiquid == "CuCl2" {
            cathodeFill = min(1, cathodeFill + speed * 0.06)
            anodeFill = min(1, anodeFill + speed * 0.03)
        } else {
            anodeFill = min(1, anodeFill + speed * 0.03)
            cathodeFill = min(1, cathodeFill + speed * 0.02)
        }
        if Int.random(in: 0...2) == 0 { bubbles = min(bubbles + 1, 14) }
        if cathodeFill >= 0.99 && anodeFill >= 0.99 {
            running = false
            SoundManager.shared.success()
            AchievementsStorage.shared.add("first_reaction")
        }
    }
}
