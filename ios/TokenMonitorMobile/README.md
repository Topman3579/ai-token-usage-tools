# Token Monitor Mobile

Native SwiftUI iPhone client for the private `token-monitor` hub API.

## Architecture

- Reads `GET /api/stats` from an HTTPS hub.
- Sends the shared secret as `Authorization: Bearer …`.
- Stores the hub URL in UserDefaults and the secret in iOS Keychain.
- Never reads or uploads prompts, source code, OAuth credentials, or local AI transcripts.

## Generate and build

```bash
cd ios/TokenMonitorMobile
xcodegen generate
xcodebuild -project TokenMonitorMobile.xcodeproj \
  -scheme TokenMonitorMobile \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## Connect

1. Run a Token Monitor hub on an HTTPS URL.
2. Run the Token Monitor agent on the Mac and point it at that hub.
3. Enter the same HTTPS hub URL and shared secret in the iPhone app.

### Private HTTPS through Tailscale

If the macOS Token Monitor widget is hosting its hub on port `17321`, expose it only to your tailnet:

```bash
tailscale serve --bg 17321
tailscale serve status
```

Use the HTTPS `.ts.net` URL printed by `tailscale serve status` in the iPhone app. The iPhone must be signed in to the same tailnet. Do not use `tailscale funnel`, because that publishes the service to the public internet.

API reference: <https://github.com/Javis603/token-monitor/blob/main/docs/API.md>
