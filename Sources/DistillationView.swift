import SwiftUI

struct DistillationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var temperature: Double = 20
    @State private var heating = false
    @State private var collected: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 16) {
                    Spacer().frame(height: 4)

                    HStack(alignment: .bottom, spacing: 4) {
                        flask
                        tube
                        condenser
                        receiver
                    }
                    .frame(height: 260)

                    flame

                    temperatureGauge

                    controls
                    Spacer()
                }
            }
            .navigationTitle("🌡️ Дистилляция")
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

    private var flask: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 70, height: 70)
                .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5))
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.10))
                .frame(width: 22, height: 40)
                .offset(y: -70)
            Circle()
                .fill(Color(hex: "#60A5FA").opacity(0.45))
                .frame(width: 60, height: 60)
                .offset(y: -4)
        }
    }

    private var tube: some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: 30, y: 0))
            p.addLine(to: CGPoint(x: 30, y: 40))
            p.addLine(to: CGPoint(x: 0, y: 40))
        }
        .stroke(Color.white.opacity(0.55), lineWidth: 3)
        .frame(width: 30, height: 40)
    }

    private var condenser: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .frame(width: 40, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5)
                )
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "#3B82F6").opacity(0.35))
                .frame(width: 30, height: 180)
        }
    }

    private var receiver: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.06))
                .frame(width: 60, height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5)
                )
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#22D3EE").opacity(0.65))
                .frame(width: 52, height: collected * 80 + 2)
                .padding(.bottom, 4)
        }
    }

    private var flame: some View {
        HStack {
            Spacer().frame(width: 30)
            VStack(spacing: 0) {
                if heating {
                    FlameShape()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#F97316"), Color(hex: "#FBBF24")],
                            startPoint: .bottom, endPoint: .top))
                        .frame(width: 24, height: 40)
                } else {
                    Circle().fill(Color.black.opacity(0.4)).frame(width: 6, height: 6)
                }
                Rectangle().fill(Color(hex: "#7C2D12")).frame(width: 4, height: 8)
                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#475569"))
                    .frame(width: 40, height: 16)
            }
            Spacer()
        }
    }

    private var temperatureGauge: some View {
        HStack(spacing: 8) {
            Image(systemName: "thermometer.medium")
                .foregroundColor(temperature > 78 ? Color(hex: "#F59E0B") : Color(hex: "#60A5FA"))
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "#1E293B"))
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#3B82F6"), Color(hex: "#EF4444")],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: g.size.width * CGFloat(temperature / 100))
                }
            }
            .frame(height: 8)
            Text("\(Int(temperature))°C")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 20)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                heating.toggle()
                if heating { SoundManager.shared.flame() }
            } label: {
                Label(heating ? "Погасить" : "Зажечь",
                      systemImage: heating ? "flame.fill" : "flame")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(heating ? Color(hex: "#EF4444") : Color(hex: "#F97316"))
                    .cornerRadius(10)
            }
            Button {
                temperature = 20; collected = 0; heating = false
            } label: {
                Label("Сброс", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private func tick() {
        if heating {
            temperature = min(100, temperature + 1.4)
        } else {
            temperature = max(20, temperature - 0.5)
        }
        if temperature >= 78 {
            collected = min(1.0, collected + 0.015)
        }
        if collected >= 0.99 {
            heating = false
            SoundManager.shared.success()
        }
    }
}
