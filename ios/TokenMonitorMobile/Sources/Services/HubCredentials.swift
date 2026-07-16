import Foundation
import Observation

@MainActor
@Observable
final class HubCredentials {
    private static let urlKey = "token-monitor-hub-url"
    private static let secretKey = "token-monitor-hub-secret"

    var hubURL: String
    var secret: String

    init(hubURL: String? = nil, secret: String? = nil) {
        self.hubURL = hubURL ?? UserDefaults.standard.string(forKey: Self.urlKey) ?? ""
        self.secret = secret ?? KeychainStore.read(key: Self.secretKey)
    }

    var isConfigured: Bool {
        URL(string: hubURL)?.scheme == "https" && !secret.isEmpty
    }

    func save() {
        hubURL = hubURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        UserDefaults.standard.set(hubURL, forKey: Self.urlKey)
        KeychainStore.write(secret, key: Self.secretKey)
    }

    static let preview = HubCredentials(hubURL: "https://monitor.example.com", secret: "preview-secret")
}

