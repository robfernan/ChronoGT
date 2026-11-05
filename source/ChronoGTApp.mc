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

    private var _view as ChronoGTView?;

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new ChronoGTView();
        return [ _view ];
    }

    // On-Device Customize Menu (Triggered via watch face customize screen / Menu button)
    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        return [ new ChronoGTSettingsMenu(), new ChronoGTSettingsMenuDelegate() ];
    }

    // Trigger immediate redraw and cache reload when user changes settings on phone or on watch
    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.reloadSettings();
        }
        WatchUi.requestUpdate();
    }

}

function getApp() as ChronoGTApp {
    return Application.getApp() as ChronoGTApp;
}
