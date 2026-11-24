# Two configurable colors and an HR arc

The fēnix 7X settings menu offers Accent Color and Ring Color, each with eight MIP palette colors. Accent Color starts at orange and controls the hours, accent labels and bezel ticks. Ring Color starts at gold and controls the steps, HR and outer battery arcs. The thin track and thicker progress arc use the same color. Gauge progress stops at the end of each track.

The heart-rate gauge divides the latest valid BPM sample by the watch's generic zone 5 upper threshold. If the watch supplies no positive limit, the face still displays BPM and the thin track. [Garmin UserProfile API](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile.html#getHeartRateZones-instance_function)

## Simulator captures

These are 280×280 exports from the Garmin simulator with SDK 9.3.0 and the fēnix 7X device profile (API 5.2.0). DEMO identifies the synthetic face values.

- [Default orange and gold](two-colors-default.png)
- [Cyan and blue selected through the watch buttons](two-colors-cyan-blue.png)
- [Native Face Colors menu](two-colors-settings.png)
- [999 steps, 11:11 and a valid BPM without a maximum](two-colors-no-hr-max.png)
- [12-hour time and exactly 10,000 steps](two-colors-goal-met.png)
- [23:59, full battery, 100,000 steps and 188 BPM](two-colors-extreme.png)
- [Unavailable metrics and 5% battery](two-colors-missing.png)
- [00:00 and zero values](two-colors-midnight.png)

The first render caught a runtime failure from calling an unavailable `Math.min` symbol. Replaced the call with a bounded ratio and reran the builds and simulator checks. At native and enlarged sizes, the dial values and labels fit inside their rings. The settings menu scrolls around the focused row, and adjacent rows can be partly obscured by the round bezel. Both settings were selectable and persisted across relaunch.

The live and preview builds compiled successfully, and all three existing tests passed. The live face rendered without DEMO in the simulator, including with the simulator set to Always-Active. The simulator supplied no recent native HR sample during the live check. The HR arc and missing-limit behavior were verified with fixtures. Physical settings access, the reported zone ceiling and the display under real lighting still need on-watch verification.
