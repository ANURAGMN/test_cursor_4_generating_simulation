# Run 2-3 test cases per Kannada simulation. Exit 0 = all pass, 1 = any fail.
# TC1: Structure (required strings, no forbidden/corruption)
# TC2: Kannada content (at least one Kannada char in HTML body)
# TC3: DOM consistency (every getElementById('id') has matching id in file)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"

$required = @('<!DOCTYPE html>', 'lang="kn"', 'Noto Sans Kannada', 'charset="UTF-8"', '</html>')
$forbidden = @('getxlementlyId', 'textuontent', 'setdttribute', 'iruaYPx', 'ooto eans eannada', 'UaF-8')

# Kannada Unicode range (Kannada block)
$kannadaRange = [regex]'[\u0C80-\u0CFF]'

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$failCount = 0
$results = @()

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name
    $tcs = @()

    # ----- TC1: Structure -----
    $tc1Pass = $true
    foreach ($req in $required) {
        if ($content -notmatch [regex]::Escape($req)) {
            $tc1Pass = $false
            $tcs += "TC1: missing $req"
            break
        }
    }
    if ($tc1Pass) {
        foreach ($bad in $forbidden) {
            if ($content -match [regex]::Escape($bad)) {
                $tc1Pass = $false
                $tcs += "TC1: forbidden $bad"
                break
            }
        }
    }
    if ($tc1Pass) { $tcs += "TC1: pass" }

    # ----- TC2: Kannada in body (before first <script) -----
    $beforeScript = $content
    $idx = $content.IndexOf('<script')
    if ($idx -gt 0) { $beforeScript = $content.Substring(0, $idx) }
    $tc2Pass = $beforeScript -match $kannadaRange
    if (-not $tc2Pass) { $tcs += "TC2: no Kannada in body" } else { $tcs += "TC2: pass" }

    # ----- TC3: getElementById targets exist -----
    $idsInScript = [regex]::Matches($content, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    $tc3Pass = $true
    $missing = @()
    foreach ($id in $idsInScript) {
        $esc = [regex]::Escape($id)
        if ($content -notmatch "id\s*=\s*['`"]$esc['`"]") {
            $tc3Pass = $false
            $missing += $id
        }
    }
    if (-not $tc3Pass) { $tcs += "TC3: missing ids: $($missing -join ', ')" } else { $tcs += "TC3: pass" }

    $allPass = $tc1Pass -and $tc2Pass -and $tc3Pass
    if (-not $allPass) {
        $failCount++
        Write-Host "FAIL $name"
        foreach ($t in $tcs) { if ($t -notmatch "pass") { Write-Host "  $t" } }
    }
    $results += [PSCustomObject]@{ File = $name; TC1 = $tc1Pass; TC2 = $tc2Pass; TC3 = $tc3Pass }
}

if ($failCount -eq 0) {
    Write-Host "PASS: All $($files.Count) simulations passed 3 test cases each."
} else {
    Write-Host "FAIL: $failCount simulation(s) failed. Total: $($files.Count)"
    exit 1
}
