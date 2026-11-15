#!/usr/bin/env python3
"""Select a deterministic simulator fixture; never included in live builds."""
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
scenario = sys.argv[1] if len(sys.argv) > 1 else "populated"
scenes = {
    "populated": {},
    "missing": {"steps": "null", "goal": "null", "hr": "null", "run": "null", "bike": "null", "swim": "null", "battery": "5.0"},
    "extreme": {"steps": "100000", "goal": "10000", "hr": "188", "run": "999900.0", "bike": "1234500.0", "swim": "99900.0", "battery": "100.0", "hour": "23", "minute": "59"},
    "midnight": {"steps": "0", "goal": "0", "hr": "null", "run": "0.0", "bike": "0.0", "swim": "0.0", "battery": "0.0", "hour": "0", "minute": "0"},
}
if scenario not in scenes:
    raise SystemExit("Scenario must be: " + ", ".join(scenes))
source = (root / "data/preview/FaceData.mc").read_text()
defaults = {"steps": "12486", "goal": "15000", "hr": "58", "run": "42600.0", "bike": "184300.0", "swim": "6250.0", "battery": "76.0", "hour": "10", "minute": "10"}
for key, value in scenes[scenario].items():
    source = source.replace(f":{key} => {defaults[key]}", f":{key} => {value}")
destination = root / ".local/preview/FaceData.mc"
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(source)
print("Synthetic preview scenario: " + scenario)
