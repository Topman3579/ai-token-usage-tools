import Observation
import SwiftUI

@MainActor
@Observable
final class AppTheme {
    static let accent = Color(red: 0.31, green: 0.84, blue: 0.82)
    static let codex = Color(red: 0.24, green: 0.72, blue: 0.78)
    static let claude = Color(red: 0.85, green: 0.47, blue: 0.34)
    static let grok = Color(red: 0.72, green: 0.72, blue: 0.76)
    static let hermes = Color(red: 0.88, green: 0.69, blue: 0.18)

    let background = Color(red: 0.08, green: 0.09, blue: 0.10)
    let panel = Color(red: 0.17, green: 0.19, blue: 0.20)
    let panelRaised = Color(red: 0.22, green: 0.24, blue: 0.25)
    let secondaryText = Color.white.opacity(0.58)

    func color(for client: String) -> Color {
        switch client.lowercased() {
        case "codex": AppTheme.codex
        case "claude", "claude-code": AppTheme.claude
        case "grok", "grok-build": AppTheme.grok
        case "hermes", "hermes-agent": AppTheme.hermes
        default: AppTheme.accent
        }
    }
}

