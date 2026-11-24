import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Fenix7XVibeFaceView extends WatchUi.WatchFace {
    private var _data;
    private var _layout as Number = -1;
    private var _renderer as FaceRenderer? = null;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
    }

    function onUpdate(dc as Dc) as Void {
        var layout = FaceLayouts.selected();
        if (_layout != layout) {
            _layout = layout;
            _renderer = FaceLayouts.renderer(layout);
        }

        var data = _data.snapshot() as Dictionary;
        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        data[:day] = date.day_of_week.toUpper();
        data[:monthDay] = date.day.format("%02d") + " " + date.month.toUpper();
        data[:date] = data[:day] + " " + data[:monthDay];

        var clock = System.getClockTime();
        var rawHour = data[:preview] ? data[:hour] : clock.hour;
        var minute = data[:preview] ? data[:minute] : clock.min;
        var hour = rawHour;
        var period = "";
        if (!System.getDeviceSettings().is24Hour) {
            hour = (rawHour + 11) % 12 + 1;
            period = rawHour >= 12 ? "PM" : "AM";
        }
        data[:rawHour] = rawHour;
        data[:minute] = minute;
        data[:hours] = hour.format("%02d");
        data[:minutes] = minute.format("%02d");
        data[:period] = period;

        (_renderer as FaceRenderer).render(dc, data, layout);
    }

    function onShow() as Void { _data.invalidate(); }
    function onEnterSleep() as Void { WatchUi.requestUpdate(); }
    function onExitSleep() as Void { WatchUi.requestUpdate(); }
}
