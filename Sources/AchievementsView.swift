import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var store = AchievementsStorage.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        header
                        ForEach(store.all) { a in
                            row(a)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("🏆 Достижения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var header: some View {
        let total = store.all.count
        let done  = store.all.filter { store.isUnlocked($0.id) }.count
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 8)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: CGFloat(done) / CGFloat(total))
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#FBBF24"), Color(hex: "#F97316")],
                            startPoint: .top, endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 72, height: 72)
                Text("\(done)/\(total)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Прогресс").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Text("Открыто \(done) из \(total)")
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
            }
            Spacer()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1E293B")))
    }

    private func row(_ a: Achievement) -> some View {
        let unlocked = store.isUnlocked(a.id)
        let prog = store.progressValue(a.id)

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(unlocked
                          ? LinearGradient(colors: [Color(hex: "#FBBF24"), Color(hex: "#F97316")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color(hex: "#334155"), Color(hex: "#1E293B")],
                                           startPoint: .top, endPoint: .bottom))
                    .frame(width: 48, height: 48)
                Image(systemName: a.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(unlocked ? .white : Color(hex: "#64748B"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(a.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(unlocked ? .white : Color(hex: "#94A3B8"))
                Text(a.description)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#64748B"))
                ProgressView(value: Double(min(prog, a.goal)), total: Double(a.goal))
                    .tint(unlocked ? Color(hex: "#22C55E") : Color(hex: "#3B82F6"))
                    .scaleEffect(x: 1, y: 0.6)
            }
            Spacer()
            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color(hex: "#22C55E"))
                    .font(.system(size: 18))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B").opacity(unlocked ? 1 : 0.6)))
    }
}
