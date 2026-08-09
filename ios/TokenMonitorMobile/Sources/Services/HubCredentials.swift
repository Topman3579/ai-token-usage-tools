import Foundation
import Observation

@MainActor
@Observable
final class HubCredentials {
    private static let urlKey = "token-monitor-hub-url"
    private static let secretKey = "token-monitor-hub-secret"

    /// Private Tailscale hub on rose — open-and-use default for commander devices.
    static let defaultHubURL = "https://rose.tailf4cb89.ts.net:17321"

    var hubURL: String
    var secret: String

    init(hubURL: String? = nil, secret: String? = nil) {
        let storedURL = UserDefaults.standard.string(forKey: Self.urlKey)
        let storedSecret = KeychainStore.read(key: Self.secretKey)
        let bundled = Self.bundledPrivateHub()

        self.hubURL = hubURL
            ?? storedURL
            ?? bundled?.url
            ?? Self.defaultHubURL
        self.secret = secret
            ?? (storedSecret.isEmpty ? (bundled?.secret ?? "") : storedSecret)

        // First launch: seed defaults so the app connects without Settings.
        if storedURL == nil {
            UserDefaults.standard.set(self.hubURL, forKey: Self.urlKey)
        }
        if storedSecret.isEmpty, !self.secret.isEmpty {
            KeychainStore.write(self.secret, key: Self.secretKey)
        }
    }

    var isConfigured: Bool {
        URL(string: hubURL)?.scheme == "https" && !secret.isEmpty
    }

    func save() {
        hubURL = hubURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        UserDefaults.standard.set(hubURL, forKey: Self.urlKey)
        KeychainStore.write(secret, key: Self.secretKey)
    }

    /// Optional build-time secrets from gitignored PrivateHub.plist (injected by upload script).
    private static func bundledPrivateHub() -> (url: String, secret: String)? {
        guard let url = Bundle.main.url(forResource: "PrivateHub", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: String] else { return nil }
        let hub = (dict["hubURL"] ?? defaultHubURL).trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = (dict["hubSecret"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !secret.isEmpty else { return nil }
        return (hub, secret)
    }

    static let preview = HubCredentials(hubURL: "https://monitor.example.com", secret: "preview-secret")
}

