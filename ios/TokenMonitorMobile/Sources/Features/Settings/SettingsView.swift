import SwiftUI

struct SettingsView: View {
    @Environment(HubCredentials.self) private var credentials
    @Environment(DashboardModel.self) private var dashboard
    @Environment(AppTheme.self) private var theme
    @FocusState private var focusedField: Field?
    @State private var saved = false

    private enum Field { case url, secret }

    var body: some View {
        @Bindable var credentials = credentials

        Form {
            Section("Private Hub") {
                TextField("https://monitor.example.com", text: $credentials.hubURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .url)

                SecureField("Shared secret", text: $credentials.secret)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .secret)

                Button {
                    credentials.save()
                    saved = true
                    focusedField = nil
                    Task { await dashboard.refresh(credentials: credentials) }
                } label: {
                    Label(saved ? "บันทึกแล้ว" : "บันทึกและเชื่อมต่อ", systemImage: saved ? "checkmark.circle.fill" : "lock.shield")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!credentials.isConfigured)
            }

            Section("Security") {
                Label("Secret เก็บใน iPhone Keychain", systemImage: "key.fill")
                Label("แอปรับเฉพาะยอดสรุป ไม่รับ prompt หรือ source code", systemImage: "hand.raised.fill")
            }

            Section("Connection") {
                Text("Hub ต้องใช้ HTTPS เช่น Cloudflare Worker หรือ Tailscale Serve เพื่อป้องกัน secret ระหว่างทาง")
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: credentials.hubURL) { saved = false }
        .onChange(of: credentials.secret) { saved = false }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(HubCredentials.preview)
        .environment(DashboardModel.preview)
        .environment(AppTheme())
        .preferredColorScheme(.dark)
}

