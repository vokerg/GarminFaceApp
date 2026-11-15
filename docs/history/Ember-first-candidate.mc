import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {
    private const EMBER = 0xFF5500;
    private const GOLD = 0xFFAA00;
    private const GRAY = 0xAAAAAA;
    private const TRACK = 0x555555;
    private var _data;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
    }

    function onUpdate(dc as Dc) as Void {
        var data = _data.snapshot() as Lang.Dictionary;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        perimeter(dc, data[:battery]);

        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateText = date.day_of_week.toUpper() + " " + date.day.format("%02d") + " " + date.month.toUpper();
        text(dc, 140, 44, Graphics.FONT_XTINY, dateText, GRAY);
        drawTime(dc, data);

        // Connected meters: one real daily goal, one absolute HR readout.
        drawSteps(dc, data[:steps], data[:goal]);
        drawHeartRate(dc, data[:hr]);

        dc.setPenWidth(1);
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(68, 219, 212, 219);
        dc.drawLine(140, 225, 140, 247);
        var statute = System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE;
        var distance = data[:distance];
        var distanceText = distance == null ? "--" : (distance / (statute ? 160934.4 : 100000.0)).format("%.1f");
        text(dc, 103, 232, Graphics.FONT_XTINY, distanceText + (statute ? " MI" : " KM"), Graphics.COLOR_WHITE);
        var calories = data[:calories];
        text(dc, 177, 232, Graphics.FONT_XTINY, calories == null ? "--" : calories.format("%d"), Graphics.COLOR_WHITE);
        text(dc, 103, 250, Graphics.FONT_XTINY, "DIST", GRAY);
        text(dc, 177, 250, Graphics.FONT_XTINY, "KCAL", GRAY);
        var battery = data[:battery];
        text(dc, 140, 67, Graphics.FONT_XTINY, "BAT " + battery.toNumber().format("%d") + "%", GOLD);
        if (data[:preview]) {
            text(dc, 140, 17, Graphics.FONT_XTINY, "DEMO", GRAY);
        }
    }

    private function text(dc, x, y, font, value, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function perimeter(dc, battery) {
        dc.setPenWidth(3);
        // A continuous capacity arc; its color and endpoint describe battery.
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(140, 140, 132, Graphics.ARC_CLOCKWISE, 225, -45);
        if (battery > 0) {
            dc.setColor(EMBER, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(140, 140, 132, Graphics.ARC_CLOCKWISE, 225, 225 - 270 * battery / 100.0);
        }
        dc.setPenWidth(1);
        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);
            dc.setColor(i % 5 == 0 ? GRAY : TRACK, Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(EMBER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left, 109, font, hours, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + leftWidth + 12, 109, font, minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!settings.is24Hour) {
            text(dc, 140, 140, Graphics.FONT_XTINY, rawHour >= 12 ? "PM" : "AM", GRAY);
        }
    }

    private function drawSteps(dc, steps, goal) {
        var x = 84;
        var y = 181;
        dc.setPenWidth(3);
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, 31, Graphics.ARC_CLOCKWISE, 225, -45);
        if (steps != null && goal != null && goal > 0 && steps > 0) {
            var progress = steps.toFloat() / goal;
            if (progress > 1) { progress = 1.0; }
            dc.setColor(EMBER, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(x, y, 31, Graphics.ARC_CLOCKWISE, 225, 225 - progress * 270);
        }
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
        text(dc, x, y - 3, Graphics.FONT_TINY, label, Graphics.COLOR_WHITE);
        text(dc, x, y + 17, Graphics.FONT_XTINY, "STEPS", GRAY);
    }

    private function drawHeartRate(dc, hr) {
        var x = 196;
        var y = 181;
        // An open frame, not a fabricated HR/180 progress gauge.
        dc.setPenWidth(1);
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, 31, Graphics.ARC_CLOCKWISE, 225, -45);
        dc.setPenWidth(2);
        dc.setColor(EMBER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(173, 148, 181, 148);
        dc.drawLine(181, 148, 185, 143);
        dc.drawLine(185, 143, 190, 153);
        dc.drawLine(190, 153, 194, 148);
        dc.drawLine(194, 148, 204, 148);
        text(dc, x, y - 3, Graphics.FONT_SMALL, hr == null ? "--" : hr.format("%d"), Graphics.COLOR_WHITE);
        text(dc, x, y + 17, Graphics.FONT_XTINY, "BPM", GRAY);
    }

    function onEnterSleep() as Void { WatchUi.requestUpdate(); }
    function onExitSleep() as Void { WatchUi.requestUpdate(); }
}
