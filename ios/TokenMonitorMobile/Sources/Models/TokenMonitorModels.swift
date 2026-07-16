import Foundation

enum UsagePeriod: String, CaseIterable, Identifiable {
    case today = "DAY"
    case month = "MONTH"
    case allTime = "TOTAL"

    var id: Self { self }
}

struct HubStats: Decodable, Sendable {
    let periods: Periods
    let devices: [DeviceSummary]
    let limits: LimitsSummary?

    struct Periods: Decodable, Sendable {
        let today: UsageSummary
        let month: UsageSummary
        let allTime: UsageSummary
    }

    static let sample = HubStats(
        periods: .init(
            today: .init(totalTokens: 163_412_296, costUsd: 145.79, clients: ["codex": 142_914_242, "claude": 20_405_653, "grok": 46_394, "hermes": 46_007], clientCosts: ["codex": 126.25, "claude": 19.21, "grok": 0.0928, "hermes": 0.2302]),
            month: .init(totalTokens: 621_550_200, costUsd: 488.42, clients: ["codex": 510_000_000, "claude": 111_550_200], clientCosts: ["codex": 380.12, "claude": 108.30]),
            allTime: .init(totalTokens: 2_840_100_000, costUsd: 2_148.90, clients: ["codex": 2_100_000_000, "claude": 740_100_000], clientCosts: ["codex": 1_500.20, "claude": 648.70])
        ),
        devices: [.init(id: "mac-pro", hostname: "Mac Pro", stale: false, updatedAt: Date())],
        limits: nil
    )
}

struct UsageSummary: Decodable, Sendable {
    let totalTokens: Double
    let costUsd: Double
    let clients: [String: Double]
    let clientCosts: [String: Double]

    init(totalTokens: Double = 0, costUsd: Double = 0, clients: [String: Double] = [:], clientCosts: [String: Double] = [:]) {
        self.totalTokens = totalTokens
        self.costUsd = costUsd
        self.clients = clients
        self.clientCosts = clientCosts
    }

    enum CodingKeys: String, CodingKey {
        case totalTokens, costUsd, clients, clientCosts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalTokens = try container.decodeIfPresent(Double.self, forKey: .totalTokens) ?? 0
        costUsd = try container.decodeIfPresent(Double.self, forKey: .costUsd) ?? 0
        clients = try container.decodeIfPresent([String: Double].self, forKey: .clients) ?? [:]
        clientCosts = try container.decodeIfPresent([String: Double].self, forKey: .clientCosts) ?? [:]
    }
}

struct DeviceSummary: Decodable, Identifiable, Sendable {
    let id: String
    let hostname: String?
    let stale: Bool?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, deviceId, hostname, stale, updatedAt
    }

    init(id: String, hostname: String?, stale: Bool?, updatedAt: Date?) {
        self.id = id
        self.hostname = hostname
        self.stale = stale
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? container.decodeIfPresent(String.self, forKey: .deviceId)
            ?? UUID().uuidString
        hostname = try container.decodeIfPresent(String.self, forKey: .hostname)
        stale = try container.decodeIfPresent(Bool.self, forKey: .stale)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}

struct LimitsSummary: Decodable, Sendable {
    let providers: [ProviderLimit]
}

struct ProviderLimit: Decodable, Identifiable, Sendable {
    let provider: String
    let status: String?
    let windows: [LimitWindow]
    var id: String { provider }
}

struct LimitWindow: Decodable, Identifiable, Sendable {
    let kind: String
    let usedPercent: Double?
    let remainingPercent: Double?
    let resetsAt: Date?
    var id: String { kind }
}

extension HubStats {
    func summary(for period: UsagePeriod) -> UsageSummary {
        switch period {
        case .today: periods.today
        case .month: periods.month
        case .allTime: periods.allTime
        }
    }
}

