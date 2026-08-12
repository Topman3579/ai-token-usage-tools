import Foundation
import Observation

@MainActor
@Observable
final class HubCredentials {
    private static let urlKey = "token-monitor-hub-url"
    private static let secretKey = "token-monitor-hub-secret"

    /// Documentation and previews only. This host can never resolve.
    static let exampleHubURL = "https://hub.example.invalid"

    var hubURL: String
    var secret: String

    init(hubURL: String? = nil, secret: String? = nil) {
        let storedURL = UserDefaults.standard.string(forKey: Self.urlKey)
        let storedSecret = KeychainStore.read(key: Self.secretKey)
        let bundled = Self.bundledPrivateHub()

        // Resolution order keeps upgrades working while avoiding a public topology default:
        // explicit test/runtime value -> saved Settings -> build-time private plist -> empty.
        self.hubURL = Self.normalizedURL(
            hubURL
                ?? storedURL
                ?? bundled?.url
                ?? ""
        )
        self.secret = secret
            ?? (storedSecret.isEmpty ? (bundled?.secret ?? "") : storedSecret)

        if storedURL == nil, hubURL == nil, let bundledURL = bundled?.url {
            UserDefaults.standard.set(bundledURL, forKey: Self.urlKey)
        }
        if storedSecret.isEmpty, secret == nil, let bundledSecret = bundled?.secret {
            KeychainStore.write(bundledSecret, key: Self.secretKey)
        }
    }

    var isConfigured: Bool {
        Self.isValidHTTPSHubURL(hubURL) && !secret.isEmpty
    }

    func save() {
        hubURL = Self.normalizedURL(hubURL)
        UserDefaults.standard.set(hubURL, forKey: Self.urlKey)
        KeychainStore.write(secret, key: Self.secretKey)
    }

    /// Optional build-time configuration from gitignored PrivateHub.plist.
    private static func bundledPrivateHub() -> (url: String, secret: String)? {
        guard let url = Bundle.main.url(forResource: "PrivateHub", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: String] else { return nil }
        let hub = normalizedURL(dict["hubURL"] ?? "")
        let secret = (dict["hubSecret"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidHTTPSHubURL(hub), !secret.isEmpty else { return nil }
        return (hub, secret)
    }

    private static func normalizedURL(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private static func isValidHTTPSHubURL(_ value: String) -> Bool {
        guard let components = URLComponents(string: normalizedURL(value)),
              components.scheme == "https",
              components.host?.isEmpty == false,
              components.user == nil,
              components.password == nil else { return false }
        return true
    }

    static let preview = HubCredentials(hubURL: exampleHubURL, secret: "preview-secret")
}
