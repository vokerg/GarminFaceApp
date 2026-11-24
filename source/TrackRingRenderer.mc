import Toybox.Graphics;
import Toybox.Lang;

class TrackRingRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    protected function demoY() as Number { return 267; }

    function draw(dc as Dc, data as Dictionary) as Void {
        arc(dc, 140, 140, 129, 218, 256, data[:battery], 100);
        arc(dc, 140, 140, 119, 218, 256, data[:steps], data[:goal]);
        arc(dc, 140, 140, 109, 218, 256, data[:hr], data[:maxHr]);
        text(dc, 140, 47, Graphics.FONT_XTINY, data[:date], _accent);
        text(dc, 140, 67, Graphics.FONT_XTINY, "BAT " + battery(data), WHITE);
        text(dc, 140, 107, Graphics.FONT_LARGE, time(data), WHITE);
        if (data[:period].length() > 0) {
            text(dc, 140, 131, Graphics.FONT_XTINY, data[:period], _accent);
        }
        text(dc, 91, 152, Graphics.FONT_TINY, steps(data[:steps]), WHITE);
        text(dc, 189, 152, Graphics.FONT_TINY, bpm(data[:hr]), WHITE);
        text(dc, 91, 169, Graphics.FONT_XTINY, "STEPS", _accent);
        text(dc, 189, 169, Graphics.FONT_XTINY, "BPM", _accent);

        text(dc, 77, 194, Graphics.FONT_XTINY, "BIKE", _accent);
        text(dc, 140, 205, Graphics.FONT_XTINY, "RUN", _accent);
        text(dc, 203, 194, Graphics.FONT_XTINY, "SWIM", _accent);
        text(dc, 77, 213, Graphics.FONT_TINY, km(data[:bike]), WHITE);
        text(dc, 140, 239, Graphics.FONT_MEDIUM, km(data[:run]), WHITE);
        text(dc, 203, 213, Graphics.FONT_TINY, km(data[:swim]), WHITE);
    }
}
