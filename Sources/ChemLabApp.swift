import SwiftUI

@main
struct ChemLabApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - ЗАГРУЗОЧНЫЙ ЭКРАН
struct SplashView: View {
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                colors: [
                    Color(hex: "#0B1020"),
                    Color(hex: "#131A2E"),
                    Color(hex: "#0B1020")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Логотип сверху
                Text("🧪 ХимЛаб")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "#3B82F6").opacity(0.6), radius: 20, x: 0, y: 0)

                // Крутящееся колесико
                ZStack {
                    // Внешнее кольцо (пульсирует)
                    Circle()
                        .stroke(Color(hex: "#3B82F6").opacity(0.25), lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulse ? 1.15 : 0.95)
                        .opacity(pulse ? 0.4 : 0.9)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                    // Вращающаяся дуга
                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "#3B82F6"),
                                    Color(hex: "#60A5FA"),
                                    Color(hex: "#3B82F6").opacity(0.1)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(Angle(degrees: rotation))

                    // Внутренний круг с иконкой
                    Circle()
                        .fill(Color(hex: "#1E293B"))
                        .frame(width: 46, height: 46)
                    Text("⚗️")
                        .font(.system(size: 22))
                }
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                    pulse = true
                }

                Spacer()

                // Надпись снизу
                VStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Text("Сделано с любовью")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "#94A3B8"))
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#EF4444"))
                    }
                    HStack(spacing: 6) {
                        Text("для Анютки")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text("от Демьяна")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }
                }
                .opacity(textOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5).delay(0.5)) {
                        textOpacity = 1
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
