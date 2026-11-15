# Fenix7XVibeFace

Custom Garmin Connect IQ watch face for **Garmin fēnix 7X**.

Current status:

- Project builds successfully.
- Simulator launches successfully.
- Watch face runs in Garmin CIQ Simulator.
- Working launch device ID is `fenix7x`.
- Do **not** use `fenix7x_sim` with `monkeydo`.

---

## Project Path

```powershell
C:\repos\face-attempt\Fenix7XVibeFace
```

Main files:

```text
source/                              Monkey C source code
resources/                           Layouts, strings, icons, images
manifest.xml                         App/device metadata
monkey.jungle                        Garmin build config
bin/Fenix7XVibeFace.prg              Compiled watch face app
bin/Fenix7XVibeFace.prg.debug.xml    Debug metadata
```

---

## Target Device

Garmin fēnix 7X

Important design constraints:

```text
Screen: 280x280
Shape: Round
Display: Memory-in-Pixel / MIP
Colors: 64
Best design style: simple, high contrast, battery-friendly
```

Avoid:

```text
Heavy animations
Gradients
Complex graphics
Too many colors
Tiny text near screen edges
```

---

## Required Tools

Installed tools:

```text
VS Code
Garmin Monkey C VS Code extension
Garmin Connect IQ SDK
Java
Garmin CIQ Simulator
```

Current SDK path used during setup:

```powershell
c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b
```

If the SDK version changes, update the `$Sdk` variable in the commands below.

---

## Open Project

```powershell
cd C:\repos\face-attempt\Fenix7XVibeFace
code .
```

---

## Build from VS Code

In VS Code:

```text
Ctrl + Shift + P
```

Search:

```text
Monkey C: Build
```

Use:

```text
Monkey C: Build for Device
```

Choose the fēnix 7X target.

A successful build should create:

```text
bin/Fenix7XVibeFace.prg
```

Warnings about language support or launcher icon size are not fatal.

Known harmless warnings:

```text
No supported languages are defined.
The launcher icon is not compatible with the specified launcher icon size.
```

---

## Start the Simulator Manually

Use PowerShell:

```powershell
$Sdk = "c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b"

Start-Process `
  -FilePath "$Sdk\bin\simulator.exe" `
  -WorkingDirectory "$Sdk\bin"
```

Wait until the **CIQ Simulator** window is open.

---

## Run the Watch Face in Simulator

This is the working command:

```powershell
$Sdk = "c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b"

& "$Sdk\bin\monkeydo.bat" `
  "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" `
  fenix7x
```

Important:

```text
Use fenix7x
Do not use fenix7x_sim with monkeydo
```

This failed:

```powershell
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x_sim
```

Error:

```text
Unable to load device fenix7x_sim.
```

Correct:

```powershell
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x
```

---

## Rebuild and Rerun Manually

Use this after editing files:

```powershell
cd C:\repos\face-attempt\Fenix7XVibeFace

$Sdk = "c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b"

& "$Sdk\bin\monkeyc.bat" `
  -o "bin\Fenix7XVibeFace.prg" `
  -f "C:\repos\face-attempt\Fenix7XVibeFace\monkey.jungle" `
  -y "C:\repos\face-attempt\developer_key" `
  -d fenix7x_sim `
  -w

& "$Sdk\bin\monkeydo.bat" `
  "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" `
  fenix7x
```

Build target may use:

```text
fenix7x_sim
```

Simulator launch target should use:

```text
fenix7x
```

---

## Check Whether Simulator Is Listening

If `monkeydo` cannot connect, check port `1234`:

```powershell
netstat -ano | findstr ":1234"
```

Good result looks like:

```text
TCP    0.0.0.0:1234    0.0.0.0:0    LISTENING
```

If port `1234` is listening, the simulator is probably running correctly.

---

## Kill and Restart Simulator

If the simulator gets stuck:

```powershell
taskkill /IM simulator.exe /F 2>$null
taskkill /IM shell.exe /F 2>$null
taskkill /IM connectiq.exe /F 2>$null
```

Then restart:

```powershell
$Sdk = "c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b"

Start-Process `
  -FilePath "$Sdk\bin\simulator.exe" `
  -WorkingDirectory "$Sdk\bin"
```

Then rerun:

```powershell
& "$Sdk\bin\monkeydo.bat" `
  "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" `
  fenix7x
```

---

## Common Errors

### Error: Unable to connect to simulator

Meaning:

```text
monkeydo cannot talk to the CIQ Simulator.
```

Fix:

```powershell
taskkill /IM simulator.exe /F 2>$null
taskkill /IM shell.exe /F 2>$null
taskkill /IM connectiq.exe /F 2>$null
```

Restart simulator from SDK `bin` directory:

```powershell
Start-Process `
  -FilePath "$Sdk\bin\simulator.exe" `
  -WorkingDirectory "$Sdk\bin"
```

Then run again with:

```powershell
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x
```

---

### Error: Unable to load device fenix7x_sim

Meaning:

```text
The simulator does not recognize fenix7x_sim as a launch device.
```

Fix:

Use:

```text
fenix7x
```

Not:

```text
fenix7x_sim
```

Correct command:

```powershell
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x
```

---

## Find Installed Device IDs

Use this if unsure about device names:

```powershell
Get-ChildItem "$env:APPDATA\Garmin\ConnectIQ\Devices" -Directory |
  Where-Object { $_.Name -like "*fenix*7*" } |
  Select-Object Name
```

Use the printed name with `monkeydo`.

---

## Gemini CLI Prompt for Future Design Work

Use this prompt when asking Gemini CLI to continue development:

```text
The Garmin fēnix 7X watch face builds and runs in the simulator.

Project path:
C:\repos\face-attempt\Fenix7XVibeFace

SDK path:
c:\Users\voker\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b

Important:
- Build target can use fenix7x_sim.
- Simulator launch target must use fenix7x.
- Do not use fenix7x_sim with monkeydo.
- PRG path is:
  C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg

Working run command:
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x

Goal:
Improve the visual design only.

Design style:
- Clean premium tactical digital watch face
- Black background
- High contrast
- Battery-friendly
- Outdoor readable
- Optimized for Garmin fēnix 7X, 280x280 round MIP screen, 64 colors

Keep:
- Large centered time
- Date below
- Battery lower left
- Steps lower right

Add:
- Small labels for BAT and STEPS
- Optional subtle circular border or simple tick marks
- Safe margins for round screen

Avoid:
- Animations
- Weather
- GPS
- Heart rate
- Bluetooth status
- New permissions
- Heavy graphics

Instructions:
Inspect the existing project files first.
Make small edits only.
Compile after each change.
If there are errors, fix them one at a time.
After a successful build, run with monkeydo using device fenix7x.
```

---

## Good Next Improvements

Recommended order:

```text
1. Improve typography and spacing.
2. Add labels: BAT and STEPS.
3. Add simple circular border or tick marks.
4. Add 12/24 hour format support.
5. Add cleaner date formatting.
6. Add step-goal color change.
7. Add better icon assets.
8. Add settings later.
9. Add heart rate later only after base face is stable.
10. Add weather much later because it requires more complexity.
```

Do not add too many features at once.

---

## Current Working Flow

Daily workflow:

```text
1. Edit source or resources.
2. Build in VS Code or with monkeyc.
3. Start simulator if not already open.
4. Run with monkeydo using fenix7x.
5. Test visually.
6. Repeat.
```

Working launch command:

```powershell
& "$Sdk\bin\monkeydo.bat" "C:\repos\face-attempt\Fenix7XVibeFace\bin\Fenix7XVibeFace.prg" fenix7x
```#   G a r m i n F a c e A p p  
 