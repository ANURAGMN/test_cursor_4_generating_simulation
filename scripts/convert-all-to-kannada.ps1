# Convert all simulation HTMLs from unit2-unit8 branches to Kannada.
# CRITICAL: Apply translations ONLY outside <script>...</script> so JS code stays intact.
# Read/write UTF-8 to avoid mojibake.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
# Prefer UTF-8 for git output (run in PowerShell 7 or set chcp 65001 first if needed)
try { $OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
$outDir = Join-Path $repoRoot "kannada_simulations"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$fontLink = @"
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Kannada:wght@400;500;600;700&display=swap" rel="stylesheet">
"@

$branchChapterMap = @{
    "origin/cursor/unit2-html-simulations-af5f" = 2
    "origin/unit3-html-simulations" = 3
    "origin/unit4-html-simulations" = 4
    "origin/unit5-html-simulations" = 5
    "origin/unit6-html-simulations" = 6
    "origin/unit7-html-simulations" = 7
    "origin/unit8-html-simulations" = 8
}

# Load translations from UTF-8 file to avoid script encoding issues (longer phrases first in file)
$translationsFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "kannada-translations.txt"
$translations = @()
if (Test-Path $translationsFile) {
    $lines = [System.IO.File]::ReadAllText($translationsFile, [System.Text.Encoding]::UTF8) -split "`n"
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -and $line -match '^([^|]+)\|(.+)$') { $translations += ,@($Matches[1], $Matches[2]) }
    }
}

function Apply-TranslationsToSegment {
    param([string]$segment)
    $s = $segment
    foreach ($pair in $translations) {
        $s = $s.Replace($pair[0], $pair[1])
    }
    return $s
}

function Convert-ToKannadaSafe {
    param([string]$html)
    # 1) Split: only translate parts OUTSIDE <script>...</script>
    $scriptStart = $html.IndexOf('<script')
    $scriptEnd = $html.IndexOf('</script>')
    if ($scriptStart -lt 0 -or $scriptEnd -lt 0) {
        # No script block: translate whole (avoid replacing in style/script anyway)
        $beforeScript = $html
        $scriptBlock = $null
        $afterScript = $null
    } else {
        $scriptEnd += '</script>'.Length
        $beforeScript = $html.Substring(0, $scriptStart)
        $scriptBlock = $html.Substring($scriptStart, $scriptEnd - $scriptStart)
        $afterScript = $html.Substring($scriptEnd)
    }

    # 2) Head/body: lang, font, and translations (no replace inside script)
    $beforeScript = $beforeScript -replace '<html lang="en">', '<html lang="kn" dir="ltr">'
    if ($beforeScript -notmatch 'Noto Sans Kannada') {
        $beforeScript = $beforeScript -replace '(<head[^>]*>)', "`$1`n$fontLink"
        $beforeScript = $beforeScript -replace 'font-family:\s*system-ui', "font-family: 'Noto Sans Kannada', system-ui"
    }
    $beforeScript = Apply-TranslationsToSegment $beforeScript

    $afterScript = Apply-TranslationsToSegment $afterScript

    # 3) Reassemble (script block unchanged)
    if ($scriptBlock -ne $null) {
        return $beforeScript + $scriptBlock + $afterScript
    }
    return $beforeScript
}

# Read from git (call operator). For correct UTF-8 run in PowerShell 7 or: chcp 65001 then run script.
function Get-GitFileUtf8 {
    param([string]$branch, [string]$path)
    $tmp = Join-Path $outDir ".tmp_git_$([Guid]::NewGuid().ToString('n').Substring(0,8)).html"
    try {
        $ref = "`"${branch}:${path}`""
        $cmd = "chcp 65001 >nul & git show $ref > `"$tmp`""
        $null = cmd /c $cmd
        if (-not (Test-Path $tmp) -or (Get-Item $tmp).Length -eq 0) { return $null }
        $text = [System.IO.File]::ReadAllText($tmp, [System.Text.Encoding]::UTF8)
        return [string]$text
    } catch {
        return $null
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

$count = 0
foreach ($branch in $branchChapterMap.Keys) {
    $chapter = $branchChapterMap[$branch]
    $files = git ls-tree --name-only $branch 2>$null | Where-Object { $_ -match '^simulation_\d+_.+\.html$' }
    foreach ($f in $files) {
        if ($f -notmatch '^simulation_(\d+)_(.+)\.html$') { continue }
        $num = $Matches[1]
        $concept = $Matches[2]
        $outName = "science_chapter${chapter}_simulation${num}_${concept}_kn.html"
        $outPath = Join-Path $outDir $outName
        if ($outName -eq "science_chapter2_simulation4_red_rose_indicator_kn.html") { $count++; Write-Host "  $outName (skip - already corrected)"; continue }
        $content = Get-GitFileUtf8 -branch $branch -path $f
        if (-not $content -or $content -isnot [string]) { Write-Warning "Could not get ${branch}:${f}"; continue }
        $kannada = Convert-ToKannadaSafe $content
        [System.IO.File]::WriteAllText($outPath, $kannada, $utf8NoBom)
        $count++
        Write-Host "  $outName"
    }
}
Write-Host "Done. Created $count Kannada simulation files."