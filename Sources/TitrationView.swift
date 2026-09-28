import SwiftUI

struct TitrationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var ml: Double = 0
    @State private var dripping = false
    @State private var timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    private let equivalence: Double = 25.0

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 16) {
                    Spacer().frame(height: 4)
                    burette
                    counter
                    flask
                    controls
                    hint
                    Spacer()
                }
            }
            .navigationTitle("💧 Титрование")
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

    private var burette: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.06))
                .frame(width: 30, height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.white.opacity(0.55), lineWidth: 1.5)
                )
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: "#FBBF24"), Color(hex: "#F59E0B")],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 26, height: max(2, 220 - ml * 7))
                .padding(.bottom, 2)
            if dripping {
                Capsule()
                    .fill(Color(hex: "#FBBF24"))
                    .frame(width: 3, height: 14)
                    .offset(y: 16)
            }
        }
    }

    private var counter: some View {
        Text("\(String(format: "%.1f", ml)) мл")
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E293B")))
    }

    private var flask: some View {
        ZStack(alignment: .bottom) {
            Triangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 130, height: 100)
                .overlay(Triangle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))

            Triangle()
                .fill(currentFlaskColor.opacity(0.7))
                .frame(width: 110, height: 70)
                .padding(.bottom, 6)
        }
    }

    private var currentFlaskColor: Color {
        let ratio = ml / equivalence
        if ratio < 0.95 { return Color(hex: "#EF4444") }
        if ratio < 1.05 { return Color(hex: "#FBBF24") }
        return Color(hex: "#22C55E")
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                dripping.toggle()
                SoundManager.shared.click()
            } label: {
                Label(dripping ? "Закрыть" : "Открыть кран",
                      systemImage: dripping ? "stop.fill" : "drop.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(dripping ? Color(hex: "#EF4444") : Color(hex: "#3B82F6"))
                    .cornerRadius(10)
            }
            Button {
                ml = 0; dripping = false
            } label: {
                Label("Сброс", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private var hint: some View {
        Text(hintText)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color(hex: "#94A3B8"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
    }

    private var hintText: String {
        if ml < equivalence - 0.5 { return "Титруем: добавляем NaOH к HCl с фенолфталеином" }
        if abs(ml - equivalence) < 0.5 { return "✅ Точка эквивалентности!" }
        return "Перетитровали — раствор стал щелочным"
    }

    private func tick() {
        guard dripping else { return }
        ml = min(50, ml + 0.3)
        if abs(ml - equivalence) < 0.3 && ml > 0 {
            SoundManager.shared.success()
            AchievementsStorage.shared.add("first_reaction")
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}
