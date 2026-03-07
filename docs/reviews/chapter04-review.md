# Chapter 4 – Review (Pros, Cons, Improvements)

**Topic:** Metals and non-metals (ಲೋಹ ಮತ್ತು ಅಲೋಹ) – malleability, ductility, sonority, heat conduction, electrical conductivity, rusting, reactions, applications  
**Files:** 10 simulations

| # | File | One-line note |
|---|------|----------------|
| 1 | simulation1_malleability_kn.html | Hammer; malleable vs brittle. |
| 2 | simulation2_ductility_kn.html | Stretch; wire result, pulling handle. |
| 3 | simulation3_sonority_kn.html | Tap; sound animation. |
| 4 | simulation4_heat_conduction_kn.html | Spoon in water; metal vs wood. |
| 5 | simulation5_electrical_conductivity_kn.html | Test materials; conductor/insulator. |
| 6 | simulation6_rusting_experiment_kn.html | Rusting conditions. |
| 7 | simulation7_metal_oxide_reaction_kn.html | Metal oxide; litmus. |
| 8 | simulation8_nonmetal_oxide_reaction_kn.html | Burn sulfur; burnSulfur. |
| 9 | simulation9_metals_nonmetals_compare_kn.html | Compare properties. |
| 10 | simulation10_applications_kn.html | Match use to material; checkMatch. |

---

## Pros

- **Property-focused:** Each sim targets one or two properties (malleability, ductility, sonority, conduction, etc.).
- **Consistent JS:** selectMaterial, hammerMaterial, testMaterial, checkMatch, burnSulfur; all IDs and handlers verified.
- **Kannada labels:** Types (ಲೋಹ/ಅಲೋಹ), instructions, and feedback in Kannada.

---

## Cons

- **Sonority animation class:** Keyframe name in Kannada can complicate maintenance; consider English keyframe names with Kannada UI text.
- **ARIA:** Interactive elements lack aria-labels.

---

## Improvements

1. Add aria-labels to material buttons and action buttons (e.g. “ಅದನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ”, “ಸುಡಿ”).
2. Optional: Unify keyframe/animation class names to English where possible, keeping Kannada only in visible strings.
