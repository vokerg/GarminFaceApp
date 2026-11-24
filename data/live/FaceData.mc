import Toybox.ActivityMonitor;
import Toybox.System;
import Toybox.Time;
import Toybox.Lang;
import Toybox.UserProfile;

// All access to daily metrics lives here. Renderer never fetches sport totals.
class FaceData {
    private var _sports = { :run => null, :bike => null, :swim => null };
    private var _expires = 0;
    private var _lastRead = 0;

    function invalidate() as Void { _expires = 0; }

    private function sports(now) as Lang.Dictionary {
        if (now < _expires && now >= _lastRead) { return _sports; }
        var totals = new RollingSportTotals(now);
        var history = UserProfile.getUserActivityHistory() as UserProfile.UserActivityHistoryIterator?;
        if (history == null) {
            _sports = { :run => null, :bike => null, :swim => null };
            _expires = now + 900;
        } else {
            var activity = history.next();
            while (activity != null) {
                totals.add(activity.type, activity.startTime == null ? null : activity.startTime.value(), activity.distance);
                activity = history.next();
            }
            _sports = totals.result();
            _expires = totals.expiresAt();
        }
        _lastRead = now;
        return _sports;
    }

    function snapshot() {
        var now = Time.now().value();
        var distances = sports(now);
        var info = ActivityMonitor.getInfo();
        var hr = null;
        var samples = ActivityMonitor.getHeartRateHistory(new Time.Duration(600), true);
        var sample = samples.next();
        while (sample != null) {
            if (sample.heartRate != null && sample.heartRate > 0 && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE &&
                sample.when != null && now - sample.when.value() >= 0 && now - sample.when.value() <= 600) {
                hr = sample.heartRate;
                break;
            }
            sample = samples.next();
        }
        return {
            :battery => System.getSystemStats().battery,
            :steps => info.steps,
            :goal => info.stepGoal,
            :hr => hr,
            :maxHr => hr == null ? null : maxHeartRate(),
            :run => distances[:run],
            :bike => distances[:bike],
            :swim => distances[:swim],
            :preview => false
        };
    }

    private function maxHeartRate() {
        // The API exposes the generic zone 5 upper threshold in BPM.
        var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        if (zones == null || zones.size() < 6) { return null; }
        var upper = zones[5];
        return upper != null && upper > 0 ? upper : null;
    }
}
