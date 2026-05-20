import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

/*
 * A refined take on the Fenixâ€‘style watch face from the original proof of concept.
 *
 * This version is tuned for readability on ConnectÂ IQ 64â€‘colour MIP displays.  Rather
 * than trying to paint large blocks of colour, the layout is organised with
 * subtle vertical and horizontal divider lines.  These guides group the
 * complications without introducing large filled areas that quantise badly on
 * lowâ€‘colour screens.  The central time remains the dominant element, with
 * hours rendered in white and minutes in orange.  The weekâ€™s running distance,
 * weekly cycling distance, current heart rate, steps, temperature, and
 * calories are displayed in neat compartments around the edges.  A segmented
 * battery gauge arcs across the top like the reference face.  Date and
 * weekday strip run along the bottom.
 */
class Fenix7XVibeFaceViewRefined extends WatchUi.WatchFace {

    // Palette tuned for MIP readability.  Avoid nearâ€‘black fills: use pure
    // black for large areas and mid greys for outlines.  Keep accent colours
    // saturated so they remain distinguishable after palette quantisation.
    private var COLOR_ORANGE   = 0xFF8800;
    private var COLOR_CYAN     = 0x66D9E8;
    private var COLOR_DK_GRAY  = 0x444444;
    private var COLOR_LT_GRAY  = 0xAAAAAA;

    private var SCREEN_CENTER = 140;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {}
    function onShow() as Void {}

    /**
     * Main drawing entry point.  Clears the screen, draws the static guides,
     * renders the data values in their compartments and finally draws the
     * stacked time and date strip.  The order of drawing is chosen to
     * minimise overdraw on the lowâ€‘power MIP screen.
     */
    function onUpdate(dc as Dc) as Void {
        // Clear background to black
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var stats   = System.getSystemStats();
        var battery = stats.battery;
        var info    = ActivityMonitor.getInfo();

        drawGuides(dc);
        drawOuterTicks(dc);
        drawBatteryGauge(dc, battery);
        drawHeader(dc, battery);

        // Top compartments: weekly run distance and weather
        drawRunCompartment(dc);
        drawWeatherCompartment(dc);

        // Middle compartments: heart rate and steps
        drawHeartRateDial(dc);
        drawStepsDial(dc, info);

        // Bottom compartments: weekly bike distance and calories
        drawBikeCompartment(dc);
        drawCaloriesCompartment(dc, info);

        // Central time and date
        drawMainTime(dc);
        drawDateStrip(dc);
    }

    /**
     * Draw reference-style side-panel hints without a full grid.
     *
     * The previous refined version drew horizontal and vertical guide lines
     * across the whole display. In the simulator that made the face look like a
     * spreadsheet, not like the original Fenix design. This version keeps only
     * subtle side-zone separators and angled inner edges, leaving the central
     * time column completely clean.
     */
    private function drawGuides(dc as Dc) as Void {
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Inner dial rings: quiet structure without rectangular grid lines.
        dc.drawCircle(SCREEN_CENTER, SCREEN_CENTER, 112);
        dc.drawCircle(SCREEN_CENTER, SCREEN_CENTER, 121);

        // Left side panel separators. These stay out of the central time zone.
        dc.drawLine(0, 70, 76, 70);
        dc.drawLine(0, 125, 76, 125);
        dc.drawLine(0, 180, 76, 180);
        dc.drawLine(0, 210, 76, 210);

        // Right side panel separators.
        dc.drawLine(204, 70, 280, 70);
        dc.drawLine(204, 125, 280, 125);
        dc.drawLine(204, 180, 280, 180);
        dc.drawLine(204, 210, 280, 210);

        // Angled inner edges echo the reference side wedges without fills.
        dc.drawLine(76, 70, 92, 92);
        dc.drawLine(76, 125, 92, 112);
        dc.drawLine(76, 180, 92, 168);
        dc.drawLine(76, 210, 92, 188);

        dc.drawLine(204, 70, 188, 92);
        dc.drawLine(204, 125, 188, 112);
        dc.drawLine(204, 180, 188, 168);
        dc.drawLine(204, 210, 188, 188);

        // Horizontal cardinal cuts, like the reference.
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, 140, 17, 140);
        dc.drawLine(263, 140, 280, 140);
    }

    /**
     * Draw minute and hour tick marks around the edge of the circular face.
     * Orange marks every quarter hour, lighter grey for fiveâ€‘minute ticks and
     * dark grey for single minutes.  This matches the reference faceâ€™s
     * radial scale.
     */
    private function drawOuterTicks(dc as Dc) as Void {
        var cx     = SCREEN_CENTER;
        var cy     = SCREEN_CENTER;
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

    /**
     * Draw the top segmented battery gauge.  Low battery segments are
     * cyan, transitioning to orange for the remaining capacity.  The
     * reference faceâ€™s gauge has 26 bars spanning from roughly 220Â° to 320Â°.
     */
    private function drawBatteryGauge(dc as Dc, battery) as Void {
        var segments = 26;
        var filled   = ((battery / 100.0) * segments).toNumber();
        var cx       = SCREEN_CENTER;
        var cy       = SCREEN_CENTER;
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

    /**
     * Draw the small header at the top centre: a battery icon, battery
     * percentage, and the FENIX label.  Percentage is leftâ€‘aligned next to
     * the battery icon, and the label sits below it centred on the face.
     */
    private function drawHeader(dc as Dc, battery) as Void {
        var x = 111;
        var y = 33;
        // Battery icon outline
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, 17, 9);
        dc.drawLine(x + 18, y + 3, x + 21, y + 3);
        dc.drawLine(x + 18, y + 6, x + 21, y + 6);
        // Battery percentage
        dc.drawText(136, 38, Graphics.FONT_XTINY, battery.toNumber().format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        // FENIX label
        dc.drawText(SCREEN_CENTER, 62, Graphics.FONT_SMALL, "FENIX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /** Draw the weekly running distance in the top left compartment. */
    private function drawRunCompartment(dc as Dc) as Void {
        var cx = 35;
        var cy = 88;
        drawMountainIcon(dc, cx, cy);
        drawSmallMetric(dc, cx, cy + 21, "RUN", getWeeklyRunDistanceLabel());
    }

    /** Draw the weather (temperature) in the top right compartment. */
    private function drawWeatherCompartment(dc as Dc) as Void {
        var cx = 245;
        var cy = 88;
        drawWeatherIcon(dc, cx, cy);
        drawSmallMetric(dc, cx, cy + 21, "TEMP", getWeatherTemperatureLabel());
    }

    /** Draw the weekly cycling distance in the bottom left compartment. */
    private function drawBikeCompartment(dc as Dc) as Void {
        var cx = 35;
        var cy = 198;
        drawBikeIcon(dc, cx, cy);
        drawSmallMetric(dc, cx, cy + 20, "BIKE", getWeeklyBikeDistanceLabel());
    }

    /** Draw the calories burned in the bottom right compartment. */
    private function drawCaloriesCompartment(dc as Dc, info as ActivityMonitor.Info) as Void {
        var cx      = 245;
        var cy      = 198;
        var calories = info.calories != null ? info.calories : 0;
        drawFlameIcon(dc, cx, cy);
        drawSmallMetric(dc, cx, cy + 20, "CAL", calories.toString());
    }

    /** Draw the heart rate dial in the middle left compartment. */
    private function drawHeartRateDial(dc as Dc) as Void {
        var hrValue  = getHeartRateValue();
        var label    = hrValue == null ? "--" : hrValue.toString();
        var progress = hrValue == null ? 0.0 : hrValue.toFloat() / 180.0;
        drawRoundDial(dc, 53, 147, 20, "HR", label, progress);
        drawHeartIcon(dc, 53, 133);
    }

    /** Draw the steps dial in the middle right compartment. */
    private function drawStepsDial(dc as Dc, info as ActivityMonitor.Info) as Void {
        var steps    = info.steps != null ? info.steps : 0;
        var stepGoal = (info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var progress = steps.toFloat() / stepGoal.toFloat();
        drawRoundDial(dc, 227, 147, 20, "STEP", formatSteps(steps), progress);
        drawFootstepsIcon(dc, 227, 133);
    }

    /**
     * Render a twoâ€‘line metric label/value pair.  The label is tiny grey
     * text, while the value is orange.  Both lines are horizontally centred
     * on the provided x coordinate.  This helper is reused for the run, bike
     * weather and calories compartments.
     */
    private function drawSmallMetric(dc as Dc, x as Number, y as Number, label as String, value as String) as Void {
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 9, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 2, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /**
     * Draw a circular dial for the heart rate and steps complications.  The
     * dial has a grey background circle, a cyan accent arc, an orange
     * progress arc and centred text.  The arcs sweep clockwise.
     */
    private function drawRoundDial(dc as Dc, cx as Number, cy as Number, radius as Number, label as String, value as String, progress as Float) as Void {
        if (progress > 1.0) { progress = 1.0; }
        if (progress < 0.0) { progress = 0.0; }
        dc.setPenWidth(3);
        // Outer circle
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);
        // Cyan accent arc (static)
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 145, 280);
        // Orange progress arc
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 285, 285 - (progress * 170).toNumber());
        // Label and value
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 10, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /**
     * Draw the stacked central time: hours in white, minutes in orange, and
     * seconds in a small bubble below the minutes.  Using FONT_NUMBER_HOT
     * instead of FONT_NUMBER_THAI_HOT keeps the size manageable on fenix
     * devices.  Adjust the vertical offsets carefully to avoid overlap with
     * the side complications.
     */
    private function drawMainTime(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hour      = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var hourStr = hour.format("%d");
        var minStr  = clockTime.min.format("%02d");
        var secStr  = clockTime.sec.format("%02d");
        // Hour
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 106, Graphics.FONT_NUMBER_HOT, hourStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // Minutes
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(SCREEN_CENTER, 158, Graphics.FONT_NUMBER_HOT, minStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // Seconds bubble
        drawSecondsBubble(dc, SCREEN_CENTER, 194, secStr);
    }

    /**
     * Draw the seconds bubble underneath the minutes.  The circle with tick
     * marks echoes the reference face.  An "S" label appears above the
     * seconds value.  Orange ticks highlight every third mark.
     */
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

    /**
     * Draw the date and weekday strip near the bottom of the face.  The
     * month abbreviation and day number sit left and right of the central
     * column.  The weekday letters are evenly spaced across the width.
     */
    private function drawDateStrip(dc as Dc) as Void {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var selected = weekdayIndex(dateInfo.day_of_week.toUpper());
        var letters  = [ "S", "M", "T", "W", "T", "F", "S" ];
        // Month abbreviation aligned to the left of the central column
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(100, 223, Graphics.FONT_XTINY, dateInfo.month.toUpper(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        // Day number aligned to the right of the central column
        dc.drawText(180, 223, Graphics.FONT_XTINY, dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        // Weekday strip
        var startX = 63;
        for (var i = 0; i < 7; i++) {
            dc.setColor(i == selected ? COLOR_ORANGE : COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + (i * 23), 238, Graphics.FONT_XTINY, letters[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    /** Return latest valid heart rate sample from history. */
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

    /** Get the current temperature in Celsius. */
    private function getWeatherTemperatureLabel() as String {
        if ((Toybox has :Weather) && (Toybox.Weather has :getCurrentConditions)) {
            var current = Weather.getCurrentConditions();
            if (current != null && current.temperature != null) {
                return current.temperature.toNumber().format("%d") + "Â°";
            }
        }
        return "--Â°";
    }

    private function getWeeklyRunDistanceLabel() as String {
        var km = getWeeklyRunDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    private function getWeeklyBikeDistanceLabel() as String {
        var km = getWeeklyBikeDistanceKm();
        return km == null ? "--" : formatDistanceKm(km);
    }

    /** Use the sum of the most recent seven days of ActivityMonitor history for
     * weekly running distance.  Garmin does not currently expose sportâ€‘split
     * totals to watch faces, so this approximation is the best available on
     * device.  If history is unavailable, return null.
     */
    private function getWeeklyRunDistanceKm() {
        return getRollingActivityDistanceKm();
    }

    /** Weekly cycling distance is not available on device.  Returning null
     * prevents the UI from showing fictitious data.  In a future version
     * this could be supplied via a settings property or companion app.
     */
    private function getWeeklyBikeDistanceKm() {
        return null;
    }

    /** Sum the ActivityMonitor history distance fields and convert to km. */
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
        if (day == "SUN" || day == "SUNDAY")   { return 0; }
        if (day == "MON" || day == "MONDAY")   { return 1; }
        if (day == "TUE" || day == "TUESDAY") { return 2; }
        if (day == "WED" || day == "WEDNESDAY") { return 3; }
        if (day == "THU" || day == "THURSDAY") { return 4; }
        if (day == "FRI" || day == "FRIDAY")   { return 5; }
        if (day == "SAT" || day == "SATURDAY") { return 6; }
        return -1;
    }

    /** Lightweight vector icons.  These avoid adding bitmap resources and
     * keep the code easy to tweak.  Colours match the accent palette.
     */
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
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
