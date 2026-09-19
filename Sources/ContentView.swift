import SwiftUI

struct ContentView: View {
    @State private var mode: AppMode = .lab

    var body: some View {
        ZStack {
            if mode == .lab { LabView() } else { ExamView() }
        }
        .overlay(alignment: .top) {
            HStack {
                Spacer()
                Picker("Режим", selection: $mode) {
                    Text("🧪 Лаборатория").tag(AppMode.lab)
                    Text("📝 Экзамен ОГЭ").tag(AppMode.exam)
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
        }
    }
}

enum AppMode { case lab, exam }

// MARK: - РЕЖИМ ЛАБОРАТОРИИ
struct LabView: View {
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

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: 50)
                    canvasArea(size: geo.size)
                    bottomPanel
                }
                if showIntro { IntroOverlay { withAnimation { showIntro = false } } }
                if let msg = toastMessage {
                    VStack {
                        Spacer()
                        Text(msg).font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white).multilineTextAlignment(.center)
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .background(Color.black.opacity(0.85)).cornerRadius(20)
                            .padding(.horizontal, 24).padding(.bottom, 170)
                    }
                    .transition(.opacity)
                }
            }
        }
        .alert(item: $pendingReaction) { p in
            Alert(title: Text("⚠️ Осторожно!"),
                  message: Text(p.reaction.warning ?? "Небезопасная реакция."),
                  dismissButton: .default(Text("Понятно")) {
                      applyReaction(reaction: p.reaction, aID: p.aID, bID: p.bID, aPos: p.aPos, bPos: p.bPos)
                  })
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
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            canvasScale = 1; lastCanvasScale = 1
                            canvasOffset = .zero; lastCanvasOffset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white).padding(10)
                            .background(Color(hex: "#1E293B").opacity(0.9)).clipShape(Circle())
                    }
                    .padding(.trailing, 14).padding(.bottom, 14)
                }
            }
        }
    }

    var bottomPanel: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(ReagentGroup.allCases, id: \.self) { g in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedGroup = g }
                    } label: {
                        Text(g.rawValue).font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selectedGroup == g ? .white : Color(hex: "#94A3B8"))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Capsule().fill(selectedGroup == g ? Color(hex: "#3B82F6") : Color(hex: "#1E293B")))
                    }
                }
                Spacer()
            }.padding(.horizontal, 12).padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ChemistryData.reagents.filter { $0.group == selectedGroup }) { r in
                        ReagentChip(reagent: r) { addReagent(r) }
                    }
                }.padding(.horizontal, 12).padding(.bottom, 12)
            }
        }.background(Color(hex: "#0F172A"))
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
            for j in (i+1)..<reagents.count {
                let b = reagents[j]
                let d = hypot(a.worldPosition.x - b.worldPosition.x, a.worldPosition.y - b.worldPosition.y)
                guard d < th else { continue }
                if let r = ChemistryData.findReaction(a.symbol, b.symbol) {
                    if r.warning != nil {
                        pendingReaction = PendingReaction(reaction: r, aID: a.id, bID: b.id,
                            aSymbol: a.symbol, bSymbol: b.symbol, aPos: a.worldPosition, bPos: b.worldPosition)
                        return
                    } else {
                        applyReaction(reaction: r, aID: a.id, bID: b.id, aPos: a.worldPosition, bPos: b.worldPosition)
                        return
                    }
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
                worldPosition: CGPoint(x: mx + CGFloat(i) * 90, y: my + 70), kind: .product, colorHex: color))
        }
        newItems.append(WorldItem(symbol: "eq", displayName: "Уравнение",
            worldPosition: CGPoint(x: mx, y: my - 90), kind: .equation,
            colorHex: "#3B82F6", equationText: reaction.equation))
        let effect = EffectAnimation(position: CGPoint(x: mx, y: my),
            color: Color(hex: reaction.effectColorHex), type: reaction.effect)
        withAnimation(.easeOut(duration: 0.3)) {
            items.removeAll { $0.id == aID || $0.id == bID }
            items.append(contentsOf: newItems)
            effects.append(effect)
        }
        showToast("⚗️ \(reaction.equation)")
        let eid = effect.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { withAnimation { effects.removeAll { $0.id == eid } } }
    }
}

// MARK: - РЕЖИМ ЭКЗАМЕНА (как sdamgia.ru)
struct ExamView: View {
    @State private var variant: ExamVariant? = nil
    @State private var currentIndex: Int = 0
    @State private var userAnswers: [UUID: String] = [:]
    @State private var showResult = false
    @State private var result: ExamResult? = nil
    @State private var equationInput: String = ""
    @State private var showExplanation = false

    var body: some View {
        ZStack {
            Color(hex: "#0B1020").ignoresSafeArea()
            VStack(spacing: 0) {
                Color.clear.frame(height: 50)
                if let v = variant, !showResult {
                    examContent(variant: v)
                } else if showResult, let r = result {
                    resultView(result: r)
                } else {
                    startScreen
                }
            }
        }
    }

    var startScreen: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("📝").font(.system(size: 80))
            Text("ОГЭ по химии").font(.system(size: 32, weight: .bold)).foregroundColor(.white)
            Text("Тренировочный вариант\nпо мотивам sdamgia.ru")
                .font(.system(size: 16)).foregroundColor(Color(hex: "#94A3B8"))
                .multilineTextAlignment(.center)
            Button {
                variant = ExamData.generateVariant(count: 10)
                currentIndex = 0
                userAnswers = [:]
                showResult = false
                equationInput = ""
            } label: {
                Text("Начать тренировку").font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color(hex: "#3B82F6")).cornerRadius(16)
            }.padding(.horizontal, 40)
            Spacer()
        }
    }

    func examContent(variant: ExamVariant) -> some View {
        let task = variant.tasks[currentIndex]
        return VStack(spacing: 0) {
            HStack {
                Text("Задание \(currentIndex + 1) из \(variant.tasks.count)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text(task.topic).font(.system(size: 11)).foregroundColor(Color(hex: "#94A3B8"))
            }.padding(.horizontal, 20).padding(.vertical, 12)
            ProgressView(value: Double(currentIndex + 1), total: Double(variant.tasks.count))
                .tint(Color(hex: "#3B82F6")).padding(.horizontal, 20)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(task.question).font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white).fixedSize(horizontal: false, vertical: true)
                    if let opts = task.options {
                        ForEach(opts, id: \.self) { opt in
                            Button {
                                userAnswers[task.id] = opt
                            } label: {
                                HStack {
                                    Image(systemName: userAnswers[task.id] == opt ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(userAnswers[task.id] == opt ? Color(hex: "#3B82F6") : Color(hex: "#475569"))
                                    Text(opt).font(.system(size: 15)).foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }.padding(14)
                                .background(RoundedRectangle(cornerRadius: 12)
                                    .fill(userAnswers[task.id] == opt ? Color(hex: "#1E3A8A").opacity(0.5) : Color(hex: "#1E293B")))
                            }
                        }
                    }
                    if task.type == .shortAnswer || task.type == .equationInput {
                        TextField("Введите ответ...", text: $equationInput)
                            .textFieldStyle(.plain).font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white).padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
                            .keyboardType(task.type == .equationInput ? .numbersAndPunctuation : .default)
                            .onChange(of: equationInput) { v in userAnswers[task.id] = v }
                    }
                    if showExplanation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Решение:").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: "#F59E0B"))
                            Text(task.explanation).font(.system(size: 14)).foregroundColor(Color(hex: "#CBD5E1"))
                                .fixedSize(horizontal: false, vertical: true)
                        }.padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
                    }
                }.padding(20)
            }
            HStack(spacing: 12) {
                if currentIndex > 0 {
                    Button {
                        currentIndex -= 1
                        equationInput = userAnswers[variant.tasks[currentIndex].id] ?? ""
                        showExplanation = false
                    } label: {
                        Text("← Назад").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            .padding(.vertical, 14).padding(.horizontal, 20)
                            .background(Color(hex: "#1E293B")).cornerRadius(12)
                    }
                }
                Button { showExplanation.toggle() } label: {
                    Text(showExplanation ? "Скрыть" : "Подсказка")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#F59E0B"))
                        .padding(.vertical, 14).padding(.horizontal, 16)
                        .background(Color(hex: "#1E293B")).cornerRadius(12)
                }
                Spacer()
                Button {
                    if currentIndex < variant.tasks.count - 1 {
                        currentIndex += 1
                        equationInput = userAnswers[variant.tasks[currentIndex].id] ?? ""
                        showExplanation = false
                    } else {
                        finishExam(variant: variant)
                    }
                } label: {
                    Text(currentIndex < variant.tasks.count - 1 ? "Далее →" : "Завершить")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        .padding(.vertical, 14).padding(.horizontal, 24)
                        .background(Color(hex: "#3B82F6")).cornerRadius(12)
                }
            }.padding(20)
        }
    }

    func finishExam(variant: ExamVariant) {
        var correct = 0
        var details: [(Int, String, String, Bool)] = []
        for (i, task) in variant.tasks.enumerated() {
            let userAns = (userAnswers[task.id] ?? "").trimmingCharacters(in: .whitespaces).lowercased()
            let correctAns = task.correctAnswer.lowercased()
            let isCorrect = userAns == correctAns
            if isCorrect { correct += 1 }
            details.append((i + 1, userAnswers[task.id] ?? "—", task.correctAnswer, isCorrect))
        }
        let score = correct * 2
        let grade: Int
        switch score {
        case 0...8: grade = 2
        case 9...15: grade = 3
        case 16...25: grade = 4
        default: grade = 5
        }
        result = ExamResult(totalTasks: variant.tasks.count, correctCount: correct, score: score, grade: grade, details: details)
        showResult = true
    }

    func resultView(result: ExamResult) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("📊 Результат").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 20) {
                    VStack {
                        Text("\(result.correctCount)/\(result.totalTasks)")
                            .font(.system(size: 32, weight: .bold)).foregroundColor(Color(hex: "#3B82F6"))
                        Text("Верных").font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
                    }
                    VStack {
                        Text("\(result.score)").font(.system(size: 32, weight: .bold)).foregroundColor(Color(hex: "#F59E0B"))
                        Text("Баллов").font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
                    }
                    VStack {
                        Text("\(result.grade)").font(.system(size: 32, weight: .bold))
                            .foregroundColor(result.grade >= 4 ? Color(hex: "#22C55E") : (result.grade == 3 ? Color(hex: "#F59E0B") : Color(hex: "#EF4444")))
                        Text("Оценка").font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
                    }
                }.padding(20).background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#1E293B")))
                VStack(alignment: .leading, spacing: 12) {
                    Text("Разбор заданий").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    ForEach(result.details, id: \.0) { d in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: d.3 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(d.3 ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Задание \(d.0)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                                Text("Ваш ответ: \(d.1)").font(.system(size: 12)).foregroundColor(Color(hex: "#94A3B8"))
                                if !d.3 {
                                    Text("Правильный: \(d.2)").font(.system(size: 12)).foregroundColor(Color(hex: "#F59E0B"))
                                }
                            }
                            Spacer()
                        }.padding(12).background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1E293B")))
                    }
                }.padding(.horizontal, 20)
                Button {
                    variant = nil; showResult = false; result = nil
                } label: {
                    Text("Пройти заново").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "#3B82F6")).cornerRadius(14)
                }
                .padding(.horizontal, 20).padding(.bottom, 40)
            }.padding(.top, 20)
        }
    }
}

// MARK: - Вспомогательные View
struct ReagentChip: View {
    let reagent: Reagent
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(RadialGradient(
                        gradient: Gradient(colors: [Color(hex: reagent.colorHex), Color(hex: reagent.colorHex).opacity(0.55)]),
                        center: .topLeading, startRadius: 4, endRadius: 40))
                        .frame(width: 54, height: 54)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                    Text(reagent.symbol)
                        .font(.system(size: reagent.symbol.count > 3 ? 10 : (reagent.symbol.count > 2 ? 13 : 17), weight: .bold))
                        .foregroundColor(.white).minimumScaleFactor(0.5).lineLimit(1).padding(.horizontal, 2)
                }
                Text(reagent.name).font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: "#94A3B8")).lineLimit(1).frame(width: 64)
            }
        }
    }
}

struct IntroOverlay: View {
    let onClose: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 18) {
                Text("🧪 ХимЛаб").font(.system(size: 30, weight: .bold)).foregroundColor(.white)
                Text("Интерактивная песочница + подготовка к ОГЭ")
                    .font(.system(size: 14)).foregroundColor(Color(hex: "#94A3B8")).multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 12) {
                    row(icon: "hand.tap", text: "Тапни по элементу внизу — он появится на холсте")
                    row(icon: "hand.draw", text: "Перетаскивай элементы пальцем")
                    row(icon: "arrow.left.and.right", text: "Двигай холст одним пальцем, масштабируй двумя")
                    row(icon: "flame", text: "Соедини два реагента рядом — начнётся реакция")
                    row(icon: "hand.tap.fill", text: "Двойной тап по элементу — удалить")
                    row(icon: "pencil.and.list.clipboard", text: "Режим «Экзамен» — тренировка ОГЭ")
                }.padding(16).background(Color(hex: "#1E293B")).cornerRadius(16).padding(.horizontal, 8)
                Button(action: onClose) {
                    Text("Начать").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(hex: "#3B82F6")).cornerRadius(14)
                }
            }.padding(24)
        }
    }
    func row(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(Color(hex: "#60A5FA")).frame(width: 24)
            Text(text).font(.system(size: 13)).foregroundColor(.white).fixedSize(horizontal: false, vertical: true)
        }
    }
}
