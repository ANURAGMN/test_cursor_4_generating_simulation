# Fix mojibake in Kannada HTML files (DOCTYPE, Noto Sans Kannada, UTF-8, font-family).
# Skip already-correct: red_rose, chapter1 light_and_shadows.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$skip = @(
    "science_chapter2_simulation4_red_rose_indicator_kn.html",
    "science_chapter1_simulation1_light_and_shadows_kn.html"
)

$fixes = @(
    @('<!iruaYPx html>', '<!DOCTYPE html>')
    @('family=ooto+eans+eannada:', 'family=Noto+Sans+Kannada:')
    @("'ooto eans eannada'", "'Noto Sans Kannada'")
    @('llinkaaceystemFont', 'BlinkMacSystemFont')
    @("'eegoe UI'", "'Segoe UI'")
    @('eoboto,', 'Roboto,')
    @('UaF-8', 'UTF-8')
)

$count = 0
Get-ChildItem -Path $outDir -Filter "*_kn.html" | ForEach-Object {
    if ($skip -contains $_.Name) { return }
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $orig = $content
    foreach ($pair in $fixes) {
        $content = $content.Replace($pair[0], $pair[1])
    }
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $content, $utf8NoBom)
        $count++
        Write-Host "Fixed: $($_.Name)"
    }
}
Write-Host "Done. Fixed $count files."