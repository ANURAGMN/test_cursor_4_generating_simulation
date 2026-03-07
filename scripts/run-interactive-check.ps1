# Interactive functionality check: buttons and interactive elements for all Kannada simulation HTML files.
# Validates that onclick/handlers and getElementById targets exist. Exit 0 = all pass, 1 = any validation fail.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$outDir = Join-Path $repoRoot "kannada_simulations"

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$totalElements = 0
$totalValidHandlers = 0
$totalIdsReferenced = 0
$totalIdsResolved = 0
$fileFails = 0
$results = [System.Collections.ArrayList]::new()
$inventory = [System.Collections.ArrayList]::new()

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name

    # Collect all id="..." in HTML
    $idMatches = [regex]::Matches($content, '\bid\s*=\s*["'']([^"'']+)["'']')
    $domIds = @{}
    foreach ($m in $idMatches) { $domIds[$m.Groups[1].Value] = $true }

    # Script block
    $scriptMatch = [regex]::Match($content, '(?s)<script>(.*?)</script>')
    if (-not $scriptMatch.Success) { $scriptMatch = [regex]::Match($content, '(?s)<script[^>]*>(.*?)</script>') }
    $scriptContent = if ($scriptMatch.Success) { $scriptMatch.Groups[1].Value } else { "" }

    # getElementById('id') and querySelector('#id')
    $getByIdMatches = [regex]::Matches($scriptContent, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)")
    $queryIdMatches = [regex]::Matches($scriptContent, "querySelector\s*\(\s*['`"]#([^'`"]+)['`"]\s*\)")
    $refIds = [System.Collections.ArrayList]::new()
    foreach ($m in $getByIdMatches) { [void]$refIds.Add($m.Groups[1].Value) }
    foreach ($m in $queryIdMatches) { [void]$refIds.Add($m.Groups[1].Value) }
    $refIdsUnique = @($refIds | Sort-Object -Unique)

    $idsOk = 0
    $idsMissing = [System.Collections.ArrayList]::new()
    foreach ($id in $refIdsUnique) {
        $totalIdsReferenced++
        if ($domIds[$id]) { $idsOk++; $totalIdsResolved++ } else { [void]$idsMissing.Add($id) }
    }

    # Interactive elements: button, onclick, data-method
    $buttonCount = ([regex]::Matches($content, '<button')).Count
    $onclickCount = ([regex]::Matches($content, '\bonclick\s*=')).Count
    $dataMethodCount = ([regex]::Matches($content, 'data-method\s*=')).Count
    $totalInteractive = $buttonCount + [Math]::Max(0, $onclickCount - $buttonCount) + $dataMethodCount
    if ($totalInteractive -eq 0 -and $onclickCount -gt 0) { $totalInteractive = $onclickCount }
    if ($totalInteractive -eq 0) { $totalInteractive = $buttonCount }

    $totalElements += [Math]::Max(1, $totalInteractive)
    $handlerValid = ($idsMissing.Count -eq 0)
    if ($handlerValid) { $totalValidHandlers += [Math]::Max(1, $totalInteractive) } else { $totalValidHandlers += 0; $fileFails++ }

    [void]$results.Add([PSCustomObject]@{
        File           = $name
        Buttons        = $buttonCount
        Onclick        = $onclickCount
        DataMethod     = $dataMethodCount
        IdsReferenced  = $refIdsUnique.Count
        IdsResolved    = $idsOk
        IdsMissing    = ($idsMissing -join "; ")
        AllIdsOk       = $handlerValid
    })
    [void]$inventory.Add("$name`t$buttonCount`t$onclickCount`t$($refIdsUnique.Count)`t$idsOk`t$handlerValid")
}

# Report
$reportPath = Join-Path $scriptDir "interactive-check-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("Interactive functionality check - " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
[void]$sb.AppendLine("Validates: getElementById/querySelector IDs exist in DOM; button/onclick count.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Per file (Buttons | Onclick | IdsRef | IdsOk | AllIdsOk):")
foreach ($r in $results) {
    $status = if ($r.AllIdsOk) { "PASS" } else { "FAIL" }
    [void]$sb.AppendLine("$status | B:$($r.Buttons) O:$($r.Onclick) | IdsRef:$($r.IdsReferenced) IdsOk:$($r.IdsResolved) | $($r.File)")
    if (-not $r.AllIdsOk -and $r.IdsMissing) { [void]$sb.AppendLine("    Missing IDs: $($r.IdsMissing)") }
}
[void]$sb.AppendLine("")
$passCount = ($results | Where-Object { $_.AllIdsOk }).Count
[void]$sb.AppendLine("Coverage: $passCount / $($files.Count) files with all referenced IDs present")
[void]$sb.AppendLine("Total IDs referenced: $totalIdsReferenced; resolved: $totalIdsResolved")
[void]$sb.AppendLine("Interactive file fails (missing ID): $fileFails")
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

$csvPath = Join-Path $scriptDir "interactive-inventory.csv"
$csvHeader = "File,Buttons,Onclick,IdsReferenced,IdsResolved,AllIdsOk"
$csvLines = @($csvHeader) + ($results | ForEach-Object { "$($_.File),$($_.Buttons),$($_.Onclick),$($_.IdsReferenced),$($_.IdsResolved),$($_.AllIdsOk)" })
[System.IO.File]::WriteAllLines($csvPath, $csvLines, [System.Text.Encoding]::UTF8)

Write-Host "Interactive check: $passCount / $($files.Count) files pass (IDs resolved); $fileFails fail" -ForegroundColor $(if ($fileFails -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Report: $reportPath | Inventory: $csvPath" -ForegroundColor Gray
if ($fileFails -gt 0) { exit 1 }
exit 0
