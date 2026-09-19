import SwiftUI

struct ContentView: View {
    @State private var items: [WorldItem] = []
    @State private var effects: [EffectAnimation] = []

    @State private var canvasOffset: CGSize = .zero
    @State private var lastCanvasOffset: CGSize = .zero
    @State private var canvasScale: CGFloat = 1.0
    @State private var lastCanvasScale: CGFloat = 1.0
    @State private var isDraggingItem = false

    @State private var selectedGroup: ReagentGroup = .elements
    @State private var showIntro = true
    @State private var toastMessage: String? = nil

    // Ожидающая реакция, которая покажет предупреждение
    @State private var pendingReaction: PendingReaction? = nil

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
        // Алерт с предупреждением о неправильном действии
        .alert(item: $pendingReaction) { pending in
            Alert(
                title: Text("⚠️ Осторожно!"),
                message: Text(pending.reaction.warning ?? "Небезопасная реакция."),
                dismissButton: .default(Text("Понятно")) {
                    // После закрытия алерта — выполняем реакцию
                    applyReaction(
                        reaction: pending.reaction,
                        aID: pending.aID,
                        bID: pending.bID,
                        aPos: pending.aPos,
                        bPos: pending.bPos
                    )
                }
            )
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

    // MARK: - Холст
    func canvasArea(size: CGSize) -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        DragGesture(minimumDistance: 1, coordinateSpace: .local)
                            .onChanged { value in
                                guard !isDraggingItem else { return }
                                canvasOffset = CGSize(
                                    width: lastCanvasOffset.width + value.translation.width,
                                    height: lastCanvasOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                guard !isDraggingItem else { return }
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
                onDragEnd: { checkReactions() },
                onDelete: { id in
                    withAnimation { items.removeAll { $0.id == id } }
                },
                onItemDragChange: { dragging in
                    isDraggingItem = dragging
                }
            )

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

    // MARK: - Нижняя панель
    var bottomPanel: some View {
        VStack(spacing: 8) {
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

    // MARK: - Логика добавления
    func addReagent(_ reagent: Reagent) {
        let randomX = CGFloat.random(in: -80...80)
        let randomY = CGFloat.random(in: -60...60)

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
        let proximityThreshold: CGFloat = 130

        let reagentItems = items.filter { $0.kind == .reagent }

        for i in 0..<reagentItems.count {
            let a = reagentItems[i]
            for j in (i+1)..<reagentItems.count {
                let b = reagentItems[j]

                let dx = a.worldPosition.x - b.worldPosition.x
                let dy = a.worldPosition.y - b.worldPosition.y
                let distance = sqrt(dx*dx + dy*dy)

                if distance < proximityThreshold {
                    if let reaction = ChemistryData.findReaction(a.symbol, b.symbol) {

                        if let _ = reaction.warning {
                            // Есть предупреждение — показываем алерт
                            pendingReaction = PendingReaction(
                                reaction: reaction,
                                aID: a.id,
                                bID: b.id,
                                aSymbol: a.symbol,
                                bSymbol: b.symbol,
                                aPos: a.worldPosition,
                                bPos: b.worldPosition
                            )
                            return
                        } else {
                            // Нет предупреждения — применяем сразу
                            applyReaction(
                                reaction: reaction,
                                aID: a.id,
                                bID: b.id,
                                aPos: a.worldPosition,
                                bPos: b.worldPosition
                            )
                            return
                        }
                    }
                }
            }
        }
    }

    // MARK: - Применение реакции
    func applyReaction(reaction: ChemicalReaction,
                       aID: UUID, bID: UUID,
                       aPos: CGPoint, bPos: CGPoint) {

        let midX = (aPos.x + bPos.x) / 2
        let midY = (aPos.y + bPos.y) / 2

        var newItems: [WorldItem] = []

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

        let equationItem = WorldItem(
            symbol: "eq",
            displayName: "Уравнение",
            worldPosition: CGPoint(x: midX, y: midY - 90),
            kind: .equation,
            colorHex: "#3B82F6",
            equationText: reaction.equation
        )
        newItems.append(equationItem)

        let effect = EffectAnimation(
            position: CGPoint(x: midX, y: midY),
            color: Color(hex: reaction.effectColorHex),
            type: reaction.effect
        )

        withAnimation(.easeOut(duration: 0.3)) {
            items.removeAll { $0.id == aID || $0.id == bID }
            items.append(contentsOf: newItems)
            effects.append(effect)
        }

        showToast("⚗️ \(reaction.equation)")

        let effectID = effect.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation {
                effects.removeAll(where: { $0.id == effectID })
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
                    introRow(icon: "exclamationmark.triangle", text: "Если реакция опасна — увидишь предупреждение")
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
