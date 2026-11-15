# Audit of the previous attempt

Inspected on 2026-11-15. Repository: `vokerg/GarminFaceApp`; original tip `297a7cd`. There are four commits, all from 2026-05-14. There is no agent transcript, so conclusions concern code and artifacts rather than the model's private reasoning.

## Evidence

| Commit / material | Finding |
| --- | --- |
| `02c500b` | Long Windows setup README includes a future-agent prompt that limits the design to time/date/battery/steps and asks for small edits. This no longer represents the owner's broader brief. |
| `7631fb5` | First source has three left gauges, including battery twice, plus large time in the same region. Build output and intermediate compiler files are committed. |
| `1ac2e7b` | Face grows into six peripheral metrics, stacked time, date strip and multiple rings. Much more density without a documented layout budget. |
| `297a7cd` | Source renamed to `_v6`; intermediate v2–v6 compiler files survive. Changes mention electric-blue panels, font collisions, smaller fonts and coordinate adjustments. No screenshots were committed to substantiate improvement. |

## Why progress appears circular

The code comments repeatedly explain fixes for local collisions and palette problems. Meanwhile, the overall composition remains crowded: metric centers at x=35/245, 11px separation between label and value, and icons sharing limited space with small gauges. Making fonts smaller can conceal one collision while reducing watch-scale readability elsewhere. This supports the owner's concern about local iteration without a stable visual standard; it does not prove no visual review happened outside Git.

The README's old prompt and actual source disagree: the prompt excludes heart rate/weather, while v6 includes both. The layout XML describes a different design and is not loaded by the current view's empty `onLayout`. There is no single authoritative brief.

## Functional and semantic issues

- `getWeeklyRunDistanceKm()` returns summed ActivityMonitor history distance, not sport-specific completed running distance. Labeling this RUN is misleading.
- `getWeeklyBikeDistanceKm()` always returns null. BIKE is a permanently empty slot.
- Missing steps/calories are converted to zero, concealing the difference between absent data and a measured zero.
- Heart rate uses the latest valid sample from a short history window, but does not communicate age. Its progress arc is HR/180, with no user-specific zone semantics.
- Temperature is always displayed as Celsius regardless of device units; no condition age is shown.
- Seconds are drawn, but sleep callbacks are empty. There is no explicit awake/low-power display policy.
- Colors described as 64-color safe include RGB values outside the regular 64-color cube. Comments report quantization surprises; confirm with the actual device palette rather than trusting comments.
- The README treats icon/language warnings as harmless instead of resolving them. Fresh build diagnostics still need assessment.

## Assessment

Monkey C and Connect IQ are the right foundation for a native watch face. A repository/platform restart is unnecessary. The layout and iteration process deserve a fresh start: retain the app shell and useful data access patterns, replace the composition after capturing a baseline, and review real simulator output throughout.

Generated `.prg`, `.mir`, `gen` and debug XML files from the original attempt are retained as historical material for now. New builds write to ignored `build/`; old binaries must not be mistaken for fresh validation. The previous Windows setup documents are archived under `docs/history/`.

## Correction after deeper API review

The original v6 comment that no public on-device API exposes sport-specific activity totals was too broad, and the first revival inherited that assumption. `UserProfile.getUserActivityHistory()` supplies sport, start time and distance for saved activities. The updated implementation uses this API for trailing-168-hour run/bike/swim totals. This does not change the audit finding that the original RUN value was aggregate ActivityMonitor distance; that implementation was still incorrect. Native history completeness and device-specific timestamps need physical-watch verification.
