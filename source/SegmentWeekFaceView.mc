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
 * Photo-inspired mosaic face.
 *
 * The zip version had the right broad idea, but it rendered as a grid with a
 * colon because the generated seven-segment string path was fragile. This
 * version drives the digits numerically and makes the reference photo's visual
 * hierarchy explicit: top dawn/weather, huge patterned time, date, three data
 * columns, steps, and battery.
 */
class SegmentWeekFaceView extends WatchUi.WatchFace {

    private var COLOR_TEAL = 0x00A6A6;
    private var COLOR_PURPLE = 0xC678D8;
    private var COLOR_GRID = 0x003366;
    private var COLOR_CYAN = 0x40C0E0;
    private var COLOR_ORANGE = 0xFF8800;
    private var COLOR_WHITE = Graphics.COLOR_WHITE;
    private var COLOR_LGRAY = 0xAAAAAA;
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

        drawTopAstronomy(dc);
        drawWeatherRow(dc, current);
        drawLargeMosaicTime(dc, clock);
        drawDateRow(dc, dateInfo, getHumidity(current));
        drawMetricsRow(dc, getHeartRateValue());
        drawStepsRow(dc, steps);
        drawBattery(dc, System.getSystemStats().battery);
    }

    private function getCurrentWeather() {
        if ((Toybox has :Weather) && (Toybox.Weather has :getCurrentConditions)) {
            return Weather.getCurrentConditions();
        }
        return null;
    }

    private function drawTopAstronomy(dc as Dc) as Void {
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(94, 16, Graphics.FONT_XTINY, "DAWN", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(186, 16, Graphics.FONT_XTINY, "DUSK", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(94, 29, Graphics.FONT_XTINY, "--:--", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(186, 29, Graphics.FONT_XTINY, "--:--", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawMoonIcon(dc, 140, 25);
    }

    private function drawWeatherRow(dc as Dc, current) as Void {
        var line1 = "--C --  FL:--C";
        var line2 = "(--)";

        if (current != null) {
            var temp = (current.temperature != null) ? current.temperature.toNumber().format("%d") : "--";
            var feels = getFeelsLikeLabel(current);
            var condition = (current.condition != null) ? current.condition.toNumber().format("%d") : "--";
            line1 = temp + "C --  FL:" + feels + "C";
            line2 = "MOSTLY CLOUDY (" + condition + ")";
        }

        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(140, 48, Graphics.FONT_XTINY, line1, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(140, 64, Graphics.FONT_XTINY, line2, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function getFeelsLikeLabel(current) as String {
        if ((current has :feelsLikeTemperature) && current.feelsLikeTemperature != null) {
            return current.feelsLikeTemperature.toNumber().format("%d");
        }
        return (current.temperature != null) ? current.temperature.toNumber().format("%d") : "--";
    }

    private function getHumidity(current) {
        if (current != null && (current has :relativeHumidity) && current.relativeHumidity != null) {
            return current.relativeHumidity;
        }
        return null;
    }

    private function drawLargeMosaicTime(dc as Dc, clock) as Void {
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        var y = 72;
        var digitW = 45;
        var digitH = 90;
        var gap = 5;
        var colonGap = 18;
        var startX = 30;
        var min = clock.min;

        drawMosaicDigit(dc, startX, y, digitW, digitH, hour / 10, COLOR_TEAL);
        drawMosaicDigit(dc, startX + digitW + gap, y, digitW, digitH, hour % 10, COLOR_PURPLE);
        drawColon(dc, startX + (digitW + gap) * 2 + 4, y);
        drawMosaicDigit(dc, startX + (digitW + gap) * 2 + colonGap, y, digitW, digitH, min / 10, COLOR_PURPLE);
        drawMosaicDigit(dc, startX + (digitW + gap) * 3 + colonGap, y, digitW, digitH, min % 10, COLOR_PURPLE);

        dc.setColor(COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(22, y + 18, 22, y + 78);
        drawSecondsBar(dc, 256, y + 18, 60, clock.sec);
    }

    private function drawMosaicDigit(dc as Dc, x as Number, y as Number, w as Number, h as Number, digit as Number, color as Number) as Void {
        var th = 15;
        var midY = y + (h / 2).toNumber() - (th / 2).toNumber();
        var lowerY = y + (h / 2).toNumber() + 3;
        var lowerH = h - (h / 2).toNumber() - th - 5;

        if (isSegmentOn(digit, 0)) { fillMosaicSegment(dc, x + th - 1, y, w - th * 2 + 2, th, color); }
        if (isSegmentOn(digit, 1)) { fillMosaicSegment(dc, x + w - th, y + th - 1, th, (h / 2).toNumber() - th + 3, color); }
        if (isSegmentOn(digit, 2)) { fillMosaicSegment(dc, x + w - th, lowerY, th, lowerH, color); }
        if (isSegmentOn(digit, 3)) { fillMosaicSegment(dc, x + th - 1, y + h - th, w - th * 2 + 2, th, color); }
        if (isSegmentOn(digit, 4)) { fillMosaicSegment(dc, x, lowerY, th, lowerH, color); }
        if (isSegmentOn(digit, 5)) { fillMosaicSegment(dc, x, y + th - 1, th, (h / 2).toNumber() - th + 3, color); }
        if (isSegmentOn(digit, 6)) { fillMosaicSegment(dc, x + th - 1, midY, w - th * 2 + 2, th, color); }
    }

    private function fillMosaicSegment(dc as Dc, x as Number, y as Number, w as Number, h as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, w, h);

        dc.setPenWidth(1);
        dc.setColor(COLOR_GRID, Graphics.COLOR_TRANSPARENT);
        var xx = x + 5;
        while (xx < x + w) {
            dc.drawLine(xx, y, xx, y + h);
            xx += 6;
        }

        var yy = y + 5;
        while (yy < y + h) {
            dc.drawLine(x, yy, x + w, yy);
            yy += 6;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var offset = -h;
        while (offset < w) {
            dc.drawLine(x + offset, y + h, x + offset + h, y);
            offset += 30;
        }
    }

    private function isSegmentOn(digit as Number, segment as Number) as Boolean {
        if (digit == 0) { return segment != 6; }
        if (digit == 1) { return segment == 1 || segment == 2; }
        if (digit == 2) { return segment == 0 || segment == 1 || segment == 6 || segment == 4 || segment == 3; }
        if (digit == 3) { return segment == 0 || segment == 1 || segment == 6 || segment == 2 || segment == 3; }
        if (digit == 4) { return segment == 5 || segment == 6 || segment == 1 || segment == 2; }
        if (digit == 5) { return segment == 0 || segment == 5 || segment == 6 || segment == 2 || segment == 3; }
        if (digit == 6) { return segment == 0 || segment == 5 || segment == 6 || segment == 2 || segment == 3 || segment == 4; }
        if (digit == 7) { return segment == 0 || segment == 1 || segment == 2; }
        if (digit == 8) { return true; }
        if (digit == 9) { return segment == 0 || segment == 1 || segment == 2 || segment == 3 || segment == 5 || segment == 6; }
        return false;
    }

    private function drawColon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y + 30, 10, 10);
        dc.fillRectangle(x, y + 58, 10, 10);
    }

    private function drawSecondsBar(dc as Dc, x as Number, y as Number, height as Number, second as Number) as Void {
        var segmentH = 4;
        var filled = (height * second / 60).toNumber();

        for (var yy = 0; yy < height; yy += segmentH + 2) {
            dc.setColor(yy <= filled ? COLOR_CYAN : COLOR_GRID, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, y + yy, 3, segmentH);
        }
    }

    private function drawDateRow(dc as Dc, dateInfo, humidity) as Void {
        var dow = weekdayShort(dateInfo.day_of_week);
        var dateStr = dateInfo.day.format("%02d") + " " + dateInfo.month.toUpper() + " " + dateInfo.year.toString();
        var humStr = humidity != null ? humidity.toNumber().format("%d") : "--";
        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        dc.drawText(140, 174, Graphics.FONT_XTINY, dow + "  " + dateStr + "    " + humStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawMetricsRow(dc as Dc, hrVal) as Void {
        var labels = [ "RUN WEEK", "LIVE HR", "BIKE WEEK" ];
        var values = [
            getRunWeekDistanceLabel(),
            (hrVal == null) ? "--" : hrVal.toString(),
            getWeeklyBikeDistanceLabel()
        ];
        var positions = [63, 140, 217];

        for (var i = 0; i < 3; i++) {
            dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(positions[i], 182, Graphics.FONT_XTINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(i == 1 ? COLOR_PURPLE : COLOR_TEAL, Graphics.COLOR_TRANSPARENT);
            dc.drawText(positions[i], 198, Graphics.FONT_MEDIUM, values[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function getRunWeekDistanceLabel() as String {
        var km = getWeeklyRunDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    private function getWeeklyBikeDistanceLabel() as String {
        var km = getWeeklyBikeDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    private function drawStepsRow(dc as Dc, steps as Number) as Void {
        drawFootIcon(dc, 95, 225);
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(116, 226, Graphics.FONT_MEDIUM, steps.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawBattery(dc as Dc, battery) as Void {
        var x = 121;
        var y = 263;
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(x, y, 38, 14, 3);
        dc.drawLine(x + 39, y + 5, x + 42, y + 5);
        dc.drawLine(x + 39, y + 9, x + 42, y + 9);
        dc.drawText(140, y + 7, Graphics.FONT_XTINY, battery.toNumber().format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
        // Public activity history does not expose sport-specific cycling
        // totals. Use the bike-week complication when available; otherwise
        // show "--" instead of inventing a value.
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
        // Approximation used only when the weekly run complication is absent:
        // ActivityMonitor history is distance over recent days, not a
        // sport-specific running split.
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
            return km.format("%.0f");
        }
        return km.format("%.1f");
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

    private function drawMoonIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawArc(x, y, 10, Graphics.ARC_CLOCKWISE, 295, 75);
        dc.drawArc(x + 4, y, 10, Graphics.ARC_CLOCKWISE, 295, 75);
    }

    private function drawFootIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_LGRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x - 5, y - 3, 3);
        dc.drawCircle(x + 4, y + 1, 3);
        dc.drawLine(x - 7, y + 3, x - 3, y + 8);
        dc.drawLine(x + 1, y + 6, x + 6, y + 11);
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
