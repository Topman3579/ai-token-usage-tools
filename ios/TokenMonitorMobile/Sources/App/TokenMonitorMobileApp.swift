import Foundation
import SwiftUI

@main
struct TokenMonitorMobileApp: App {
    @State private var credentials = HubCredentials()
    @State private var dashboard = DashboardModel(
        demoMode: ProcessInfo.processInfo.arguments.contains("--demo-data")
    )
    @State private var theme = AppTheme()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(credentials)
                .environment(dashboard)
                .environment(theme)
                .preferredColorScheme(.dark)
        }
    }
}
