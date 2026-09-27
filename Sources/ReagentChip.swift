import SwiftUI

// MARK: - 🎨 КРАСИВАЯ СФЕРА-РЕАГЕНТ

struct ReagentChip: View {
    let reagent: Reagent
    var size: CGFloat = 56
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // 1. Внешнее свечение в цвет вещества
                    Circle()
                        .fill(Color(hex: reagent.colorHex))
                        .frame(width: size * 1.10, height: size * 1.10)
                        .blur(radius: 12)
                        .opacity(0.55)

                    // 2. Внутренний цветной "подсвет" по контуру
                    Circle()
                        .strokeBorder(Color(hex: reagent.colorHex).opacity(0.9), lineWidth: 1.5)
                        .frame(width: size + 1, height: size + 1)
                        .blur(radius: 1.5)
                        .opacity(0.6)

                    // 3. Основная глянцевая сфера
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.65), location: 0.00),
                                    .init(color: Color.white.opacity(0.20), location: 0.18),
                                    .init(color: Color(hex: reagent.colorHex).opacity(0.98), location: 0.55),
                                    .init(color: Color(hex: reagent.colorHex).opacity(0.60), location: 1.00)
                                ]),
                                center: UnitPoint(x: 0.32, y: 0.28),
                                startRadius: 1,
                                endRadius: size * 0.72
                            )
                        )
                        .frame(width: size, height: size)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.85), .white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.3
                                )
                        )
                        .shadow(color: Color(hex: reagent.colorHex).opacity(0.55),
                                radius: 6, x: 0, y: 3)

                    // 4. Верхний блик (маленький, яркий)
                    Circle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: size * 0.16, height: size * 0.16)
                        .blur(radius: 1.8)
                        .offset(x: -size * 0.20, y: -size * 0.24)

                    // 5. Нижний мягкий отблеск (объём)
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: size * 0.40, height: size * 0.18)
                        .blur(radius: 3)
                        .offset(x: size * 0.05, y: size * 0.28)

                    // 6. Символ
                    Text(reagent.symbol)
                        .font(.system(size: fontSizeForSymbol(), weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 4)

                    // 7. Кольцо группы: сплошное / пунктир / точки
                    Circle()
                        .strokeBorder(groupRingColor, style: StrokeStyle(lineWidth: 1.4, dash: groupRingDash))
                        .frame(width: size + 6, height: size + 6)
                }

                if size >= 50 {
                    Text(reagent.name)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#CBD5E1"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 76)
                }
            }
            .frame(width: size + 24)
        }
        .buttonStyle(ChipPressStyle())
    }

    private var groupRingColor: Color {
        switch reagent.group {
        case .elements:  return Color.white.opacity(0.45)
        case .compounds: return Color(hex: "#60A5FA").opacity(0.85)
        case .organic:   return Color(hex: "#A78BFA").opacity(0.90)
        }
    }

    private var groupRingDash: [CGFloat] {
        switch reagent.group {
        case .elements:  return []
        case .compounds: return [4, 3]
        case .organic:   return [1.5, 2.5]
        }
    }

    func fontSizeForSymbol() -> CGFloat {
        let base: CGFloat = size >= 50 ? 19 : 15
        switch reagent.symbol.count {
        case 5...:  return base - 7
        case 4:     return base - 5
        case 3:     return base - 3
        default:    return base
        }
    }
}

// MARK: - Анимация нажатия

struct ChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
