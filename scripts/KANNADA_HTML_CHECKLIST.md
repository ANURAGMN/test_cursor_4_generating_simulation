# Kannada HTML – holistic check todo

Use this checklist to verify all Kannada simulation HTML files. Target: **70 files** (all `*_kn.html` except the reference `science_chapter2_simulation4_red_rose_indicator_kn.html` if treated as reference-only; otherwise all **71**).

---

## 1. Check every HTML file

- [ ] **Coverage:** Confirm every expected simulation has a `kannada_simulations/*_kn.html` file (71 files total).
- [ ] **Listing:** Keep or generate a list of all `*_kn.html` (e.g. `Get-ChildItem kannada_simulations\*_kn.html`).
- [ ] **Naming:** Ensure naming follows `science_chapterN_simulationM_<concept>_kn.html`.

**Scripts:** `run-translation-tests.ps1` (counts files); `verify-kannada-simulations.ps1` (structure).

---

## 2. Maintain file-specific translation

- [ ] **Per-file translation files:** Each `*_kn.html` can have `scripts/translations/<basename>.txt` (e.g. `science_chapter7_simulation7_combined_heat_transfer_kn.txt`).
- [ ] **Format:** `English phrase|Kannada phrase` (one per line); file-specific entries override common `kannada-translations.txt`.
- [ ] **Apply:** After editing translations, run `apply-translations-to-kannada-files.ps1` so all 70/71 HTMLs get the latest common + file-specific translations.
- [ ] **No regression:** Re-run translation tests after any change to `kannada-translations.txt`, `force-replacements.txt`, or `scripts/translations/*.txt`.

**Scripts:** `apply-translations-to-kannada-files.ps1`; `scripts/translations/README.md`.

---

## 3. Garbled text (mojibake) check

- [ ] **Detection:** Scan every `*_kn.html` for garbled patterns (e.g. `à²…` sequences or other Latin-1 supplement where Kannada is expected).
- [ ] **Fix source:** Add correct Kannada replacements to `scripts/force-replacements.txt` (or file-specific `scripts/translations/<basename>.txt`) and re-run the apply script.
- [ ] **Automation (optional):** Extend translation tests or add a small script to report lines/files containing known mojibake patterns so all 70/71 files are checked.

**Note:** Translation tests currently skip segments containing `[\u00A0-\u00FF]` for TC1/TC2 so mojibake doesn’t count as “untranslated”; a dedicated mojibake scan is still recommended.

---

## 4. Functionality check – every button and interactive element (all 70 HTMLs)

- [ ] **Inventory:** For each of the 70 HTML files, list interactive elements: buttons, tabs, dropdowns, sliders, links, clickable areas, etc.
- [ ] **Per file:** For each file, verify:
  - Buttons and tabs switch content/state (e.g. method selector in combined heat transfer).
  - No JS errors (e.g. `methods[method]` or `getElementById` exist; handlers attached).
  - Event handlers use stable keys (e.g. English `data-method` or string keys) so encoding doesn’t break clicks.
- [ ] **Execution:** Manually or via a browser automation run through each file and trigger each button/interactive element; confirm visible response and no console errors.
- [ ] **Documentation (optional):** Maintain a short “interactive map” (e.g. CSV or markdown) listing file → list of interactive elements and expected behaviour.

**Scripts:** No fully automated script yet; manual or Playwright/Puppeteer-based checks recommended.

---

## Quick commands

```powershell
# From repo root
cd scripts

# 1 & 2 – Translation + structure
.\run-translation-tests.ps1
.\verify-kannada-simulations.ps1

# Apply translations (after editing translations)
.\apply-translations-to-kannada-files.ps1
```

---

## Todo summary

| # | Task | Status |
|---|------|--------|
| 1 | Check every HTML file (71; list & coverage) | Pending |
| 2 | Maintain file-specific translation (`scripts/translations/` + apply) | Pending |
| 3 | Garbled text (mojibake) check across all 70/71 HTML | Pending |
| 4 | Functionality check: every button & interactive element in all 70 HTML | Pending |

Update this file and the Cursor todo list as items are completed.
