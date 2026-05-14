import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {

    // 64-color-MIP-safe palette. Avoid custom dark blues and near-black fills:
    // the fenix simulator can dither them into speckled panels. Large areas
    // must stay exact black; gray, orange, and cyan are reserved for thin
    // outlines, ticks, arcs, icons, and text.
    private var COLOR_ORANGE = 0xFF8800;
    private var COLOR_CYAN = 0x66D9E8;
    private var COLOR_PANEL_EDGE = 0x333333;
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

    // Main update loop. The drawing order is intentional: vector shell first,
    // then dynamic complications, then the central time/date stack.
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var stats = System.getSystemStats();
        var battery = stats.battery;
        var info = ActivityMonitor.getInfo();

        drawVectorBackground(dc);
        drawOuterTicks(dc);
        drawBatteryGauge(dc, battery);
        drawHeader(dc, battery);

        drawLeftStack(dc);
        drawRightStack(dc, info);

        drawMainTime(dc);
        drawDateStrip(dc);
    }

    /**
     * Draw the clean vector-only background shell.
     *
     * Bitmap/static backgrounds and near-black panel fills look good on paper,
     * but the fenix 7X MIP simulator can dither them into noisy speckles. Keep
     * all large surfaces exact black and use only thin gray/orange strokes for
     * structure.
     */
    private function drawVectorBackground(dc as Dc) as Void {
        drawStaticShell(dc);
        drawSidePodFrames(dc);
        drawCenterColumnGuides(dc);
    }

    /**
     * Static background structure.
     *
     * The face keeps the Fenix-inspired instrument layout while avoiding any
     * filled navy/gray blocks that can dither on Garmin's 64-color MIP display.
     */
    private function drawStaticShell(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(SCREEN_CENTER, SCREEN_CENTER, 121);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(SCREEN_CENTER, SCREEN_CENTER, 113);

        dc.setPenWidth(1);
        dc.setColor(COLOR_PANEL_EDGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(SCREEN_CENTER, SCREEN_CENTER, 113);
        dc.drawCircle(SCREEN_CENTER, SCREEN_CENTER, 121);

        // Horizontal orange cardinal cuts like the reference image.
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, 140, 18, 140);
        dc.drawLine(262, 140, 280, 140);
    }

    /** Draw four side complication pods with black interiors and thin outlines. */
    private function drawSidePodFrames(dc as Dc) as Void {
        drawSidePodFrame(dc, 10, 74, 62, 46, true);
        drawSidePodFrame(dc, 208, 74, 62, 46, false);
        drawSidePodFrame(dc, 10, 162, 62, 46, true);
        drawSidePodFrame(dc, 208, 162, 62, 46, false);
    }

    /** Draw subtle center guides without using filled panel color. */
    private function drawCenterColumnGuides(dc as Dc) as Void {
        dc.setColor(COLOR_PANEL_EDGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(82, 72, 93, 91);
        dc.drawLine(198, 72, 187, 91);
        dc.drawLine(82, 208, 93, 189);
        dc.drawLine(198, 208, 187, 189);
    }

    /** Draw one outline-only pod with a clipped-looking diagonal inner edge. */
    private function drawSidePodFrame(dc as Dc, x as Number, y as Number, w as Number, h as Number, leftSide as Boolean) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(x, y, w, h, 6);

        dc.setColor(COLOR_PANEL_EDGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(x, y, w, h, 6);

        // Inner diagonal edge echoes the angled side panels in the reference.
        if (leftSide) {
            dc.drawLine(x + w, y + 4, x + w - 10, y + h - 4);
        } else {
            dc.drawLine(x, y + 4, x + 10, y + h - 4);
        }
    }

    /** Draw outer minute/hour tick marks, with orange quarter-hour anchors. */
    private function drawOuterTicks(dc as Dc) as Void {
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;
        var outerR = 134;
        var innerR = 129;

        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);

            if (i % 15 == 0) {
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(3);
                dc.drawLine(
                    cx + 119 * Math.cos(angle), cy + 119 * Math.sin(angle),
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
        var segments = 27;
        var filled = ((battery / 100.0) * segments).toNumber();
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;

        dc.setPenWidth(4);
        for (var i = 0; i < segments; i++) {
            // Top-left to top-right arc only.
            var angle = Math.toRadians(218 + (i * 3.9));
            if (i < filled) {
                dc.setColor(i < 8 ? COLOR_CYAN : COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(
                cx + 114 * Math.cos(angle), cy + 114 * Math.sin(angle),
                cx + 123 * Math.cos(angle), cy + 123 * Math.sin(angle)
            );
        }
    }

    /** Battery icon, percentage, and FENIX label. */
    private function drawHeader(dc as Dc, battery) as Void {
        var x = 109;
        var y = 35;

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, 17, 8);
        dc.drawLine(x + 18, y + 3, x + 21, y + 3);
        dc.drawLine(x + 18, y + 5, x + 21, y + 5);
        dc.drawText(135, 39, Graphics.FONT_XTINY, battery.toNumber().format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(SCREEN_CENTER, 61, Graphics.FONT_SMALL, "FENIX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Left complication stack: run, HR, bike. */
    private function drawLeftStack(dc as Dc) as Void {
        drawMountainIcon(dc, 41, 83);
        drawMetricInPod(dc, 41, 101, "RUN", getWeeklyRunDistanceLabel());

        drawRoundDial(dc, 55, 141, 20, "HR", getHeartRateLabel(), getHeartRateProgress());
        drawHeartIcon(dc, 55, 128);

        drawBikeIcon(dc, 41, 191);
        drawMetricInPod(dc, 41, 207, "BIKE", getWeeklyBikeDistanceLabel());
    }

    /** Right complication stack: weather, steps, calories. */
    private function drawRightStack(dc as Dc, info as ActivityMonitor.Info) as Void {
        drawWeatherIcon(dc, 239, 83);
        drawMetricInPod(dc, 239, 101, "TEMP", getWeatherTemperatureLabel());

        var steps = info.steps != null ? info.steps : 0;
        var stepGoal = (info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var progress = steps.toFloat() / stepGoal.toFloat();
        drawRoundDial(dc, 225, 141, 20, "STEP", formatSteps(steps), progress);
        drawFootstepsIcon(dc, 225, 128);

        var calories = info.calories != null ? info.calories : 0;
        drawFlameIcon(dc, 239, 191);
        drawMetricInPod(dc, 239, 207, "CAL", calories.toString());
    }

    /** Two-line side metric inside a pod. */
    private function drawMetricInPod(dc as Dc, x as Number, y as Number, label as String, value as String) as Void {
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 8, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 4, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Shared circular dial renderer for heart rate and steps. */
    private function drawRoundDial(dc as Dc, cx as Number, cy as Number, radius as Number, label as String, value as String, progress as Float) as Void {
        if (progress > 1.0) { progress = 1.0; }
        if (progress < 0.0) { progress = 0.0; }

        dc.setPenWidth(3);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 145, 282);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 286, 286 - (progress * 166).toNumber());

        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 1, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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

        // Built-in Garmin fonts are much wider than the reference digits.
        // FONT_NUMBER_HOT is the best readable compromise without bitmap digits.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(92, 71, 96, 125);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 100, Graphics.FONT_NUMBER_HOT, hourStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 153, Graphics.FONT_NUMBER_HOT, minStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawSecondsBubble(dc, SCREEN_CENTER, 191, secStr);
    }

    /** Small seconds bubble at the bottom of the minute digits. */
    private function drawSecondsBubble(dc as Dc, cx as Number, cy as Number, seconds as String) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(cx - 20, cy - 20, 40, 40);

        dc.setPenWidth(2);
        dc.setColor(COLOR_PANEL_EDGE, Graphics.COLOR_TRANSPARENT);
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

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(76, 211, 128, 37);

        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(102, 220, Graphics.FONT_XTINY, dateInfo.month.toUpper(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(178, 220, Graphics.FONT_XTINY, dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_PANEL_EDGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(88, 228, 192, 228);

        for (var i = 0; i < 7; i++) {
            dc.setColor(i == selected ? COLOR_ORANGE : COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + (i * 19), 239, Graphics.FONT_XTINY, letters[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function getHeartRateLabel() as String {
        var hrValue = getHeartRateValue();
        return hrValue == null ? "--" : hrValue.toString();
    }

    private function getHeartRateProgress() as Float {
        var hrValue = getHeartRateValue();
        return hrValue == null ? 0.0 : hrValue.toFloat() / 180.0;
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
     * Connect IQ exposes recent aggregate daily distance from ActivityMonitor,
     * but not completed-activity totals split by sport. This is a rolling
     * weekly distance approximation until a settings/companion-fed run total is
     * added.
     */
    private function getWeeklyRunDistanceKm() {
        return getRollingActivityDistanceKm();
    }

    /**
     * Public watch-face APIs do not expose weekly cycling distance by sport.
     * Keep the UI honest and show -- instead of inventing a value.
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

    // Lightweight vector icons. Bitmap assets would be the next fidelity step,
    // but these keep the project buildable as a single-source change.
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
