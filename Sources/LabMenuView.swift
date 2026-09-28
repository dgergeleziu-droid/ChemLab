import SwiftUI

// Все экраны меню
enum LabMenuItem: String, Identifiable {
    case achievements, diary, daily, atom, solubility, molarMass
    case electrolysis, distillation, titration, indicators
    case buildReaction, molecule, redox, quiz

    var id: String { rawValue }
}

struct LabMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared

    @State private var activeItem: LabMenuItem? = nil
    @State private var soundEnabled = SoundManager.shared.enabled

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        sectionTitle("📈 Прогресс")
                        tile(icon: "trophy.fill", color: "#FBBF24",
                             title: "Достижения",
                             subtitle: "Открыто \(AchievementsStorage.shared.unlocked.count) из \(AchievementsStorage.shared.all.count)") {
                            activeItem = .achievements
                        }
                        tile(icon: "book.closed.fill", color: "#A78BFA",
                             title: "Дневник опытов",
                             subtitle: "Записей: \(DiaryStorage.shared.entries.count)") {
                            activeItem = .diary
                        }
                        tile(icon: "calendar", color: "#F97316",
                             title: "Задание дня",
                             subtitle: "Серия: \(UserDefaults.standard.integer(forKey: "chemlab.daily.streak")) 🔥") {
                            activeItem = .daily
                        }

                        sectionTitle("📚 Справочник")
                        tile(icon: "atom", color: "#60A5FA",
                             title: "Строение атома",
                             subtitle: "Ядро, орбиты, электронные слои") {
                            activeItem = .atom
                        }
                        tile(icon: "square.grid.3x3.fill", color: "#22C55E",
                             title: "Таблица растворимости",
                             subtitle: "14 катионов × 10 анионов") {
                            activeItem = .solubility
                        }
                        tile(icon: "function", color: "#F59E0B",
                             title: "Молярная масса",
                             subtitle: "Посчитать M для любой формулы") {
                            activeItem = .molarMass
                        }

                        sectionTitle("⚗️ Опыты")
                        tile(icon: "bolt.fill", color: "#FBBF24",
                             title: "Электролиз",
                             subtitle: "Ванна с электродами и батарейкой") {
                            activeItem = .electrolysis
                        }
                        tile(icon: "thermometer.medium", color: "#EF4444",
                             title: "Дистилляция",
                             subtitle: "Колба → холодильник → приёмник") {
                            activeItem = .distillation
                        }
                        tile(icon: "drop.fill", color: "#06B6D4",
                             title: "Титрование",
                             subtitle: "Бюретка, точка эквивалентности") {
                            activeItem = .titration
                        }
                        tile(icon: "paintpalette.fill", color: "#EC4899",
                             title: "Индикаторы",
                             subtitle: "Лакмус, метилоранж, фенолфталеин") {
                            activeItem = .indicators
                        }

                        sectionTitle("🎮 Игры")
                        tile(icon: "puzzlepiece.fill", color: "#8B5CF6",
                             title: "Собери реакцию",
                             subtitle: "Расставь реагенты и продукты") {
                            activeItem = .buildReaction
                        }
                        tile(icon: "circle.hexagongrid.fill", color: "#14B8A6",
                             title: "Конструктор молекул",
                             subtitle: "Собери H₂O, CH₄, CO₂, NH₃") {
                            activeItem = .molecule
                        }
                        tile(icon: "arrow.left.arrow.right", color: "#F43F5E",
                             title: "ОВР баланс",
                             subtitle: "Окислитель и восстановитель") {
                            activeItem = .redox
                        }
                        tile(icon: "target", color: "#EF4444",
                             title: "Угадай элемент",
                             subtitle: "Рекорд: \(UserDefaults.standard.integer(forKey: "chemlab.quiz.best"))") {
                            activeItem = .quiz
                        }

                        sectionTitle("⚙️ Настройки")
                        soundToggle
                        themeRow
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
            .sheet(item: $activeItem) { item in
                switch item {
                case .achievements:  AchievementsView()
                case .diary:         DiaryView()
                case .daily:         DailyChallengeView()
                case .atom:          AtomStructureView()
                case .solubility:    SolubilityTableView()
                case .molarMass:     MolarMassView()
                case .electrolysis:  ElectrolysisView()
                case .distillation:  DistillationView()
                case .titration:     TitrationView()
                case .indicators:    IndicatorsView()
                case .buildReaction: BuildReactionView()
                case .molecule:      MoleculeBuilderView()
                case .redox:         RedoxBalanceView()
                case .quiz:          GuessElementView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Компоненты

    private func sectionTitle(_ t: String) -> some View {
        HStack {
            Text(t).font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "#94A3B8"))
            Spacer()
        }.padding(.top, 4)
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
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8")).lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(Color(hex: "#475569"))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
        }
        .buttonStyle(.plain)
    }

    private var soundToggle: some View {
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
                Text("Звуки").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Text(soundEnabled ? "Включены" : "Выключены")
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
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

    private var themeRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#A78BFA").opacity(0.20))
                    .frame(width: 48, height: 48)
                Image(systemName: themeManager.theme.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#A78BFA"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Тема").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Text(themeManager.theme.rawValue)
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
            }
            Spacer()
            Picker("", selection: $themeManager.theme) {
                ForEach(AppTheme.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.menu)
            .tint(Color(hex: "#A78BFA"))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
    }
}
