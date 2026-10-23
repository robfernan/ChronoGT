import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ChronoGTApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new ChronoGTView() ];
    }

    // Trigger immediate redraw when user changes Theme or Gauge Mode in Garmin Connect
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as ChronoGTApp {
    return Application.getApp() as ChronoGTApp;
}
