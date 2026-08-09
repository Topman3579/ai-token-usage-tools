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
  # Inject private hub defaults from local rose credentials (gitignored; never commit).
  /usr/bin/python3 - <<'PY'
import json, plistlib
from pathlib import Path
cred = json.loads((Path.home() / "Library/Application Support/Token Monitor/credentials.json").read_text())
secret = cred.get("hubHostSecret") or cred.get("secret")
if not secret:
    raise SystemExit("hub secret missing on this Mac — open Token Monitor host first")
out = Path("Sources/PrivateHub.plist")
with out.open("wb") as f:
    plistlib.dump({
        "hubURL": "https://rose.tailf4cb89.ts.net:17321",
        "hubSecret": secret,
    }, f)
print(f"▶ PrivateHub.plist ready (secret_len={len(secret)})")
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
