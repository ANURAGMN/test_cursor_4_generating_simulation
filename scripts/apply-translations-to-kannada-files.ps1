# Apply kannada-translations.txt to all *_kn.html in kannada_simulations (HTML parts only).
# Use UTF-8. Skip red_rose (already full Kannada). Longest-first to avoid partial replaces.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"
$translationsFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "kannada-translations.txt"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$translations = @()
if (Test-Path $translationsFile) {
    $lines = [System.IO.File]::ReadAllText($translationsFile, [System.Text.Encoding]::UTF8) -split "`n"
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -and $line -notmatch '^\s*#' -and $line -match '^([^|]+)\|(.+)$') {
            $translations += ,@($Matches[1], $Matches[2])
        }
    }
}
# Longest English first to avoid partial replacement
$translations = $translations | Sort-Object { -$_[0].Length }

# Protect id="..." so we don't translate e.g. quizResult -> quizಫಲಿತಾಂಶ
function Apply-ToSegment { param([string]$seg)
    $s = $seg
    $idMatches = [regex]::Matches($s, 'id\s*=\s*["'']([^"'']+)["'']')
    for ($i = $idMatches.Count - 1; $i -ge 0; $i--) {
        $m = $idMatches[$i]
        $s = $s.Substring(0, $m.Index) + "id=`"___IDP${i}___`"" + $s.Substring($m.Index + $m.Length)
    }
    foreach ($pair in $translations) { $s = $s.Replace($pair[0], $pair[1]) }
    for ($i = 0; $i -lt $idMatches.Count; $i++) { $s = $s.Replace("id=`"___IDP${i}___`"", $idMatches[$i].Value) }
    return $s
}

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$count = 0
foreach ($f in $files) {
    if ($f.Name -eq "science_chapter2_simulation4_red_rose_indicator_kn.html") { continue }
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $scriptStart = $content.IndexOf('<script')
    $scriptEnd = $content.IndexOf('</script>')
    if ($scriptStart -lt 0 -or $scriptEnd -lt 0) {
        $content = Apply-ToSegment $content
    } else {
        $scriptEnd += '</script>'.Length
        $before = Apply-ToSegment $content.Substring(0, $scriptStart)
        $scriptBlock = $content.Substring($scriptStart, $scriptEnd - $scriptStart)
        $after = Apply-ToSegment $content.Substring($scriptEnd)
        $content = $before + $scriptBlock + $after
    }
    [System.IO.File]::WriteAllText($f.FullName, $content, $utf8NoBom)
    $count++
    Write-Host "  $($f.Name)"
}
Write-Host "Applied translations to $count files."
