# Agent handoff — working state and physical installation

Updated 2026-11-15. Read this before repeating environment setup, design experiments or installation troubleshooting.

## Owner decisions

- Watch is **fēnix 7X Solar**. Owner liked the orange/white visual direction.
- Required fields: battery percentage, time/date, daily steps, running/cycling/swimming kilometers for the **trailing 168 hours**, and HR.
- **RUN is the priority**: its larger upright value occupies the bottom center. BIKE curves along the lower-left bezel; SWIM follows the lower-right.
- Owner requested removing `7D KM`; they already know the period and units. Do not put the legend back.
- Owner correctly identified step text crossing the frame. Current dials have centers (92,172)/(188,172), radius 36; values sit at y−6 and labels at y+12. Step strings wider than 56px use the smaller native font. Preserve padding when changing fonts.
- DEMO marks **synthetic simulator previews only**. The installed live build does not display DEMO. Do not remove fixture labeling and then present synthetic values as real.
- Press-and-hold native shortcuts are implemented for battery/date/steps/HR/run/bike. Swim has no matching native complication and remains display-only. Native destination screens may use calendar-week totals; the face still computes trailing 168 hours.

## Current implementation and verification

Canonical code is in `source/`, with separate `data/live` and generated preview adapters. Do not compile `docs/history/*.mc`.

`UserProfile.getUserActivityHistory()` provides sport, start time and meters. This is the native source for rolling totals; the old claim that a companion service was required was too broad. Don't substitute ActivityMonitor walking distance or calendar-week complications for these totals. Aggregate without assuming iterator ordering. Cache for at most 15 minutes or until the next expiry. Uncertain relevant fields produce `--`.

SDK 9.3.0, Java 21, Monkey C extension and `fenix7x` definition are installed. `./scripts/ciq doctor`, `build`, `preview-build populated`, `preview-run`, `run` and `test` are the working entry points. Three semantic/hit-region tests pass. Build and preview compile without warnings. SDK test runner can exit 1 despite PASSED; the script requires an explicit fresh nonempty zero-failure report.

Latest populated screenshots and settings verification are in the [two-color simulator review](reviews/2026-11-24-two-colors.md). The updated live build also launched in the simulator without DEMO. A simulator long-press did not visibly launch a native app, so physical shortcut behavior is **not yet verified**.

The main revival and padding/shortcut fixes were pushed and fast-forward merged into `main`, through implementation commit `96f810f`. Subsequent documentation commits record this installation.

## Successful physical transfer

On 2026-11-15, copied the live build to **`/GARMIN/Apps/Ember.prg`** on the connected watch. Downloaded that exact new object back and compared it byte for byte (`cmp`), then checked matching SHA-256:

```
44f7e2219d0d4a7593f5fd03c1b5e824c076ce2c2a726054311bba5f06a0f592
```

This proves the file transfer, **not** successful selection, startup, data fidelity or power behavior on the physical watch. The owner was instructed to disconnect and select **MENU → Watch Face → Fenix7XVibeFace → Apply**. Confirm their reported result before marking on-watch acceptance complete. No other watch files were changed.

## Working macOS transfer procedure — CLI, no OpenMTP required

Homebrew `libmtp` **1.1.23** and `libusb` **1.0.30** were installed in this session. Reuse them. OpenMTP was not installed or needed for the successful transfer.

1. **On the physical watch**, disconnect USB, hold middle-left MENU and choose **System → USB Mode → MTP**, then reconnect. This is not a setting in a Mac application. The earlier Garmin/proprietary mode exposed VID 091e/PID 0003 and was not an MTP filesystem.
2. Quit Garmin Express **and its background service**. Quitting the visible app alone did not release the USB interface. `ioreg` identified Garmin Express Service as `UsbExclusiveOwner`; `mtp-detect` returned `libusb_claim_interface() = -3` while it held the connection. Inspect actual process IDs before terminating only the Express/service processes; don't hardcode the old PIDs or permanently disable startup settings. Check no firmware update or sync is in progress first.
3. `mtp-detect` should connect and report device **Model: fenix 7X**, friendly name **fenix 7X**, firmware/device version **2718** in this session. Its libmtp database label was misspelled **Garmin Euduro 2** (VID 091e/PID 4f43); trust the device's own model field, not that database label. Do not re-target the build to Enduro because of it.
4. `mtp-folders` enumerates folders. The actual target was **GARMIN → Apps** (case shown by the device). Folder object IDs are session/device-specific; discover them each time. `mtp-files` can check for an existing `Ember.prg` before uploading; keep full metadata output local/temporary, not in Git or chat.
5. Stage the live PRG under the desired basename, then upload to the **folder path**, not a destination filename:

```sh
mkdir -p .local/install
cp build/Fenix7XVibeFace.prg .local/install/Ember.prg
mtp-sendfile .local/install/Ember.prg /GARMIN/Apps
```

`mtp-sendfile` uses the **local basename** as the remote filename. Despite its usage text, its second argument resolves the parent folder. It reported a new file object ID on success. Do not assume it safely replaces an existing same-name object; handle upgrades deliberately after checking what exists. The first installation found no existing Ember/Fenix7XVibeFace PRG.

6. Download by the newly reported object ID, then compare:

```sh
mtp-getfile NEW_OBJECT_ID .local/install/Ember-readback.prg
cmp .local/install/Ember.prg .local/install/Ember-readback.prg
shasum -a 256 .local/install/Ember.prg .local/install/Ember-readback.prg
```

The actual successful transfer object ID was 16778950, but **do not reuse it blindly**. Re-enumerate before future operations. `.local/` is ignored. Keep signing keys outside the repo (`~/.config/garmin/developer_key.der`, mode 600); never overwrite the key as part of routine setup.

Repeated `MTP extended association type 0x00000001 encountered` messages appeared during enumeration and upload but did not prevent a verified transfer. Evaluate the operation result and read-back rather than treating those messages alone as failure.

## Remaining physical-watch acceptance

Confirm the face starts after selection, has no DEMO marker, and displays real time/battery/steps/HR. Verify rolling sport totals against known saved sessions, particularly Edge/indoor rides, pool/open-water swims and multisport legs. Validate actual timestamp semantics and native history completeness on firmware 2718. Test press-and-hold destinations, refresh after saving an activity, sleep/wake behavior, actual MIP readability and battery cost. Do not claim these are proven by simulator tests or the verified USB copy.

If it shows an IQ error, reconnect in MTP, obtain `GARMIN/Apps/LOGS/CIQ_LOG.YAML`, and diagnose using the local build's debug information. Do not reinstall SDKs or redesign the face before inspecting the actual error.

## Repository closeout

All current implementation and installation notes are on main. The superseded May experiment branches were reviewed and preserved through `archive/may-*` tags and source/resource snapshots under `docs/history/may-experiments/`. Their history was incorporated with an explicit ours-strategy merge so the accepted active implementation stays intact. Temporary branches can be removed after verifying their tips are ancestors of main. Do not resurrect the archived alternative renderers or aggregate-distance fallbacks as missing work.
