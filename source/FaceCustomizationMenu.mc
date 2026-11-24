import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

class FaceCustomizationMenu extends WatchUi.Menu2 {
    private var _layoutItem as WatchUi.MenuItem;
    private var _accentItem as WatchUi.MenuItem;
    private var _gaugeItem as WatchUi.MenuItem;

    function initialize() {
        Menu2.initialize({:title => "Customize"});
        _layoutItem = new WatchUi.MenuItem("Layout", null, FaceLayouts.KEY, null);
        _accentItem = new WatchUi.MenuItem("Accent Color", null, FaceColors.ACCENT, null);
        _gaugeItem = new WatchUi.MenuItem("Gauge Color", null, FaceColors.RING, null);
        addItem(_layoutItem);
        addItem(_accentItem);
        addItem(_gaugeItem);
        refreshLabels();
    }

    function refreshLabels() as Void {
        var layout = FaceLayouts.selected();
        _layoutItem.setSubLabel(FaceLayouts.NAMES[layout]);
        _accentItem.setSubLabel(FaceColors.PALETTE[FaceColors.selectedIndex(FaceColors.ACCENT, layout)][0]);
        _gaugeItem.setSubLabel(FaceColors.PALETTE[FaceColors.selectedIndex(FaceColors.RING, layout)][0]);
    }
}

class FaceCustomizationDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as FaceCustomizationMenu;

    function initialize(menu as FaceCustomizationMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        var layout = FaceLayouts.selected();
        var options = new WatchUi.Menu2({:title => item.getLabel()});
        if (key.equals(FaceLayouts.KEY)) {
            for (var i = 0; i < FaceLayouts.NAMES.size(); i++) {
                options.addItem(new WatchUi.MenuItem(FaceLayouts.NAMES[i], null, FaceLayouts.IDS[i], null));
            }
            options.setFocus(layout);
        } else {
            for (var i = 0; i < FaceColors.PALETTE.size(); i++) {
                options.addItem(new WatchUi.MenuItem(FaceColors.PALETTE[i][0], null, i, null));
            }
            options.setFocus(FaceColors.selectedIndex(key, layout));
        }
        WatchUi.pushView(options, new FaceOptionDelegate(_menu, key), WatchUi.SLIDE_IMMEDIATE);
    }
}

class FaceOptionDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as FaceCustomizationMenu;
    private var _key as String;

    function initialize(menu as FaceCustomizationMenu, key as String) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _key = key;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Storage.setValue(_key, item.getId() as String or Number);
        _menu.refreshLabels();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
