# Convert all simulation HTMLs from unit2-unit8 branches to Kannada and save to kannada_simulations/
# Run from repo root. Requires: current branch can be kannada (files written to kannada_simulations/)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot "kannada_simulations"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$fontLink = @"
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Kannada:wght@400;500;600;700&display=swap" rel="stylesheet">
"@

# Branch ref -> chapter number. Unit2 uses cursor/unit2-html-simulations-af5f
$branchChapterMap = @{
    "origin/cursor/unit2-html-simulations-af5f" = 2
    "origin/unit3-html-simulations" = 3
    "origin/unit4-html-simulations" = 4
    "origin/unit5-html-simulations" = 5
    "origin/unit6-html-simulations" = 6
    "origin/unit7-html-simulations" = 7
    "origin/unit8-html-simulations" = 8
}

# Common English -> Kannada (order: longer phrases first to avoid partial replace)
$translations = @(
    @("Reference (baseline)", "ಉಲ್ಲೇಖ (ಆಧಾರ)")
    @("Experiment (change & observe)", "ಪ್ರಯೋಗ (ಬದಲಾಯಿಸಿ ಮತ್ತು ಗಮನಿಸಿ)")
    @("Select a solution to test:", "ಪರೀಕ್ಷಿಸಲು ದ್ರಾವಣ ಆಯ್ಕೆಮಾಡಿ:")
    @("What you discovered:", "ನೀವು ಕಂಡುಕೊಂಡದ್ದು:")
    @("Key Insight:", "ಮುಖ್ಯ ಅಂತರ್ದೃಷ್ಟಿ:")
    @("Blue Litmus", "ನೀಲಿ ಲಿಟ್ಮಸ್")
    @("Red Litmus", "ಕೆಂಪು ಲಿಟ್ಮಸ್")
    @("Soap Solution", "ಸಾಬೂನು ದ್ರಾವಣ")
    @("Baking Soda", "ಬೇಕಿಂಗ್ ಸೋಡಾ")
    @("Lime Water", "ಸುಣ್ಣದ ನೀರು")
    @("Tap Water", "ನಳ ನೀರು")
    @("Sugar Solution", "ಸಕ್ಕರೆ ದ್ರಾವಣ")
    @("Salt Solution", "ಉಪ್ಪು ದ್ರಾವಣ")
    @("Lemon Juice", "ನಿಂಬೆ ರಸ")
    @("Curd/Yogurt", "ಮೊಸರು")
    @("Solution:", "ದ್ರಾವಣ:")
    @("Conclusion:", "ತೀರ್ಮಾನ:")
    @("Submit", "ಸಲ್ಲಿಸಿ")
    @("Adjust", "ಸರಿಹೊಂದಿಸಿ")
    @("Distance", "ದೂರ")
    @("Size", "ಗಾತ್ರ")
    @("Material", "ಪದಾರ್ಥ")
    @("Opaque", "ಅಪಾರದರ್ಶಕ")
    @("Translucent", "ಅರೆಪಾರದರ್ಶಕ")
    @("Transparent", "ಪಾರದರ್ಶಕ")
    @("Select", "ಆಯ್ಕೆಮಾಡಿ")
    @("Test", "ಪರೀಕ್ಷೆ")
    @("Result", "ಫಲಿತಾಂಶ")
    @("Conclusion", "ತೀರ್ಮಾನ")
    @("Solution", "ದ್ರಾವಣ")
    @("Original", "ಮೂಲ")
    @("No change", "ಬದಲಾವಣೆ ಇಲ್ಲ")
    @("Dip Papers", "ಕಾಗದಗಳನ್ನು ಮುಳುಗಿಸಿ")
    @("ACIDIC", "ಆಮ್ಲೀಯ")
    @("BASIC", "ಕ್ಷಾರೀಯ")
    @("NEUTRAL", "ತಟಸ್ಥ")
    @("Acidic", "ಆಮ್ಲೀಯ")
    @("Basic", "ಕ್ಷಾರೀಯ")
    @("Neutral", "ತಟಸ್ಥ")
    @("Blue", "ನೀಲಿ")
    @("Red", "ಕೆಂಪು")
    @("Lemon", "ನಿಂಬೆ")
    @("Vinegar", "ವಿನಿಗರ್")
    @("Curd", "ಮೊಸರು")
    @("Soap", "ಸಾಬೂನು")
    @("Sugar", "ಸಕ್ಕರೆ")
    @("Salt", "ಉಪ್ಪು")
    @("Water", "ನೀರು")
)

function Convert-ToKannada {
    param([string]$html)
    $out = $html
    $out = $out -replace '<html lang="en">', '<html lang="kn" dir="ltr">'
    if ($out -notmatch 'Noto Sans Kannada') {
        $out = $out -replace '(<head[^>]*>)', "`$1`n$fontLink"
        $out = $out -replace 'font-family:\s*system-ui', "font-family: 'Noto Sans Kannada', system-ui"
    }
    foreach ($pair in $translations) {
        $out = $out.Replace($pair[0], $pair[1])
    }
    return $out
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
        $content = git show "${branch}:${f}" 2>$null
        if (-not $content) { Write-Warning "Could not get ${branch}:${f}"; continue }
        $kannada = Convert-ToKannada $content
        [System.IO.File]::WriteAllText($outPath, $kannada, [System.Text.UTF8Encoding]::new($false))
        $count++
        Write-Host "  $outName"
    }
}
Write-Host "Done. Created $count Kannada simulation files."
# lightsShadows4 -> chapter 1 is already in kannada_simulations (science_chapter1_simulation1_light_and_shadows_kn.html)
