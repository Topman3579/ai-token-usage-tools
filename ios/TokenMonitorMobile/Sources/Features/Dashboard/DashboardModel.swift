import Foundation
import Observation

@MainActor
@Observable
final class DashboardModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    var stats: HubStats?
    var state: LoadState = .idle
    var selectedPeriod: UsagePeriod = .today
    var lastUpdated: Date?

    private let client = TokenMonitorClient()
    private let demoMode: Bool

    init(demoMode: Bool = false) {
        self.demoMode = demoMode
        if demoMode {
            stats = .sample
            state = .loaded
            lastUpdated = Date()
        }
    }

    func refresh(credentials: HubCredentials) async {
        guard !demoMode else { return }
        guard credentials.isConfigured else {
            state = .failed("ตั้งค่า HTTPS Hub URL และ secret ก่อนเริ่มใช้งาน")
            return
        }
        if stats == nil { state = .loading }
        do {
            stats = try await client.fetchStats(hubURL: credentials.hubURL, secret: credentials.secret)
            lastUpdated = Date()
            state = .loaded
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func startAutoRefresh(credentials: HubCredentials) async {
        while !Task.isCancelled {
            await refresh(credentials: credentials)
            try? await Task.sleep(for: .seconds(30))
        }
    }

    static let preview: DashboardModel = {
        DashboardModel(demoMode: true)
    }()
}
