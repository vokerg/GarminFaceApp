import Toybox.Graphics;
import Toybox.Lang;

class SignalBarsRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 140, 35, Graphics.FONT_XTINY, data[:date], _accent);
        text(dc, 140, 62, Graphics.FONT_MEDIUM, time(data), WHITE);
        if (data[:period].length() > 0) {
            text(dc, 203, 63, Graphics.FONT_XTINY, data[:period], _accent);
        }

        column(dc, 63, "BAT", battery(data), data[:battery], 100);
        column(dc, 140, "STEPS", steps(data[:steps]), data[:steps], data[:goal]);
        column(dc, 217, "BPM", bpm(data[:hr]), data[:hr], data[:maxHr]);

        line(dc, 46, 206, 234, 206, _accent);
        text(dc, 75, 220, Graphics.FONT_XTINY, "BIKE", _accent);
        text(dc, 140, 223, Graphics.FONT_XTINY, "RUN", _accent);
        text(dc, 205, 220, Graphics.FONT_XTINY, "SWIM", _accent);
        text(dc, 75, 236, Graphics.FONT_TINY, km(data[:bike]), WHITE);
        text(dc, 140, 244, Graphics.FONT_SMALL, km(data[:run]), WHITE);
        text(dc, 205, 236, Graphics.FONT_TINY, km(data[:swim]), WHITE);
    }

    private function column(dc, x, label, value, reading, limit) {
        var progress = 10 * ratio(reading, limit);
        dc.setColor(_gauge, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 10; i++) {
            var y = 159 - i * 8;
            dc.drawRectangle(x - 22, y, 44, 5);
            var width = ((progress - i) * 42).toNumber();
            if (width > 0) {
                dc.fillRectangle(x - 21, y + 1, width > 42 ? 42 : width, 3);
            }
        }
        text(dc, x, 177, Graphics.FONT_TINY, value, WHITE);
        text(dc, x, 195, Graphics.FONT_XTINY, label, _accent);
    }
}
