import SwiftUI

struct ReagentChip: View {
    let reagent: Reagent
    var size: CGFloat = 56
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    // Основная сфера — мягкий градиент
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: reagent.colorHex).opacity(0.95),
                                    Color(hex: reagent.colorHex).opacity(0.65)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(
                            color: Color(hex: reagent.colorHex).opacity(0.35),
                            radius: 4, x: 0, y: 2
                        )

                    // Верхний блик
                    Circle()
                        .fill(Color.white.opacity(0.40))
                        .frame(width: size * 0.22, height: size * 0.22)
                        .blur(radius: 3)
                        .offset(x: -size * 0.15, y: -size * 0.18)

                    // Символ
                    Text(reagent.symbol)
                        .font(.system(size: fontSizeForSymbol(),
                                      weight: .bold,
                                      design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.30), radius: 1, x: 0, y: 1)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                }
                .frame(width: size, height: size)

                if size >= 50 {
                    Text(reagent.name)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: "#94A3B8"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 72)
                }
            }
            .frame(width: size + 12)
        }
        .buttonStyle(ChipPressStyle())
    }

    func fontSizeForSymbol() -> CGFloat {
        let base: CGFloat = size >= 50 ? 18 : 14
        switch reagent.symbol.count {
        case 5...:  return base - 7
        case 4:     return base - 5
        case 3:     return base - 3
        default:    return base
        }
    }
}

struct ChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}
