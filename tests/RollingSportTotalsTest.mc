import Toybox.Activity;
import Toybox.Test;

(:test)
function trailingSevenDays(logger) {
    var now = 1800000000;
    var totals = new RollingSportTotals(now);
    // Unsorted records, including the exact expiry boundary and a future record.
    totals.add(Activity.SPORT_RUNNING, now - 604799, 5000);
    totals.add(Activity.SPORT_CYCLING, now - 86400, 42000);
    totals.add(Activity.SPORT_RUNNING, now - 604800, 99999);
    totals.add(Activity.SPORT_SWIMMING, now - 100, 2500);
    totals.add(Activity.SPORT_RUNNING, now, 3000);
    totals.add(Activity.SPORT_RUNNING, now + 1, 99999);
    totals.add(Activity.SPORT_WALKING, now, 99999);
    var result = totals.result();
    Test.assertEqual(result[:run], 8000.0);
    Test.assertEqual(result[:bike], 42000.0);
    Test.assertEqual(result[:swim], 2500.0);
    Test.assertEqual(totals.expiresAt(), now + 1);
    // Advance two seconds: the old 5km run must disappear without a Monday reset.
    var later = new RollingSportTotals(now + 2);
    later.add(Activity.SPORT_RUNNING, now - 604799, 5000);
    later.add(Activity.SPORT_RUNNING, now, 3000);
    Test.assertEqual(later.result()[:run], 3000.0);
    return true;
}

(:test)
function uncertainSportIsNotZero(logger) {
    var now = 1800000000;
    var totals = new RollingSportTotals(now);
    totals.add(Activity.SPORT_RUNNING, null, 5000);
    totals.add(Activity.SPORT_RUNNING, now, 3000);
    totals.add(Activity.SPORT_CYCLING, now - 100, null);
    totals.add(Activity.SPORT_SWIMMING, now - 100, 0);
    var result = totals.result();
    Test.assert(result[:run] == null);
    Test.assert(result[:bike] == null);
    Test.assertEqual(result[:swim], 0.0);
    // Known old data is excluded; a suspicious legacy epoch is never silently zero.
    var old = new RollingSportTotals(now);
    old.add(Activity.SPORT_RUNNING, now - 604801, null);
    Test.assertEqual(old.result()[:run], 0.0);
    old.add(Activity.SPORT_RUNNING, now - 631065600, 1000);
    Test.assert(old.result()[:run] == null);
    return true;
}
