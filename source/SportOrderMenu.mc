import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

class SportOrderMenu extends WatchUi.Menu2 {
    private var _items as Array<WatchUi.MenuItem> = [];

    function initialize() {
        Menu2.initialize({:title => "Activity Order"});
        for (var rank = 0; rank < SportOrder.RANKS.size(); rank++) {
            var item = new WatchUi.MenuItem(SportOrder.RANKS[rank], null, rank, null);
            _items.add(item);
            addItem(item);
        }
        refreshLabels();
    }

    function refreshLabels() as Void {
        var order = SportOrder.selected();
        for (var rank = 0; rank < _items.size(); rank++) {
            _items[rank].setSubLabel(SportOrder.NAMES[order[rank]]);
        }
    }
}

class SportRankDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as SportOrderMenu;

    function initialize(menu as SportOrderMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var rank = item.getId() as Number;
        var order = SportOrder.selected();
        var options = new WatchUi.Menu2({:title => SportOrder.RANKS[rank]});
        for (var sport = 0; sport < SportOrder.NAMES.size(); sport++) {
            options.addItem(new WatchUi.MenuItem(SportOrder.NAMES[sport], null, sport, null));
        }
        options.setFocus(order[rank]);
        WatchUi.pushView(options, new SportChoiceDelegate(_menu, rank), WatchUi.SLIDE_IMMEDIATE);
    }
}

class SportChoiceDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as SportOrderMenu;
    private var _rank as Number;

    function initialize(menu as SportOrderMenu, rank as Number) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _rank = rank;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var order = SportOrder.swapped(SportOrder.selected(), _rank, item.getId() as Number);
        Storage.setValue(SportOrder.KEY, order);
        _menu.refreshLabels();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
