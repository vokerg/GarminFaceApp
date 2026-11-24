import Toybox.Application.Storage;
import Toybox.Lang;

module SportOrder {
    const KEY = "SportOrder";
    const PRIMARY = 0;
    const SECONDARY = 1;
    const TERTIARY = 2;
    const RUN = 0;
    const BIKE = 1;
    const SWIM = 2;
    const DEFAULT = [RUN, BIKE, SWIM];
    const METRICS = [:run, :bike, :swim];
    const NAMES = ["Run", "Bike", "Swim"];
    const RANKS = ["Primary", "Secondary", "Tertiary"];

    function selected() as Array<Number> {
        var saved = Storage.getValue(KEY);
        if (saved instanceof Array && saved.size() == 3 &&
            DEFAULT.indexOf(saved[0]) >= 0 && DEFAULT.indexOf(saved[1]) >= 0 && DEFAULT.indexOf(saved[2]) >= 0 &&
            saved[0] != saved[1] && saved[0] != saved[2] && saved[1] != saved[2]) {
            return saved as Array<Number>;
        }
        return DEFAULT;
    }

    function swapped(order as Array<Number>, rank as Number, sport as Number) as Array<Number> {
        var next = [order[0], order[1], order[2]];
        next[order.indexOf(sport)] = order[rank];
        next[rank] = sport;
        return next;
    }
}
