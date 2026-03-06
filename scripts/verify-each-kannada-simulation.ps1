# Verify each Kannada simulation one by one. Prints per-file result for all ~70 files.
# Run from repo root. Exit 0 = all pass, 1 = any fail.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"

$required = @('<!DOCTYPE html>', 'lang="kn"', 'Noto Sans Kannada', 'charset="UTF-8"', '</html>')
$forbidden = @('getxlementlyId', 'textuontent', 'setdttribute', 'iruaYPx', 'ooto eans eannada', 'UaF-8')
$kannadaRange = [regex]'[\u0C80-\u0CFF]'

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$failCount = 0
$n = 0

foreach ($f in $files) {
    $n++
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name

    $tc1 = $true
    foreach ($req in $required) {
        if ($content -notmatch [regex]::Escape($req)) { $tc1 = $false; break }
    }
    if ($tc1) {
        foreach ($bad in $forbidden) {
            if ($content -match [regex]::Escape($bad)) { $tc1 = $false; break }
        }
    }

    $idx = $content.IndexOf('<script')
    $beforeScript = if ($idx -gt 0) { $content.Substring(0, $idx) } else { $content }
    $tc2 = $beforeScript -match $kannadaRange

    $idsInScript = [regex]::Matches($content, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    $tc3 = $true
    $missing = @()
    foreach ($id in $idsInScript) {
        $esc = [regex]::Escape($id)
        if ($content -notmatch "id\s*=\s*['`"]$esc['`"]") { $tc3 = $false; $missing += $id }
    }

    $ok = $tc1 -and $tc2 -and $tc3
    $status = if ($ok) { "PASS" } else { "FAIL"; $failCount++ }
    $t1 = if ($tc1) { "TC1Y" } else { "TC1N" }
    $t2 = if ($tc2) { "TC2Y" } else { "TC2N" }
    $t3 = if ($tc3) { "TC3Y" } else { "TC3N" }
    Write-Host ("{0,3}. {1}  {2}  {3} {4} {5}" -f $n, $status, $name, $t1, $t2, $t3)
    if (-not $tc3 -and $missing.Count -gt 0) { Write-Host "     missing ids: $($missing -join ', ')" }
}

Write-Host ""
if ($failCount -eq 0) {
    Write-Host "VERIFIED: All $($files.Count) simulations pass (one-by-one check)."
} else {
    Write-Host "FAILED: $failCount simulation(s) need fixes. Total: $($files.Count)"
    exit 1
}
