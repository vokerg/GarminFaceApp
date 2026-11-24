import Toybox.Complications;
import Toybox.Test;
import Toybox.Lang;

(:test)
function shortcutsMatchVisibleFields(logger) {
    var shortcuts = new FaceShortcuts();
    Test.assertEqual(shortcuts.typeAt(92, 172, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_STEPS);
    Test.assertEqual(shortcuts.typeAt(188, 172, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_HEART_RATE);
    Test.assertEqual(shortcuts.typeAt(140, 62, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_BATTERY);
    Test.assertEqual(shortcuts.typeAt(140, 40, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_DATE);
    Test.assertEqual(shortcuts.typeAt(140, 235, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
    Test.assertEqual(shortcuts.typeAt(45, 215, FaceLayouts.EMBER), Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE);
    Test.assert(shortcuts.typeAt(235, 215, FaceLayouts.EMBER) == null); // no invented swim provider
    Test.assert(shortcuts.typeAt(140, 103, FaceLayouts.EMBER) == null); // time isn't a training shortcut
    Test.assert(shortcuts.typeAt(0, 0, FaceLayouts.EMBER) == null);
    return true;
}

(:test)
function conceptShortcutsFollowMetrics(logger) {
    var shortcuts = new FaceShortcuts();
    var expected = [Complications.COMPLICATION_TYPE_DATE, Complications.COMPLICATION_TYPE_BATTERY,
        Complications.COMPLICATION_TYPE_STEPS, Complications.COMPLICATION_TYPE_HEART_RATE,
        Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE, Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE];
    // Date, battery, steps, HR, run, bike, swim, time.
    var landmarks = [
        [[48, 113], [231, 113], [91, 194], [189, 194], [140, 237], [76, 228], [204, 228], [140, 99]],
        [[140, 41], [159, 87], [159, 128], [159, 169], [140, 242], [76, 233], [204, 233], [89, 89]],
        [[140, 35], [211, 56], [91, 243], [189, 243], [165, 113], [79, 187], [201, 187], [99, 60]],
        [[140, 35], [63, 177], [140, 177], [217, 177], [140, 244], [75, 236], [205, 236], [140, 62]],
        [[140, 37], [66, 139], [140, 139], [214, 139], [140, 206], [66, 206], [214, 206], [140, 74]],
        [[140, 42], [74, 220], [140, 220], [206, 220], [140, 159], [82, 187], [198, 187], [140, 100]],
        [[140, 47], [140, 67], [91, 152], [189, 152], [140, 239], [77, 213], [203, 213], [140, 107]],
        [[93, 40], [204, 40], [83, 195], [197, 195], [140, 251], [80, 240], [200, 240], [100, 89]]
    ];
    for (var i = 0; i < landmarks.size(); i++) {
        var layout = i + 1;
        for (var j = 0; j < expected.size(); j++) {
            Test.assertEqual(shortcuts.typeAt(landmarks[i][j][0], landmarks[i][j][1], layout), expected[j]);
        }
        Test.assert(shortcuts.typeAt(landmarks[i][6][0], landmarks[i][6][1], layout) == null);
        Test.assert(shortcuts.typeAt(landmarks[i][7][0], landmarks[i][7][1], layout) == null);
    }
    return true;
}
