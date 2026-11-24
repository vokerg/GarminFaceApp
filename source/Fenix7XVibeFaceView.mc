import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {
    private var _accent as Number = 0;
    private var _ring as Number = 0;
    private var _data;
    private var _bezelFont = null;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
    }

    function onUpdate(dc as Dc) as Void {
        _accent = FaceColors.color(FaceColors.ACCENT);
        _ring = FaceColors.color(FaceColors.RING);
        var data = _data.snapshot() as Lang.Dictionary;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        perimeter(dc, data[:battery]);

        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateText = date.day_of_week.toUpper() + " " + date.day.format("%02d") + " " + date.month.toUpper();
        text(dc, 140, 40, Graphics.FONT_XTINY, dateText, _accent);
        drawTime(dc, data);

        drawSteps(dc, data[:steps], data[:goal]);
        drawHeartRate(dc, data[:hr], data[:maxHr]);
        drawSportBezel(dc, data);

        var battery = data[:battery];
        text(dc, 140, 62, Graphics.FONT_XTINY, "BAT " + battery.toNumber().format("%d") + "%", _accent);
        if (data[:preview]) {
            text(dc, 140, 17, Graphics.FONT_XTINY, "DEMO", _accent);
        }
    }

    private function text(dc, x, y, font, value, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function gauge(dc, x, y, radius, value, limit) {
        dc.setColor(_ring, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, 225, -45);
        if (value != null && value > 0 && limit != null && limit > 0) {
            var progress = value >= limit ? 1.0 : value.toFloat() / limit;
            dc.setPenWidth(3);
            dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, 225, 225 - progress * 270);
            dc.setPenWidth(1);
        }
    }

    private function perimeter(dc, battery) {
        gauge(dc, 140, 140, 132, battery, 100);
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);
            var inner = i % 5 == 0 ? 122 : 125;
            dc.drawLine(140 + inner * Math.cos(angle), 140 + inner * Math.sin(angle),
                140 + 128 * Math.cos(angle), 140 + 128 * Math.sin(angle));
        }
    }

    private function drawTime(dc, data as Lang.Dictionary) {
        var clock = System.getClockTime();
        var rawHour = data[:preview] ? data[:hour] : clock.hour;
        var hour = rawHour;
        var minute = data[:preview] ? data[:minute] : clock.min;
        var settings = System.getDeviceSettings();
        if (!settings.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var hours = hour.format("%02d");
        var minutes = minute.format("%02d");
        var font = Graphics.FONT_NUMBER_HOT;
        // Measure the actual device glyphs instead of guessing a center split.
        var leftWidth = dc.getTextWidthInPixels(hours, font);
        var rightWidth = dc.getTextWidthInPixels(minutes, font);
        var left = 140 - (leftWidth + rightWidth + 12) / 2;
        dc.setColor(_accent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left, 103, font, hours, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + leftWidth + 12, 103, font, minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!settings.is24Hour) {
            text(dc, 140, 134, Graphics.FONT_XTINY, rawHour >= 12 ? "PM" : "AM", _accent);
        }
    }

    private function drawSteps(dc, steps, goal) {
        var x = 92;
        var y = 172;
        gauge(dc, x, y, 36, steps, goal);
        var label = "--";
        if (steps != null) {
            if (steps >= 99950) {
                label = (steps / 1000.0).format("%.0f") + "k";
            } else if (steps >= 1000) {
                label = (steps / 1000.0).format("%.1f") + "k";
            } else {
                label = steps.format("%d");
            }
        }
        var valueFont = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(label, valueFont) > 56) { valueFont = Graphics.FONT_XTINY; }
        text(dc, x, y - 6, valueFont, label, Graphics.COLOR_WHITE);
        text(dc, x, y + 12, Graphics.FONT_XTINY, "STEPS", _accent);
    }

    private function drawHeartRate(dc, hr, maxHr) {
        var x = 188;
        var y = 172;
        gauge(dc, x, y, 36, hr, maxHr);
        text(dc, x, y - 6, Graphics.FONT_TINY, hr == null ? "--" : hr.format("%d"), Graphics.COLOR_WHITE);
        text(dc, x, y + 12, Graphics.FONT_XTINY, "BPM", _accent);
    }

    function onLayout(dc as Dc) as Void {
        _bezelFont = Graphics.getVectorFont({:face => ["RobotoCondensedBold", "RobotoCondensedRegular", "RobotoRegular"], :size => 16});
    }

    private function sportLabel(name, meters) {
        if (meters == null) { return name + " --"; }
        var km = meters / 1000.0;
        if (km >= 1000.0) { return name + " " + km.format("%.0f"); }
        return name + " " + km.format("%.1f");
    }

    private function drawSportBezel(dc, data as Lang.Dictionary) {
        // The owner knows the period and units. Use the freed center space for
        // a larger, upright running value instead of repeating that legend.
        text(dc, 140, 214, Graphics.FONT_XTINY, "RUN", _accent);
        var run = data[:run];
        var runValue = run == null ? "--" : (run / 1000.0).format(run >= 1000000 ? "%.0f" : "%.1f");
        text(dc, 140, 235, Graphics.FONT_SMALL, runValue, Graphics.COLOR_WHITE);
        var labels = [sportLabel("BIKE", data[:bike]), sportLabel("SWIM", data[:swim])];
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

    function onShow() as Void { _data.invalidate(); }
    function onEnterSleep() as Void { WatchUi.requestUpdate(); }
    function onExitSleep() as Void { WatchUi.requestUpdate(); }
}
