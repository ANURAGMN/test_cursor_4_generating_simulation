# Apply Kannada translations to all *_kn.html: common (kannada-translations.txt) + per-file (scripts/translations/<basename>.txt).
# HTML and script block are translated. UTF-8. Skip red_rose. Longest-first. id= and getElementById protected.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$outDir = Join-Path $repoRoot "kannada_simulations"
$translationsFile = Join-Path $scriptDir "kannada-translations.txt"
$translationsDir = Join-Path $scriptDir "translations"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# Load common translations (shared by all HTML files)
$commonTranslations = @()
if (Test-Path $translationsFile) {
    $raw = [System.IO.File]::ReadAllText($translationsFile, [System.Text.Encoding]::UTF8)
    if ($raw.Length -gt 0 -and [int][char]$raw[0] -eq 0xFEFF) { $raw = $raw.Substring(1) }
    $lines = $raw -split "`r?`n"
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -and $line -notmatch '^\s*#' -and $line -match '^([^|]+)\|(.+)$') {
            $commonTranslations += ,@($Matches[1].Trim(), $Matches[2].Trim())
        }
    }
}

# Load file-specific translations from scripts/translations/<basename>.txt (English -> Kannada; file-specific overrides common)
function Get-TranslationsForFile {
    param([string]$baseName)
    $merged = @{}
    foreach ($pair in $commonTranslations) {
        $merged[$pair[0]] = $pair[1]
    }
    $filePath = Join-Path $translationsDir ($baseName + ".txt")
    if (Test-Path $filePath) {
        $lines = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8) -split "`r?`n"
        foreach ($line in $lines) {
            $line = $line.Trim()
            if ($line -and $line -notmatch '^\s*#' -and $line -match '^([^|]+)\|(.+)$') {
                $merged[$Matches[1].Trim()] = $Matches[2].Trim()
            }
        }
    }
    $list = @()
    foreach ($k in $merged.Keys) { $list += ,@($k, $merged[$k]) }
    return $list | Sort-Object { -$_[0].Length }
}

# Force-replace stub strings first (loaded from file to avoid .ps1 encoding issues)
$forceReplacementsFile = Join-Path $scriptDir "force-replacements.txt"
$forceReplacements = @()
if (Test-Path $forceReplacementsFile) {
    $raw = [System.IO.File]::ReadAllText($forceReplacementsFile, [System.Text.Encoding]::UTF8)
    if ($raw.Length -gt 0 -and [int][char]$raw[0] -eq 0xFEFF) { $raw = $raw.Substring(1) }
    foreach ($line in ($raw -split "`r?`n")) {
        $line = $line.Trim()
        if ($line -and $line -notmatch '^\s*#' -and $line -match '^([^|]+)\|(.+)$') {
            $forceReplacements += ,@($Matches[1].Trim(), $Matches[2].Trim())
        }
    }
}
# Force list order: keep file order (put longest strings first in force-replacements.txt)

# Protect id="..." so we don't translate e.g. quizResult -> quizಫಲಿತಾಂಶ
function Apply-ToSegment { param([string]$seg, [array]$translations)
    $s = $seg
    foreach ($fr in $forceReplacements) { $s = $s.Replace($fr[0], $fr[1]) }
    $idMatches = [regex]::Matches($s, 'id\s*=\s*["'']([^"'']+)["'']')
    for ($i = $idMatches.Count - 1; $i -ge 0; $i--) {
        $m = $idMatches[$i]
        $s = $s.Substring(0, $m.Index) + "id=`"___IDP${i}___`"" + $s.Substring($m.Index + $m.Length)
    }
    foreach ($pair in $translations) { $s = $s.Replace($pair[0], $pair[1]) }
    for ($i = 0; $i -lt $idMatches.Count; $i++) { $s = $s.Replace("id=`"___IDP${i}___`"", $idMatches[$i].Value) }
    return $s
}

# Protect getElementById('id') in full content so 'id' is not translated; then restore after Apply-ToSegment
function Apply-ToFullContent { param([string]$content, [array]$translations)
    $s = $content
    $getByIdMatches = [regex]::Matches($s, "getElementById\s*\(\s*['`"]([^'`"]+)['`"]\s*\)")
    for ($i = $getByIdMatches.Count - 1; $i -ge 0; $i--) {
        $m = $getByIdMatches[$i]
        $repl = "getElementById('___GID${i}___')"
        $s = $s.Substring(0, $m.Index) + $repl + $s.Substring($m.Index + $m.Length)
    }
    $s = Apply-ToSegment $s $translations
    for ($i = 0; $i -lt $getByIdMatches.Count; $i++) {
        $idVal = $getByIdMatches[$i].Groups[1].Value
        $s = $s.Replace("___GID${i}___", $idVal)
    }
    $s = [regex]::Replace($s, 'show[\u0C80-\u0CFF]+', 'showSource')
    return $s
}

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$count = 0
foreach ($f in $files) {
    if ($f.Name -eq "science_chapter2_simulation4_red_rose_indicator_kn.html") { continue }
    $baseName = $f.Name -replace '\.html$',''
    $translations = Get-TranslationsForFile $baseName
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $content = Apply-ToFullContent $content $translations
    [System.IO.File]::WriteAllText($f.FullName, $content, $utf8NoBom)
    $count++
    Write-Host "  $($f.Name)"
}
Write-Host "Applied translations to $count files (common + per-HTML from scripts/translations/)."
