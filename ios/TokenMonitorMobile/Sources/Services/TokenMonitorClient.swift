import Foundation

struct TokenMonitorClient: Sendable {
    enum ClientError: LocalizedError {
        case invalidURL
        case unauthorized
        case server(Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL: "Hub URL ไม่ถูกต้อง ต้องเป็น HTTPS"
            case .unauthorized: "Secret ไม่ถูกต้อง หรือไม่มีสิทธิ์เข้าถึง"
            case .server(let code): "Hub ตอบกลับด้วยสถานะ \(code)"
            }
        }
    }

    func fetchStats(hubURL: String, secret: String) async throws -> HubStats {
        guard var components = URLComponents(string: hubURL), components.scheme == "https" else {
            throw ClientError.invalidURL
        }
        components.path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/api/stats"
        guard let url = components.url else { throw ClientError.invalidURL }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ClientError.server(0) }
        if http.statusCode == 401 || http.statusCode == 403 { throw ClientError.unauthorized }
        guard (200..<300).contains(http.statusCode) else { throw ClientError.server(http.statusCode) }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(HubStats.self, from: data)
    }
}

