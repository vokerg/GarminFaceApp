import Toybox.Application.Storage;
import Toybox.Lang;

module FaceLayouts {
    const EMBER = 0;
    const FIELD_COMPASS = 1;
    const SPLIT_CLOCK = 2;
    const TRAINING_LEDGER = 3;
    const SIGNAL_BARS = 4;
    const METRIC_GRID = 5;
    const TYPE_STUDY = 6;
    const TRACK_RING = 7;
    const QUADRANT_CLOCK = 8;

    const KEY = "FaceLayout";
    const IDS = ["ember", "field-compass", "split-clock", "training-ledger",
        "signal-bars", "metric-grid", "type-study", "track-ring", "quadrant-clock"];
    const NAMES = ["Ember", "Field Compass", "Split Clock", "Training Ledger",
        "Signal Bars", "Metric Grid", "Type Study", "Track Ring", "Quadrant Clock"];

    // Indices in the 64-color MIP palette offered by FaceColors.
    const ACCENTS = [0, 1, 4, 3, 5, 6, 7, 4, 2];
    const GAUGES = [1, 0, 5, 6, 3, 5, 1, 1, 4];

    function selected() as Number {
        var saved = Storage.getValue(KEY);
        var layout = saved instanceof String ? IDS.indexOf(saved) : -1;
        return layout < 0 ? BuildProfile.LAYOUT : layout;
    }

    function renderer(layout as Number) as FaceRenderer {
        switch (layout) {
            case FIELD_COMPASS: return new FieldCompassRenderer();
            case SPLIT_CLOCK: return new SplitClockRenderer();
            case TRAINING_LEDGER: return new TrainingLedgerRenderer();
            case SIGNAL_BARS: return new SignalBarsRenderer();
            case METRIC_GRID: return new MetricGridRenderer();
            case TYPE_STUDY: return new TypeStudyRenderer();
            case TRACK_RING: return new TrackRingRenderer();
            case QUADRANT_CLOCK: return new QuadrantClockRenderer();
            default: return new EmberRenderer();
        }
    }
}
