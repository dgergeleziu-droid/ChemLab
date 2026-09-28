import SwiftUI

struct BuildReactionView: View {
    @Environment(\.dismiss) private var dismiss

    struct Puzzle: Identifiable {
        let id = UUID()
        let left: [String]           // правильные реагенты
        let right: [String]          // правильные продукты
        let equation: String
    }

    private let bank: [Puzzle] = [
        .init(left: ["H2","O2"], right: ["H2O"], equation: "2H₂ + O₂ → 2H₂O"),
        .init(left: ["Na","H2O"], right: ["NaOH","H2"], equation: "2Na + 2H₂O → 2NaOH + H₂↑"),
        .init(left: ["CuO","H2"], right: ["Cu","H2O"], equation: "CuO + H₂ → Cu + H₂O"),
        .init(left: ["NaOH","HCl"], right: ["NaCl","H2O"], equation: "NaOH + HCl → NaCl + H₂O"),
        .init(left: ["Fe","CuSO4"], right: ["FeSO4","Cu"], equation: "Fe + CuSO₄ → FeSO₄ + Cu")
    ]

    @State private var puzzle: Puzzle? = nil
    @State private var slotsLeft: [String] = []
    @State private var slotsRight: [String] = []
    @State private var pool: [String] = []
    @State private var draggable: String? = nil
    @State private var dragPos: CGPoint = .zero
    @State private var attempts: Int = 0
    @State private var score: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                if let p = puzzle {
                    VStack(spacing: 20) {
                        header
                        Spacer().frame(height: 4)
                        equationRow(p)
                        Spacer()
                        poolArea
                        controls(p)
                        Spacer()
                    }
                } else {
                    startScreen
                }
                dragPreview
            }
            .navigationTitle("🧩 Собери реакцию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { if puzzle == nil { start() } }
    }

    private var header: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundColor(Color(hex: "#FBBF24"))
            Spacer()
            Text("Попытка \(attempts)").foregroundColor(Color(hex: "#94A3B8"))
        }
        .font(.system(size: 13, weight: .semibold))
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func equationRow(_ p: Puzzle) -> some View {
        HStack(spacing: 10) {
            slotRow($slotsLeft, accept: p.left)
            Text("→").foregroundColor(.white).font(.system(size: 20, weight: .bold))
            slotRow($slotsRight, accept: p.right)
        }
        .padding(.horizontal, 16)
    }

    private func slotRow(_ slots: Binding<[String]>, accept: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<accept.count, id: \.self) { i in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#1E293B"))
                        .frame(width: 70, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
                    if i < slots.wrappedValue.count {
                        Text(slots.wrappedValue[i])
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Text("?").font(.system(size: 16)).foregroundColor(Color(hex: "#475569"))
                    }
                }
                .onDrop(of: [.text], delegate: DropSlotDelegate { text in
                    insert(text, into: slots, maxCount: accept.count)
                })
            }
        }
    }

    private var poolArea: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(pool, id: \.self) { s in
                    Text(s)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Capsule().fill(Color(hex: "#3B82F6")))
                        .opacity(draggable == s ? 0.4 : 1)
                        .onDrag {
                            draggable = s
                            return NSItemProvider(object: s as NSString)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
    }

    private func controls(_ p: Puzzle) -> some View {
        HStack(spacing: 12) {
            Button {
                check(p)
            } label: {
                Label("Проверить", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color(hex: "#22C55E")).cornerRadius(10)
            }
            Button { start() } label: {
                Label("Ещё", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1E293B")).cornerRadius(10)
            }
        }
    }

    private var startScreen: some View {
        VStack(spacing: 20) {
            Text("🧩").font(.system(size: 70))
            Text("Собери реакцию")
                .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
            Text("Перетащи реагенты и продукты в нужные слоты")
                .font(.system(size: 13)).foregroundColor(Color(hex: "#94A3B8"))
                .multilineTextAlignment(.center).padding(.horizontal, 30)
            Button { start() } label: {
                Text("Начать").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 12)
                    .background(Color(hex: "#3B82F6")).cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var dragPreview: some View {
        if let d = draggable {
            Text(d)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Capsule().fill(Color(hex: "#3B82F6")))
                .position(dragPos)
                .allowsHitTesting(false)
        }
    }

    private func insert(_ text: String, into slots: Binding<[String]>, maxCount: Int) {
        guard slots.wrappedValue.count < maxCount else { return }
        slots.wrappedValue.append(text)
        pool.removeAll { $0 == text }
        SoundManager.shared.click()
    }

    private func check(_ p: Puzzle) {
        attempts += 1
        let leftOK = slotsLeft == p.left
        let rightOK = slotsRight == p.right
        if leftOK && rightOK {
            score += 1
            SoundManager.shared.success()
            AchievementsStorage.shared.add("first_reaction")
            showFlash("✅ Верно! \(p.equation)")
        } else {
            SoundManager.shared.error()
            showFlash("❌ Пока не так. Попробуй ещё")
        }
    }

    @State private var flashText: String? = nil
    private func showFlash(_ m: String) {
        withAnimation { flashText = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { flashText = nil }
        }
    }

    private func start() {
        guard let p = bank.randomElement() else { return }
        puzzle = p
        slotsLeft = []
        slotsRight = []
        pool = (p.left + p.right).shuffled()
        draggable = nil
    }
}

// Вспомогательный DropDelegate
struct DropSlotDelegate: DropDelegate {
    let onDrop: (String) -> Void
    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [.text]).first else { return false }
        provider.loadObject(ofClass: NSString.self) { obj, _ in
            if let s = obj as? String {
                DispatchQueue.main.async { onDrop(s) }
            }
        }
        return true
    }
}
