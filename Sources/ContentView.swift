import SwiftUI

struct ContentView: View {
    @State private var items: [WorldItem] = []
    @State private var effects: [EffectAnimation] = []

    @State private var canvasOffset: CGSize = .zero
    @State private var lastCanvasOffset: CGSize = .zero
    @State private var canvasScale: CGFloat = 1.0
    @State private var lastCanvasScale: CGFloat = 1.0

    @State private var selectedGroup: ReagentGroup = .elements
    @State private var showIntro = true
    @State private var toastMessage: String? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                    canvasArea(size: geo.size)
                    bottomPanel
                }

                if showIntro {
                    IntroOverlay { withAnimation { showIntro = false } }
                }

                if let msg = toastMessage {
                    VStack {
                        Spacer()
                        Text(msg)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(20)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 170)
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Верхняя панель
    var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ХимЛаб")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Интерактивная химия · 8–10 класс")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#94A3B8"))
            }
            Spacer()

            Button {
                withAnimation { items.removeAll(); effects.removeAll() }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#EF4444"))
                    .padding(10)
                    .background(Color(hex: "#1E293B"))
                    .clipShape(Circle())
            }

            Button { showIntro = true } label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#60A5FA"))
                    .padding(10)
                    .background(Color(hex: "#1E293B"))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#0F172A"))
    }

    // MARK: - Область холста
    func canvasArea(size: CGSize) -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                canvasOffset = CGSize(
                                    width: lastCanvasOffset.width + value.translation.width,
                                    height: lastCanvasOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastCanvasOffset = canvasOffset
                            },
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastCanvasScale * value
                                canvasScale = min(max(newScale, 0.35), 3.5)
                            }
                            .onEnded { _ in
                                lastCanvasScale = canvasScale
                            }
                    )
                )

            CanvasView(
                items: $items,
                effects: $effects,
                canvasScale: canvasScale,
                canvasOffset: canvasOffset,
                screenSize: size,
                onMove: { _, _ in },
                onDragEnd: { checkReactions() },
                onDelete: { id in
                    withAnimation { items.removeAll { $0.id == id } }
                }
            )

            // Кнопка сброса масштаба
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            canvasScale = 1.0
                            lastCanvasScale = 1.0
                            canvasOffset = .zero
                            lastCanvasOffset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "#1E293B").opacity(0.9))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 14)
                    .padding(.bottom, 14)
                }
            }
        }
    }

    // MARK: - Нижняя панель с реагентами
    var bottomPanel: some View {
        VStack(spacing: 8) {
            // Группы
            HStack(spacing: 8) {
                ForEach(ReagentGroup.allCases, id: \.self) { group in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedGroup = group
                        }
                    } label: {
                        Text(group.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selectedGroup == group ? .white : Color(hex: "#94A3B8"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(
                                    selectedGroup == group
                                        ? Color(hex: "#3B82F6")
                                        : Color(hex: "#1E293B")
                                )
                            )
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)

            // Список реагентов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ChemistryData.reagents.filter { $0.group == selectedGroup }) { reagent in
                        ReagentChip(reagent: reagent) {
                            addReagent(reagent)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color(hex: "#0F172A"))
    }

    // MARK: - Логика
    func addReagent(_ reagent: Reagent) {
        let randomX = CGFloat.random(in: -80...80)
        let randomY = CGFloat.random(in: -60...60)

        // переводим экранные координаты в мировые
        let worldX = (randomX - canvasOffset.width) / canvasScale
        let worldY = (randomY - canvasOffset.height) / canvasScale

        let newItem = WorldItem(
            symbol: reagent.symbol,
            displayName: reagent.name,
            worldPosition: CGPoint(x: worldX, y: worldY),
            kind: .reagent,
            colorHex: reagent.colorHex
        )
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.append(newItem)
        }
        showToast("Добавлено: \(reagent.name)")
    }

    func showToast(_ msg: String) {
        withAnimation { toastMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { toastMessage = nil }
        }
    }

    // MARK: - Проверка реакций
    func checkReactions() {
        let proximityThreshold: CGFloat = 90

        var reacted: Set<UUID> = []
        var newItems: [WorldItem] = []
        var newEffects: [EffectAnimation] = []

        let reagentItems = items.filter { $0.kind == .reagent }

        for i in 0..<reagentItems.count {
            let a = reagentItems[i]
            if reacted.contains(a.id) { continue }

            for j in (i+1)..<reagentItems.count {
                let b = reagentItems[j]
                if reacted.contains(b.id) { continue }

                let dx = a.worldPosition.x - b.worldPosition.x
                let dy = a.worldPosition.y - b.worldPosition.y
                let distance = sqrt(dx*dx + dy*dy)

                if distance < proximityThreshold {
                    if let reaction = ChemistryData.findReaction(a.symbol, b.symbol) {
                        reacted.insert(a.id)
                        reacted.insert(b.id)

                        let midX = (a.worldPosition.x + b.worldPosition.x) / 2
                        let midY = (a.worldPosition.y + b.worldPosition.y) / 2

                        // Продукт(ы)
                        for (index, productSymbol) in reaction.products.enumerated() {
                            let productColor = ChemistryData.findReagent(by: productSymbol)?.colorHex ?? "#94A3B8"
                            let productName = reaction.productNames.indices.contains(index)
                                ? reaction.productNames[index]
                                : productSymbol

                            let productItem = WorldItem(
                                symbol: productSymbol,
                                displayName: productName,
                                worldPosition: CGPoint(
                                    x: midX + CGFloat(index) * 90,
                                    y: midY + 70
                                ),
                                kind: .product,
                                colorHex: productColor
                            )
                            newItems.append(productItem)
                        }

                        // Уравнение
                        let equationItem = WorldItem(
                            symbol: "eq",
                            displayName: "Уравнение",
                            worldPosition: CGPoint(x: midX, y: midY - 90),
                            kind: .equation,
                            colorHex: "#3B82F6",
                            equationText: reaction.equation
                        )
                        newItems.append(equationItem)

                        // Эффект
                        newEffects.append(
                            EffectAnimation(
                                position: CGPoint(x: midX, y: midY),
                                color: Color(hex: reaction.effectColorHex),
                                type: reaction.effect
                            )
                        )

                        showToast("⚗️ \(reaction.equation)")
                        break
                    }
                }
            }
        }

        guard !reacted.isEmpty else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            items.removeAll { reacted.contains($0.id) }
            items.append(contentsOf: newItems)
            effects.append(contentsOf: newEffects)
        }

        // Запоминаем ID новых эффектов, чтобы удалить только их
        let newEffectIDs = Set(newEffects.map { $0.id })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation {
                effects.removeAll(where: { newEffectIDs.contains($0.id) })
            }
        }
    }
}

// MARK: - Кнопка реагента
struct ReagentChip: View {
    let reagent: Reagent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: reagent.colorHex),
                                    Color(hex: reagent.colorHex).opacity(0.55)
                                ]),
                                center: .topLeading,
                                startRadius: 4,
                                endRadius: 40
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))

                    Text(reagent.symbol)
                        .font(.system(size: reagent.symbol.count > 3 ? 11 : (reagent.symbol.count > 2 ? 14 : 18), weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 2)
                }
                Text(reagent.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: "#94A3B8"))
                    .lineLimit(1)
                    .frame(width: 64)
            }
        }
    }
}

// MARK: - Обучающий оверлей
struct IntroOverlay: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("🧪 ХимЛаб")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Text("Интерактивная песочница для изучения химии")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#94A3B8"))
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 12) {
                    introRow(icon: "hand.tap", text: "Тапни по элементу внизу — он появится на холсте")
                    introRow(icon: "hand.draw", text: "Перетаскивай элементы пальцем")
                    introRow(icon: "arrow.left.and.right", text: "Двигай холст одним пальцем, масштабируй двумя")
                    introRow(icon: "flame", text: "Соедини два реагента рядом — начнётся реакция")
                    introRow(icon: "text.alignleft", text: "Уравнение реакции тоже можно двигать")
                    introRow(icon: "hand.tap.fill", text: "Двойной тап по элементу — удалить")
                }
                .padding(16)
                .background(Color(hex: "#1E293B"))
                .cornerRadius(16)
                .padding(.horizontal, 8)

                Button(action: onClose) {
                    Text("Начать")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#3B82F6"))
                        .cornerRadius(14)
                }
            }
            .padding(24)
        }
    }

    func introRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#60A5FA"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
