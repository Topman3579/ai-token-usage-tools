import SwiftUI

struct DashboardView: View {
    @Environment(HubCredentials.self) private var credentials
    @Environment(DashboardModel.self) private var model
    @Environment(AppTheme.self) private var theme

    var body: some View {
        @Bindable var model = model

        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    periodPicker(selection: $model.selectedPeriod)
                    content
                }
                .padding(18)
            }
            .refreshable { await model.refresh(credentials: credentials) }
        }
        .navigationTitle("Token Monitor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.background, for: .navigationBar)
        .task(id: credentials.hubURL + credentials.secret) {
            await model.startAutoRefresh(credentials: credentials)
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "sum")
                .font(.title2.bold())
            Circle()
                .fill(connectionColor)
                .frame(width: 8, height: 8)
                .accessibilityLabel(connectionLabel)
            Spacer()
            if let date = model.lastUpdated {
                Text(date, style: .time)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .foregroundStyle(.white)
    }

    private func periodPicker(selection: Binding<UsagePeriod>) -> some View {
        Picker("ช่วงเวลา", selection: selection) {
            ForEach(UsagePeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("period-picker")
    }

    @ViewBuilder
    private var content: some View {
        if let stats = model.stats {
            let summary = stats.summary(for: model.selectedPeriod)
            UsageSummaryView(summary: summary, devices: stats.devices)
        } else {
            switch model.state {
            case .idle, .loading:
                UsageSummaryView(summary: .init(totalTokens: 123_456_789, costUsd: 123.45, clients: ["codex": 100_000_000, "claude": 23_456_789]), devices: [])
                    .redacted(reason: .placeholder)
            case .failed(let message):
                ContentUnavailableView {
                    Label("ยังเชื่อมต่อไม่ได้", systemImage: "network.slash")
                } description: {
                    Text(message)
                } actions: {
                    Button("ลองใหม่") {
                        Task { await model.refresh(credentials: credentials) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .loaded:
                ContentUnavailableView("ไม่มีข้อมูล", systemImage: "tray")
            }
        }
    }

    private var connectionColor: Color {
        if case .loaded = model.state { return .green }
        if case .failed = model.state { return .red }
        return .yellow
    }

    private var connectionLabel: String {
        if case .loaded = model.state { return "เชื่อมต่อแล้ว" }
        if case .failed = model.state { return "เชื่อมต่อไม่สำเร็จ" }
        return "กำลังเชื่อมต่อ"
    }
}

private struct UsageSummaryView: View {
    @Environment(AppTheme.self) private var theme
    let summary: UsageSummary
    let devices: [DeviceSummary]

    private var sortedClients: [(name: String, tokens: Double)] {
        summary.clients.map { ($0.key, $0.value) }.sorted { $0.tokens > $1.tokens }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("TOTAL TOKENS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.secondaryText)
                Text(summary.totalTokens, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)
                    .contentTransition(.numericText())
                Text(summary.costUsd, format: .currency(code: "USD"))
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(theme.secondaryText)
            }

            Divider().overlay(Color.white.opacity(0.12))

            ForEach(sortedClients, id: \.name) { client in
                ToolUsageRow(
                    name: client.name,
                    tokens: client.tokens,
                    cost: summary.clientCosts[client.name] ?? 0,
                    proportion: summary.totalTokens > 0 ? client.tokens / summary.totalTokens : 0
                )
            }

            if !devices.isEmpty {
                Divider().overlay(Color.white.opacity(0.12))
                Label("\(devices.filter { $0.stale != true }.count) devices online", systemImage: "desktopcomputer.and.macbook")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .padding(22)
        .background(theme.panel.gradient, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        }
    }
}

private struct ToolUsageRow: View {
    @Environment(AppTheme.self) private var theme
    let name: String
    let tokens: Double
    let cost: Double
    let proportion: Double

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Label(displayName, systemImage: iconName)
                    .font(.headline.monospaced())
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(tokens, format: .number.precision(.fractionLength(0)))
                        .font(.headline.monospacedDigit())
                    Text(cost, format: .currency(code: "USD"))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(theme.secondaryText)
                }
            }
            ProgressView(value: min(max(proportion, 0), 1))
                .tint(theme.color(for: name))
        }
        .accessibilityElement(children: .combine)
    }

    private var displayName: String {
        name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }

    private var iconName: String {
        switch name.lowercased() {
        case "codex": "brain.head.profile"
        case "claude", "claude-code": "sparkles"
        case "grok", "grok-build": "chart.xyaxis.line"
        case "hermes", "hermes-agent": "figure.run"
        default: "terminal"
        }
    }
}

#Preview("Loaded") {
    NavigationStack { DashboardView() }
        .environment(HubCredentials.preview)
        .environment(DashboardModel.preview)
        .environment(AppTheme())
        .preferredColorScheme(.dark)
}

#Preview("Not configured") {
    NavigationStack { DashboardView() }
        .environment(HubCredentials(hubURL: "", secret: ""))
        .environment(DashboardModel())
        .environment(AppTheme())
        .preferredColorScheme(.dark)
}

