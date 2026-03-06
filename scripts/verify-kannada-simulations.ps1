# Verify all Kannada simulation HTML files are production-ready.
# Run from repo root. Exit code 0 = all pass, 1 = any fail.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"

$required = @('<!DOCTYPE html>', 'lang="kn"', 'Noto Sans Kannada', 'charset="UTF-8"', '</html>')
$forbidden = @('getxlementlyId', 'textuontent', 'setdttribute', 'iruaYPx', 'ooto eans eannada', 'UaF-8')

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$fail = 0
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name
    foreach ($req in $required) {
        if ($content -notmatch [regex]::Escape($req)) {
            Write-Host "FAIL $name - missing: $req"
            $fail++
            break
        }
    }
    foreach ($bad in $forbidden) {
        if ($content -match [regex]::Escape($bad)) {
            Write-Host "FAIL $name - contains forbidden: $bad"
            $fail++
            break
        }
    }
}
if ($fail -eq 0) {
    Write-Host "PASS: All $($files.Count) Kannada simulation files verified production-ready."
} else {
    Write-Host "FAIL: $fail file(s) have issues."
    exit 1
}
