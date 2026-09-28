import SwiftUI

struct LabMenuView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showAchievements = false
    @State private var showDiary = false
    @State private var showAtom = false
    @State private var showSolubility = false
    @State private var showIndicators = false
    @State private var showMolarMass = false
    @State private var showQuiz = false
    @State private var soundEnabled = SoundManager.shared.enabled

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        // Раздел 1 — прогресс
                        sectionTitle("📈 Прогресс")
                        tile(icon: "trophy.fill", color: "#FBBF24",
                             title: "Достижения",
                             subtitle: "Открыто \(AchievementsStorage.shared.unlocked.count) из \(AchievementsStorage.shared.all.count)") {
                            showAchievements = true
                        }
                        tile(icon: "book.closed.fill", color: "#A78BFA",
                             title: "Дневник опытов",
                             subtitle: "Записей: \(DiaryStorage.shared.entries.count)") {
                            showDiary = true
                        }

                        // Раздел 2 — справочник
                        sectionTitle("📚 Справочник")
                        tile(icon: "atom", color: "#60A5FA",
                             title: "Строение атома",
                             subtitle: "Ядро, орбиты, электронные слои") {
                            showAtom = true
                        }
                        tile(icon: "square.grid.3x3.fill", color: "#22C55E",
                             title: "Таблица растворимости",
                             subtitle: "14 катионов × 10 анионов") {
                            showSolubility = true
                        }
                        tile(icon: "function", color: "#F59E0B",
                             title: "Молярная масса",
                             subtitle: "Посчитать M для любой формулы") {
                            showMolarMass = true
                        }

                        // Раздел 3 — опыты
                        sectionTitle("🌈 Опыты и игры")
                        tile(icon: "paintpalette.fill", color: "#EC4899",
                             title: "Индикаторы",
                             subtitle: "Лакмус, метилоранж, фенолфталеин") {
                            showIndicators = true
                        }
                        tile(icon: "target", color: "#EF4444",
                             title: "Угадай элемент",
                             subtitle: "Викторина · рекорд \(UserDefaults.standard.integer(forKey: "chemlab.quiz.best"))") {
                            showQuiz = true
                        }

                        // Настройки
                        sectionTitle("⚙️ Настройки")
                        soundToggle
                    }
                    .padding(16)
                }
            }
            .navigationTitle("🧪 Лаборатория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
            .sheet(isPresented: $showAchievements) { AchievementsView() }
            .sheet(isPresented: $showDiary) { DiaryView() }
            .sheet(isPresented: $showAtom) { AtomStructureView() }
            .sheet(isPresented: $showSolubility) { SolubilityTableView() }
            .sheet(isPresented: $showIndicators) { IndicatorsView() }
            .sheet(isPresented: $showMolarMass) { MolarMassView() }
            .sheet(isPresented: $showQuiz) { GuessElementView() }
        }
        .navigationViewStyle(.stack)
    }

    private func sectionTitle(_ t: String) -> some View {
        HStack {
            Text(t)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "#94A3B8"))
            Spacer()
        }
        .padding(.top, 4)
    }

    private func tile(icon: String, color: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            SoundManager.shared.click()
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: color).opacity(0.20))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: color))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#475569"))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
        }
        .buttonStyle(.plain)
    }

    private var soundToggle: some View {
        Button {
            soundEnabled.toggle()
            SoundManager.shared.enabled = soundEnabled
            if soundEnabled { SoundManager.shared.success() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#3B82F6").opacity(0.20))
                        .frame(width: 48, height: 48)
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#3B82F6"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Звуки")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(soundEnabled ? "Включены" : "Выключены")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#94A3B8"))
                }
                Spacer()
                Toggle("", isOn: $soundEnabled)
                    .labelsHidden()
                    .onChange(of: soundEnabled) { v in
                        SoundManager.shared.enabled = v
                        if v { SoundManager.shared.success() }
                    }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
        }
        .buttonStyle(.plain)
    }
}
