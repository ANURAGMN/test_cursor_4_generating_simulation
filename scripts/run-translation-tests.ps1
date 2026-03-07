# Run 2-3 translation test cases per Kannada simulation file.
# Focus: every visible text element should be translated to Kannada.
# Run from repo root. Exit 0 = all pass, 1 = any fail.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"

# Kannada Unicode block
$kannadaChar = [regex]'[\u0C80-\u0CFF]'
# 5+ consecutive Latin letters (English-like)
$latinRun5 = [regex]'[A-Za-z]{5,}'
$latinRun6 = [regex]'[A-Za-z]{6,}'

# Allowlist: segments that may stay in English (formulas, units, technical)
$allowlist = @('H₂O', 'H2O', 'pH', 'LED', 'ACID', 'BASE', 'NEUTRAL', 'HCl', 'NaOH', 'CO2', 'O2', 'N2', 'NaHCO3', 'CH3COOH', 'CH3COONa', 'Ladakh')

function Has-Kannada { param([string]$s); return $s -match $kannadaChar }
function Is-Allowlisted {
    param([string]$s)
    foreach ($a in $allowlist) {
        if ($s -match [regex]::Escape($a)) { return $true }
    }
    return $false
}

# TC1: Body visible text - every text segment between > and < that has 5+ letters must contain Kannada (or be allowlisted)
function Test-TC1-BodyVisibleTranslated {
    param([string]$content)
    $bodyOnly = $content
    $bodyOnly = [regex]::Replace($bodyOnly, '<script[\s\S]*?</script>', ' ')
    $bodyOnly = [regex]::Replace($bodyOnly, '<style[\s\S]*?</style>', ' ')
    $matches = [regex]::Matches($bodyOnly, '>([^<]{4,}?)<')
    $failSegments = [System.Collections.ArrayList]::new()
    foreach ($m in $matches) {
        $text = $m.Groups[1].Value.Trim()
        if ($text.Length -lt 5) { continue }
        if ($text -match 'transform=|stroke=|fill=|font-weight=|x=|y=|cx=|cy=|rx=|ry=|viewBox|stroke-width') { continue }
        if ($text -match 'getElementById|classList|\.style') { continue }
        if (-not ($text -match $latinRun5)) { continue }
        if ((Has-Kannada $text) -or (Is-Allowlisted $text)) { continue }
        $snip = if ($text.Length -gt 60) { $text.Substring(0, 57) + "..." } else { $text }
        [void]$failSegments.Add($snip)
    }
    return $failSegments
}
function Test-TC1-FullSegments {
    param([string]$content)
    $bodyOnly = [regex]::Replace([regex]::Replace($content, '<script[\s\S]*?</script>', ' '), '<style[\s\S]*?</style>', ' ')
    $out = [System.Collections.ArrayList]::new()
    foreach ($m in [regex]::Matches($bodyOnly, '>([^<]{4,}?)<')) {
        $text = $m.Groups[1].Value.Trim()
        if ($text.Length -lt 5 -or $text -match 'transform=|stroke=|fill=|font-weight=|getElementById|classList') { continue }
        if (-not ($text -match $latinRun5) -or (Has-Kannada $text) -or (Is-Allowlisted $text)) { continue }
        if ($text -match '[\u00A0-\u00FF]') { continue }  # mojibake (Latin-1 supplement incl. ²) - treat as non-Latin for TC1
        [void]$out.Add($text)
    }
    return $out
}

# TC2: Script visible strings - innerHTML/textContent/result/title/learning/action strings with 6+ letters must contain Kannada (or allowlisted)
function Test-TC2-ScriptVisibleTranslated {
    param([string]$content)
    $scriptBlocks = [regex]::Matches($content, '<script[\s\S]*?</script>')
    $scriptContent = ($scriptBlocks | ForEach-Object { $_.Value }) -join "`n"
    $failSegments = [System.Collections.ArrayList]::new()
    $patterns = @(
        "(?:innerHTML|textContent|innerText)\s*=\s*['`"]([^'`"]{8,}?)['`"]",
        "(?:result|title|learning|action|content|text|label)\s*:\s*['`"]([^'`"]{10,}?)['`"]",
        "(?:expText|detailText|takeawayText|infoText|learningText)\.(?:innerHTML|textContent)\s*=\s*['`"]([^'`"]{10,}?)['`"]"
    )
    foreach ($pat in $patterns) {
        foreach ($m in [regex]::Matches($scriptContent, $pat)) {
            $s = $m.Groups[1].Value
            if ($s -notmatch $latinRun6) { continue }
            if ($s -match 'getElementById|setAttribute|translate\(') { continue }
            if ((Has-Kannada $s) -or (Is-Allowlisted $s)) { continue }
            if ($s -match '[\u00A0-\u00FF]{2,}') { continue }  # mojibake (Latin-1 supplement) - treat as non-Latin for TC2
            $snip = if ($s.Length -gt 60) { $s.Substring(0, 57) + "..." } else { $s }
            [void]$failSegments.Add($snip)
        }
    }
    return $failSegments
}
function Test-TC2-FullSegments {
    param([string]$content)
    $scriptContent = ($([regex]::Matches($content, '<script[\s\S]*?</script>') | ForEach-Object { $_.Value }) -join "`n")
    $out = [System.Collections.ArrayList]::new()
    $patterns = @(
        "(?:innerHTML|textContent|innerText)\s*=\s*['`"]([^'`"]{8,}?)['`"]",
        "(?:result|title|learning|action|content|text|label)\s*:\s*['`"]([^'`"]{10,}?)['`"]",
        "(?:expText|detailText|takeawayText|infoText|learningText)\.(?:innerHTML|textContent)\s*=\s*['`"]([^'`"]{10,}?)['`"]"
    )
    foreach ($pat in $patterns) {
        foreach ($m in [regex]::Matches($scriptContent, $pat)) {
            $s = $m.Groups[1].Value
            if ($s -notmatch $latinRun6 -or $s -match 'getElementById|setAttribute|translate\(') { continue }
            if ((Has-Kannada $s) -or (Is-Allowlisted $s)) { continue }
            if ($s -match '[\u00A0-\u00FF]{2,}') { continue }
            [void]$out.Add($s)
        }
    }
    return $out
}

# TC3: Headings and first paragraph - <h1>, <h2>, <p> in body must contain at least one Kannada character
function Test-TC3-HeadingsTranslated {
    param([string]$content)
    $bodyOnly = $content
    $bodyOnly = [regex]::Replace($bodyOnly, '<script[\s\S]*?</script>', ' ')
    $bodyOnly = [regex]::Replace($bodyOnly, '<style[\s\S]*?</style>', ' ')
    $failTags = [System.Collections.ArrayList]::new()
    foreach ($tag in @('h1', 'h2', 'p')) {
        $pattern = "<${tag}[^>]*>([^<]{2,}?)</${tag}>"
        foreach ($m in [System.Text.RegularExpressions.Regex]::Matches($bodyOnly, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $inner = $m.Groups[1].Value.Trim()
            if ($inner.Length -lt 2) { continue }
            if ((Has-Kannada $inner) -or (Is-Allowlisted $inner)) { continue }
            if ($inner -match $latinRun5) {
                $snip = if ($inner.Length -gt 50) { $inner.Substring(0, 47) + "..." } else { $inner }
                [void]$failTags.Add("<${tag}>: $snip")
            }
        }
    }
    return $failTags
}
function Test-TC3-FullSegments {
    param([string]$content)
    $bodyOnly = [regex]::Replace([regex]::Replace($content, '<script[\s\S]*?</script>', ' '), '<style[\s\S]*?</style>', ' ')
    $out = [System.Collections.ArrayList]::new()
    foreach ($tag in @('h1', 'h2', 'p')) {
        $pattern = "<${tag}[^>]*>([^<]{2,}?)</${tag}>"
        foreach ($m in [System.Text.RegularExpressions.Regex]::Matches($bodyOnly, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $inner = $m.Groups[1].Value.Trim()
            if ($inner.Length -lt 2 -or -not ($inner -match $latinRun5)) { continue }
            if ((Has-Kannada $inner) -or (Is-Allowlisted $inner)) { continue }
            [void]$out.Add($inner)
        }
    }
    return $out
}

# ----- Main -----
$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$failCount = 0
$results = @()
$maxSnippetsToShow = 3

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name
    $tc1Fails = Test-TC1-BodyVisibleTranslated $content
    $tc2Fails = Test-TC2-ScriptVisibleTranslated $content
    $tc3Fails = Test-TC3-HeadingsTranslated $content

    $tc1Pass = ($tc1Fails.Count -eq 0)
    $tc2Pass = ($tc2Fails.Count -eq 0)
    $tc3Pass = ($tc3Fails.Count -eq 0)
    $allPass = $tc1Pass -and $tc2Pass -and $tc3Pass

    $results += [PSCustomObject]@{
        File   = $name
        TC1    = $tc1Pass
        TC2    = $tc2Pass
        TC3    = $tc3Pass
        AllPass = $allPass
        TC1Count = $tc1Fails.Count
        TC2Count = $tc2Fails.Count
        TC3Count = $tc3Fails.Count
    }

    if (-not $allPass) {
        $failCount++
        Write-Host "FAIL $name" -ForegroundColor Red
        if (-not $tc1Pass) {
            $show = $tc1Fails | Select-Object -First $maxSnippetsToShow
            Write-Host "  TC1 (body visible): $($tc1Fails.Count) untranslated" -ForegroundColor Yellow
            $show | ForEach-Object { Write-Host "    $_" }
        }
        if (-not $tc2Pass) {
            $show = $tc2Fails | Select-Object -First $maxSnippetsToShow
            Write-Host "  TC2 (script visible): $($tc2Fails.Count) untranslated" -ForegroundColor Yellow
            $show | ForEach-Object { Write-Host "    $_" }
        }
        if (-not $tc3Pass) {
            $show = $tc3Fails | Select-Object -First $maxSnippetsToShow
            Write-Host "  TC3 (headings/p): $($tc3Fails.Count) untranslated" -ForegroundColor Yellow
            $show | ForEach-Object { Write-Host "    $_" }
        }
    } else {
        Write-Host "PASS $name" -ForegroundColor Green
    }
}

# Summary
$passCount = ($results | Where-Object { $_.AllPass }).Count
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Translation test summary" -ForegroundColor Cyan
Write-Host "  Total files: $($files.Count)" -ForegroundColor White
Write-Host "  PASS (all 3 TCs): $passCount" -ForegroundColor Green
Write-Host "  FAIL: $failCount" -ForegroundColor $(if ($failCount -gt 0) { 'Red' } else { 'White' })
Write-Host "  TC1 = body visible text in Kannada" -ForegroundColor Gray
Write-Host "  TC2 = script visible strings in Kannada" -ForegroundColor Gray
Write-Host "  TC3 = headings and p in Kannada" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan

# Write detailed report
$reportPath = Join-Path $repoRoot "scripts\translation-test-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("Translation tests - " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
[void]$sb.AppendLine("TC1: Body visible text translated | TC2: Script visible strings translated | TC3: Headings and p translated")
[void]$sb.AppendLine("")
foreach ($r in $results) {
    $status = if ($r.AllPass) { "PASS" } else { "FAIL" }
    [void]$sb.AppendLine("$status | TC1:$($r.TC1Count) TC2:$($r.TC2Count) TC3:$($r.TC3Count) | $($r.File)")
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("PASS: $passCount | FAIL: $failCount | Total: $($files.Count)")
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "Report: $reportPath" -ForegroundColor Gray

# Collect ALL failing FULL segments for 100% coverage (unique)
$allFull = [System.Collections.ArrayList]::new()
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText((Join-Path $outDir $f.Name), [System.Text.Encoding]::UTF8)
    foreach ($s in (Test-TC1-FullSegments $content)) { [void]$allFull.Add($s) }
    foreach ($s in (Test-TC2-FullSegments $content)) { [void]$allFull.Add($s) }
    foreach ($s in (Test-TC3-FullSegments $content)) { [void]$allFull.Add($s) }
}
$uniqueFull = @($allFull | Sort-Object -Unique)
$snippetsPath = Join-Path $repoRoot "scripts\translation-fail-snippets.txt"
if ($uniqueFull.Count -gt 0) { [System.IO.File]::WriteAllLines($snippetsPath, $uniqueFull, [System.Text.Encoding]::UTF8) }
Write-Host "Unique full fail segments: $($uniqueFull.Count) -> $snippetsPath" -ForegroundColor Gray

if ($failCount -gt 0) { exit 1 }
exit 0
