import Foundation

@MainActor
class AIService: ObservableObject {
    @Published var isThinking = false
    @Published var errorMessage: String? = nil

    // ⚠️ ВСТАВЬ СВОЙ BASE64-КЛЮЧ СЮДА
    private let authKey = "MDFhMGJhOWQtMTU4MS03NjkzLThiNzUtM2Q4NGFjMzRjZjhmOmM4NjYyOWE1LWYwOWMtNDVjOS1hYjMyLTljNGJmOGI3OTUzMA=="

    private let oauthURL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
    private let apiURL = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions"

    private var accessToken: String? = nil
    private var tokenExpiry: Date = .distantPast

    // MARK: - Получение токена
    private func getToken() async throws -> String {
        if let token = accessToken, Date() < tokenExpiry {
            return token
        }

        var request = URLRequest(url: URL(string: oauthURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "RqUID")
        request.httpBody = "scope=GIGACHAT_API_PERS".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "AI", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка авторизации GigaChat"])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["access_token"] as? String else {
            throw NSError(domain: "AI", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Токен не получен"])
        }

        accessToken = token
        tokenExpiry = Date().addingTimeInterval(25 * 60) // токен живёт 30 мин, обновим за 5 мин до конца
        return token
    }

    // MARK: - Запрос к ИИ
    func ask(_ question: String) async -> String {
        isThinking = true
        errorMessage = nil
        defer { isThinking = false }

        do {
            let token = try await getToken()

            var request = URLRequest(url: URL(string: apiURL)!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let systemPrompt = """
            Ты — помощник по химии для школьника. Отвечай кратко, чётко, по делу.
            Только факты и примеры. Без воды. Максимум 5–7 предложений.
            """

            let body: [String: Any] = [
                "model": "GigaChat",
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": question]
                ],
                "temperature": 0.6,
                "max_tokens": 800
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 40
            let session = URLSession(configuration: config,
                                     delegate: SSLBypassDelegate(),
                                     delegateQueue: nil)

            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                throw NSError(domain: "AI", code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Ошибка API: \(raw)"])
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw NSError(domain: "AI", code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "Пустой ответ от ИИ"])
            }

            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            errorMessage = error.localizedDescription
            return "Ошибка: \(error.localizedDescription)"
        }
    }
}

// MARK: - Отключение проверки SSL (Сбер использует самоподписанный сертификат)
class SSLBypassDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
