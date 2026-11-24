import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class FaceRenderer {
    protected const WHITE = Graphics.COLOR_WHITE;
    protected const BLACK = Graphics.COLOR_BLACK;
    protected var _accent as Number = 0;
    protected var _gauge as Number = 0;

    private var _sportOrder as Array<Number> = SportOrder.DEFAULT;

    function initialize() {}

    function render(dc as Dc, data as Dictionary, layout as Number) as Void {
        _accent = FaceColors.color(FaceColors.ACCENT, layout);
        _gauge = FaceColors.color(FaceColors.RING, layout);
        _sportOrder = SportOrder.selected();
        dc.setColor(BLACK, BLACK);
        dc.clear();
        draw(dc, data);
        if (data[:preview]) {
            text(dc, 140, demoY(), Graphics.FONT_XTINY, "DEMO", _accent);
        }
    }

    function draw(dc as Dc, data as Dictionary) as Void {}

    protected function demoY() as Number { return 17; }

    protected function text(dc, x, y, font, value, color) {
        align(dc, x, y, font, value, color, Graphics.TEXT_JUSTIFY_CENTER);
    }

    protected function align(dc, x, y, font, value, color, justification) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, value, justification | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    protected function fittedText(dc, x, y, font, fallback, maxWidth, value, color) {
        text(dc, x, y, dc.getTextWidthInPixels(value, font) > maxWidth ? fallback : font, value, color);
    }

    protected function ratio(value, limit) {
        if (value == null || value <= 0 || limit == null || limit <= 0) { return 0.0; }
        return value >= limit ? 1.0 : value.toFloat() / limit;
    }

    protected function bar(dc, x, y, width, value, limit) {
        dc.setColor(_gauge, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, y, x + width - 1, y);
        var fill = (width * ratio(value, limit)).toNumber();
        if (fill > 0) {
            dc.fillRectangle(x, y - 1, fill, 3);
        }
    }

    protected function arc(dc, x, y, radius, start, span, value, limit) {
        dc.setColor(_gauge, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, start, start - span);
        var fill = ratio(value, limit);
        if (fill > 0) {
            dc.setPenWidth(3);
            dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, start, start - span * fill);
            dc.setPenWidth(1);
        }
    }

    protected function line(dc, x1, y1, x2, y2, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y2);
    }

    protected function polarLine(dc, x, y, inner, outer, degrees) {
        var angle = Math.toRadians(degrees);
        var dx = Math.sin(angle);
        var dy = -Math.cos(angle);
        dc.drawLine(x + inner * dx, y + inner * dy, x + outer * dx, y + outer * dy);
    }

    protected function battery(data as Dictionary) {
        return data[:battery].toNumber().format("%d") + "%";
    }

    protected function steps(value) {
        if (value == null) { return "--"; }
        if (value >= 99950) { return (value / 1000.0).format("%.0f") + "k"; }
        if (value >= 1000) { return (value / 1000.0).format("%.1f") + "k"; }
        return value.format("%d");
    }

    protected function bpm(value) {
        return value == null ? "--" : value.format("%d");
    }

    protected function sportLabel(rank as Number) as String {
        return SportOrder.NAMES[_sportOrder[rank]].toUpper();
    }

    protected function sportKm(data as Dictionary, rank as Number) as String {
        var meters = data[SportOrder.METRICS[_sportOrder[rank]]];
        if (meters == null) { return "--"; }
        return (meters / 1000.0).format(meters >= 1000000 ? "%.0f" : "%.1f");
    }

    protected function time(data as Dictionary) {
        return data[:hours] + ":" + data[:minutes];
    }
}
