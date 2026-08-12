#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

if git -C "$REPO_ROOT" grep -I -q -E \
  'https?://[[:alnum:]-]+(\.[[:alnum:]-]+)*\.ts\.net(:[[:digit:]]+)?' -- .; then
  print -u2 "public-config check failed: tracked Tailscale hostname URL detected"
  exit 1
fi

if git -C "$REPO_ROOT" grep -I -q -E \
  '(^|[^[:digit:]])100\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}([^[:digit:]]|$)' -- .; then
  print -u2 "public-config check failed: tracked Tailscale-range address detected"
  exit 1
fi

if ! git -C "$REPO_ROOT" grep -q -F 'https://hub.example.invalid' -- \
  ios/TokenMonitorMobile/INSTALL_TH.md \
  ios/TokenMonitorMobile/Sources/Services/HubCredentials.swift; then
  print -u2 "public-config check failed: safe example URL missing"
  exit 1
fi

print "public-config check passed"
