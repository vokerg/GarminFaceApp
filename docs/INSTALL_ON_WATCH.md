# Install on the fēnix 7X from this Mac

Use the live device build: `build/Fenix7XVibeFace.prg`. It is compiled for `fenix7x` and uses actual watch data. Do not copy `EmberPreview.prg` or `EmberTests.prg`.

## First install

1. Connect the watch to the Mac using a USB data cable. Unlock/accept file transfer on the watch if prompted. If its USB setting offers MTP and Garmin mode, use MTP for file transfer.
2. Quit Garmin Express so another application can access the MTP connection. The fēnix 7X uses MTP; it may not appear as a disk in Finder. Use [OpenMTP](https://openmtp.ganeshrvel.com/) to browse the watch. Its official Homebrew installation command is `brew install --cask openmtp`.
3. In the watch's internal storage, open `GARMIN/APPS`. Copy the live PRG there. You may call the destination `Ember.prg`; retain this filename for future updates. Copy only this new file and leave existing files in place.
4. Wait for the transfer to finish, disconnect the watch, then from its watch face hold MENU (middle-left), select **Watch Face**, scroll to **Fenix7XVibeFace**, and select **Apply**. The face may be represented by its preview rather than its name. Firmware menu wording can vary slightly.

There is no need to publish to the Connect IQ Store for this local test. Merely syncing Garmin Connect does not transfer an arbitrary PRG from the Mac.

## Updating

Build with `./scripts/ciq build`, switch the watch temporarily to another face, reconnect and replace the same `GARMIN/APPS/Ember.prg`, then disconnect and select this face again. Keep the signing key at `~/.config/garmin/developer_key.der`; do not regenerate it for each build. The original project's old signing key was unavailable, so this is a new local development signing identity.

## Initial checks on the physical watch

Confirm time, battery, steps and HR. Compare RUN/BIKE/SWIM against activities **starting within the trailing 168 hours**. Distances are always kilometers. Check a newly saved workout and any ride recorded on an Edge/indoor platform, since native watch-history completeness is not yet established. HR can show `--` until a valid recent sample exists. The DEMO marker must be absent.

If the watch shows an IQ error, copy `GARMIN/APPS/LOGS/CIQ_LOG.YAML` back to the Mac for diagnosis. A PRG that renders in the simulator is not a substitute for this first physical-watch check.

Sources: [Garmin first-app/sideload workflow](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/), [Garmin MTP devices](https://support.garmin.com/en-US/?faq=CZqibgTHMb0dAYEaj2UiU7), [Garmin Mac watch recognition](https://support.garmin.com/en-US/?faq=zUa4z1zKNn39o6JiqZDHNA), [fēnix 7 watch-face settings](https://www8.garmin.com/manuals/webhelp/GUID-C001C335-A8EC-4A41-AB0E-BAC434259F92/EN-GB/GUID-A4EA51C3-D0B2-48E3-807A-768C6F07D7BA.html), [OpenMTP official repository](https://github.com/ganeshrvel/openmtp).

## Press-and-hold shortcuts

With touchscreen enabled, hold battery, date, steps or HR to request Garmin's corresponding native screen. Hold RUN or BIKE to request the built-in history view. Those built-in views may use a calendar-week period even though this face displays trailing 168 hours. SWIM is display-only. Short taps are left to the system. Native providers and behavior during activity recording depend on the watch firmware and require a first on-watch test; a rejected launch leaves the face usable.
