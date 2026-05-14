import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {

    // Tactical Color Palette (64-color safe)
    private var COLOR_ORANGE = 0xFF5500;
    private var COLOR_DK_GRAY = 0x555555;
    private var COLOR_LT_GRAY = 0xAAAAAA;

    // Layout Constants
    private var SCREEN_CENTER = 140;
    private var WIDGET_RADIUS = 26;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    // Main update loop
    function onUpdate(dc as Dc) as Void {
        // 1. Clear Screen (Black background)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // 2. Draw Outer Ticks (r=124-128)
        drawOuterTicks(dc);

        // 3. Draw Main Time
        drawMainTime(dc);

        // 4. Draw Date Panel
        drawDatePanel(dc);

        // 5. Draw 3 Circular Widgets (Left side)
        // Standardized spacing and radius for tactical balance
        
        var stats = System.getSystemStats();
        var battery = stats.battery;
        var info = ActivityMonitor.getInfo();
        
        // Widget 1: Battery (Top-Left)
        drawCircularWidget(dc, 85, 80, WIDGET_RADIUS, "BAT", battery.toNumber().toString(), battery / 100.0);

        // Widget 2: Steps (Mid-Left)
        var steps = info.steps != null ? info.steps : 0;
        var stepGoal = (info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var stepProgress = steps.toFloat() / stepGoal.toFloat();
        if (stepProgress > 1.0) { stepProgress = 1.0; }
        drawCircularWidget(dc, 65, 140, WIDGET_RADIUS, "STEP", formatSteps(steps), stepProgress);

        // Widget 3: Battery Redux / Placeholder (Bottom-Left)
        // Using Battery again to keep it consistent and safe (no new permissions)
        drawCircularWidget(dc, 85, 200, WIDGET_RADIUS, "BAT", battery.toNumber().toString(), battery / 100.0);
    }

    /**
     * Draw outer minute/hour tick marks.
     * Orange at 12, 3, 6, and 9 o’clock.
     */
    private function drawOuterTicks(dc as Dc) as Void {
        var cx = SCREEN_CENTER;
        var cy = SCREEN_CENTER;
        var outerR = 128;
        var innerR = 124;
        
        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);
            
            if (i % 15 == 0) {
                // 12, 3, 6, 9 positions - Thick Orange
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(3);
                var thickInnerR = 116;
                dc.drawLine(
                    cx + thickInnerR * Math.cos(angle), cy + thickInnerR * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            } else if (i % 5 == 0) {
                // Hour marks - Gray
                dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawLine(
                    cx + innerR * Math.cos(angle), cy + innerR * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            } else {
                // Minute marks - Dark Gray
                dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(1);
                dc.drawLine(
                    cx + (innerR + 2) * Math.cos(angle), cy + (innerR + 2) * Math.sin(angle),
                    cx + outerR * Math.cos(angle), cy + outerR * Math.sin(angle)
                );
            }
        }
    }

    /**
     * Standardized circular widget.
     */
    private function drawCircularWidget(dc as Dc, cx as Number, cy as Number, radius as Number, label as String, value as String, progress as Float) as Void {
        // 1. Background Arc (Gray)
        dc.setPenWidth(2);
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        // 2. Progress Arc (Orange)
        if (progress > 0) {
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            var startAngle = 90;
            var sweepAngle = (progress * 360).toNumber();
            var endAngle = startAngle - sweepAngle;
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }

        // 3. Label (Gray, above center)
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (radius * 0.55), Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Value (White, center)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 0.1), Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /**
     * Main time display.
     * Slightly reduced font (THAI_HOT) for better crowding control.
     */
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

        var centerX = SCREEN_CENTER;
        var centerY = 120; // Adjusted for better vertical balance

        // VIBE label (Tactical brand)
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 35, centerY - 40, Graphics.FONT_XTINY, "VIBE", Graphics.TEXT_JUSTIFY_LEFT);

        // Hour digits (White)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 4, centerY, Graphics.FONT_NUMBER_THAI_HOT, hourStr, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Minute digits (Orange)
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 4, centerY, Graphics.FONT_NUMBER_THAI_HOT, minStr, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Seconds (Small White) - Tucked closer to minutes
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 75, centerY + 8, Graphics.FONT_XTINY, secStr, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    /**
     * Polished date panel inward and aligned.
     */
    private function drawDatePanel(dc as Dc) as Void {
        var now = Time.now();
        var dateInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
        
        var dateX = 155; // Moved inward from 180
        var dateY = 165; // Aligned better under time

        // Divider line
        dc.setColor(COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(dateX, dateY, dateX + 70, dateY);

        // Date text (DOW DAY MONTH)
        var dateStr = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week.toUpper(), dateInfo.day, dateInfo.month.toUpper()]);
        dc.setColor(COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dateX + 2, dateY + 4, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    /**
     * Format steps with K notation.
     */
    private function formatSteps(steps as Number) as String {
        if (steps >= 1000) {
            return (steps / 1000.0).format("%.1f") + "K";
        }
        return steps.toString();
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

}
