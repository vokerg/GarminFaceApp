import Toybox.Activity;
import Toybox.Lang;

// Half-open trailing window: (now - 168h, now]. Distances are meters.
// Accept samples in any order. Never assign aggregate walking to a sport.
class RollingSportTotals {
    private var _now;
    private var _cutoff;
    private var _values as Lang.Dictionary;
    private var _expires;

    function initialize(now) {
        _now = now;
        _cutoff = now - 604800;
        _values = { :run => 0.0, :bike => 0.0, :swim => 0.0 };
        _expires = now + 900;
    }

    function add(sport, started, meters) as Void {
        var key = null;
        if (sport == Activity.SPORT_RUNNING) { key = :run; }
        else if (sport == Activity.SPORT_CYCLING) { key = :bike; }
        else if (sport == Activity.SPORT_SWIMMING) { key = :swim; }
        else { return; }

        // Unknown date makes this sport's total uncertain, not zero.
        if (started == null) { _values[key] = null; return; }
        // Reject implausibly old timestamps rather than guess an epoch correction.
        if (started < _now - 315576000) { _values[key] = null; return; }
        if (started <= _cutoff || started > _now) { return; }
        if (started + 604800 < _expires) { _expires = started + 604800; }
        if (meters == null || meters < 0) { _values[key] = null; return; }
        if (_values[key] != null) { _values[key] += meters; }
    }

    function result() as Lang.Dictionary { return _values; }
    function expiresAt() { return _expires; }
}
