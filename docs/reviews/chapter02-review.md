# Chapter 2 – Review (Pros, Cons, Improvements)

**Topic:** Acids, bases, indicators, neutralisation (ಅಮ್ಲ, ಕ್ಷಾರ, ಸೂಚಕಗಳು)  
**Files:** 10 simulations

| # | File | One-line note |
|---|------|----------------|
| 1 | simulation1_hidden_message_kn.html | Intro/engagement; gradient UI, safe-area. |
| 2 | simulation2_litmus_indicator_kn.html | Litmus in acid/base; clear result labels. |
| 3 | simulation3_properties_acids_bases_kn.html | Properties comparison; compact. |
| 4 | simulation4_red_rose_indicator_kn.html | Red rose indicator; visual feedback. |
| 5 | simulation5_turmeric_indicator_kn.html | Turmeric; consistent control pattern. |
| 6 | simulation6_olfactory_indicator_kn.html | Smell indicator; caution messaging. |
| 7 | simulation7_neutralisation_reaction_kn.html | Neutralisation; equation/feedback. |
| 8 | simulation8_ant_bite_treatment_kn.html | Application; ant bite + base. |
| 9 | simulation9_soil_treatment_kn.html | Soil treatment; real-world link. |
| 10 | simulation10_industrial_waste_treatment_kn.html | Industrial waste; broader context. |

---

## Pros

- **Consistent layout:** Header, section titles, sim-card, visual area across files; Noto Sans Kannada, viewport, theme-color.
- **Application focus:** From indicators (litmus, turmeric, red rose, olfactory) to neutralisation and real-life use (ant bite, soil, industrial waste).
- **Kannada UI:** Titles, labels, and instructions in Kannada; JS identifiers in English (post-fix) for maintainability.
- **Touch-friendly:** Buttons and controls sized for mobile; safe-area insets where used.
- **No missing IDs:** All getElementById/querySelector targets exist in DOM (verified).

---

## Cons

- **No concept-text block in some sims:** Review script flags "no_concept_text" for several Ch2 files; concept could be in header/paragraph only.
- **Limited ARIA:** Interactive elements generally lack aria-labels for screen readers.
- **Varied visual height:** Some use 40vh, others differ; small inconsistency.

---

## Improvements

1. **Accessibility:** Add `aria-label` to buttons and key controls in each sim (e.g. "ಅಮ್ಲ ಸೇರಿಸಿ", "ಕ್ಷಾರ ಸೇರಿಸಿ").
2. **Consistency:** Where helpful, add a short `.concept-text` or `.concept-card` with one sentence on "why this indicator" or "what we see".
3. **Optional:** Add a chapter index page (list of 10 sims with short titles and links) for easier navigation.
