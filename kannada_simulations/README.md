# Kannada student-specific simulations

All simulation HTML files are converted to **Kannada (ಕನ್ನಡ)** for Kannada-medium students. Each file is named:

**`subjectName_chapterorder_simulationorder_conceptname_kn.html`**

Example: `science_chapter1_simulation1_light_and_shadows_kn.html`, `science_chapter2_simulation2_litmus_indicator_kn.html`.

## What was done

- **Language:** `lang="kn"`, `dir="ltr"`, Kannada UI text throughout.
- **Font:** Noto Sans Kannada (Google Fonts) for correct Kannada rendering.
- **Logic fixes:** In the Light & Shadows simulation, the drag hint was clarified (horizontal = light distance, vertical = object size). Material label in metrics shows Kannada text (ಅಪಾರದರ್ಶಕ, ಅರೆಪಾರದರ್ಶಕ, ಪಾರದರ್ಶಕ) via script.
- **Naming:** All files follow `science_chapterN_simulationM_conceptname_kn.html`.

## Files (all 71 simulations)

- **Chapter 1:** `science_chapter1_simulation1_light_and_shadows_kn.html` (from lightsShadows4.html on any branch)
- **Chapter 2:** 10 simulations (unit2 → cursor/unit2-html-simulations-af5f): hidden_message, litmus_indicator, properties_acids_bases, red_rose_indicator, turmeric_indicator, olfactory_indicator, neutralisation_reaction, ant_bite_treatment, soil_treatment, industrial_waste_treatment
- **Chapter 3:** 10 simulations (unit3-html-simulations): electricity_uses, electricity_sources, torch_components, electric_cell, battery_connection, lamp_types, simple_circuit, electric_switch, circuit_symbols, conductors_insulators
- **Chapter 4:** 10 simulations (unit4): malleability, ductility, sonority, heat_conduction, electrical_conductivity, rusting_experiment, metal_oxide_reaction, nonmetal_oxide_reaction, metals_nonmetals_compare, applications
- **Chapter 5:** 10 simulations (unit5): physical_changes, chemical_changes, reversible_irreversible, states_of_matter, fire_triangle, oxygen_combustion, candle_burning, combustion_examples, desirable_undesirable, weathering_erosion
- **Chapter 6:** 10 simulations (unit6): life_stages, growth_chart, physical_changes, voice_changes, menstrual_cycle, emotional_changes, nutrition, hygiene, healthy_habits, say_no
- **Chapter 7:** 10 simulations (unit7): heat_sources, conduction, conductors_insulators, convection, land_sea_breeze, radiation, combined_heat_transfer, water_cycle, infiltration, water_conservation
- **Chapter 8:** 10 simulations (unit8): historical_clocks, sundial, pendulum, pendulum_timing, time_units, speed_calculator, speed_race, uniform_motion, nonuniform_motion, speedometer

## Conversion script and encoding

The script **`scripts/convert-all-to-kannada.ps1`** regenerates Kannada HTML from the unit branches. It:

- Reads git content via **cmd with chcp 65001** so output is UTF-8.
- Applies translations **only outside `<script>...</script>`** so JavaScript (e.g. `getElementById`, `SOLUTIONS`) is never changed.
- Loads translation pairs from **`scripts/kannada-translations.txt`** (UTF-8) to avoid script-file encoding issues.
- Adds `lang="kn"`, Noto Sans Kannada font, and Kannada UI strings in the HTML body.

**Reference correct file:** **`science_chapter2_simulation4_red_rose_indicator_kn.html`** is a full reference: structure matches the original, all visible text is in Kannada (including script-driven labels via `nameKn` / `TYPE_KN`). Use it as the template for adding Kannada to dynamic text inside `<script>` in other simulations.

## How to add more Kannada simulations from other branches

1. **Checkout the branch** that has the HTML you need:
   ```bash
   git fetch origin
   git checkout remotes/origin/cursor/unit2-html-simulations-af5f   # unit2
   git checkout remotes/origin/unit3-html-simulations   # unit3
   # etc. for unit4, unit5, unit6, unit7, unit8
   ```

2. **Map branch → chapter:**
   - main / lightsShadows4 → chapter 1  
   - unit2 → chapter 2  
   - unit3 → chapter 3  
   - unit4 → chapter 4  
   - unit5 → chapter 5  
   - unit6 → chapter 6  
   - unit7 → chapter 7  
   - unit8 → chapter 8  

3. **For each HTML** (e.g. `simulation_2_litmus_indicator.html` on unit2):
   - Convert all user-visible text to Kannada.
   - Set `<html lang="kn" dir="ltr">`, add Noto Sans Kannada in `<head>`, and use `font-family: 'Noto Sans Kannada', ...` in body.
   - Save as `science_chapterN_simulationM_conceptname_kn.html` in this folder (e.g. `science_chapter2_simulation2_litmus_indicator_kn.html`).

4. **Optional:** Use the conversion script (requires Node.js):
   ```bash
   node scripts/convert-to-kannada.js path/to/simulation_X.html kannada_simulations/science_chapterN_simulationX_concept_kn.html
   ```
   Then manually add any missing Kannada strings (especially inside `<script>`).

## Production verification

All **71** Kannada simulation files have been verified production-ready:

- **Structure:** Each file has `<!DOCTYPE html>`, `lang="kn"`, `charset="UTF-8"`, Noto Sans Kannada font (link + body), and valid `</html>`.
- **No corruption:** No mojibake (e.g. no `iruaYPx`, `ooto eans eannada`) and no broken JavaScript (`getElementById`, `textContent`, `setAttribute` etc. left intact).
- **Parity with original:** Conversion applies only to HTML; `<script>...</script>` is unchanged so behavior matches the English original. Common UI strings are translated via `kannada-translations.txt`.

To re-verify after any changes, run from repo root:

```powershell
.\scripts\verify-kannada-simulations.ps1
```

Exit code 0 = all pass.

### Retest with 2–3 test cases per simulation

For quality assurance, each simulation is checked with **3 test cases**:

- **TC1 – Structure:** Required strings present (`<!DOCTYPE html>`, `lang="kn"`, Noto Sans Kannada, `charset="UTF-8"`, `</html>`), no forbidden/corruption strings.
- **TC2 – Kannada content:** At least one Kannada character (Unicode 0C80–0CFF) in the HTML body (before `<script>`).
- **TC3 – DOM consistency:** Every `getElementById('id')` in script has a matching `id="..."` in the file.

Run from repo root:

```powershell
.\scripts\test-kannada-simulations.ps1
```

All 71 simulations currently pass all three test cases. To add or update Kannada UI text, edit `scripts/kannada-translations.txt` (format `English|Kannada` per line, UTF-8), then run `.\scripts\apply-translations-to-kannada-files.ps1` (id attributes are protected from translation).

### One-by-one verification (all ~70 files)

To print a **per-file result** for every simulation (PASS/FAIL and TC1/TC2/TC3 per file), run:

```powershell
.\scripts\verify-each-kannada-simulation.ps1
```

This checks each of the 71 files individually and reports status. A manual spot-check of 2–3 files per chapter (structure, Kannada title/body, key elements) has been done; all sampled files have correct DOCTYPE, `lang="kn"`, Noto Sans Kannada, UTF-8, and Kannada titles.

### Logic and original-file comparison (all ~70, one-by-one)

Each Kannada simulation is compared to its **original** HTML from the repo (git) for:

- **Script block:** The `<script>...</script>` block in the Kannada file must match the original (ensures no accidental corruption). **Exceptions:** `science_chapter1_simulation1_light_and_shadows_kn.html` (improved script with Kannada material labels `typeKn`, ಪದಾರ್ಥ) and `science_chapter2_simulation4_red_rose_indicator_kn.html` (full Kannada script) are intentionally different and are skipped for script comparison.
- **DOM consistency:** Every `getElementById('id')` in the script has a matching `id="..."` in the file so behaviour matches the original.

Run from repo root (requires git and origin branches):

```powershell
.\scripts\compare-kannada-to-original.ps1
```

All 71 simulations pass this logic check (script match or allowed exception + DOM ids present).

## Branch → HTML list

See **BRANCH_HTML_MAPPING.md** in this folder for the full list of branches and their HTML files and target Kannada filenames.

## Correcting logical flaws

When converting, review each simulation for:

- Correct labels (e.g. “drag” meaning light distance vs object size).
- Correct units and metrics (Kannada labels for values).
- No broken interactivity (button text, tooltips, and script-driven text in Kannada where needed).
