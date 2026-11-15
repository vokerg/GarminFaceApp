# GarminFaceApp — revival

A personal Garmin Connect IQ watch face. Current device target: **fēnix 7X**, round 280×280 MIP, 64 colors. A first replacement renderer is implemented and runs in the Garmin simulator. The original v6 source is preserved under `docs/history/`; its actual simulator baseline and the candidate captures are under `docs/reviews/`.

Start with [the project bible](docs/PROJECT_BIBLE.md), [the previous-attempt audit](docs/ATTEMPT_AUDIT.md), and [setup status](docs/SETUP.md).

## macOS development

Install Garmin Connect IQ SDK Manager and the official `garmin.monkey-c` VS Code extension. In SDK Manager, sign in, select an SDK, and download the `fenix7x` device definition. Java is required.

```sh
./scripts/ciq keygen      # creates a local development signing key outside Git
./scripts/ciq doctor
./scripts/ciq build
./scripts/ciq simulator
./scripts/ciq run         # after the simulator is ready
```

The script reads Garmin’s `current-sdk.cfg`. Override with `CIQ_SDK`, `CIQ_DATA`, `CIQ_DEVICE`, or `CIQ_KEY` when needed. Both build and run use `fenix7x`; do not use `fenix7x_sim` as the run target. Build output goes to `build/`.

The new local signing key is for development. The old signing key was not in the repository; keep the original if updating an already distributed application.

## Visual development

A successful compile proves only that the program compiles. Capture the baseline first, then inspect each candidate at native size and enlarged. Store renders and decisions together under `docs/reviews/`. Follow the review procedure in the bible. Do not present browser drawings or marketing mockups as Garmin simulator output.

The old Windows instructions are preserved in [docs/history](docs/history/README-windows-2026-05.md). Generated output committed by the original attempt remains historical material, not build input or evidence of a fresh successful build.

## Synthetic visual checks

```sh
./scripts/ciq preview-build populated  # also: missing, extreme, midnight
./scripts/ciq preview-run
```

The preview build uses a separate data adapter, fixes the time/metrics, and marks the screen DEMO. Date and unit/time-format preferences still come from the simulator. `build` uses only the live adapter. Both builds share the app ID and replace each other in the simulator; only the live `build/Fenix7XVibeFace.prg` should be used on the watch.

See [the current bezel/sports review](docs/reviews/2026-11-15-triathlon-bezel.md) for rendered evidence and limitations. The first design review remains in the history of this work.

## Current fields

Battery percentage, time/date, today's steps and heart rate; BIKE and SWIM follow the lower bezel; RUN has a larger upright value at the bottom center. All three mean kilometers for activities starting within the trailing 168 hours. The owner requested removing the redundant period/unit legend. Totals use native saved activity history and the `UserProfile` permission. They are cached for at most 15 minutes, with earlier expiration when a counted activity leaves the window. Garmin Connect account completeness and multisport/other-device records still need verification on the physical watch.

```sh
./scripts/ciq test  # semantic tests in the Garmin simulator; simulator must be running
```

To install on the physical watch, follow [the sideloading guide](docs/INSTALL_ON_WATCH.md). Copy only the live build, never the DEMO preview or test binary.
