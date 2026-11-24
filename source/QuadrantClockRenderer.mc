import Toybox.Graphics;
import Toybox.Lang;

class QuadrantClockRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 93, 40, Graphics.FONT_XTINY, data[:date], WHITE);
        text(dc, 204, 40, Graphics.FONT_XTINY, "BAT " + battery(data), _accent);
        bar(dc, 183, 52, 43, data[:battery], 100);

        line(dc, 140, 59, 140, 178, _accent);
        line(dc, 48, 120, 232, 120, _accent);
        digits(dc, 89, data[:hours], WHITE);
        digits(dc, 151, data[:minutes], _accent);
        if (data[:period].length() > 0) {
            text(dc, 238, 146, Graphics.FONT_XTINY, data[:period], WHITE);
        }

        text(dc, 83, 195, Graphics.FONT_XTINY, "STEPS " + steps(data[:steps]), WHITE);
        text(dc, 197, 195, Graphics.FONT_XTINY, "BPM " + bpm(data[:hr]), WHITE);
        bar(dc, 49, 210, 68, data[:steps], data[:goal]);
        bar(dc, 163, 210, 68, data[:hr], data[:maxHr]);

        text(dc, 80, 222, Graphics.FONT_XTINY, "BIKE", _accent);
        text(dc, 140, 230, Graphics.FONT_XTINY, "RUN", _accent);
        text(dc, 200, 222, Graphics.FONT_XTINY, "SWIM", _accent);
        text(dc, 80, 240, Graphics.FONT_TINY, km(data[:bike]), WHITE);
        text(dc, 140, 251, Graphics.FONT_SMALL, km(data[:run]), WHITE);
        text(dc, 200, 240, Graphics.FONT_TINY, km(data[:swim]), WHITE);
    }

    private function digits(dc, y, value as String, color) {
        text(dc, 100, y, Graphics.FONT_NUMBER_HOT, value.substring(0, 1), color);
        text(dc, 180, y, Graphics.FONT_NUMBER_HOT, value.substring(1, 2), color);
    }
}
