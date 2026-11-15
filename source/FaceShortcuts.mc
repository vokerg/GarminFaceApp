import Toybox.Complications;
import Toybox.Lang;
import Toybox.WatchUi;

class FaceShortcuts extends WatchUi.WatchFaceDelegate {
    function initialize() { WatchFaceDelegate.initialize(); }

    // Coordinates share the renderer's 280px device space. Touch-and-hold only;
    // ordinary taps and unsupported fields remain under the system's control.
    function typeAt(x, y) {
        if (x >= 65 && x <= 215 && y >= 50 && y <= 74) {
            return Complications.COMPLICATION_TYPE_BATTERY;
        }
        if (x >= 65 && x <= 215 && y >= 27 && y < 50) {
            return Complications.COMPLICATION_TYPE_DATE;
        }
        if ((x - 92) * (x - 92) + (y - 172) * (y - 172) <= 1296) {
            return Complications.COMPLICATION_TYPE_STEPS;
        }
        if ((x - 188) * (x - 188) + (y - 172) * (y - 172) <= 1296) {
            return Complications.COMPLICATION_TYPE_HEART_RATE;
        }
        if (x >= 95 && x <= 185 && y >= 207 && y <= 253) {
            return Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE;
        }
        if (x >= 22 && x <= 85 && y >= 190 && y <= 245) {
            return Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE;
        }
        return null;
    }

    function onPress(event as WatchUi.ClickEvent) as Lang.Boolean {
        var point = event.getCoordinates();
        var type = typeAt(point[0], point[1]);
        if (type == null) { return false; }
        try {
            Complications.exitTo(new Complications.Id(type));
            return true;
        } catch (error) {
            // Native provider unavailable (or launching prohibited during an
            // activity). Keep the watch face usable rather than crash.
            return false;
        }
    }
}
