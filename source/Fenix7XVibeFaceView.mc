import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {

    // fēnix-like 64-color-safe palette. Keep the art mostly flat so the face
    // stays readable on MIP and does not pay for gradients or bitmap assets.
    private var COLOR_ORANGE = 0xFF8800;
    private var COLOR_CYAN = 0x66D9E8;
    private var COLOR_BLUE = 0x082A3D;
    private var COLOR_BLUE_DARK = 0x031622;
    private var COLOR_PANEL = 0x0B2433;
    private var COLOR_DK_GRAY = 0x444444;
    private var COLOR_LT_GRAY = 0xAAAAAA;

    private var SCREEN_CENTER = 140;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    // Main update loop. Draw order intentionally mirrors the reference face:
    // background panels -> outer ticks/top gauge -> side widgets -> time/date.
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var stats = System.getSystemStats();
        var battery = stats.battery;
        var info = ActivityMonitor.getInfo();

        drawBackgroundPanels(dc);
        drawOuterTicks(dc);
        drawBatteryGauge(dc, battery);
        drawHeader(dc, battery);

        drawTopLeftRunDistance(dc);
        drawTopRightWeather(dc);
        drawHeartRateDial(dc);
        drawStepsDial(dc, info);
        drawBottomLeftBikeDistance(dc);
        drawBottomRightCalories(dc, info);

        drawMainTime(dc);
        drawDateStrip(dc);
    }

    /** Draw the dark block geometry behind the complications. */
    private function drawBackgroundPanels(dc as Dc) as Void {
        dc.setColor(COLOR_BLUE_DARK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(36, 52, 66, 54);
        dc.fillRectangle(178, 52, 66, 54);
        dc.fillRectangle(24, 116, 76, 52);
        dc.fillRectangle(180, 116, 76, 52);
        dc.fillRectangle(36, 180, 66, 54);
        dc.fillRectangle(178, 180, 66, 54);

        dc.setColor(COLOR_PANEL, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(103, 48, 74, 170);
    }

    /** Draw outer minute/hour tick marks, with orange quarter-hour anchors. */
    private function drawOuterTicks(dc as Dc) as Void {
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;
        var outerR = 134;
        var innerR = 128;

        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);

            if (i % 15 == 0) {
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(3);
                dc.drawLine(
                    cx + 120 * Math.cos(angle), cy + 120 * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            } else if (i % 5 == 0) {
                dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawLine(
                    cx + innerR * Math.cos(angle), cy + innerR * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            } else {
                dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(1);
                dc.drawLine(
                    cx + 131 * Math.cos(angle), cy + 131 * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            }
        }
    }

    /** Top segmented battery arc like the reference face. */
    private function drawBatteryGauge(dc as Dc, battery) as Void {
        var filled = ((battery / 100.0) * 30).toNumber();
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;

        dc.setPenWidth(4);
        for (var i = 0; i < 30; i++) {
            var angle = Math.toRadians(216 + (i * 3.6));
            if (i < filled) {
                dc.setColor(i < 8 ? COLOR_CYAN : COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(
                cx + 116 * Math.cos(angle), cy + 116 * Math.sin(angle),
                cx + 124 * Math.cos(angle), cy + 124 * Math.sin(angle)
            );
        }
    }

    /** Battery icon, percentage, and FENIX label. */
    private function drawHeader(dc as Dc, battery) as Void {
        var x = 112;
        var y = 31;

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, 17, 9);
        dc.drawLine(x + 18, y + 3, x + 21, y + 3);
        dc.drawLine(x + 18, y + 6, x + 21, y + 6);
        dc.drawText(136, 36, Graphics.FONT_XTINY, battery.toNumber().format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(SCREEN_CENTER, 61, Graphics.FONT_SMALL, "FENIX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Replaces the reference elevation slot with weekly running distance UI. */
    private function drawTopLeftRunDistance(dc as Dc) as Void {
        drawMountainIcon(dc, 54, 79);
        drawSmallMetric(dc, 58, 99, "RUN", getWeeklyRunDistanceLabel());
    }

    /** Weather is already Celsius in Toybox.Weather.CurrentConditions. */
    private function drawTopRightWeather(dc as Dc) as Void {
        drawWeatherIcon(dc, 218, 76);
        drawSmallMetric(dc, 218, 99, "TEMP", getWeatherTemperatureLabel());
    }

    /** Replaces body battery with latest available heart-rate history sample. */
    private function drawHeartRateDial(dc as Dc) as Void {
        var hrValue = getHeartRateValue();
        var label = hrValue == null ? "--" : hrValue.toString();
        var progress = hrValue == null ? 0.0 : hrValue.toFloat() / 180.0;
        drawRoundDial(dc, 63, 141, 31, "HR", label, progress);
        drawHeartIcon(dc, 63, 128);
    }

    private function drawStepsDial(dc as Dc, info as ActivityMonitor.Info) as Void {
        var steps = info.steps != null ? info.steps : 0;
        var stepGoal = (info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var progress = steps.toFloat() / stepGoal.toFloat();
        drawRoundDial(dc, 218, 141, 31, "STEP", formatSteps(steps), progress);
        drawFootstepsIcon(dc, 218, 127);
    }

    /** Replaces the unknown 814 slot with weekly cycling distance UI. */
    private function drawBottomLeftBikeDistance(dc as Dc) as Void {
        drawBikeIcon(dc, 62, 203);
        drawSmallMetric(dc, 61, 222, "BIKE", getWeeklyBikeDistanceLabel());
    }

    private function drawBottomRightCalories(dc as Dc, info as ActivityMonitor.Info) as Void {
        var calories = info.calories != null ? info.calories : 0;
        drawFlameIcon(dc, 215, 199);
        drawSmallMetric(dc, 218, 222, "CAL", calories.toString());
    }

    /** Common two-line mini metric. */
    private function drawSmallMetric(dc as Dc, x as Number, y as Number, label as String, value as String) as Void {
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 13, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Shared circular dial renderer for heart rate and steps. */
    private function drawRoundDial(dc as Dc, cx as Number, cy as Number, radius as Number, label as String, value as String, progress as Float) as Void {
        if (progress > 1.0) { progress = 1.0; }
        if (progress < 0.0) { progress = 0.0; }

        dc.setPenWidth(5);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 140, 320);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 320, 320 - (progress * 180).toNumber());

        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 10, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 24, Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Main stacked time. Hour is white, minutes are orange/cyan like the reference. */
    private function drawMainTime(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        var hourStr = hour.format("%d");
        var minStr = clockTime.min.format("%02d");
        var secStr = clockTime.sec.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 105, Graphics.FONT_NUMBER_THAI_HOT, hourStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 159, Graphics.FONT_NUMBER_THAI_HOT, minStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawSecondsBubble(dc, SCREEN_CENTER, 194, secStr);
    }

    /** Small seconds bubble at the bottom of the minute digits. */
    private function drawSecondsBubble(dc as Dc, cx as Number, cy as Number, seconds as String) as Void {
        dc.setPenWidth(2);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, 24);

        for (var i = 0; i < 48; i++) {
            var angle = Math.toRadians(i * 7.5 - 90);
            dc.setColor(i % 4 == 0 ? COLOR_ORANGE : COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(
                cx + 20 * Math.cos(angle), cy + 20 * Math.sin(angle),
                cx + 24 * Math.cos(angle), cy + 24 * Math.sin(angle)
            );
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 7, Graphics.FONT_XTINY, "SEC", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 9, Graphics.FONT_TINY, seconds, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Month/day plus weekday strip near the bottom edge. */
    private function drawDateStrip(dc as Dc) as Void {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var selected = weekdayIndex(dateInfo.day_of_week.toUpper());
        var letters = [ "S", "M", "T", "W", "T", "F", "S" ];
        var startX = 82;

        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(96, 226, Graphics.FONT_SMALL, dateInfo.month.toUpper(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(181, 226, Graphics.FONT_SMALL, dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        for (var i = 0; i < 7; i++) {
            dc.setColor(i == selected ? COLOR_ORANGE : COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + (i * 20), 250, Graphics.FONT_XTINY, letters[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    /** Latest valid heart-rate sample from ActivityMonitor history. */
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

    /** Current weather temperature. Toybox.Weather reports Celsius natively. */
    private function getWeatherTemperatureLabel() as String {
        if ((Toybox has :Weather) && (Toybox.Weather has :getCurrentConditions)) {
            var current = Weather.getCurrentConditions();
            if (current != null && current.temperature != null) {
                return current.temperature.toNumber().format("%d") + "°";
            }
        }
        return "--°";
    }

    private function getWeeklyRunDistanceLabel() as String {
        var km = getWeeklyRunDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    private function getWeeklyBikeDistanceLabel() as String {
        var km = getWeeklyBikeDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    /**
     * Connect IQ exposes up to 7 days of aggregate ActivityMonitor distance,
     * but not completed-activity totals split by sport. Keep this helper small
     * so it can later be replaced by a settings/companion-fed weekly run value.
     */
    private function getWeeklyRunDistanceKm() {
        return getRollingActivityDistanceKm();
    }

    /**
     * No on-device public watch-face API exposes weekly cycling distance by
     * sport. Returning null keeps the UI honest instead of showing fake data.
     */
    private function getWeeklyBikeDistanceKm() {
        return null;
    }

    /** Sum the most recent ActivityMonitor history distance samples. */
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

    private function weekdayIndex(day as String) as Number {
        if (day == "SUN" || day == "SUNDAY") { return 0; }
        if (day == "MON" || day == "MONDAY") { return 1; }
        if (day == "TUE" || day == "TUESDAY") { return 2; }
        if (day == "WED" || day == "WEDNESDAY") { return 3; }
        if (day == "THU" || day == "THURSDAY") { return 4; }
        if (day == "FRI" || day == "FRIDAY") { return 5; }
        if (day == "SAT" || day == "SATURDAY") { return 6; }
        return -1;
    }

    // Lightweight vector icons. These avoid adding bitmap resources and keep
    // the design easy to tune directly in Monkey C.
    private function drawMountainIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(x - 18, y + 10, x - 4, y - 12);
        dc.drawLine(x - 4, y - 12, x + 7, y + 10);
        dc.drawLine(x - 1, y + 10, x + 10, y - 5);
        dc.drawLine(x + 10, y - 5, x + 20, y + 10);
    }

    private function drawWeatherIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x + 9, y - 7, 7);
        dc.drawLine(x + 9, y - 20, x + 9, y - 16);
        dc.drawLine(x + 20, y - 7, x + 24, y - 7);
        dc.drawLine(x + 17, y - 16, x + 20, y - 19);

        dc.setPenWidth(3);
        dc.drawArc(x, y, 15, Graphics.ARC_CLOCKWISE, 190, 350);
        dc.drawLine(x - 15, y + 2, x + 19, y + 2);
    }

    private function drawHeartIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x - 4, y - 2, 4);
        dc.drawCircle(x + 4, y - 2, 4);
        dc.drawLine(x - 8, y, x, y + 9);
        dc.drawLine(x + 8, y, x, y + 9);
    }

    private function drawFootstepsIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x - 5, y - 4, 4);
        dc.drawCircle(x + 6, y + 1, 4);
        dc.drawLine(x - 8, y + 4, x - 3, y + 9);
        dc.drawLine(x + 3, y + 8, x + 8, y + 13);
    }

    private function drawBikeIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x - 12, y + 7, 7);
        dc.drawCircle(x + 12, y + 7, 7);
        dc.drawLine(x - 12, y + 7, x, y + 7);
        dc.drawLine(x, y + 7, x + 7, y - 4);
        dc.drawLine(x + 7, y - 4, x + 12, y + 7);
        dc.drawLine(x, y + 7, x - 4, y - 4);
        dc.drawLine(x - 8, y - 4, x + 2, y - 4);
    }

    private function drawFlameIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawArc(x, y, 13, Graphics.ARC_CLOCKWISE, 120, 330);
        dc.drawLine(x - 6, y + 9, x, y - 17);
        dc.drawLine(x, y - 17, x + 5, y - 1);
        dc.drawLine(x + 5, y - 1, x + 10, y + 8);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

}
