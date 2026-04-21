#!/bin/bash

set -euo pipefail

TARGET_ROOT="${1:-$HOME/.openclaw}"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
elif command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
else
  echo "[finance-opc] python or python3 not found in PATH" >&2
  exit 1
fi

echo "[finance-opc] repo root:   $REPO_ROOT"
echo "[finance-opc] target root: $TARGET_ROOT"

cd "$REPO_ROOT"
"$PYTHON_BIN" "./workspace/scripts/deploy_profile.py" --target-root "$TARGET_ROOT" --package-root "$REPO_ROOT"

export OPENCLAW_STATE_DIR="$TARGET_ROOT"
export OPENCLAW_CONFIG_PATH="$TARGET_ROOT/openclaw.json"

if openclaw config validate; then
  echo
  echo "[finance-opc] install complete."
else
  echo
  echo "[finance-opc] profile imported, but the host config still has validation issues unrelated to this package." >&2
  echo "[finance-opc] Run 'openclaw doctor' or fix the reported keys manually, then retry the smoke test." >&2
fi

echo "[finance-opc] next steps:"
echo "  1. Restart the OpenClaw gateway or desktop app."
echo "  2. Open a new chat session."
echo "  3. Test with: @finance_main analyze 000001.SZ"
