param(
  [string]$TargetRoot = "$HOME\\.openclaw"
)

$ErrorActionPreference = "Stop"

function ConvertTo-PlainData {
  param([Parameter(ValueFromPipeline = $true)]$Value)

  if ($null -eq $Value) {
    return $null
  }

  if ($Value -is [System.Collections.IDictionary]) {
    $result = @{}
    foreach ($key in $Value.Keys) {
      $result[$key] = ConvertTo-PlainData $Value[$key]
    }
    return $result
  }

  if ($Value -is [pscustomobject]) {
    $result = @{}
    foreach ($prop in $Value.PSObject.Properties) {
      $result[$prop.Name] = ConvertTo-PlainData $prop.Value
    }
    return $result
  }

  if (($Value -is [System.Collections.IEnumerable]) -and ($Value -isnot [string])) {
    $items = @()
    foreach ($item in $Value) {
      $items += ,(ConvertTo-PlainData $item)
    }
    return ,$items
  }

  return $Value
}

function Remove-JsonComments {
  param([string]$Text)

  $builder = New-Object System.Text.StringBuilder
  $inString = $false
  $escaped = $false
  $inLineComment = $false
  $inBlockComment = $false
  $i = 0

  while ($i -lt $Text.Length) {
    $ch = $Text[$i]
    $next = if ($i + 1 -lt $Text.Length) { $Text[$i + 1] } else { [char]0 }

    if ($inLineComment) {
      if ($ch -eq "`n") {
        $inLineComment = $false
        [void]$builder.Append($ch)
      }
      $i++
      continue
    }

    if ($inBlockComment) {
      if (($ch -eq '*') -and ($next -eq '/')) {
        $inBlockComment = $false
        $i += 2
      }
      else {
        $i++
      }
      continue
    }

    if ($inString) {
      [void]$builder.Append($ch)
      if ($escaped) {
        $escaped = $false
      }
      elseif ($ch -eq '\') {
        $escaped = $true
      }
      elseif ($ch -eq '"') {
        $inString = $false
      }
      $i++
      continue
    }

    if ($ch -eq '"') {
      $inString = $true
      [void]$builder.Append($ch)
      $i++
      continue
    }

    if (($ch -eq '/') -and ($next -eq '/')) {
      $inLineComment = $true
      $i += 2
      continue
    }

    if (($ch -eq '/') -and ($next -eq '*')) {
      $inBlockComment = $true
      $i += 2
      continue
    }

    [void]$builder.Append($ch)
    $i++
  }

  return $builder.ToString()
}

function Remove-JsonTrailingCommas {
  param([string]$Text)

  $builder = New-Object System.Text.StringBuilder
  $inString = $false
  $escaped = $false

  foreach ($ch in $Text.ToCharArray()) {
    if ($inString) {
      [void]$builder.Append($ch)
      if ($escaped) {
        $escaped = $false
      }
      elseif ($ch -eq '\') {
        $escaped = $true
      }
      elseif ($ch -eq '"') {
        $inString = $false
      }
      continue
    }

    if ($ch -eq '"') {
      $inString = $true
      [void]$builder.Append($ch)
      continue
    }

    if (($ch -eq ']') -or ($ch -eq '}')) {
      $current = $builder.ToString()
      $idx = $current.Length - 1
      while (($idx -ge 0) -and [char]::IsWhiteSpace($current[$idx])) {
        $idx--
      }
      if (($idx -ge 0) -and ($current[$idx] -eq ',')) {
        [void]$builder.Remove($idx, 1)
      }
    }

    [void]$builder.Append($ch)
  }

  return $builder.ToString()
}

function Read-JsonFile {
  param(
    [string]$Path,
    [switch]$AllowRecovery
  )

  $raw = [System.IO.File]::ReadAllText($Path)
  $encoding = New-Object System.Text.UTF8Encoding($false)
  if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) {
    $raw = $raw.Substring(1)
  }

  try {
    $parsed = $raw | ConvertFrom-Json
    return @{
      Data = ConvertTo-PlainData $parsed
      Raw = $raw
      Recovered = $false
    }
  }
  catch {
    if (-not $AllowRecovery) {
      throw
    }

    $sanitized = Remove-JsonTrailingCommas (Remove-JsonComments $raw)
    try {
      $parsed = $sanitized | ConvertFrom-Json
      return @{
        Data = ConvertTo-PlainData $parsed
        Raw = $raw
        Recovered = $true
      }
    }
    catch {
      throw "[finance-opc] Cannot parse existing OpenClaw config: $Path`n[finance-opc] The file is not valid JSON, even after stripping comments and trailing commas.`n[finance-opc] Please fix or back up that file, then rerun the installer."
    }
  }
}

function Rewrite-Placeholders {
  param(
    $Value,
    [string]$DomainRoot,
    [string]$ProfileRoot
  )

  if ($Value -is [string]) {
    return $Value.Replace("__DOMAIN_ROOT__", $DomainRoot.Replace("\", "/")).Replace("__PROFILE_ROOT__", $ProfileRoot.Replace("\", "/"))
  }

  if ($Value -is [System.Collections.IDictionary]) {
    $result = @{}
    foreach ($key in $Value.Keys) {
      $result[$key] = Rewrite-Placeholders -Value $Value[$key] -DomainRoot $DomainRoot -ProfileRoot $ProfileRoot
    }
    return $result
  }

  if (($Value -is [System.Collections.IEnumerable]) -and ($Value -isnot [string])) {
    $items = @()
    foreach ($item in $Value) {
      $items += ,(Rewrite-Placeholders -Value $item -DomainRoot $DomainRoot -ProfileRoot $ProfileRoot)
    }
    return ,$items
  }

  return $Value
}

function Deep-Fill {
  param(
    $Destination,
    $Source
  )

  if (($Destination -is [System.Collections.IDictionary]) -and ($Source -is [System.Collections.IDictionary])) {
    foreach ($key in $Source.Keys) {
      if (-not $Destination.Contains($key)) {
        $Destination[$key] = ConvertTo-PlainData $Source[$key]
      }
      elseif (($Destination[$key] -is [System.Collections.IDictionary]) -and ($Source[$key] -is [System.Collections.IDictionary])) {
        $Destination[$key] = Deep-Fill -Destination $Destination[$key] -Source $Source[$key]
      }
    }
  }

  return $Destination
}

$repoRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$targetRootResolved = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((Get-Location).Path, $TargetRoot))
$domainRoot = Join-Path (Join-Path $targetRootResolved "domains") "finance-opc"
$configPath = Join-Path $targetRootResolved "openclaw.json"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $targetRootResolved "openclaw.json.finance-opc-backup.$timestamp.bak"

Write-Host "[finance-opc] repo root:   $repoRoot"
Write-Host "[finance-opc] target root: $targetRootResolved"

New-Item -ItemType Directory -Path $targetRootResolved -Force | Out-Null
New-Item -ItemType Directory -Path $domainRoot -Force | Out-Null

foreach ($rel in @("agents", "workspace")) {
  $src = Join-Path $repoRoot $rel
  $dst = Join-Path $domainRoot $rel
  if (Test-Path $dst) {
    Remove-Item -Recurse -Force $dst
  }
  Copy-Item -Recurse -Force $src $dst
}

$envTemplateSrc = Join-Path $repoRoot ".env.template"
$envTemplateDst = Join-Path $domainRoot ".env.template"
$envDst = Join-Path $domainRoot ".env"
if (Test-Path $envTemplateSrc) {
  Copy-Item -Force $envTemplateSrc $envTemplateDst
  if (-not (Test-Path $envDst)) {
    Copy-Item -Force $envTemplateSrc $envDst
  }
}

$overlayRaw = [System.IO.File]::ReadAllText((Join-Path $repoRoot "openclaw.json"))
$overlay = ConvertTo-PlainData ($overlayRaw | ConvertFrom-Json)
$overlay = Rewrite-Placeholders -Value $overlay -DomainRoot $domainRoot -ProfileRoot $targetRootResolved

$recoveredHostConfig = $false
if (Test-Path $configPath) {
  $hostConfig = Read-JsonFile -Path $configPath -AllowRecovery
  $current = $hostConfig.Data
  $recoveredHostConfig = [bool]$hostConfig.Recovered
  [System.IO.File]::WriteAllText($backupPath, $hostConfig.Raw, (New-Object System.Text.UTF8Encoding($false)))
}
else {
  $current = @{}
}

if (-not $current.Contains("skills")) {
  $current["skills"] = @{}
}
if (-not $current["skills"].Contains("load")) {
  $current["skills"]["load"] = @{}
}
if (-not $current["skills"]["load"].Contains("extraDirs")) {
  $current["skills"]["load"]["extraDirs"] = @()
}
foreach ($skillDir in $overlay["skills"]["load"]["extraDirs"]) {
  if ($current["skills"]["load"]["extraDirs"] -notcontains $skillDir) {
    $current["skills"]["load"]["extraDirs"] += $skillDir
  }
}

if (-not $current.Contains("agents")) {
  $current["agents"] = @{}
}
if (-not $current["agents"].Contains("defaults")) {
  $current["agents"]["defaults"] = @{}
}
$overlayDefaults = $overlay["agents"]["defaults"]
if ((-not $current["agents"]["defaults"].Contains("workspace")) -and $overlayDefaults["workspace"]) {
  $current["agents"]["defaults"]["workspace"] = $overlayDefaults["workspace"]
}
foreach ($key in $overlayDefaults.Keys) {
  if ($key -eq "workspace") {
    continue
  }
  if (-not $current["agents"]["defaults"].Contains($key)) {
    $current["agents"]["defaults"][$key] = ConvertTo-PlainData $overlayDefaults[$key]
  }
  elseif (($current["agents"]["defaults"][$key] -is [System.Collections.IDictionary]) -and ($overlayDefaults[$key] -is [System.Collections.IDictionary])) {
    $current["agents"]["defaults"][$key] = Deep-Fill -Destination $current["agents"]["defaults"][$key] -Source $overlayDefaults[$key]
  }
}

if (-not $current["agents"].Contains("list")) {
  $current["agents"]["list"] = @()
}

$byId = @{}
foreach ($agent in $current["agents"]["list"]) {
  if (($agent -is [System.Collections.IDictionary]) -and $agent.Contains("id")) {
    $byId[$agent["id"]] = ConvertTo-PlainData $agent
  }
}
foreach ($overlayAgent in $overlay["agents"]["list"]) {
  $byId[$overlayAgent["id"]] = ConvertTo-PlainData $overlayAgent
}
$current["agents"]["list"] = @($byId.Values)

$mainAgent = $null
foreach ($agent in $current["agents"]["list"]) {
  if (($agent -is [System.Collections.IDictionary]) -and $agent["id"] -eq "main") {
    $mainAgent = $agent
    break
  }
}
if ($mainAgent) {
  if (-not $mainAgent.Contains("subagents")) {
    $mainAgent["subagents"] = @{}
  }
  if (-not $mainAgent["subagents"].Contains("allowAgents")) {
    $mainAgent["subagents"]["allowAgents"] = @()
  }
  if ($mainAgent["subagents"]["allowAgents"] -notcontains "finance_main") {
    $mainAgent["subagents"]["allowAgents"] += "finance_main"
  }
}

$currentJson = $current | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($configPath, $currentJson, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "[finance-opc] overlay imported into $domainRoot"
if (Test-Path $backupPath) {
  Write-Host "[finance-opc] backup created: $backupPath"
}
if ($recoveredHostConfig) {
  Write-Warning "[finance-opc] recovered the host openclaw.json by stripping comments or trailing commas before merging."
}

${env:OPENCLAW_STATE_DIR} = $targetRootResolved
${env:OPENCLAW_CONFIG_PATH} = $configPath

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
