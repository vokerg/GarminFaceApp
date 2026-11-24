import Toybox.Graphics;
import Toybox.Lang;

class SplitClockRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 140, 41, Graphics.FONT_XTINY, data[:date], _accent);
        line(dc, 144, 62, 144, 186, _accent);
        text(dc, 89, 89, Graphics.FONT_NUMBER_HOT, data[:hours], _accent);
        text(dc, 89, 149, Graphics.FONT_NUMBER_HOT, data[:minutes], WHITE);
        if (data[:period].length() > 0) {
            text(dc, 89, 184, Graphics.FONT_XTINY, data[:period], _accent);
        }

        row(dc, 70, "BAT", battery(data), data[:battery], 100);
        row(dc, 111, "STEPS", steps(data[:steps]), data[:steps], data[:goal]);
        row(dc, 152, "BPM", bpm(data[:hr]), data[:hr], data[:maxHr]);

        line(dc, 43, 202, 237, 202, _accent);
        text(dc, 76, 215, Graphics.FONT_XTINY, sportLabel(SportOrder.SECONDARY), _accent);
        text(dc, 140, 220, Graphics.FONT_XTINY, sportLabel(SportOrder.PRIMARY), _accent);
        text(dc, 204, 215, Graphics.FONT_XTINY, sportLabel(SportOrder.TERTIARY), _accent);
        text(dc, 76, 233, Graphics.FONT_TINY, sportKm(data, SportOrder.SECONDARY), WHITE);
        text(dc, 140, 242, Graphics.FONT_SMALL, sportKm(data, SportOrder.PRIMARY), WHITE);
        text(dc, 204, 233, Graphics.FONT_TINY, sportKm(data, SportOrder.TERTIARY), WHITE);
    }

    private function row(dc, y, label, value, reading, limit) {
        align(dc, 159, y, Graphics.FONT_XTINY, label, _accent, Graphics.TEXT_JUSTIFY_LEFT);
        align(dc, 159, y + 17, Graphics.FONT_TINY, value, WHITE, Graphics.TEXT_JUSTIFY_LEFT);
        bar(dc, 159, y + 31, 76, reading, limit);
    }
}
