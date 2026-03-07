# Chapter 5 – Review (Pros, Cons, Improvements)

**Topic:** Physical and chemical changes, reversible/irreversible, states of matter, fire triangle, combustion, candle, weathering  
**Files:** 10 simulations

| # | File | One-line note |
|---|------|----------------|
| 1 | simulation1_physical_changes_kn.html | Crush, stretch; physical change. |
| 2 | simulation2_chemical_changes_kn.html | Vinegar + baking soda; limewater. |
| 3 | simulation3_reversible_irreversible_kn.html | Reversible vs not; examples. |
| 4 | simulation4_states_of_matter_kn.html | Solid/liquid/gas; temperature. |
| 5 | simulation5_fire_triangle_kn.html | Fuel, oxygen, heat. |
| 6 | simulation6_oxygen_combustion_kn.html | Jar, candle; oxygen use. |
| 7 | simulation7_candle_burning_kn.html | Physical vs chemical view. |
| 8 | simulation8_combustion_examples_kn.html | Materials; burnMaterial. |
| 9 | simulation9_desirable_undesirable_kn.html | Desirable vs undesirable changes. |
| 10 | simulation10_weathering_erosion_kn.html | Timeline; snow/sand/cave scale. |

---

## Pros

- **Concept progression:** Physical → chemical → reversible/irreversible → states → fire → combustion → applications → weathering.
- **Timers and animation:** setInterval/clearInterval used correctly; candle and weathering visuals.
- **English identifiers:** lightCandle, jarClosed, selectMaterial, burnMaterial, sandEl, etc.; no mixed names.

---

## Cons

- **Some long strings:** Inline explanation text in JS; could be moved to data or hidden divs for easier translation.
- **ARIA:** Controls and mode toggles need aria-labels.

---

## Improvements

1. Add aria-labels to mode tabs and action buttons (e.g. “ರಾಸಾಯನಿಕ ದೃಶ್ಯ”, “ಮೇಣ ಬೆಳಗಿಸಿ”).
2. Optional: Extract long explanation strings into a `TEXTS` object or data attribute for easier editing.
