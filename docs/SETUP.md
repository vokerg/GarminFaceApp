# Verified setup — 2026-11-15

Workspace: `/Users/dg/repos/GarminFaceApp`, branch `revive/instrument-face`. Source cloned from `https://github.com/vokerg/GarminFaceApp`. The owner authorized committing/pushing the complete revival and merging it into main. Current design prioritizes running; see the final screenshot in the triathlon review.

| Component | Status |
| --- | --- |
| Connect IQ SDK Manager | Installed through Homebrew, version 1.0.16, `/Applications/SdkManager.app` |
| Official Monkey C VS Code extension | Installed, `garmin.monkey-c` 1.1.3 |
| Java | Existing Amazon Corretto 21; compiler launches successfully |
| SDK | Garmin Connect IQ 9.3.0, official macOS download |
| Device | `fenix7x`, downloaded via SDK Manager after owner sign-in; simulator reports API 5.2.0 |
| Development signing key | Generated at `~/.config/garmin/developer_key.der`, mode 600, outside repository |
| Doctor | Passed: compiler, Java, selected SDK, device definition, signing key |
| Original v6 baseline | Fresh build and simulator run succeeded; screenshot saved |
| Replacement live and preview builds | Build successfully without warnings after source/resource fixes |
| Live adapter | Launched in simulator; date/time/battery/HR/daily metrics render; no DEMO marker |
| Synthetic checks | Populated, missing, extreme and midnight rendered and visually inspected; captures saved |

SDK directory:

```
~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.3.0-2026-10-20-95888f262
```

`scripts/ciq` reads `current-sdk.cfg`, so switching SDK versions in SDK Manager does not require editing scripts. Use `CIQ_SDK` to override. This first script targets macOS; Windows instructions are archived, not newly verified.

The old repository key was unavailable. The generated key is suitable for local development, not proof of continuity with any previously published package. No watch deployment, store upload, account credential extraction, or physical-watch test was performed.

Sources: [Garmin SDK installation](https://developer.garmin.com/connect-iq/sdk/), [official SDK release index](https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json), and locally installed SDK 9.3.0 API documentation for ActivityMonitor, System.DeviceSettings and Graphics.

## Rolling sports update

The live adapter now reads UserProfile saved activity history for rolling run/bike/swim totals; the manifest includes the native UserProfile permission. Live and preview builds pass without warnings, the live adapter was launched and inspected (zero totals for the simulator's empty history), and two Monkey C aggregation tests pass. Current visual evidence and remaining physical-watch checks are in `docs/reviews/2026-11-15-triathlon-bezel.md`.

## First physical sideload — verified transfer

Installed Homebrew libmtp 1.1.23/libusb 1.0.30, switched the watch itself from Garmin USB mode to MTP, released Garmin Express's background-service lock, and copied the live build to `GARMIN/Apps/Ember.prg`. Read-back compared byte for byte and matched SHA-256. Physical watch selection/startup and training-data/shortcut behavior remain awaiting owner confirmation. Exact commands and failure diagnoses are saved in `docs/AGENT_HANDOFF.md`.
