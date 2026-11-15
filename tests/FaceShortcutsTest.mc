import Toybox.Complications;
import Toybox.Test;

(:test)
function shortcutsMatchVisibleFields(logger) {
    var shortcuts = new FaceShortcuts();
    Test.assertEqual(shortcuts.typeAt(92, 172), Complications.COMPLICATION_TYPE_STEPS);
    Test.assertEqual(shortcuts.typeAt(188, 172), Complications.COMPLICATION_TYPE_HEART_RATE);
    Test.assertEqual(shortcuts.typeAt(140, 62), Complications.COMPLICATION_TYPE_BATTERY);
    Test.assertEqual(shortcuts.typeAt(140, 40), Complications.COMPLICATION_TYPE_DATE);
    Test.assertEqual(shortcuts.typeAt(140, 235), Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
    Test.assertEqual(shortcuts.typeAt(45, 215), Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE);
    Test.assert(shortcuts.typeAt(235, 215) == null); // no invented swim provider
    Test.assert(shortcuts.typeAt(140, 103) == null); // time isn't a training shortcut
    Test.assert(shortcuts.typeAt(0, 0) == null);
    return true;
}
