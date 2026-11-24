import Toybox.Application.Storage;
import Toybox.Lang;

module FaceColors {
    const ACCENT = "AccentColor";
    const RING = "RingColor";
    const PALETTE = [
        ["Orange", 0xFF5500],
        ["Gold", 0xFFAA00],
        ["Red", 0xFF5555],
        ["Green", 0x55FF55],
        ["Cyan", 0x55FFFF],
        ["Blue", 0x55AAFF],
        ["Violet", 0xAA55FF],
        ["Pink", 0xFF55AA]
    ];

    function selectedIndex(key as String, layout as Number) as Number {
        var saved = Storage.getValue(key);
        if (saved instanceof Number && saved >= 0 && saved < PALETTE.size()) {
            return saved;
        }
        return key.equals(RING) ? FaceLayouts.GAUGES[layout] : FaceLayouts.ACCENTS[layout];
    }

    function color(key as String, layout as Number) as Number {
        return PALETTE[selectedIndex(key, layout)][1];
    }
}
