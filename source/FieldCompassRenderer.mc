import Toybox.Graphics;
import Toybox.Lang;

class FieldCompassRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        var cx = 140;
        var cy = 99;
        var minute = data[:minute];
        dc.setPenWidth(1);
        for (var i = 0; i < 60; i++) {
            var major = i % 5 == 0;
            dc.setColor(major ? _accent : 0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            polarLine(dc, cx, cy, major ? 53 : 59, 64, i * 6);
        }
        text(dc, cx, 52, Graphics.FONT_XTINY, "12", _accent);
        text(dc, cx, 146, Graphics.FONT_XTINY, "6", _accent);
        if (data[:period].length() > 0) {
            text(dc, cx, 123, Graphics.FONT_XTINY, data[:period], _accent);
        }
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        polarLine(dc, cx, cy, -5, 28, (data[:rawHour] % 12) * 30 + minute / 2.0);
        dc.setColor(_gauge, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        polarLine(dc, cx, cy, -8, 39, minute * 6);
        dc.fillCircle(cx, cy, 4);
        dc.setPenWidth(1);

        text(dc, 48, 91, Graphics.FONT_XTINY, data[:day], _accent);
        text(dc, 48, 113, Graphics.FONT_XTINY, data[:monthDay], WHITE);
        text(dc, 231, 91, Graphics.FONT_XTINY, "BAT", _accent);
        text(dc, 231, 113, Graphics.FONT_TINY, battery(data), WHITE);
        bar(dc, 209, 129, 45, data[:battery], 100);

        text(dc, 91, 174, Graphics.FONT_XTINY, "STEPS", _accent);
        text(dc, 91, 194, Graphics.FONT_TINY, steps(data[:steps]), WHITE);
        bar(dc, 60, 209, 63, data[:steps], data[:goal]);
        text(dc, 189, 174, Graphics.FONT_XTINY, "BPM", _accent);
        text(dc, 189, 194, Graphics.FONT_TINY, bpm(data[:hr]), WHITE);
        bar(dc, 158, 209, 63, data[:hr], data[:maxHr]);

        text(dc, 76, 228, Graphics.FONT_TINY, km(data[:bike]), WHITE);
        text(dc, 140, 237, Graphics.FONT_SMALL, km(data[:run]), WHITE);
        text(dc, 204, 228, Graphics.FONT_TINY, km(data[:swim]), WHITE);
        text(dc, 76, 245, Graphics.FONT_XTINY, "BIKE", _accent);
        text(dc, 140, 259, Graphics.FONT_XTINY, "RUN", _accent);
        text(dc, 204, 245, Graphics.FONT_XTINY, "SWIM", _accent);
    }
}
