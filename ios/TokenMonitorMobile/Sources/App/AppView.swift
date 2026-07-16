import SwiftUI

struct AppView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Monitor", systemImage: "sum")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    AppView()
        .environment(HubCredentials.preview)
        .environment(DashboardModel.preview)
        .environment(AppTheme())
        .preferredColorScheme(.dark)
}

