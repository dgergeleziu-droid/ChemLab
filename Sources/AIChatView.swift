import SwiftUI

struct AIChatView: View {
    @StateObject private var ai = AIService()
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var history: [(q: String, a: String)] = []
    @FocusState private var isFocused: Bool

    let quickQuestions = [
        "Что такое валентность?",
        "Почему Cu не реагирует с HCl?",
        "Как расставить коэффициенты?",
        "Что такое электролит?",
        "Объясни реакцию нейтрализации",
        "Какие бывают оксиды?"
    ]

    var body: some View {
        ZStack {
            Color(hex: "#0B1020").ignoresSafeArea()

            VStack(spacing: 0) {
                Color.clear.frame(height: 50)

                // Заголовок
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#3B82F6"))
                    Text("ИИ-помощник")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 12)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {

                            // Быстрые вопросы (если нет истории)
                            if history.isEmpty && answer.isEmpty && !ai.isThinking {
                                Text("Спроси что угодно по химии")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#94A3B8"))
                                    .padding(.bottom, 4)

                                ForEach(quickQuestions, id: \.self) { q in
                                    Button {
                                        question = q
                                        Task { await send() }
                                    } label: {
                                        HStack {
                                            Image(systemName: "bolt.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "#F59E0B"))
                                            Text(q)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 11))
                                                .foregroundColor(Color(hex: "#64748B"))
                                        }
                                        .padding(12)
                                        .background(RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "#1E293B")))
                                    }
                                }
                            }

                            // История
                            ForEach(Array(history.enumerated()), id: \.offset) { _, item in
                                chatBubble(text: item.q, isUser: true)
                                chatBubble(text: item.a, isUser: false)
                            }

                            // Текущий ответ
                            if !answer.isEmpty || ai.isThinking {
                                chatBubble(text: question, isUser: true)

                                if ai.isThinking {
                                    HStack(spacing: 8) {
                                        ProgressView().tint(Color(hex: "#3B82F6"))
                                        Text("Думаю...")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#94A3B8"))
                                    }
                                    .padding(12)
                                } else {
                                    chatBubble(text: answer, isUser: false)
                                }
                            }

                            if let err = ai.errorMessage {
                                Text("⚠️ \(err)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#EF4444"))
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#7F1D1D").opacity(0.5)))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .id("bottom")
                    }
                    .onChange(of: ai.isThinking) { _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                    .onChange(of: answer) { _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                // Поле ввода
                HStack(spacing: 10) {
                    TextField("Введи вопрос...", text: $question, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#1E293B")))
                        .focused($isFocused)
                        .disabled(ai.isThinking)

                    Button {
                        Task { await send() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(question.isEmpty || ai.isThinking ? Color(hex: "#334155") : Color(hex: "#3B82F6"))
                    }
                    .disabled(question.isEmpty || ai.isThinking)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: "#0F172A"))
            }
        }
    }

    func send() async {
        let q = question.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        isFocused = false
        question = ""
        answer = ""
        let response = await ai.ask(q)
        answer = response
        if !response.starts(with: "Ошибка") {
            history.append((q: q, a: response))
            answer = ""
        }
    }

    @ViewBuilder
    func chatBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14)
                    .fill(isUser ? Color(hex: "#3B82F6") : Color(hex: "#1E293B")))
                .fixedSize(horizontal: false, vertical: true)
            if !isUser { Spacer(minLength: 40) }
        }
    }
}
