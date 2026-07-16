# Token Monitor Mobile

Native SwiftUI iPhone and iPad client for the private `token-monitor` hub API.

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
3. Enter the same HTTPS hub URL and shared secret in the iPhone or iPad app.

### Private HTTPS through Tailscale

If the macOS Token Monitor widget is hosting its hub on port `17321`, expose it only to your tailnet:

```bash
tailscale serve --bg --https=17321 17321
tailscale serve status
```

Use the HTTPS `.ts.net` URL printed by `tailscale serve status` in the mobile app. Each iPhone or iPad must have Tailscale installed, be signed in to the same tailnet, and show `Connected`. Do not use `tailscale funnel`, because that publishes the service to the public internet.

## Install on a registered iPhone or iPad

1. Connect and pair the device with Xcode.
2. Enable Developer Mode in **Settings → Privacy & Security**.
3. Select the development team under **Signing & Capabilities** and keep automatic signing enabled.
4. Build and install to the physical device from Xcode.
5. On first launch, trust the developer profile if iOS or iPadOS requests it.
6. Configure the private HTTPS hub URL and shared secret. Never commit the secret to Git.

Physical installation was verified on both iPhone and iPad on 2026-07-16. For a larger tester group, use TestFlight instead of registering and cabling every device.

Apple references: [registered-device distribution](https://developer.apple.com/documentation/Xcode/distributing-your-app-to-registered-devices) and [TestFlight](https://developer.apple.com/testflight/).

API reference: <https://github.com/Javis603/token-monitor/blob/main/docs/API.md>
