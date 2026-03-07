# Chapter 8 – Review (Pros, Cons, Improvements)

**Topic:** Time and motion (ಸಮಯ ಮತ್ತು ಚಲನೆ) – historical clocks, sundial, pendulum, pendulum timing, time units, speed calculator, speed race, uniform/non-uniform motion, speedometer  
**Files:** 10 simulations

| # | File | One-line note |
|---|------|----------------|
| 1 | simulation1_historical_clocks_kn.html | Sun, water, sand, candle, pendulum, quartz; selectClock; animationInterval. |
| 2 | simulation2_sundial_kn.html | updateSundial(hours); gnomon angle. |
| 3 | simulation3_pendulum_kn.html | start/stop/resetPendulum; updateLength; wireEl. |
| 4 | simulation4_pendulum_timing_kn.html | Short/medium/long; animatePendulums; timerInterval. |
| 5 | simulation5_time_units_kn.html | Hours, minutes, seconds, ms. |
| 6 | simulation6_speed_calculator_kn.html | Speed = distance/time. |
| 7 | simulation7_speed_race_kn.html | Walker vs cyclist; raceInterval. |
| 8 | simulation8_uniform_motion_kn.html | updateSpeed; maxDistance; train. |
| 9 | simulation9_nonuniform_motion_kn.html | getSpeedAtTime; intervals. |
| 10 | simulation10_speedometer_kn.html | totalDistance, tripDistance; padStart. |

---

## Pros

- **Chronological and conceptual:** Clocks history → sundial → pendulum → timing → units → speed → race → uniform/non-uniform → speedometer.
- **Math and units:** Time units and speed formula clearly shown; toFixed/padStart used for display.
- **All identifiers in English:** No mixed names; setProperty, animationInterval, updateSundial, etc.

---

## Cons

- **Sundial:** Slider and time display could have optional 24h format.
- **ARIA:** Clock type buttons, sliders, and start/stop buttons need aria-labels.

---

## Improvements

1. Add aria-labels to clock type buttons (“ಸೂರ್ಯ ಘಡಿಯಾರ”, “ಊಸರವಳಿ”), sliders (“ಸಮಯ”, “ದೂರ”, “ವೇಗ”), and start/stop/reset (“ಪ್ರಾರಂಭ”, “ನಿಲ್ಲಿಸಿ”, “ಮರುಹೊಂದಿಸಿ”).
2. Optional: Add 24h toggle for sundial time display.
