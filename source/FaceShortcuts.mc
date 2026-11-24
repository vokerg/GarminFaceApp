import Toybox.Complications;
import Toybox.Lang;
import Toybox.WatchUi;

class FaceShortcuts extends WatchUi.WatchFaceDelegate {
    private const TYPES = [Complications.COMPLICATION_TYPE_DATE, Complications.COMPLICATION_TYPE_BATTERY,
        Complications.COMPLICATION_TYPE_STEPS, Complications.COMPLICATION_TYPE_HEART_RATE];
    private const SPORT_TYPES = [
        Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE,
        Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE,
        null
    ];

    // Rectangles are [left, top, right, bottom] for date, battery, steps, HR, then activity rank.
    private const REGIONS = [
        [[14, 80, 77, 126], [207, 80, 257, 133], [56, 166, 125, 212], [155, 166, 224, 212], [104, 216, 176, 268], [41, 220, 102, 259], [178, 220, 239, 259]],
        [[65, 27, 215, 53], [154, 61, 238, 103], [154, 104, 238, 144], [154, 145, 238, 185], [107, 209, 173, 261], [39, 209, 105, 257], [175, 209, 241, 257]],
        [[65, 25, 215, 45], [176, 46, 245, 75], [63, 214, 118, 260], [162, 214, 217, 260], [19, 82, 261, 147], [43, 155, 114, 199], [166, 155, 237, 199]],
        [[65, 25, 215, 46], [39, 82, 87, 202], [116, 82, 164, 202], [193, 82, 241, 202], [108, 214, 172, 260], [43, 214, 104, 255], [176, 214, 237, 255]],
        [[65, 25, 215, 48], [32, 105, 100, 159], [106, 105, 174, 159], [180, 105, 248, 159], [106, 172, 174, 226], [32, 172, 100, 226], [180, 172, 248, 226]],
        [[60, 25, 220, 58], [50, 208, 98, 251], [108, 208, 172, 251], [182, 208, 230, 251], [69, 144, 211, 174], [42, 176, 123, 198], [157, 176, 238, 198]],
        [[66, 37, 214, 58], [88, 59, 192, 80], [59, 140, 122, 179], [158, 140, 221, 179], [103, 184, 176, 254], [44, 184, 101, 229], [179, 184, 236, 229]],
        [[50, 27, 134, 53], [150, 27, 230, 55], [39, 184, 127, 214], [153, 184, 241, 214], [110, 215, 170, 255], [50, 215, 107, 255], [173, 215, 230, 255]]
    ];

    function initialize() { WatchFaceDelegate.initialize(); }

    // Coordinates share the renderer's 280px device space. Touch-and-hold only;
    // ordinary taps and unsupported fields remain under the system's control.
    function typeAt(x, y, layout, sportOrder as Lang.Array<Lang.Number>) {
        if (layout == FaceLayouts.EMBER) { return emberTypeAt(x, y, sportOrder); }
        var regions = REGIONS[layout - 1];
        for (var i = 0; i < regions.size(); i++) {
            var r = regions[i];
            if (x >= r[0] && y >= r[1] && x <= r[2] && y <= r[3]) {
                return i < TYPES.size() ? TYPES[i] : SPORT_TYPES[sportOrder[i - TYPES.size()]];
            }
        }
        return null;
    }

    private function emberTypeAt(x, y, sportOrder as Lang.Array<Lang.Number>) {
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
            return SPORT_TYPES[sportOrder[SportOrder.PRIMARY]];
        }
        if (x >= 22 && x <= 85 && y >= 190 && y <= 245) {
            return SPORT_TYPES[sportOrder[SportOrder.SECONDARY]];
        }
        if (x >= 195 && x <= 258 && y >= 190 && y <= 245) {
            return SPORT_TYPES[sportOrder[SportOrder.TERTIARY]];
        }
        return null;
    }

    function onPress(event as WatchUi.ClickEvent) as Lang.Boolean {
        var point = event.getCoordinates();
        var type = typeAt(point[0], point[1], FaceLayouts.selected(), SportOrder.selected());
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
