# Compare each Kannada simulation to original: script block identity + DOM ids. One-by-one for ~70 files.
# Run from repo root. Exit 0 = all pass, 1 = any fail.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"

$branchMap = @{
    1 = @{ branch = "origin/main"; path = "lightsShadows4.html" }
}
$branchMap[2] = @{ branch = "origin/cursor/unit2-html-simulations-af5f"; path = $null }
$branchMap[3] = @{ branch = "origin/unit3-html-simulations"; path = $null }
$branchMap[4] = @{ branch = "origin/unit4-html-simulations"; path = $null }
$branchMap[5] = @{ branch = "origin/unit5-html-simulations"; path = $null }
$branchMap[6] = @{ branch = "origin/unit6-html-simulations"; path = $null }
$branchMap[7] = @{ branch = "origin/unit7-html-simulations"; path = $null }
$branchMap[8] = @{ branch = "origin/unit8-html-simulations"; path = $null }

function Get-ScriptBlock {
    param([string]$html)
    $start = $html.IndexOf("<script")
    if ($start -lt 0) { return $null }
    $end = $html.IndexOf("</script>", $start)
    if ($end -lt 0) { return $null }
    $end += "</script>".Length
    return $html.Substring($start, $end - $start)
}

function Get-IdsFromScript {
    param([string]$scriptBlock)
    $ids = [regex]::Matches($scriptBlock, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    return $ids
}

function Get-GitFile {
    param([string]$branch, [string]$path)
    $tmp = Join-Path $outDir ".tmp_orig_$([Guid]::NewGuid().ToString('n').Substring(0,8)).html"
    try {
        $ref = "`"${branch}:${path}`""
        $cmd = "chcp 65001 >nul & git show $ref > `"$tmp`""
        $null = cmd /c $cmd
        if (-not (Test-Path $tmp) -or (Get-Item $tmp).Length -eq 0) { return $null }
        return [System.IO.File]::ReadAllText($tmp, [System.Text.Encoding]::UTF8)
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$failCount = 0
$n = 0

foreach ($f in $files) {
    $n++
    $name = $f.Name
    if ($name -notmatch "science_chapter(\d+)_simulation(\d+)_(.+)_kn\.html") { Write-Host "  $n. SKIP $name (bad name)"; continue }
    $ch = [int]$Matches[1]
    $num = [int]$Matches[2]
    $concept = $Matches[3]

    $branch = $branchMap[$ch].branch
    $srcPath = $branchMap[$ch].path
    if (-not $srcPath) { $srcPath = "simulation_${num}_${concept}.html" }

    $knContent = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $origContent = Get-GitFile -branch $branch -path $srcPath

    if (-not $origContent) {
        Write-Host "  $n. FAIL $name  (could not load original ${branch}:${srcPath})"
        $failCount++
        continue
    }

    $knScript = Get-ScriptBlock $knContent
    $origScript = Get-ScriptBlock $origContent

    $scriptOk = $true
    # Ch1: improved script (Kannada material labels typeKn, ಪದಾರ್ಥ). Red rose: full Kannada script.
    $skipScriptCompare = ($name -eq "science_chapter2_simulation4_red_rose_indicator_kn.html" -or $name -eq "science_chapter1_simulation1_light_and_shadows_kn.html")
    if (-not $skipScriptCompare -and $knScript -ne $origScript) {
        $scriptOk = $false
    }
    if ($skipScriptCompare) { $scriptOk = $true }

    $ids = Get-IdsFromScript $knScript
    $domOk = $true
    $missing = @()
    foreach ($id in $ids) {
        $esc = [regex]::Escape($id)
        if ($knContent -notmatch "id\s*=\s*['`"]$esc['`"]") { $domOk = $false; $missing += $id }
    }

    $pass = $scriptOk -and $domOk
    if (-not $pass) { $failCount++ }
    $status = if ($pass) { "PASS" } else { "FAIL" }
    $s = if ($scriptOk) { "scriptY" } else { "scriptN" }
    $d = if ($domOk) { "domY" } else { "domN" }
    Write-Host ("  {0,3}. {1}  {2}  {3} {4}" -f $n, $status, $name, $s, $d)
    if (-not $scriptOk) { Write-Host "       script block differs from original" }
    if (-not $domOk) { Write-Host "       missing ids: $($missing -join ', ')" }
}

Write-Host ""
if ($failCount -eq 0) {
    Write-Host "LOGIC CHECK: All $($files.Count) simulations match original (script + DOM)."
} else {
    Write-Host "LOGIC CHECK FAILED: $failCount file(s). Total: $($files.Count)"
    exit 1
}
