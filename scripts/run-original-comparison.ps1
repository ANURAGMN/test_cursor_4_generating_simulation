# Compare Kannada HTML files with original source from git branches.
# Checks: critical IDs preserved, script block count, button/input count. Exit 0 = all pass or no originals, 1 = any fail.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$outDir = Join-Path $repoRoot "kannada_simulations"

$branchChapterMap = @{
    "origin/cursor/unit2-html-simulations-af5f" = 2
    "origin/unit3-html-simulations" = 3
    "origin/unit4-html-simulations" = 4
    "origin/unit5-html-simulations" = 5
    "origin/unit6-html-simulations" = 6
    "origin/unit7-html-simulations" = 7
    "origin/unit8-html-simulations" = 8
}

function Get-OriginalContent {
    param([string]$branch, [string]$path)
    try {
        $ref = "`"${branch}:${path}`""
        $result = git show $ref 2>$null
        if ($result) { return $result }
    } catch {}
    return $null
}

# Map kannada file name to branch and source path: science_chapterN_simulationM_concept_kn.html -> simulation_M_concept.html on unitN
$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$compared = 0
$passCount = 0
$results = [System.Collections.ArrayList]::new()

foreach ($f in $files) {
    $name = $f.Name
    if ($name -notmatch 'science_chapter(\d+)_simulation(\d+)_(.+)_kn\.html') { continue }
    $chapter = [int]$Matches[1]
    $simNum = $Matches[2]
    $concept = $Matches[3]
    $branch = $branchChapterMap.Keys | Where-Object { $branchChapterMap[$_] -eq $chapter } | Select-Object -First 1
    if (-not $branch) { continue }
    $sourcePath = "simulation_${simNum}_${concept}.html"
    $origContent = Get-OriginalContent -branch $branch -path $sourcePath
    if (-not $origContent) { continue }

    $compared++
    $knContent = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)

    # OC1/OC2: IDs referenced in Kannada script exist in original
    $knScriptMatch = [regex]::Match($knContent, '(?s)<script[^>]*>(.*?)</script>')
    $knScript = if ($knScriptMatch.Success) { $knScriptMatch.Groups[1].Value } else { "" }
    $origScriptMatch = [regex]::Match($origContent, '(?s)<script[^>]*>(.*?)</script>')
    $origScript = if ($origScriptMatch.Success) { $origScriptMatch.Groups[1].Value } else { "" }

    $knIds = [regex]::Matches($knScript, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)") | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    $origIdMatches = [regex]::Matches($origContent, '\bid\s*=\s*["'']([^"'']+)["'']')
    $origIds = @{}
    foreach ($m in $origIdMatches) { $origIds[$m.Groups[1].Value] = $true }

    $idsOk = $true
    foreach ($id in $knIds) { if (-not $origIds[$id]) { $idsOk = $false; break } }

    # OC2: script block count
    $knScriptCount = ([regex]::Matches($knContent, '<script')).Count
    $origScriptCount = ([regex]::Matches($origContent, '<script')).Count
    $scriptCountOk = ($knScriptCount -eq $origScriptCount)

    # OC3: button count (Kannada >= original or same)
    $knButtons = ([regex]::Matches($knContent, '<button')).Count
    $origButtons = ([regex]::Matches($origContent, '<button')).Count
    $buttonsOk = ($knButtons -ge $origButtons -or $origButtons -eq 0)

    $pass = $idsOk -and $scriptCountOk -and $buttonsOk
    if ($pass) { $passCount++ }

    [void]$results.Add([PSCustomObject]@{
        File          = $name
        Original      = "${branch}:${sourcePath}"
        IdsOk         = $idsOk
        ScriptCountOk = $scriptCountOk
        ButtonsOk     = $buttonsOk
        Pass          = $pass
    })
}

# Report
$reportPath = Join-Path $scriptDir "original-comparison-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("Original file comparison - " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
[void]$sb.AppendLine("Compares: IDs in script, script block count, button count.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Per file (only files with original on branch):")
foreach ($r in $results) {
    $status = if ($r.Pass) { "PASS" } else { "FAIL" }
    [void]$sb.AppendLine("$status | Ids:$($r.IdsOk) ScriptCnt:$($r.ScriptCountOk) Btn:$($r.ButtonsOk) | $($r.File)")
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Files compared: $compared / $($files.Count)")
[void]$sb.AppendLine("Comparison pass: $passCount / $compared")
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host "Original comparison: $passCount / $compared files pass (of $compared with original)" -ForegroundColor $(if ($compared -eq 0) { 'Gray' } elseif ($passCount -eq $compared) { 'Green' } else { 'Yellow' })
Write-Host "Report: $reportPath" -ForegroundColor Gray
$failCount = $compared - $passCount
if ($failCount -gt 0) { exit 1 }
exit 0
