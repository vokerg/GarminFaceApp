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
    // v6 notes: avoid filled blue side blocks. The fēnix simulator maps many
    // arbitrary dark RGB colors to a much brighter 64-color MIP palette entry,
    // so solid vector panels looked electric blue. This version keeps the
    // layout but uses black backing plus thin gray/orange panel separators.
    private var COLOR_ORANGE = 0xFF8800;
    private var COLOR_CYAN = 0x66D9E8;
    // Avoid custom dark blues for filled areas: on 64-color MIP they can
    // quantize into saturated navy. Use them only for future bitmap assets.
    private var COLOR_BLUE = 0x000000;
    private var COLOR_BLUE_DARK = 0x000000;
    private var COLOR_PANEL = 0x222222;
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

    /**
     * Draw subtle side-panel geometry similar to the reference face.
     *
     * Filled custom-blue rectangles looked too bright in the simulator because
     * the target display palette is small. Thin separators keep the Fenix-style
     * grouping without introducing ugly color quantization artifacts.
     */
    private function drawBackgroundPanels(dc as Dc) as Void {
        dc.setPenWidth(1);

        // Panel outlines: enough structure to group the complications, but the
        // background remains black so the face stays closer to the reference.
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(6, 72, 54, 48);
        dc.drawRectangle(220, 72, 54, 48);
        dc.drawRectangle(6, 160, 54, 48);
        dc.drawRectangle(220, 160, 54, 48);

        // Reference-like horizontal cuts at 9 and 3 o'clock.
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, 140, 17, 140);
        dc.drawLine(263, 140, 280, 140);

        // Small gray dividers separate top/middle/bottom complication zones.
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(8, 124, 58, 124);
        dc.drawLine(222, 124, 272, 124);
        dc.drawLine(8, 156, 58, 156);
        dc.drawLine(222, 156, 272, 156);
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
        var segments = 26;
        var filled = ((battery / 100.0) * segments).toNumber();
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;

        dc.setPenWidth(4);
        for (var i = 0; i < segments; i++) {
            var angle = Math.toRadians(221 + (i * 3.8));
            if (i < filled) {
                dc.setColor(i < 7 ? COLOR_CYAN : COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(
                cx + 115 * Math.cos(angle), cy + 115 * Math.sin(angle),
                cx + 123 * Math.cos(angle), cy + 123 * Math.sin(angle)
            );
        }
    }

    /** Battery icon, percentage, and FENIX label. */
    private function drawHeader(dc as Dc, battery) as Void {
        var x = 111;
        var y = 33;

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, 17, 9);
        dc.drawLine(x + 18, y + 3, x + 21, y + 3);
        dc.drawLine(x + 18, y + 6, x + 21, y + 6);
        dc.drawText(136, 38, Graphics.FONT_XTINY, battery.toNumber().format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(SCREEN_CENTER, 62, Graphics.FONT_SMALL, "FENIX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Replaces the reference elevation slot with weekly running distance UI. */
    private function drawTopLeftRunDistance(dc as Dc) as Void {
        drawMountainIcon(dc, 35, 82);
        drawSmallMetric(dc, 35, 103, "RUN", getWeeklyRunDistanceLabel());
    }

    /** Weather is already Celsius in Toybox.Weather.CurrentConditions. */
    private function drawTopRightWeather(dc as Dc) as Void {
        drawWeatherIcon(dc, 245, 82);
        drawSmallMetric(dc, 245, 103, "TEMP", getWeatherTemperatureLabel());
    }

    /** Replaces body battery with latest available heart-rate history sample. */
    private function drawHeartRateDial(dc as Dc) as Void {
        var hrValue = getHeartRateValue();
        var label = hrValue == null ? "--" : hrValue.toString();
        var progress = hrValue == null ? 0.0 : hrValue.toFloat() / 180.0;
        drawRoundDial(dc, 53, 144, 20, "HR", label, progress);
        drawHeartIcon(dc, 53, 130);
    }

    private function drawStepsDial(dc as Dc, info as ActivityMonitor.Info) as Void {
        var steps = info.steps != null ? info.steps : 0;
        var stepGoal = (info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var progress = steps.toFloat() / stepGoal.toFloat();
        drawRoundDial(dc, 227, 144, 20, "STEP", formatSteps(steps), progress);
        drawFootstepsIcon(dc, 227, 130);
    }

    /** Replaces the unknown 814 slot with weekly cycling distance UI. */
    private function drawBottomLeftBikeDistance(dc as Dc) as Void {
        drawBikeIcon(dc, 35, 194);
        drawSmallMetric(dc, 35, 208, "BIKE", getWeeklyBikeDistanceLabel());
    }

    private function drawBottomRightCalories(dc as Dc, info as ActivityMonitor.Info) as Void {
        var calories = info.calories != null ? info.calories : 0;
        drawFlameIcon(dc, 245, 194);
        drawSmallMetric(dc, 245, 208, "CAL", calories.toString());
    }

    /** Common two-line mini metric. */
    private function drawSmallMetric(dc as Dc, x as Number, y as Number, label as String, value as String) as Void {
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 9, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 2, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Shared circular dial renderer for heart rate and steps. */
    private function drawRoundDial(dc as Dc, cx as Number, cy as Number, radius as Number, label as String, value as String, progress as Float) as Void {
        if (progress > 1.0) { progress = 1.0; }
        if (progress < 0.0) { progress = 0.0; }

        dc.setPenWidth(3);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        // Static cyan accent plus orange progress, like the original dial language.
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 145, 280);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 285, 285 - (progress * 170).toNumber());

        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 10, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Main stacked time. Hour is white, minutes are orange like the reference. */
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

        // FONT_NUMBER_HOT is intentionally smaller than FONT_NUMBER_THAI_HOT.
        // The Thai hot font looked close in isolation but collided with the
        // date and complications in the simulator.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 102, Graphics.FONT_NUMBER_HOT, hourStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 154, Graphics.FONT_NUMBER_HOT, minStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawSecondsBubble(dc, SCREEN_CENTER, 192, secStr);
    }

    /** Small seconds bubble at the bottom of the minute digits. */
    private function drawSecondsBubble(dc as Dc, cx as Number, cy as Number, seconds as String) as Void {
        dc.setPenWidth(2);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, 13);

        for (var i = 0; i < 36; i++) {
            var angle = Math.toRadians(i * 10 - 90);
            dc.setColor(i % 3 == 0 ? COLOR_ORANGE : COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(
                cx + 10 * Math.cos(angle), cy + 10 * Math.sin(angle),
                cx + 13 * Math.cos(angle), cy + 13 * Math.sin(angle)
            );
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 4, Graphics.FONT_XTINY, "S", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 5, Graphics.FONT_XTINY, seconds, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Month/day plus weekday strip near the bottom edge. */
    private function drawDateStrip(dc as Dc) as Void {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var selected = weekdayIndex(dateInfo.day_of_week.toUpper());
        var letters = [ "S", "M", "T", "W", "T", "F", "S" ];
        var startX = 83;

        // Keep the date outside the time column. Using XTINY avoids the
        // FONT_TINY month/day collision seen in the simulator screenshot.
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(101, 222, Graphics.FONT_XTINY, dateInfo.month.toUpper(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(179, 222, Graphics.FONT_XTINY, dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        for (var i = 0; i < 7; i++) {
            dc.setColor(i == selected ? COLOR_ORANGE : COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + (i * 19), 238, Graphics.FONT_XTINY, letters[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
        dc.setPenWidth(2);
        dc.drawLine(x - 13, y + 8, x - 3, y - 9);
        dc.drawLine(x - 3, y - 9, x + 6, y + 8);
        dc.drawLine(x, y + 8, x + 9, y - 3);
        dc.drawLine(x + 9, y - 3, x + 16, y + 8);
    }

    private function drawWeatherIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x + 6, y - 6, 6);
        dc.drawLine(x + 6, y - 17, x + 6, y - 14);
        dc.drawLine(x + 16, y - 6, x + 19, y - 6);
        dc.drawLine(x + 13, y - 13, x + 16, y - 16);

        dc.setPenWidth(2);
        dc.drawArc(x - 4, y, 11, Graphics.ARC_CLOCKWISE, 190, 350);
        dc.drawLine(x - 15, y + 2, x + 12, y + 2);
    }

    private function drawHeartIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x - 3, y - 1, 3);
        dc.drawCircle(x + 3, y - 1, 3);
        dc.drawLine(x - 6, y, x, y + 7);
        dc.drawLine(x + 6, y, x, y + 7);
    }

    private function drawFootstepsIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x - 4, y - 3, 3);
        dc.drawCircle(x + 5, y + 1, 3);
        dc.drawLine(x - 6, y + 3, x - 2, y + 7);
        dc.drawLine(x + 2, y + 6, x + 6, y + 10);
    }

    private function drawBikeIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x - 9, y + 5, 5);
        dc.drawCircle(x + 9, y + 5, 5);
        dc.drawLine(x - 9, y + 5, x, y + 5);
        dc.drawLine(x, y + 5, x + 5, y - 3);
        dc.drawLine(x + 5, y - 3, x + 9, y + 5);
        dc.drawLine(x, y + 5, x - 3, y - 3);
        dc.drawLine(x - 6, y - 3, x + 2, y - 3);
    }

    private function drawFlameIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawArc(x, y, 10, Graphics.ARC_CLOCKWISE, 120, 330);
        dc.drawLine(x - 5, y + 7, x, y - 13);
        dc.drawLine(x, y - 13, x + 4, y - 1);
        dc.drawLine(x + 4, y - 1, x + 8, y + 6);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

}
