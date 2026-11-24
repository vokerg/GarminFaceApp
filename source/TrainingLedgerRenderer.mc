import Toybox.Graphics;
import Toybox.Lang;

class TrainingLedgerRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    function draw(dc as Dc, data as Dictionary) as Void {
        text(dc, 140, 35, Graphics.FONT_XTINY, data[:date], _accent);
        text(dc, 99, 60, Graphics.FONT_SMALL, time(data), WHITE);
        if (data[:period].length() > 0) {
            text(dc, 152, 60, Graphics.FONT_XTINY, data[:period], _accent);
        }
        text(dc, 211, 56, Graphics.FONT_XTINY, "BAT " + battery(data), WHITE);
        bar(dc, 181, 70, 60, data[:battery], 100);

        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(19, 82, 242, 65);
        text(dc, 63, 113, Graphics.FONT_TINY, "RUN", BLACK);
        fittedText(dc, 165, 113, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, 154, km(data[:run]), BLACK);

        text(dc, 79, 165, Graphics.FONT_XTINY, "BIKE", _accent);
        text(dc, 201, 165, Graphics.FONT_XTINY, "SWIM", _accent);
        text(dc, 79, 187, Graphics.FONT_SMALL, km(data[:bike]), WHITE);
        text(dc, 201, 187, Graphics.FONT_SMALL, km(data[:swim]), WHITE);

        line(dc, 44, 207, 236, 207, _accent);
        text(dc, 91, 225, Graphics.FONT_XTINY, "STEPS", _accent);
        text(dc, 189, 225, Graphics.FONT_XTINY, "BPM", _accent);
        text(dc, 91, 243, Graphics.FONT_TINY, steps(data[:steps]), WHITE);
        text(dc, 189, 243, Graphics.FONT_TINY, bpm(data[:hr]), WHITE);
        bar(dc, 68, 257, 49, data[:steps], data[:goal]);
        bar(dc, 164, 257, 49, data[:hr], data[:maxHr]);
    }
}
