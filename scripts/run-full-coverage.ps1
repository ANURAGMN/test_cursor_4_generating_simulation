# Run all test suites and produce a combined coverage report.
# Runs: translation, garbled, interactive, original-comparison, learnability. Writes coverage-report.txt.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
Push-Location $scriptDir

$reportPath = Join-Path $scriptDir "coverage-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("========================================")
[void]$sb.AppendLine("Kannada simulations - full coverage report")
[void]$sb.AppendLine((Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
[void]$sb.AppendLine("========================================")
[void]$sb.AppendLine("")

$totalFiles = 71
$translationPass = 0
$garbledClean = 0
$interactivePass = 0
$compared = 0
$comparisonPass = 0
$learnabilityPass = 0

# 1. Translation
[void]$sb.AppendLine("--- 1. Translation ---")
try {
    $translationOutput = & .\run-translation-tests.ps1 2>&1
    $translationOutput | Out-String | Write-Host
    $reportFile = Join-Path $scriptDir "translation-test-report.txt"
    if (Test-Path $reportFile) {
        $reportContent = [System.IO.File]::ReadAllText($reportFile, [System.Text.Encoding]::UTF8)
        if ($reportContent -match 'PASS:\s*(\d+)\s*\|\s*FAIL:\s*(\d+)') {
            $translationPass = [int]$Matches[1]
        }
    }
    [void]$sb.AppendLine("Translation: $translationPass / $totalFiles files pass (all 3 TCs)")
} catch {
    [void]$sb.AppendLine("Translation: ERROR - $($_.Exception.Message)")
}
[void]$sb.AppendLine("")

# 2. Garbled
[void]$sb.AppendLine("--- 2. Garbled text (mojibake) ---")
try {
    $garbledOutput = & .\run-garbled-check.ps1 2>&1
    $garbledOutput | Out-String | Write-Host
    $garbledReport = Join-Path $scriptDir "garbled-check-report.txt"
    if (Test-Path $garbledReport) {
        $gcontent = [System.IO.File]::ReadAllText($garbledReport, [System.Text.Encoding]::UTF8)
        if ($gcontent -match 'Coverage:\s*(\d+)\s*/\s*(\d+)\s*files clean') {
            $garbledClean = [int]$Matches[1]
        }
    }
    [void]$sb.AppendLine("Garbled: $garbledClean / $totalFiles files clean (0 mojibake segments)")
} catch {
    [void]$sb.AppendLine("Garbled: ERROR - $($_.Exception.Message)")
}
[void]$sb.AppendLine("")

# 3. Interactive
[void]$sb.AppendLine("--- 3. Interactive functionality ---")
try {
    $interactiveOutput = & .\run-interactive-check.ps1 2>&1
    $interactiveOutput | Out-String | Write-Host
    $interReport = Join-Path $scriptDir "interactive-check-report.txt"
    if (Test-Path $interReport) {
        $icontent = [System.IO.File]::ReadAllText($interReport, [System.Text.Encoding]::UTF8)
        if ($icontent -match 'Coverage:\s*(\d+)\s*/\s*(\d+)\s*files with all referenced IDs') {
            $interactivePass = [int]$Matches[1]
        }
    }
    [void]$sb.AppendLine("Interactive: $interactivePass / $totalFiles files pass (IDs resolved)")
} catch {
    [void]$sb.AppendLine("Interactive: ERROR - $($_.Exception.Message)")
}
[void]$sb.AppendLine("")

# 4. Original comparison
[void]$sb.AppendLine("--- 4. Comparison with original ---")
try {
    $compareOutput = & .\run-original-comparison.ps1 2>&1
    $compareOutput | Out-String | Write-Host
    $compReport = Join-Path $scriptDir "original-comparison-report.txt"
    if (Test-Path $compReport) {
        $ccontent = [System.IO.File]::ReadAllText($compReport, [System.Text.Encoding]::UTF8)
        if ($ccontent -match 'Files compared:\s*(\d+)\s*/\s*(\d+)') { $compared = [int]$Matches[1] }
        if ($ccontent -match 'Comparison pass:\s*(\d+)\s*/\s*(\d+)') { $comparisonPass = [int]$Matches[1] }
    }
    [void]$sb.AppendLine("Comparison: $comparisonPass / $compared pass (of $compared with original)")
} catch {
    [void]$sb.AppendLine("Comparison: ERROR - $($_.Exception.Message)")
}
[void]$sb.AppendLine("")

# 5. Learnability (can Kannada student learn?)
[void]$sb.AppendLine("--- 5. Learnability (can Kannada student learn?) ---")
try {
    $learnOutput = & .\run-learnability-check.ps1 2>&1
    $learnOutput | Out-String | Write-Host
    $learnReport = Join-Path $scriptDir "learnability-check-report.txt"
    if (Test-Path $learnReport) {
        $lcontent = [System.IO.File]::ReadAllText($learnReport, [System.Text.Encoding]::UTF8)
        if ($lcontent -match 'Learnability coverage:\s*(\d+)\s*/\s*(\d+)\s*files pass') {
            $learnabilityPass = [int]$Matches[1]
        }
    }
    [void]$sb.AppendLine("Learnability: $learnabilityPass / $totalFiles files pass (L1 and L2 and L3)")
} catch {
    [void]$sb.AppendLine("Learnability: ERROR - $($_.Exception.Message)")
}
[void]$sb.AppendLine("")

# Coverage metrics summary
[void]$sb.AppendLine("========================================")
[void]$sb.AppendLine("Coverage metrics summary")
[void]$sb.AppendLine("========================================")
$transPct = if ($totalFiles -gt 0) { [Math]::Round(100.0 * $translationPass / $totalFiles, 1) } else { 0 }
$garbPct = if ($totalFiles -gt 0) { [Math]::Round(100.0 * $garbledClean / $totalFiles, 1) } else { 0 }
$interPct = if ($totalFiles -gt 0) { [Math]::Round(100.0 * $interactivePass / $totalFiles, 1) } else { 0 }
$compCovPct = if ($totalFiles -gt 0) { [Math]::Round(100.0 * $compared / $totalFiles, 1) } else { 0 }
$compPassPct = if ($compared -gt 0) { [Math]::Round(100.0 * $comparisonPass / $compared, 1) } else { 0 }
$learnPct = if ($totalFiles -gt 0) { [Math]::Round(100.0 * $learnabilityPass / $totalFiles, 1) } else { 0 }

[void]$sb.AppendLine("Translation:    $translationPass / $totalFiles = $transPct%")
[void]$sb.AppendLine("Garbled:        $garbledClean / $totalFiles = $garbPct%")
[void]$sb.AppendLine("Interactive:   $interactivePass / $totalFiles = $interPct%")
[void]$sb.AppendLine("Compared:      $compared / $totalFiles = $compCovPct%")
[void]$sb.AppendLine("Compare pass:  $comparisonPass / $compared = $compPassPct%")
[void]$sb.AppendLine("Learnability:  $learnabilityPass / $totalFiles = $learnPct% (can Kannada student learn?)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Reports: translation-test-report.txt, garbled-check-report.txt, interactive-check-report.txt, original-comparison-report.txt, learnability-check-report.txt")
[void]$sb.AppendLine("See TEST-CASES-AND-COVERAGE.md for test case definitions.")

[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
Pop-Location

Write-Host ""
Write-Host "Full coverage report: $reportPath" -ForegroundColor Cyan
Write-Host ("Translation: " + $transPct + "% | Garbled: " + $garbPct + "% | Interactive: " + $interPct + "% | Learnability: " + $learnPct + "% | Comparison: " + $compCovPct + "%") -ForegroundColor White
