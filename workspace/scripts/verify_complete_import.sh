#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}/finance-opc-verify-$$"

echo "[finance-opc] running package verification"

REQUIRED_FILES=(
  "openclaw.json"
  ".env.template"
  "install-finance-opc.ps1"
  "install.sh"
  "workspace/SOUL.md"
  "workspace/AGENTS.md"
  "workspace/TOOLS.md"
  "agents/finance_data/SOUL.md"
  "agents/finance_analysis/SOUL.md"
  "agents/finance_trading/SOUL.md"
  "agents/finance_monitor/SOUL.md"
  "workspace/scripts/deploy_profile.py"
)

for rel in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$ROOT_DIR/$rel" ]; then
    echo "❌ missing $rel"
    exit 1
  fi
done

echo "✅ required package files exist"

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

for agent_id in finance_main finance_data finance_analysis finance_trading finance_monitor; do
  if ! grep -q "\"id\"[[:space:]]*:[[:space:]]*\"$agent_id\"" "$TMP_ROOT/openclaw.json"; then
    echo "❌ missing agent registration for $agent_id"
    exit 1
  fi
done

echo "✅ agent registrations found in merged config"

if [ ! -f "$TMP_ROOT/domains/finance-opc/.env" ]; then
  echo "❌ .env was not created for deployed domain"
  exit 1
fi

echo "✅ domain .env created"

if command -v openclaw >/dev/null 2>&1; then
  OPENCLAW_STATE_DIR="$TMP_ROOT" OPENCLAW_CONFIG_PATH="$TMP_ROOT/openclaw.json" openclaw config validate >/dev/null
  echo "✅ temp deployment config validates"
else
  echo "⚠️ openclaw not found; skipped config validation"
fi

echo "✅ package verification passed"
