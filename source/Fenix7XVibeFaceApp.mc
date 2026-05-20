import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Fenix7XVibeFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        // Instantiate the refined face view.  Previous versions of this
        // application returned Fenix7XVibeFaceView, but the refined
        // implementation lives in Fenix7XVibeFaceViewRefined.mc.  Return
        // an instance here so the updated face loads at runtime.
        return [ new Fenix7XVibeFaceViewRefined() ];
    }

}

function getApp() as Fenix7XVibeFaceApp {
    return Application.getApp() as Fenix7XVibeFaceApp;
}
