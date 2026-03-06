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

## Branch → HTML list

See **BRANCH_HTML_MAPPING.md** in this folder for the full list of branches and their HTML files and target Kannada filenames.

## Correcting logical flaws

When converting, review each simulation for:

- Correct labels (e.g. “drag” meaning light distance vs object size).
- Correct units and metrics (Kannada labels for values).
- No broken interactivity (button text, tooltips, and script-driven text in Kannada where needed).
