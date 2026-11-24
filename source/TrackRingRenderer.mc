import Toybox.Graphics;
import Toybox.Lang;

class TrackRingRenderer extends FaceRenderer {
    function initialize() { FaceRenderer.initialize(); }

    protected function demoY() as Number { return 267; }

    function draw(dc as Dc, data as Dictionary) as Void {
        arc(dc, 140, 140, 129, 203, 226, data[:battery], 100);
        arc(dc, 140, 140, 119, 203, 226, data[:steps], data[:goal]);
        arc(dc, 140, 140, 109, 203, 226, data[:hr], data[:maxHr]);
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

        text(dc, 80, 194, Graphics.FONT_XTINY, sportLabel(SportOrder.SECONDARY), _accent);
        text(dc, 140, 205, Graphics.FONT_XTINY, sportLabel(SportOrder.PRIMARY), _accent);
        text(dc, 200, 194, Graphics.FONT_XTINY, sportLabel(SportOrder.TERTIARY), _accent);
        text(dc, 80, 213, Graphics.FONT_TINY, sportKm(data, SportOrder.SECONDARY), WHITE);
        text(dc, 140, 239, Graphics.FONT_MEDIUM, sportKm(data, SportOrder.PRIMARY), WHITE);
        text(dc, 200, 213, Graphics.FONT_TINY, sportKm(data, SportOrder.TERTIARY), WHITE);
    }
}
