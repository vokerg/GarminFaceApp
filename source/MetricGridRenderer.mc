import Toybox.Graphics;
import Toybox.Lang;

class MetricGridRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 140, 37, Graphics.FONT_XTINY, data[:date], _accent);
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(48, 52, 184, 44);
        text(dc, 140, 74, Graphics.FONT_MEDIUM, time(data), BLACK);
        if (data[:period].length() > 0) {
            text(dc, 207, 76, Graphics.FONT_XTINY, data[:period], BLACK);
        }

        tile(dc, 32, 105, "BAT", battery(data));
        tile(dc, 106, 105, "STEPS", steps(data[:steps]));
        tile(dc, 180, 105, "BPM", bpm(data[:hr]));
        bar(dc, 42, 153, 48, data[:battery], 100);
        bar(dc, 116, 153, 48, data[:steps], data[:goal]);
        bar(dc, 190, 153, 48, data[:hr], data[:maxHr]);

        tile(dc, 32, 172, "BIKE", km(data[:bike]));
        tile(dc, 106, 172, "RUN", km(data[:run]));
        tile(dc, 180, 172, "SWIM", km(data[:swim]));
    }

    private function tile(dc, x, y, label, value) {
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, 68, 54);
        text(dc, x + 34, y + 14, Graphics.FONT_XTINY, label, _accent);
        fittedText(dc, x + 34, y + 34, Graphics.FONT_SMALL, Graphics.FONT_TINY, 60, value, WHITE);
    }
}
