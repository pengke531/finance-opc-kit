param(
  [string]$TargetRoot = "$HOME\\.openclaw"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
  $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
  throw "[finance-opc] python or python3 not found in PATH"
}

Write-Host "[finance-opc] repo root:   $repoRoot"
Write-Host "[finance-opc] target root: $TargetRoot"

Push-Location $repoRoot
try {
  & $python.Source ".\\workspace\\scripts\\deploy_profile.py" --target-root $TargetRoot --package-root $repoRoot
  if ($LASTEXITCODE -ne 0) {
    throw "[finance-opc] deploy_profile.py failed with exit code $LASTEXITCODE. See the error output above."
  }

  ${env:OPENCLAW_STATE_DIR} = $TargetRoot
  ${env:OPENCLAW_CONFIG_PATH} = Join-Path $TargetRoot "openclaw.json"

  openclaw config validate | Out-Host
  $validateExit = $LASTEXITCODE

  Write-Host ""
  if ($validateExit -eq 0) {
    Write-Host "[finance-opc] install complete."
  }
  else {
    Write-Warning "[finance-opc] profile imported, but the host config still has validation issues unrelated to this package. Run 'openclaw doctor' or fix the reported keys manually."
  }
  Write-Host "[finance-opc] next steps:"
  Write-Host "  1. Restart the OpenClaw gateway or desktop app."
  Write-Host "  2. Open a new chat session."
  Write-Host "  3. Test with: @finance_main analyze 000001.SZ"
}
finally {
  Pop-Location
}
