import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

module FaceColors {
    const ACCENT = "AccentColor";
    const RING = "RingColor";
    const PALETTE = [
        ["Orange", 0xFF5500],
        ["Gold", 0xFFAA00],
        ["Red", 0xFF5555],
        ["Green", 0x55FF55],
        ["Cyan", 0x55FFFF],
        ["Blue", 0x55AAFF],
        ["Violet", 0xAA55FF],
        ["Pink", 0xFF55AA]
    ];

    function selectedIndex(key as String) as Number {
        var saved = Storage.getValue(key);
        if (saved instanceof Number && saved >= 0 && saved < PALETTE.size()) {
            return saved;
        }
        return key.equals(RING) ? 1 : 0;
    }

    function color(key as String) as Number {
        return PALETTE[selectedIndex(key)][1];
    }
}

class FaceColorSettings extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Face Colors"});
        addItem(new WatchUi.MenuItem("Accent Color", FaceColors.PALETTE[FaceColors.selectedIndex(FaceColors.ACCENT)][0], FaceColors.ACCENT, null));
        addItem(new WatchUi.MenuItem("Ring Color", FaceColors.PALETTE[FaceColors.selectedIndex(FaceColors.RING)][0], FaceColors.RING, null));
    }
}

class FaceColorSettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        var menu = new WatchUi.Menu2({:title => item.getLabel()});
        for (var i = 0; i < FaceColors.PALETTE.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(FaceColors.PALETTE[i][0], null, i, null));
        }
        menu.setFocus(FaceColors.selectedIndex(key));
        WatchUi.pushView(menu, new FaceColorChoiceDelegate(item), WatchUi.SLIDE_IMMEDIATE);
    }
}

class FaceColorChoiceDelegate extends WatchUi.Menu2InputDelegate {
    private var _setting as WatchUi.MenuItem;

    function initialize(setting as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _setting = setting;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Storage.setValue(_setting.getId() as String, item.getId() as Number);
        _setting.setSubLabel(item.getLabel());
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
