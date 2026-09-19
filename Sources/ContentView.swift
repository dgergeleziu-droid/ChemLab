// MARK: - ЛАБОРАТОРИЯ
struct LabView: View {
    @Binding var incomingReagents: [String]
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
    @State private var pendingReaction: PendingReaction? = nil
    @State private var noReactionInfo: NoReactionInfo? = nil
    @State private var conditionsInfo: ConditionsInfo? = nil
    @State private var warnedPairs: Set<String> = []
    @State private var reactingItems: Set<UUID> = []
    @State private var activeConditions: Set<ConditionType> = []
    @State private var showConditionsPanel = false
    @State private var showPeriodicTable = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()

                VStack(spacing: 0) {
                    Color.clear.frame(height: isLandscape ? 24 : 52)
                    canvasArea(size: geo.size)
                    bottomPanel(isLandscape: isLandscape)
                }

                if showIntro { IntroOverlay { withAnimation { showIntro = false } } }

                if showConditionsPanel {
                    VStack {
                        ConditionsPanel(active: $activeConditions)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        Spacer()
                    }
                    .padding(.top, isLandscape ? 24 : 52)
                    .zIndex(150)
                }

                if let msg = toastMessage, pendingReaction == nil, noReactionInfo == nil, conditionsInfo == nil {
                    VStack {
                        Spacer()
                        Text(msg).font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white).multilineTextAlignment(.center)
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .background(Color.black.opacity(0.85)).cornerRadius(20)
                            .padding(.horizontal, 24).padding(.bottom, 170)
                    }.transition(.opacity)
                }
                if let nr = noReactionInfo {
                    NoReactionOverlay(info: nr) {
                        withAnimation(.easeOut(duration: 0.2)) { noReactionInfo = nil }
                    }.zIndex(200)
                }
                if let ci = conditionsInfo {
                    ConditionsOverlay(info: ci) {
                        withAnimation(.easeOut(duration: 0.2)) { conditionsInfo = nil }
                    }.zIndex(210)
                }
            }
        }
        .alert(item: $pendingReaction) { p in
            Alert(title: Text("⚠️ Осторожно!"),
                  message: Text(p.reaction.warning ?? "Небезопасная реакция."),
                  dismissButton: .default(Text("Понятно")) {
                      applyReaction(reaction: p.reaction, aID: p.aID, bID: p.bID,
                                    aPos: p.aPos, bPos: p.bPos)
                  })
        }
        .fullScreenCover(isPresented: $showPeriodicTable) {
            PeriodicTableView(
                onSelect: { r in addReagent(r) },
                onClose: { showPeriodicTable = false }
            )
        }
        .onChange(of: incomingReagents) { reagents in
            guard !reagents.isEmpty else { return }
            for sym in reagents {
                let r = ChemistryData.findReagent(by: sym)
                    ?? Reagent(symbol: sym, name: sym, colorHex: "#94A3B8", group: .elements)
                addReagent(r)
            }
            incomingReagents = []
        }
    }

    var conditionsBadges: some View {
        HStack(spacing: 4) {
            if activeConditions.isEmpty {
                Text("Условия: обычные")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#64748B"))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color(hex: "#1E293B").opacity(0.7))
                    .cornerRadius(14)
            } else {
                ForEach(Array(activeConditions).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { c in
                    HStack(spacing: 3) {
                        Image(systemName: c.icon).font(.system(size: 9))
                        Text(c.shortLabel).font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color(hex: "#3B82F6"))
                    .cornerRadius(12)
                }
            }
        }
    }

    func canvasArea(size: CGSize) -> some View {
        ZStack {
            Color.clear.contentShape(Rectangle())
                .gesture(SimultaneousGesture(
                    DragGesture(minimumDistance: 1, coordinateSpace: .local)
                        .onChanged { v in
                            guard !isDraggingItem else { return }
                            canvasOffset = CGSize(width: lastCanvasOffset.width + v.translation.width,
                                                  height: lastCanvasOffset.height + v.translation.height)
                        }
                        .onEnded { _ in
                            guard !isDraggingItem else { return }
                            lastCanvasOffset = canvasOffset
                        },
                    MagnificationGesture()
                        .onChanged { v in canvasScale = min(max(lastCanvasScale * v, 0.35), 3.5) }
                        .onEnded { _ in lastCanvasScale = canvasScale }
                ))

            CanvasView(items: $items, effects: $effects, canvasScale: canvasScale,
                       canvasOffset: canvasOffset, screenSize: size,
                       onDragEnd: { checkReactions() },
                       onDelete: { id in withAnimation { items.removeAll { $0.id == id } } },
                       onItemDragChange: { isDraggingItem = $0 })

            VStack {
                HStack {
                    conditionsBadges
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showConditionsPanel.toggle()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Условия")
                                    .font(.system(size: 8, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: showConditionsPanel ? "#3B82F6" : "#1E293B").opacity(0.95))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(
                                    activeConditions.isEmpty ? Color.clear : Color(hex: "#22C55E"),
                                    lineWidth: 2
                                )
                            )
                        }

                        Button {
                            withAnimation {
                                canvasScale = 1; lastCanvasScale = 1
                                canvasOffset = .zero; lastCanvasOffset = .zero
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white).padding(10)
                                .background(Color(hex: "#1E293B").opacity(0.9))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 14).padding(.bottom, 14)
                }
            }
        }
    }

    func bottomPanel(isLandscape: Bool) -> some View {
        VStack(spacing: isLandscape ? 4 : 8) {
            // Табы групп
            HStack(spacing: 8) {
                ForEach(ReagentGroup.allCases, id: \.self) { g in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedGroup = g }
                    } label: {
                        Text(g.rawValue).font(.system(size: isLandscape ? 11 : 12, weight: .semibold))
                            .foregroundColor(selectedGroup == g ? .white : Color(hex: "#94A3B8"))
                            .padding(.horizontal, isLandscape ? 10 : 14)
                            .padding(.vertical, isLandscape ? 4 : 7)
                            .background(Capsule().fill(selectedGroup == g ? Color(hex: "#3B82F6") : Color(hex: "#1E293B")))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, isLandscape ? 4 : 10)

            // Кнопка "Открыть таблицу Менделеева" (только для вкладки Элементы)
            if selectedGroup == .elements {
                Button {
                    showPeriodicTable = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.grid.3x2.fill")
                            .font(.system(size: 14))
                        Text("Открыть таблицу Менделеева")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, isLandscape ? 8 : 11)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 12)
            }

            // Горизонтальный список реагентов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isLandscape ? 8 : 10) {
                    ForEach(ChemistryData.reagents.filter { $0.group == selectedGroup }) { r in
                        ReagentChip(reagent: r, size: isLandscape ? 40 : 54) { addReagent(r) }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, isLandscape ? 6 : 12)
            }
        }
        .background(Color(hex: "#0F172A"))
    }

    func addReagent(_ r: Reagent) {
        let rx = CGFloat.random(in: -80...80)
        let ry = CGFloat.random(in: -60...60)
        let wx = (rx - canvasOffset.width) / canvasScale
        let wy = (ry - canvasOffset.height) / canvasScale
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.append(WorldItem(symbol: r.symbol, displayName: r.name,
                worldPosition: CGPoint(x: wx, y: wy), kind: .reagent, colorHex: r.colorHex))
        }
        showToast("Добавлено: \(r.name)")
    }

    func showToast(_ m: String) {
        withAnimation { toastMessage = m }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { toastMessage = nil } }
    }

    func checkReactions() {
        let th: CGFloat = 130
        let reagents = items.filter { $0.kind == .reagent }

        for i in 0..<reagents.count {
            let a = reagents[i]
            if reactingItems.contains(a.id) { continue }
            for j in (i+1)..<reagents.count {
                let b = reagents[j]
                if reactingItems.contains(b.id) { continue }

                let d = hypot(a.worldPosition.x - b.worldPosition.x,
                              a.worldPosition.y - b.worldPosition.y)
                guard d < th else { continue }

                let key = [a.symbol, b.symbol].sorted().joined(separator: "+")

                if let r = ChemistryData.findReaction(a.symbol, b.symbol) {
                    let needed = r.requiredConditions
                    let missing = needed.subtracting(activeConditions)

                    if !missing.isEmpty {
                        let alreadyWarned = warnedPairs.contains("cond_" + key)
                        if !alreadyWarned {
                            warnedPairs.insert("cond_" + key)
                            let nameA = ChemistryData.findReagent(by: a.symbol)?.name ?? a.symbol
                            let nameB = ChemistryData.findReagent(by: b.symbol)?.name ?? b.symbol
                            conditionsInfo = ConditionsInfo(
                                title: "⚙️ Нужны другие условия",
                                message: "\(nameA) и \(nameB) могут реагировать, но нужны особые условия.\n\nНе хватает: \(missing.map { $0.rawValue }.joined(separator: ", ")).\n\nОткрой панель «Условия» (справа снизу), включи их и снова соедини вещества.",
                                missing: missing
                            )
                        }
                        return
                    }

                    if r.warning != nil {
                        pendingReaction = PendingReaction(reaction: r, aID: a.id, bID: b.id,
                            aSymbol: a.symbol, bSymbol: b.symbol, aPos: a.worldPosition, bPos: b.worldPosition)
                        return
                    } else {
                        applyReaction(reaction: r, aID: a.id, bID: b.id,
                                      aPos: a.worldPosition, bPos: b.worldPosition)
                        return
                    }
                }

                if !warnedPairs.contains(key) {
                    warnedPairs.insert(key)
                    let nameA = ChemistryData.findReagent(by: a.symbol)?.name ?? a.symbol
                    let nameB = ChemistryData.findReagent(by: b.symbol)?.name ?? b.symbol
                    noReactionInfo = NoReactionInfo(
                        title: "🚫 Реакции нет",
                        message: "\(nameA) (\(a.symbol)) и \(nameB) (\(b.symbol)) не взаимодействуют друг с другом ни при каких обычных условиях.\n\nПроверь формулы и убедись, что эти вещества в принципе могут реагировать."
                    )
                    return
                }
            }
        }
    }

    func applyReaction(reaction: ChemicalReaction, aID: UUID, bID: UUID, aPos: CGPoint, bPos: CGPoint) {
        let mx = (aPos.x + bPos.x) / 2
        let my = (aPos.y + bPos.y) / 2

        var newItems: [WorldItem] = []
        for (i, sym) in reaction.products.enumerated() {
            let color = ChemistryData.findReagent(by: sym)?.colorHex ?? "#94A3B8"
            let name = reaction.productNames.indices.contains(i) ? reaction.productNames[i] : sym
            newItems.append(WorldItem(symbol: sym, displayName: name,
                worldPosition: CGPoint(x: mx + CGFloat(i) * 90, y: my),
                kind: .product, colorHex: color))
        }
        let equationItem = WorldItem(
            symbol: "eq", displayName: "Уравнение",
            worldPosition: CGPoint(x: mx, y: my - 100),
            kind: .equation, colorHex: "#3B82F6", equationText: reaction.equation
        )

        let effect = EffectAnimation(
            position: CGPoint(x: mx, y: my + 50),
            color: Color(hex: reaction.effectColorHex),
            type: reaction.effect
        )

        withAnimation(.easeOut(duration: 0.3)) {
            items.removeAll { $0.id == aID || $0.id == bID }
            items.append(contentsOf: newItems)
            items.append(equationItem)
            effects.append(effect)
        }
        showToast("⚗️ \(reaction.equation)")

        let eid = effect.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                effects.removeAll { $0.id == eid }
            }
        }
    }
}
