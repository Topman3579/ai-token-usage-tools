#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

if git -C "$REPO_ROOT" grep -I -q -E \
  'https?://[[:alnum:]-]+(\.[[:alnum:]-]+)*\.ts\.net(:[[:digit:]]+)?' -- .; then
  printf '%s\n' "public-config check failed: tracked Tailscale hostname URL detected" >&2
  exit 1
fi

if git -C "$REPO_ROOT" grep -I -q -E \
  '(^|[^[:digit:]])100\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}([^[:digit:]]|$)' -- .; then
  printf '%s\n' "public-config check failed: tracked Tailscale-range address detected" >&2
  exit 1
fi

if ! git -C "$REPO_ROOT" grep -q -F 'https://hub.example.invalid' -- \
  ios/TokenMonitorMobile/INSTALL_TH.md \
  ios/TokenMonitorMobile/Sources/Services/HubCredentials.swift; then
  printf '%s\n' "public-config check failed: safe example URL missing" >&2
  exit 1
fi

printf '%s\n' "public-config check passed"
