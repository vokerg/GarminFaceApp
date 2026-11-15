# Project bible

## Purpose

Build a personal Garmin watch face that feels like a deliberate outdoor instrument: striking time typography, useful training and daily context, and orange gauges that connect related values. Dense information should remain readable on the actual watch.

Owner brief, 2026-11-15: revive the earlier attempt, inspect why it went in circles, install the development environment, and establish a better foundation. Starting over is authorized if needed. The reference is [this Garmin product photograph](https://www.loebeshop.dk/media/catalog/product/cache/74c1057f7991b4edb2bc7bdaa94de933/0/1/010-04336-01_01_fenix9pro_hr_47mm_lte_titanium-autumn-spark_front-left_0000_hero_orange.jpg), saved under `docs/references/garmin-orange-reference.jpg`.

## Working decisions

- Owner confirmed fēnix 7X on 2026-11-15: 280×280 round MIP, 64 colors. The supplied photo is visual inspiration, not evidence of the owner's watch model.
- Keep the application identity and Git history. Replace the layout as a coherent design after a simulator baseline exists; don't keep incrementing `_v7`, `_v8` files.
- Working design name: **Ember Instrument**. This is a proposal, not an owner-approved product name.
- Black background, white time, orange emphasis, limited gray separators. Use colors supported by the device palette. Avoid relying on smooth gradients or dark tonal layering from the marketing photo.
- Keep source code and development credentials separate. Historical generated files are not fresh build evidence.

## Visual direction

The useful ideas in the reference are hierarchy, asymmetry, curved geometry and consistent accent color. Do not copy every decorative mark. A connected data point has a reason for its gauge: steps against the daily goal, battery against capacity. Avoid decorative cyan segments and arbitrary heart-rate percentages.

The owner liked the first candidate and then specified the actual fields: battery percentage, time, daily steps, rolling last-seven-day run/bike/swim kilometers, plus heart rate if it fits. They suggested placement around the bezel. This is the current brief and supersedes the first candidate's distance/calorie footer.

Current layout: date at y=40, battery at y=62, dominant time at y=103, steps and HR centered at (92,172) and (188,172), radius 36. Bike and swim curve around the lower bezel at radius 113 and angles 215°/325°. The owner requested removing the redundant `7D KM` legend. Its space now holds an upright RUN label at y=214 and a larger running value at y=235; all sport values still mean trailing-168-hour kilometers. Battery retains the outer capacity arc. Calories, daily walking distance, weather and seconds are omitted.

Curved labels use the device's native vector font and radial text API. Prefer the fixed 16px condensed face; a horizontal fallback exists if the font is unavailable. Render long values before changing typography. The source and API expose a font fallback, but the fallback has not been forced and visually validated.

## Data contract

| Metric | Source / intended semantics | Behavior when unavailable |
| --- | --- | --- |
| Time/date | System clock, device 12/24h preference, Gregorian date | Core device data |
| Battery | `System.getSystemStats().battery`, percent | No invented estimate of remaining days |
| Steps | `ActivityMonitor.getInfo().steps` | `--`, distinguish missing from zero |
| Step goal | `ActivityMonitor.getInfo().stepGoal` | No progress arc if absent/nonpositive |
| HR | Latest valid `ActivityMonitor.getHeartRateHistory` sample | `--`; respect sample age, never substitute demo HR |
| Run / bike / swim | `UserProfile.getUserActivityHistory()`: filter `Activity.SPORT_RUNNING`, `SPORT_CYCLING`, `SPORT_SWIMMING`, sum activity distances in meters, display kilometers | Missing/invalid date or distance makes the affected sport `--`; accessible empty history sums to zero |

**Rolling window:** activities whose start timestamp is in `(now − 604800 seconds, now]`. This means trailing 168 hours, not the calendar week and not seven midnight-to-midnight dates. Each activity contributes its full saved distance based on its start time. All three values use kilometers regardless of device unit preference, as requested. Running/cycling display tenths below 1000km and whole kilometers above it; swimming currently uses the same precision.

**Refresh:** scan on initial use/view show, then cache for up to 15 minutes or until the earliest included activity expires, whichever comes first. Clock rollback invalidates the cache. Wrist wake requests a redraw without automatically rescanning history. Saved activities normally return to a new face instance; physical-watch behavior remains to be verified.

**Source scope:** these are the records exposed by the watch's native history, not a direct Garmin Connect account query. Completeness, activities originating on another device, deleted activities, indoor variants, and multisport leg exposure require verification on the owner's watch. Include only the three explicit sport enums; never guess a split for a generic multisport entry. Null sport types are excluded because they cannot be attributed. Extremely old/suspicious timestamps produce an unavailable total for that sport rather than an invented epoch conversion.

**Permission:** `UserProfile` is required to read activity history. No new network or companion service is used. The earlier assessment that a separate data source was necessary was too restrictive; the native UserProfile API provides the needed fields. See [API method](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile.html#getUserActivityHistory-instance_function) and [record fields](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/UserActivity.html).

## Architecture target

One canonical view, one data adapter, one layout/palette definition. Fetch/cache a data snapshot independently of drawing. Keep a simulator-only deterministic fixture mode so representative values, maximum widths and missing-data states can be rendered through the same drawing functions. Fixture mode must be visibly identifiable in development and excluded from release output. Do not add network infrastructure to solve a layout problem.

Watch-face lifecycle must explicitly account for sleep/awake behavior. Choose minute cadence by default. Seconds are optional and should disappear or freeze appropriately in low-power mode. Do not introduce a full-screen per-second redraw without measuring its effect on the target.

## Visual review procedure

1. Build and run the unmodified v6 view; capture a baseline from the actual Garmin simulator. Record commit, SDK, device and data state.
2. Render one coherent candidate. Save the native-resolution image under `docs/reviews/`, with a short adjacent Markdown review.
3. Inspect native size for legibility and enlarged size for clipping/overlap. Confirm time dominates, labels are readable, arcs have clear semantics, and peripheral information stays inside the round screen.
4. Exercise representative populated data, missing data, zeros, goal exceeded, long values, 12/24h and low-power state. Required examples include 00:00, 11:11, 23:59, low/full battery, 999/10,000/100,000 steps, and HR unavailable/three digits. Do not claim these checks passed without rendering them.
5. Fix the largest observed defect, capture again, compare to the previous render, and record the result. After two unsuccessful tweaks to the same region, revisit the layout bounds/font choice rather than nudging coordinates again.
6. Keep the accepted screenshot and reasoning. A compiler success, uninspected screenshot, HTML mockup, or generated marketing image is not visual acceptance.

Review record: hypothesis → source change → build/run result → screenshot paths → observed defects → decision. No screenshots from the original development session were present. The revived environment now has a fresh v6 baseline and candidate captures.

## Milestones and current state

- [x] Locate/clone repository and inspect all four commits.
- [x] Install SDK Manager, Monkey C extension and SDK 9.3.0; verify compiler launches.
- [x] Add portable build/run entry points and local development signing key.
- [x] Preserve reference and historical Windows instructions; write audit and design contract.
- [x] Confirm current watch model: fēnix 7X.
- [x] Download target device definition via authenticated Garmin SDK Manager.
- [x] Fresh build/run and baseline simulator screenshot.
- [x] Implement and visually inspect first Ember Instrument candidate; save populated/missing/extreme/midnight captures.
- [ ] Verify data and lifecycle edge cases; then inspect on physical watch.

The development environment is verified and the first candidate builds/runs. Initial visual checks pass for the recorded states, with the step-width defect corrected. The owner approved the first visual direction; the current bezel sports revision is ready for review. Physical-watch readability, lifecycle diagnostics and power behavior remain unverified.

Latest evidence: [triathlon/bezel review](reviews/2026-11-15-triathlon-bezel.md). Two Monkey C semantic tests verify window boundaries, independent sport totals, unsorted input, expiry, missing fields and suspicious timestamps.

Owner refinement: running is the priority sport. The bottom center is RUN; BIKE/SWIM remain on the lower bezel. The cycling-focused intermediate rendering is historical, not the current design.

Final padding fix: values moved to y−6 and labels to y+12 inside the 36px dials. Step values wider than 56px use the smaller native font, keeping them clear of the arc. `triathlon-run-padded.png` is the current populated screenshot.

Press-and-hold shortcuts are implemented through WatchFaceDelegate/Complications for battery, date, steps, HR, RUN and BIKE. RUN/BIKE open Garmin's native history providers, whose views may use calendar-week totals; displayed face values remain trailing 168 hours. There is no native swimming complication in this API, so swim is display-only. Unsupported/provider-blocked launches return false safely. Added ComplicationSubscriber permission. Native app launch destinations require physical-watch verification; simulator coordinate dispatch did not show a native app opening.

Physical deployment milestone (2026-11-15): live PRG transferred as `GARMIN/Apps/Ember.prg`, downloaded back and byte-for-byte verified. Physical activation/data/shortcut/power acceptance remains pending. Read `docs/AGENT_HANDOFF.md` for the proven CLI transfer process and all current owner decisions.
