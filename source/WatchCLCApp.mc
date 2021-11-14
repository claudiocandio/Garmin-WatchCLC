import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class WatchCLCApp extends Application.AppBase {

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
    function getInitialView() as Array<Views or InputDelegates>? {
        //return [ new WatchCLCView() ] as Array<Views or InputDelegates>;

		if( Toybox.WatchUi.WatchFace has :onPartialUpdate ) {
        	return [ new WatchCLCView(), new WatchCLCViewDelegate()  ] as Array<Views or InputDelegates>;
        } else {
        	return [ new WatchCLCView() ] as Array<Views or InputDelegates>;
        }        

    }
    
    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchCLCView.loadSettings();
        WatchUi.requestUpdate();
    }
}

function getApp() as WatchCLCApp {
    return Application.getApp() as WatchCLCApp;
}