import Toybox.ActivityMonitor;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

/*
 * A fresh segment-week face generated from segment_week_face.zip, adjusted to
 * fit this project. It keeps the archive's large mosaic seven-segment time and
 * weather rows, while preserving the existing complication-backed weekly run
 * and bike distances.
 */
class SegmentWeekFaceView extends WatchUi.WatchFace {

    private var COLOR_DIGIT = 0xC678D8;
    private var COLOR_HATCH = 0x142A40;
    private var COLOR_CYAN = 0x40C0E0;
    private var COLOR_ORANGE = 0xFF8800;
    private var COLOR_WHITE = Graphics.COLOR_WHITE;
    private var COLOR_LGRAY = 0xAAAAAA;
    private var COLOR_DGRAY = 0x666666;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        if (Toybox has :Complications) {
            Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE));
            Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE));
            Complications.registerComplicationChangeCallback(method(:onComplicationChange));
        }
    }

    function onShow() as Void {}

    function onComplicationChange(id as Complications.Id) as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var info = ActivityMonitor.getInfo();
        var clock = System.getClockTime();
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var current = getCurrentWeather();
        var steps = (info != null && info.steps != null) ? info.steps : 0;
        var stepGoal = (info != null && info.stepGoal != null && info.stepGoal > 0) ? info.stepGoal : 10000;

        drawWeatherRow(dc, current);
        drawLargeTime(dc, clock);
        drawMetricsRow(dc, getWeeklyRunDistanceKm(), getHeartRateValue(), getWeeklyBikeDistanceKm());
        drawStepsRow(dc, steps, stepGoal);
        drawDateRow(dc, dateInfo, getHumidity(current));
    }

    private function getCurrentWeather() {
        if ((Toybox has :Weather) && (Toybox.Weather has :getCurrentConditions)) {
            return Weather.getCurrentConditions();
        }
        return null;
    }

    private function drawWeatherRow(dc as Dc, current) as Void {
        var line1 = "--C --  FL:--C";
        var line2 = "(--)";

        if (current != null) {
            var temp = (current.temperature != null) ? current.temperature.toNumber().format("%d") : "--";
            var feels = getFeelsLikeLabel(current);
            var delta = getDewPointDeltaLabel(current);
            var condition = (current.condition != null) ? current.condition.toNumber().format("%d") : "--";
            line1 = temp + "C " + delta + "  FL:" + feels + "C";
            line2 = "(" + condition + ")";
        }

        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(140, 18, Graphics.FONT_XTINY, line1, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(140, 32, Graphics.FONT_XTINY, line2, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function getFeelsLikeLabel(current) as String {
        if ((current has :feelsLikeTemperature) && current.feelsLikeTemperature != null) {
            return current.feelsLikeTemperature.toNumber().format("%d");
        }
        return (current.temperature != null) ? current.temperature.toNumber().format("%d") : "--";
    }

    private function getDewPointDeltaLabel(current) as String {
        // Keep the generated row shape, but avoid optional weather fields that
        // are not exposed consistently across fenix7x compiler metadata.
        return "--";
    }

    private function getHumidity(current) {
        if (current != null && (current has :relativeHumidity) && current.relativeHumidity != null) {
            return current.relativeHumidity;
        }
        return null;
    }

    private function drawLargeTime(dc as Dc, clock) as Void {
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        var hourStr = hour.format("%02d");
        var minStr = clock.min.format("%02d");
        var digitW = 45;
        var digitH = 90;
        var spacing = 12;
        var totalW = digitW * 4 + spacing * 3;
        var startX = ((280 - totalW) / 2).toNumber();
        var yPos = 55;

        drawCrossHatch(dc, startX, yPos, totalW, digitH, 6);
        drawSevenSegDigit(dc, startX, yPos, digitW, digitH, hourStr.substring(0, 1));
        drawSevenSegDigit(dc, startX + digitW + spacing, yPos, digitW, digitH, hourStr.substring(1, 2));
        drawSevenSegDigit(dc, startX + (digitW + spacing) * 2, yPos, digitW, digitH, minStr.substring(0, 1));
        drawSevenSegDigit(dc, startX + (digitW + spacing) * 3, yPos, digitW, digitH, minStr.substring(1, 2));

        var colonX = (startX + digitW * 2 + spacing * 1.5).toNumber();
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(colonX - 5, yPos + 28, 10, 10);
        dc.fillRectangle(colonX - 5, yPos + 56, 10, 10);

        drawSecondsBar(dc, startX + totalW + 8, yPos, digitH, clock.sec);
    }

    private function drawSevenSegDigit(dc as Dc, x as Number, y as Number, w as Number, h as Number, digit as String) as Void {
        var segments = getSegmentsForDigit(digit);
        var th = (w / 6).toNumber();
        var halfH = h / 2.0;

        dc.setColor(COLOR_DIGIT, Graphics.COLOR_TRANSPARENT);
        if (segmentIsOn(segments, 0)) { dc.fillRectangle(x + th + 1, y, w - 2 * th - 2, th); }
        if (segmentIsOn(segments, 1)) { dc.fillRectangle(x + w - th, y + th, th, (halfH - th).toNumber()); }
        if (segmentIsOn(segments, 2)) { dc.fillRectangle(x + w - th, (y + halfH + th / 2).toNumber(), th, (halfH - 1.5 * th).toNumber()); }
        if (segmentIsOn(segments, 3)) { dc.fillRectangle(x + th + 1, y + h - th, w - 2 * th - 2, th); }
        if (segmentIsOn(segments, 4)) { dc.fillRectangle(x, (y + halfH + th / 2).toNumber(), th, (halfH - 1.5 * th).toNumber()); }
        if (segmentIsOn(segments, 5)) { dc.fillRectangle(x, y + th, th, (halfH - th).toNumber()); }
        if (segmentIsOn(segments, 6)) { dc.fillRectangle(x + th + 1, (y + halfH - th / 2).toNumber(), w - 2 * th - 2, th); }
    }

    private function getSegmentsForDigit(digit as String) {
        if (digit == "0") { return [0, 1, 2, 3, 4, 5]; }
        if (digit == "1") { return [1, 2]; }
        if (digit == "2") { return [0, 1, 6, 4, 3]; }
        if (digit == "3") { return [0, 1, 6, 2, 3]; }
        if (digit == "4") { return [5, 6, 1, 2]; }
        if (digit == "5") { return [0, 5, 6, 2, 3]; }
        if (digit == "6") { return [0, 5, 6, 2, 3, 4]; }
        if (digit == "7") { return [0, 1, 2]; }
        if (digit == "8") { return [0, 1, 2, 3, 4, 5, 6]; }
        if (digit == "9") { return [0, 1, 2, 3, 5, 6]; }
        return [];
    }

    private function segmentIsOn(segments, idx as Number) as Boolean {
        for (var i = 0; i < segments.size(); i++) {
            if (segments[i] == idx) { return true; }
        }
        return false;
    }

    private function drawCrossHatch(dc as Dc, x as Number, y as Number, w as Number, h as Number, spacing as Number) as Void {
        dc.setColor(COLOR_HATCH, Graphics.COLOR_TRANSPARENT);

        var xx = x;
        while (xx <= x + w) {
            dc.drawLine(xx, y, xx, y + h);
            xx += spacing;
        }

        var yy = y;
        while (yy <= y + h) {
            dc.drawLine(x, yy, x + w, yy);
            yy += spacing;
        }
    }

    private function drawSecondsBar(dc as Dc, x as Number, y as Number, height as Number, secVal as Number) as Void {
        var segH = height / 60.0;
        for (var i = 0; i < 60; i++) {
            var yPos = (y + i * segH).toNumber();
            dc.setColor(i < secVal ? (i < 30 ? COLOR_ORANGE : COLOR_CYAN) : COLOR_DGRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, yPos, 4, (segH - 1).toNumber());
        }
    }

    private function drawMetricsRow(dc as Dc, runKm, hrVal, bikeKm) as Void {
        var labels = [ "RUN WEEK", "LIVE HR", "BIKE WEEK" ];
        var values = [
            (runKm == null) ? "--" : formatDistanceKm(runKm),
            (hrVal == null) ? "--" : hrVal.toString(),
            (bikeKm == null) ? "--" : formatDistanceKm(bikeKm)
        ];
        var positions = [46, 140, 234];

        for (var i = 0; i < 3; i++) {
            dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(positions[i], 160, Graphics.FONT_XTINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(positions[i], 172, Graphics.FONT_XTINY, values[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawStepsRow(dc as Dc, steps as Number, goal as Number) as Void {
        var y = 188;
        var barX = 120;
        var barW = 130;
        var barH = 6;
        var progress = (goal > 0) ? (steps.toFloat() / goal.toFloat()) : 0.0;
        if (progress > 1.0) { progress = 1.0; }
        if (progress < 0.0) { progress = 0.0; }

        drawFootIcon(dc, 40, y + 8);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(70, y + 8, Graphics.FONT_XTINY, formatSteps(steps), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_DGRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, y + 5, barW, barH);

        var fillW = (barW * progress).toNumber();
        var half = (barW / 2.0).toNumber();
        if (fillW <= half) {
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, y + 5, fillW, barH);
        } else {
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, y + 5, half, barH);
            dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX + half, y + 5, fillW - half, barH);
        }
    }

    private function drawDateRow(dc as Dc, dateInfo, humidity) as Void {
        var dow = weekdayShort(dateInfo.day_of_week);
        var dateStr = dateInfo.day.format("%02d") + " " + dateInfo.month.toUpper();
        var humStr = humidity != null ? humidity.toNumber().format("%d") + "%" : "--%";
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(140, 228, Graphics.FONT_XTINY, dow + ", " + dateStr + " " + humStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function getHeartRateValue() {
        if (!(ActivityMonitor has :getHeartRateHistory)) {
            return null;
        }

        var iterator = ActivityMonitor.getHeartRateHistory(6, true);
        if (iterator == null) {
            return null;
        }

        var sample = iterator.next();
        while (sample != null) {
            if (sample.heartRate != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate;
            }
            sample = iterator.next();
        }

        return null;
    }

    private function getWeeklyRunDistanceKm() {
        var km = getComplicationDistanceKm(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
        return km == null ? getRollingActivityDistanceKm() : km;
    }

    private function getWeeklyBikeDistanceKm() {
        return getComplicationDistanceKm(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE);
    }

    private function getComplicationDistanceKm(complicationType) {
        if (!(Toybox has :Complications)) {
            return null;
        }

        var complication = Complications.getComplication(new Complications.Id(complicationType));
        if (complication == null || complication.value == null) {
            return null;
        }

        return complication.value.toFloat() / 1000.0;
    }

    private function getRollingActivityDistanceKm() {
        var history = ActivityMonitor.getHistory();
        if (history == null) {
            return null;
        }

        var cm = 0;
        for (var i = 0; i < history.size(); i++) {
            var day = history[i];
            if (day.distance != null) {
                cm += day.distance;
            }
        }

        return cm.toFloat() / 100000.0;
    }

    private function formatDistanceKm(km as Float) as String {
        if (km >= 100.0) {
            return km.format("%.0f") + "K";
        }
        return km.format("%.1f") + "K";
    }

    private function formatSteps(steps as Number) as String {
        if (steps >= 1000) {
            return (steps / 1000.0).format("%.1f") + "K";
        }
        return steps.toString();
    }

    private function weekdayShort(day as String) as String {
        var upper = day.toUpper();
        if (upper == "SUN" || upper == "SUNDAY") { return "SUN"; }
        if (upper == "MON" || upper == "MONDAY") { return "MON"; }
        if (upper == "TUE" || upper == "TUESDAY") { return "TUE"; }
        if (upper == "WED" || upper == "WEDNESDAY") { return "WED"; }
        if (upper == "THU" || upper == "THURSDAY") { return "THU"; }
        if (upper == "FRI" || upper == "FRIDAY") { return "FRI"; }
        if (upper == "SAT" || upper == "SATURDAY") { return "SAT"; }
        return "---";
    }

    private function drawFootIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x - 4, y - 2, 3);
        dc.drawCircle(x + 3, y + 2, 3);
        dc.drawLine(x - 6, y + 4, x - 2, y + 8);
        dc.drawLine(x + 1, y + 7, x + 5, y + 11);
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
