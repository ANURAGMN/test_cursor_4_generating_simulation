# Per-HTML Kannada translations

Each file here is **specific to one simulation HTML**.  
Filename = HTML basename: `science_chapterN_simulationM_<topic>_kn.txt` (no `.html`).

## Format

- One line per translation: `English|Kannada`
- Lines starting with `#` are comments and ignored.
- UTF-8 encoding.

## How they are used

1. **Common** translations: `scripts/kannada-translations.txt` is applied to every HTML.
2. **File-specific** translations: `scripts/translations/<basename>.txt` are applied only to the matching `*_kn.html`. Entries here **override** the same English phrase in the common file for that HTML only.

Example: to change only the “Start” button text for the pendulum simulation, add to  
`science_chapter8_simulation3_pendulum_kn.txt`:

```
Start|ನಿಮ್ಮ ಕನ್ನಡ ಪಾಠ
```

Then run `scripts/apply-translations-to-kannada-files.ps1` from the repo root.

## Adding new translations for one HTML

1. Open `scripts/translations/<that_simulation>_kn.txt`.
2. Add lines: `Exact English text|ಕನ್ನಡ ಅನುವಾದ`
3. Run the apply script so the HTML is updated.
