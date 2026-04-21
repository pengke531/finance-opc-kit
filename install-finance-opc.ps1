param(
  [string]$TargetRoot = "$HOME\\.openclaw"
)

$ErrorActionPreference = "Stop"

function Get-PythonCommand {
  $candidates = @(
    @{ Command = "py"; Args = @("-3") },
    @{ Command = "python"; Args = @() },
    @{ Command = "python3"; Args = @() }
  )

  foreach ($candidate in $candidates) {
    $cmd = Get-Command $candidate.Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
      continue
    }

    try {
      & $candidate.Command @($candidate.Args + @("--version")) | Out-Host
      if ($LASTEXITCODE -eq 0) {
        return $candidate
      }
    }
    catch {
      continue
    }
  }

  throw "[finance-opc] No working Python runtime found. Please install Python 3, or make sure one of these commands works: py -3, python, python3"
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Get-PythonCommand

Write-Host "[finance-opc] repo root:   $repoRoot"
Write-Host "[finance-opc] target root: $TargetRoot"

Push-Location $repoRoot
try {
  & $python.Command @($python.Args + @(".\\workspace\\scripts\\deploy_profile.py", "--target-root", $TargetRoot, "--package-root", $repoRoot))
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
