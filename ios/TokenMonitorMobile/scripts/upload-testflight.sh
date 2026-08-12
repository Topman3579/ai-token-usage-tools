#!/bin/zsh
# Archive + export + upload Token Monitor Mobile to TestFlight.
# Requires App Store Connect app record for net.topmanidmb.TokenMonitorMobile
# (create once in ASC web — API key cannot CREATE apps).
set -euo pipefail
cd "${0:A:h:h}"
KEY_ID=L8QB234WH9
ISSUER=69a6de74-6042-47e3-e053-5b8c7c11a4d1
export API_PRIVATE_KEYS_DIR="$HOME/.appstoreconnect/private_keys"
CLEAN_PATH=/usr/bin:/bin:/usr/sbin:/sbin

if [[ "${1:-}" == "--archive" ]]; then
  # Inject build-only private configuration. Sources/PrivateHub.plist is gitignored.
  /usr/bin/python3 - <<'PY'
import json
import os
import plistlib
from pathlib import Path
from urllib.parse import urlsplit

credentials_path = Path.home() / "Library/Application Support/Token Monitor/credentials.json"
credentials = json.loads(credentials_path.read_text())
secret = credentials.get("hubHostSecret") or credentials.get("secret")
hub_url = (
    os.environ.get("TOKEN_MONITOR_HUB_URL")
    or credentials.get("hubURL")
    or credentials.get("hubUrl")
    or credentials.get("hubHostURL")
    or credentials.get("hubHostUrl")
    or ""
).strip().rstrip("/")

if not secret:
    raise SystemExit("hub secret missing on this Mac — open Token Monitor host first")
if not hub_url:
    raise SystemExit("hub URL missing — set TOKEN_MONITOR_HUB_URL to the private HTTPS URL")

try:
    parsed = urlsplit(hub_url)
    port = parsed.port
except ValueError as error:
    raise SystemExit(f"invalid hub URL: {error}") from error

if parsed.scheme != "https" or not parsed.hostname:
    raise SystemExit("hub URL must use HTTPS and include a hostname")
if parsed.username is not None or parsed.password is not None:
    raise SystemExit("hub URL must not contain credentials")
if parsed.query or parsed.fragment:
    raise SystemExit("hub URL must not contain a query or fragment")
if parsed.hostname.endswith(".invalid"):
    raise SystemExit("replace the documentation placeholder with the private hub URL")
if port is not None and not 1 <= port <= 65535:
    raise SystemExit("hub URL port must be between 1 and 65535")

output = Path("Sources/PrivateHub.plist")
with output.open("wb") as file:
    plistlib.dump({"hubURL": hub_url, "hubSecret": secret}, file)
print("▶ PrivateHub.plist ready (private values omitted)")
PY
  # bump build
  CUR=$(grep 'CURRENT_PROJECT_VERSION:' project.yml | grep -oE '[0-9]+' | head -1)
  NEXT=$((CUR + 1))
  sed -i '' "s/CURRENT_PROJECT_VERSION: \"$CUR\"/CURRENT_PROJECT_VERSION: \"$NEXT\"/" project.yml
  echo "▶ build $NEXT"
  xcodegen generate >/dev/null
  rm -rf build/TokenMonitor.xcarchive build/export-ipa
  xcodebuild -project TokenMonitorMobile.xcodeproj -scheme TokenMonitorMobile \
    -configuration Release -destination 'generic/platform=iOS' \
    -archivePath build/TokenMonitor.xcarchive archive -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=PV32ZHE46M
  env PATH="$CLEAN_PATH" xcodebuild -exportArchive \
    -archivePath build/TokenMonitor.xcarchive \
    -exportOptionsPlist ExportOptions-export.plist \
    -exportPath build/export-ipa -allowProvisioningUpdates
fi

IPA="$(ls -1 build/export-ipa/*.ipa | head -1)"
[[ -f "$IPA" ]] || { print -u2 "IPA missing — run with --archive first"; exit 1; }

print "▶ validate $IPA"
xcrun altool --validate-app -f "$IPA" -t ios --apiKey "$KEY_ID" --apiIssuer "$ISSUER"
print "▶ upload"
xcrun altool --upload-app -f "$IPA" -t ios --apiKey "$KEY_ID" --apiIssuer "$ISSUER"
print "✅ uploaded — wait 5–20 min in TestFlight"
