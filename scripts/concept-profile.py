#!/usr/bin/env python3
"""Create an isolated app identity and starting layout for a review build."""
from pathlib import Path
import sys
import uuid

PROFILES = {
    "ember": ("Ember Layout Lab", "EmberLayoutLab"),
    "field-compass": ("Field Compass", "FieldCompass"),
    "split-clock": ("Split Clock", "SplitClock"),
    "training-ledger": ("Training Ledger", "TrainingLedger"),
    "signal-bars": ("Signal Bars", "SignalBars"),
    "metric-grid": ("Metric Grid", "MetricGrid"),
    "type-study": ("Type Study", "TypeStudy"),
    "track-ring": ("Track Ring", "TrackRing"),
    "quadrant-clock": ("Quadrant Clock", "QuadrantClock"),
}
ROOT = Path(__file__).resolve().parent.parent
key = sys.argv[1]
if key not in PROFILES:
    raise SystemExit("CIQ_LAYOUT must be one of: " + ", ".join(PROFILES))

name, filename = PROFILES[key]
profile = ROOT / ".local" / "profiles" / key
profile.mkdir(parents=True, exist_ok=True)
strings = profile / "strings"
strings.mkdir(exist_ok=True)

identity = uuid.uuid5(uuid.NAMESPACE_URL, f"https://github.com/vokerg/GarminFaceApp/concept/{key}")
manifest = (ROOT / "manifest.xml").read_text()
production_id = 'id="A3B3C3D3E3F343A3B3C3D3E3F343A3B3"'
if manifest.count(production_id) != 1:
    raise SystemExit("The production application ID changed. Update the review profile template.")
manifest = manifest.replace(production_id, f'id="{identity.hex.upper()}"', 1)
(profile / "manifest.xml").write_text(manifest)
(strings / "strings.xml").write_text(f'<strings><string id="AppName">{name}</string></strings>\n')
constant = key.upper().replace("-", "_")
(profile / "BuildProfile.mc").write_text(f"module BuildProfile {{ const LAYOUT = FaceLayouts.{constant}; }}\n")

resources = "base.resourcePath = ../../../resources/drawables;../../../resources/layouts;strings"
for mode, data in {
    "live": "../../../data/live",
    "preview": "../../preview",
    "test": "../../../data/preview;../../../tests",
}.items():
    (profile / f"{mode}.jungle").write_text(
        f"project.manifest = manifest.xml\nbase.sourcePath = ../../../source;BuildProfile.mc;{data}\n{resources}\n"
    )
print(filename)
