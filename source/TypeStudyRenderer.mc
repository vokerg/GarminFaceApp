import Toybox.Graphics;
import Toybox.Lang;

class TypeStudyRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 140, 42, Graphics.FONT_SMALL, data[:date], _accent);

        var font = Graphics.FONT_NUMBER_HOT;
        var hours = data[:hours];
        var minutes = data[:minutes];
        var leftWidth = dc.getTextWidthInPixels(hours, font);
        var rightWidth = dc.getTextWidthInPixels(minutes, font);
        var left = 140 - (leftWidth + rightWidth + 20) / 2;
        align(dc, left, 100, font, hours, WHITE, Graphics.TEXT_JUSTIFY_LEFT);
        align(dc, left + leftWidth + 20, 100, font, minutes, WHITE, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(left + leftWidth + 10, 94, 3);
        dc.fillCircle(left + leftWidth + 10, 108, 3);
        if (data[:period].length() > 0) {
            text(dc, 140, 135, Graphics.FONT_XTINY, data[:period], _accent);
        }

        text(dc, 140, 159, Graphics.FONT_SMALL, "RUN  " + km(data[:run]), WHITE);
        text(dc, 82, 187, Graphics.FONT_XTINY, "BIKE " + km(data[:bike]), WHITE);
        text(dc, 198, 187, Graphics.FONT_XTINY, "SWIM " + km(data[:swim]), WHITE);

        footer(dc, 74, "BAT", battery(data), data[:battery], 100);
        footer(dc, 140, "STEPS", steps(data[:steps]), data[:steps], data[:goal]);
        footer(dc, 206, "BPM", bpm(data[:hr]), data[:hr], data[:maxHr]);
    }

    private function footer(dc, x, label, value, reading, limit) {
        text(dc, x, 220, Graphics.FONT_TINY, value, WHITE);
        text(dc, x, 237, Graphics.FONT_XTINY, label, _accent);
        bar(dc, x - 16, 249, 33, reading, limit);
    }
}
