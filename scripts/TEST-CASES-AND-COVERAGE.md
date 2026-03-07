# Test Cases and Coverage Metrics – Kannada Simulations

This document defines **test cases** and **coverage metrics** for all `kannada_simulations/*_kn.html` files (71 total). Run the full suite with:

```powershell
cd scripts
.\run-full-coverage.ps1
```

Output: `scripts/coverage-report.txt` (and optional JSON).

---

## 1. Translation test cases and coverage

**Scope:** Every `*_kn.html` file.  
**Script:** `run-translation-tests.ps1`

| ID   | Test case | Input | Expected | Coverage metric |
|------|------------|--------|----------|------------------|
| **TC1** | Body visible text translated | Body HTML (excl. script/style) | No segment with 5+ consecutive Latin letters without Kannada or allowlist | **TC1 pass %** = (files with 0 TC1 failures) / 71 |
| **TC2** | Script visible strings translated | Script block innerHTML/textContent/result/title/… strings | No string with 6+ Latin letters without Kannada or allowlist | **TC2 pass %** = (files with 0 TC2 failures) / 71 |
| **TC3** | Headings and paragraphs in Kannada | `<h1>`, `<h2>`, `<p>` content | Each contains at least one Kannada character or is allowlisted | **TC3 pass %** = (files with 0 TC3 failures) / 71 |

**Allowlist:** H₂O, H2O, pH, LED, ACID, BASE, NEUTRAL, HCl, NaOH, CO2, O2, N2, NaHCO3, CH3COOH, CH3COONa, Ladakh.

**Coverage metrics:**
- **Translation file coverage:** `(files with AllPass) / 71` → target 100%.
- **Segment-level:** Total TC1+TC2+TC3 fail segments across files; target 0.

**Report:** `translation-test-report.txt`, `translation-fail-snippets.txt`.

---

## 2. Garbled text (mojibake) test cases and coverage

**Scope:** Every `*_kn.html` file.  
**Script:** `run-garbled-check.ps1`

| ID   | Test case | Input | Expected | Coverage metric |
|------|------------|--------|----------|------------------|
| **GT1** | No UTF-8-as-Latin-1 mojibake in body | Body text (excl. script/style) | No run of pattern `à²` (or `à³`) followed by continuation bytes typical of mis-decoded Kannada | **Files clean** = count of files with 0 mojibake hits in body |
| **GT2** | No mojibake in script visible strings | Script block string literals shown to user | Same as GT1 for script content | **Files clean (script)** = count of files with 0 mojibake in script |

**Mojibake pattern:** Sequences like `à²¬à²¿à²¸à²¿`, `à²¨à³€à²µà³`, etc. (UTF-8 Kannada bytes interpreted as Latin-1).

**Coverage metrics:**
- **Garbled-file coverage:** `(files with 0 mojibake segments) / 71` → target 100%.
- **Total mojibake segments:** Sum over all files; target 0.

**Report:** `garbled-check-report.txt`.

---

## 3. Interactive functionality test cases and coverage

**Scope:** Every `*_kn.html` file.  
**Script:** `run-interactive-check.ps1`

| ID   | Test case | Input | Expected | Coverage metric |
|------|------------|--------|----------|------------------|
| **IF1** | Buttons have handlers | Each `<button>`, `onclick=`, `addEventListener` | For each onclick/handler, a corresponding function or method exists in script | **Handler coverage** = (elements with valid handler) / (total interactive elements) |
| **IF2** | Referenced IDs exist | All `getElementById('id')`, `querySelector('[id]')` in script | Each referenced `id` appears in the HTML | **ID coverage** = (IDs that exist in DOM) / (IDs referenced in script) |
| **IF3** | Data-driven handlers use defined keys | `onclick="fn('key')"` or `data-method="key"` | If script uses a `methods[key]` or similar object, `key` is present | **Key coverage** = (keys that exist) / (keys used in markup) |

**Interactive elements:** `<button>`, `<a>` with onclick, elements with `onclick=`, `data-method` (or similar) used by script.

**Coverage metrics:**
- **Interactive file coverage:** (files with 100% IF1/IF2/IF3 for their elements) / 71.
- **Total interactive elements:** Count across 71 files.
- **Total elements with valid handler:** Count where IF1 passes.

**Report:** `interactive-check-report.txt`, optional `interactive-inventory.csv`.

---

## 4. Comparison with original file test cases and coverage

**Scope:** Every `*_kn.html` that has a corresponding original on a known git branch.  
**Script:** `run-original-comparison.ps1`

**Original mapping:**  
`science_chapterN_simulationM_<concept>_kn.html` → branch `origin/unitK-html-simulations` (K=N for N≥2) or chapter 1 from `lightsShadows4.html`.  
Script uses `convert-all-to-kannada.ps1` branch map to resolve original path.

| ID   | Test case | Input | Expected | Coverage metric |
|------|------------|--------|----------|------------------|
| **OC1** | Critical IDs preserved | IDs referenced in Kannada file script (getElementById, querySelector) | Same IDs exist in original HTML (or original has same count of script-referenced IDs) | **ID match %** per file; **files compared** = count with original available |
| **OC2** | Structure parity | Kannada file structure | Same number of `<script>` blocks; `id` attributes on key containers preserved | **Structure pass %** = (files with same script count and no critical ID drop) / (files compared) |
| **OC3** | No accidental removal of interactive elements | Button/input count in original | Kannada file has at least the same number of buttons/inputs (or documented exception) | **Element count pass %** per file |

**Coverage metrics:**
- **Comparison coverage:** (files for which original was found and compared) / 71.
- **Comparison pass:** (files that pass OC1+OC2+OC3) / (files compared).

**Report:** `original-comparison-report.txt`.

---

## 5. Learnability (can a Kannada student learn from the HTML?)

**Scope:** Every `*_kn.html` file.  
**Script:** `run-learnability-check.ps1`

**Goal:** Measure whether a Kannada-medium student can actually **learn** from the simulation: is there clear instructional content in Kannada, and is it structured for learning?

| ID   | Test case | Input | Expected | Coverage metric |
|------|------------|--------|----------|------------------|
| **L1** | Clear topic heading | `<h1>` or `<h2>` in body | At least one heading contains Kannada (or allowlisted) so the student knows the topic | **L1 pass %** = (files with ≥1 Kannada heading) / 71 |
| **L2** | Learning content block | Body HTML | At least one “learning” block: concept-card, takeaway, learning-text, detail-text, method-info, info-panel, process-text, or similar (class/id hint) | **L2 pass %** = (files with ≥1 such block) / 71 |
| **L3** | Minimum Kannada instructional text | Body text (excl. script/style) | Total Kannada character count (U+0C80–U+0CFF) ≥ threshold (e.g. 80) so there is something substantial to read | **L3 pass %** = (files meeting threshold) / 71 |
| **L4** | Explanatory paragraph or list | `<p>`, `.concept-text`, `.method-text`, or similar | At least one paragraph-like segment with Kannada (length ≥ 20 chars) | **L4 pass %** = (files with ≥1 such segment) / 71 |

**Learnability pass:** File passes if L1 and L2 and L3 (and optionally L4) are true.

**Coverage metrics:**
- **Learnability file coverage:** `(files that pass learnability) / 71` → target 100%.
- **Per-criterion:** L1 %, L2 %, L3 %, L4 % (for diagnosis).

**Report:** `learnability-check-report.txt`.

---

## 6. Combined coverage report

**Script:** `run-full-coverage.ps1`

Produces:

1. **Translation:** Pass/fail per file (TC1, TC2, TC3), segment counts, **translation coverage %**.
2. **Garbled:** Files with 0 mojibake, total mojibake segments, **garbled coverage %**.
3. **Interactive:** Total elements, validated handlers, **interactive coverage %**.
4. **Original comparison:** Files compared, IDs/structure pass, **comparison coverage %** and **comparison pass %**.
5. **Learnability:** L1–L4 per file, **learnability coverage %** (can a Kannada student learn from the HTML?).

**Coverage metric summary (targets):**

| Metric | Formula | Target |
|--------|--------|--------|
| Translation | (files AllPass) / 71 | 100% |
| Garbled | (files with 0 mojibake) / 71 | 100% |
| Interactive | (elements with valid handler) / (total interactive elements) | 100% |
| Comparison | (files compared) / 71; (files pass) / (files compared) | 100% compared, 100% pass |
| Learnability | (files pass L1∧L2∧L3) / 71 | 100% |

---

## 7. File manifest

| Script | Purpose |
|--------|--------|
| `run-translation-tests.ps1` | TC1, TC2, TC3; translation-test-report.txt |
| `run-garbled-check.ps1` | GT1, GT2; garbled-check-report.txt |
| `run-interactive-check.ps1` | IF1, IF2, IF3; interactive-check-report.txt |
| `run-original-comparison.ps1` | OC1, OC2, OC3; original-comparison-report.txt |
| `run-learnability-check.ps1` | L1–L4; learnability-check-report.txt (can Kannada student learn?) |
| `run-full-coverage.ps1` | Runs all, writes coverage-report.txt |
| `verify-kannada-simulations.ps1` | Production sanity (DOCTYPE, lang, font, charset) |

All paths relative to repo root; run from `scripts/` or repo root.
