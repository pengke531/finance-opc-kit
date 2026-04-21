#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}/finance-opc-safety-$$"
HOST_CONFIG="$HOME/.openclaw/openclaw.json"

echo "[finance-opc] verifying package safety"

if [ ! -f "$ROOT_DIR/openclaw.json" ]; then
  echo "❌ missing openclaw.json"
  exit 1
fi

if ! grep -q '"mode"[[:space:]]*:[[:space:]]*"incremental-import"' "$ROOT_DIR/openclaw.json"; then
  echo "❌ package is not configured for incremental import"
  exit 1
fi

if [ ! -f "$ROOT_DIR/workspace/scripts/deploy_profile.py" ]; then
  echo "❌ missing deploy_profile.py"
  exit 1
fi

hash_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 '$path').Hash"
  fi
}

BEFORE_HASH="missing"
if [ -f "$HOST_CONFIG" ]; then
  BEFORE_HASH="$(hash_file "$HOST_CONFIG")"
fi

mkdir -p "$TMP_ROOT"
trap 'rm -rf "$TMP_ROOT"' EXIT

if command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
elif command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
else
  echo "❌ python or python3 not found"
  exit 1
fi

"$PYTHON_BIN" "$ROOT_DIR/workspace/scripts/deploy_profile.py" --target-root "$TMP_ROOT" --package-root "$ROOT_DIR"

if [ ! -f "$TMP_ROOT/openclaw.json" ]; then
  echo "❌ temp deployment did not produce openclaw.json"
  exit 1
fi

if command -v openclaw >/dev/null 2>&1; then
  OPENCLAW_STATE_DIR="$TMP_ROOT" OPENCLAW_CONFIG_PATH="$TMP_ROOT/openclaw.json" openclaw config validate >/dev/null
  echo "✅ temp config validates"
else
  echo "⚠️ openclaw not found; skipped config validation"
fi

AFTER_HASH="missing"
if [ -f "$HOST_CONFIG" ]; then
  AFTER_HASH="$(hash_file "$HOST_CONFIG")"
fi

if [ "$BEFORE_HASH" != "$AFTER_HASH" ]; then
  echo "❌ host config changed during safety verification"
  exit 1
fi

echo "✅ host config unchanged"
echo "✅ package safety verification passed"
