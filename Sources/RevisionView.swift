import SwiftUI

struct RevisionView: View {
    @State private var selectedClass: Int = 8

    var body: some View {
        ZStack {
            Color(hex: "#0B1020").ignoresSafeArea()

            VStack(spacing: 0) {
                Color.clear.frame(height: 50)

                // Заголовок
               HStack {
    VStack(alignment: .leading, spacing: 2) {
        Text("Повторение")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.white)
        Text("Шпаргалка и ИИ-помощник")
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "#94A3B8"))
    }
    Spacer()
    NavigationLink {
        AIChatView()
    } label: {
        HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 13))
            Text("ИИ")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color(hex: "#3B82F6"), Color(hex: "#8B5CF6")],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .cornerRadius(20)
    }
}
.padding(.horizontal, 20).padding(.vertical, 12)

                // Вкладки 8/9/10
                HStack(spacing: 8) {
                    ForEach([8, 9, 10], id: \.self) { cls in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedClass = cls }
                        } label: {
                            Text("\(cls) класс")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedClass == cls ? .white : Color(hex: "#94A3B8"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(selectedClass == cls ? Color(hex: "#3B82F6") : Color(hex: "#1E293B")))
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 10)

                // Контент
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if selectedClass == 8 { class8Content }
                        else if selectedClass == 9 { class9Content }
                        else { class10Content }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - 8 КЛАСС
    var class8Content: some View {
        Group {
            topicCard(icon: "flask", title: "Основные классы неорганики", items: [
                "Оксиды — ЭₓОᵧ. Основные (Na₂O, CaO) + кислота → соль + вода. Кислотные (CO₂, SO₃) + щёлочь → соль + вода.",
                "Кислоты — HₙX. Реагируют с металлами (до H₂), оксидами, основаниями, солями.",
                "Основания — Me(OH)ₙ. Щёлочи — растворимые (NaOH, KOH, Ca(OH)₂). Реагируют с кислотами и кислотными оксидами.",
                "Соли — Meₓ(кисл.ост.)ᵧ. Реагируют с металлами (более активными), кислотами, щелочами, солями."
            ])

            topicCard(icon: "atom", title: "Строение атома", items: [
                "Атом = ядро (p⁺ + n⁰) + электроны (e⁻).",
                "Число p⁺ = порядковый номер. Число n⁰ = масса − номер.",
                "Электроны распределены по слоям: 2, 8, 8, ...",
                "На внешнем слое не больше 8 e⁻. Внешние электроны → валентность."
            ])

            topicCard(icon: "arrow.left.arrow.right", title: "Химические реакции", items: [
                "Соединения: A + B → AB",
                "Разложения: AB → A + B",
                "Замещения: A + BC → AC + B (металл + соль/кислота)",
                "Обмена: AB + CD → AD + CB",
                "Признаки: газ ↑, осадок ↓, тепло, цвет, запах."
            ])

            topicCard(icon: "drop.fill", title: "Растворы и вода", items: [
                "Растворимость: твёрдые ↑ при нагреве; газы ↓ при нагреве.",
                "Электролиты — проводят ток в растворе (соли, кислоты, щёлочи).",
                "Реакция нейтрализации: кислота + основание → соль + H₂O."
            ])
        }
    }

    // MARK: - 9 КЛАСС
    var class9Content: some View {
        Group {
            topicCard(icon: "tablecells", title: "Периодический закон", items: [
                "Свойства элементов и соединений зависят от заряда ядра.",
                "В периоде слева→направо: металличность ↓, неметалличность ↑.",
                "В группе сверху→вниз: металличность ↑, радиус ↑."
            ])

            topicCard(icon: "atom", title: "Химическая связь", items: [
                "Ковалентная неполярная — между одинаковыми атомами (H₂, O₂).",
                "Ковалентная полярная — между разными неметаллами (H₂O, HCl).",
                "Ионная — металл + неметалл (NaCl, CaO).",
                "Металлическая — в металлах и сплавах."
            ])

            topicCard(icon: "bolt.fill", title: "Электролитическая диссоциация", items: [
                "Сильные электролиты: щёлочи, сильные кислоты (HCl, HNO₃, H₂SO₄), большинство солей.",
                "Слабые: слабые кислоты (H₂CO₃, H₂S, H₂SiO₃), вода.",
                "Реакции ионного обмена идут до конца, если образуется осадок ↓, газ ↑ или вода."
            ])

            topicCard(icon: "leaf", title: "Химия элементов", items: [
                "Металлы: щелочные (Li→Cs), щёлочноземельные (Ca, Sr, Ba), Al, Fe, Cu.",
                "Неметаллы: галогены (F→I), халькогены (O, S), N, P, C, Si.",
                "Fe: Fe²⁺ (зелёный), Fe³⁺ (бурый). Cu: Cu²⁺ (синий)."
            ])
        }
    }

    // MARK: - 10 КЛАСС
    var class10Content: some View {
        Group {
            topicCard(icon: "hexagon", title: "Органические соединения", items: [
                "Углеводороды: алканы CₙH₂ₙ₊₂ (насыщенные), алкены CₙH₂ₙ (двойная связь), алкины CₙH₂ₙ₋₂ (тройная).",
                "Арены — бензол C₆H₆, ароматическая связь.",
                "Спирты — R-OH. Метанол CH₃OH, этанол C₂H₅OH.",
                "Карбоновые кислоты — R-COOH. Уксусная CH₃COOH."
            ])

            topicCard(icon: "flame", title: "Реакции органики", items: [
                "Горение: CₓHᵧ + O₂ → CO₂ + H₂O.",
                "Присоединение (алкены/алкины): + H₂, + Br₂, + H₂O.",
                "Замещение (алканы): CH₄ + Cl₂ → CH₃Cl + HCl (свет).",
                "Качественные реакции: Br₂ обесцвечивается у алкенов и алкинов; Cu(OH)₂ синеет с глицерином и глюкозой."
            ])

            topicCard(icon: "flask", title: "Классы органики", items: [
                "Алканы — только σ-связи, реакции замещения.",
                "Алкены/алкины — реакции присоединения (KMnO₄, Br₂).",
                "Спирты — реакция с Na даёт H₂, окисляются до альдегидов.",
                "Карбоновые кислоты — дают соли с металлами и щелочами, эфиры со спиртами."
            ])
        }
    }

    // MARK: - Карточка темы
    func topicCard(icon: String, title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#60A5FA"))
                    .frame(width: 22)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color(hex: "#3B82F6"))
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#CBD5E1"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#1E293B")))
    }
}
