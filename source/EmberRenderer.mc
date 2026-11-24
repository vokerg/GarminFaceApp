import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class EmberRenderer extends FaceRenderer {
    private var _bezelFont;

    function initialize() {
        FaceRenderer.initialize();
        _bezelFont = Graphics.getVectorFont({:face => ["RobotoCondensedBold", "RobotoCondensedRegular", "RobotoRegular"], :size => 16});
    }

    function draw(dc as Dc, data as Dictionary) as Void {
        perimeter(dc, data[:battery]);
        text(dc, 140, 40, Graphics.FONT_XTINY, data[:date], _accent);
        drawTime(dc, data);
        drawSteps(dc, data[:steps], data[:goal]);
        drawHeartRate(dc, data[:hr], data[:maxHr]);
        drawSportBezel(dc, data);
        text(dc, 140, 62, Graphics.FONT_XTINY, "BAT " + battery(data), _accent);
    }

    private function perimeter(dc, battery) {
        arc(dc, 140, 140, 132, 225, 270, battery, 100);
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);
            var inner = i % 5 == 0 ? 122 : 125;
            dc.drawLine(140 + inner * Math.cos(angle), 140 + inner * Math.sin(angle),
                140 + 128 * Math.cos(angle), 140 + 128 * Math.sin(angle));
        }
    }

    private function drawTime(dc, data as Lang.Dictionary) {
        var hours = data[:hours];
        var minutes = data[:minutes];
        var font = Graphics.FONT_NUMBER_HOT;
        // Measure the actual device glyphs instead of guessing a center split.
        var leftWidth = dc.getTextWidthInPixels(hours, font);
        var rightWidth = dc.getTextWidthInPixels(minutes, font);
        var left = 140 - (leftWidth + rightWidth + 12) / 2;
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left, 103, font, hours, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + leftWidth + 12, 103, font, minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if (data[:period].length() > 0) {
            text(dc, 140, 134, Graphics.FONT_XTINY, data[:period], _accent);
        }
    }

    private function drawSteps(dc, count, goal) {
        var x = 92;
        var y = 172;
        arc(dc, x, y, 36, 225, 270, count, goal);
        fittedText(dc, x, y - 6, Graphics.FONT_TINY, Graphics.FONT_XTINY, 56, steps(count), WHITE);
        text(dc, x, y + 12, Graphics.FONT_XTINY, "STEPS", _accent);
    }

    private function drawHeartRate(dc, hr, maxHr) {
        var x = 188;
        var y = 172;
        arc(dc, x, y, 36, 225, 270, hr, maxHr);
        text(dc, x, y - 6, Graphics.FONT_TINY, bpm(hr), Graphics.COLOR_WHITE);
        text(dc, x, y + 12, Graphics.FONT_XTINY, "BPM", _accent);
    }

    private function drawSportBezel(dc, data as Lang.Dictionary) {
        // The owner knows the period and units. Use the freed center space for
        // a larger, upright running value instead of repeating that legend.
        text(dc, 140, 214, Graphics.FONT_XTINY, "RUN", _accent);
        text(dc, 140, 235, Graphics.FONT_SMALL, km(data[:run]), WHITE);
        var labels = ["BIKE " + km(data[:bike]), "SWIM " + km(data[:swim])];
        var angles = [215, 325];
        for (var i = 0; i < 2; i++) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            if (_bezelFont != null) {
                dc.drawRadialText(140, 140, _bezelFont, labels[i],
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
                    angles[i], 113, Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE);
            } else {
                // Readable fallback if a firmware lacks the requested vector face.
                text(dc, 66 + i * 148, 217, Graphics.FONT_XTINY, labels[i], Graphics.COLOR_WHITE);
            }
        }
    }
}
