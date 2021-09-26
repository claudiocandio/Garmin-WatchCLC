import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.Time.Gregorian;

// Windows: alt + num ascii numeri keypad with blocnum pressed, not keybord
// Linux ctrl-shift-U hex 4 cifre e invio

class WatchCLCView extends WatchUi.WatchFace {

	var screen = null as Text;
    var view = null as Text;
	var ccFontBig = null;
	var ccFont = null;
	var ccFontSmall = null;
	
	var ForegroundColor = null as Number;

	var garminFontBig = null;
	var garminFont = null;
	var garminFontSmall = null;
	
	var BLEconnectedPrev = false;
	var doNotDisturbPrev = false;
	var heartPrev = null as Text;
	var stepsPrev = null as Text;
	var distancePrev = null as Text;
	var batteryPrev = null as Number;
	var batteryLowPrev = null as Number;
	var pressurePrev = null;
	var datenowStrPrev = null;

	var batteryLow = null as Number;
	var showSecs = true;
	var showSecsPrev = false;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

		// System.println("screen: " + System.getDeviceSettings().screenWidth + "x" + System.getDeviceSettings().screenHeight);
		screen = System.getDeviceSettings().screenWidth + "x" + System.getDeviceSettings().screenHeight;
		screen = screen.toString();

		if (screen.equals("240x240")) { // Fenix 6S
	        setLayout(Rez.Layouts.Fenix6S(dc));
		} else if (screen.equals("260x260")) { // Fenix 6
	        setLayout(Rez.Layouts.Fenix6(dc));
		} else if (screen.equals("280x280")) { // Fenix 6X
	        setLayout(Rez.Layouts.Fenix6X(dc));
		} else { // should not get here
			System.println("NO SCREEN = " + screen);
			System.exit();
		}
        
        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont110px);
        ccFont = WatchUi.loadResource(Rez.Fonts.ccFont50px);
        ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont40px);
        
        garminFont = WatchUi.loadResource(Rez.Fonts.garminFont40px);
        garminFontSmall = WatchUi.loadResource(Rez.Fonts.garminFont30px);
        
        ForegroundColor = getApp().getProperty("ForegroundColor");
        
        view = View.findDrawableById("HeartIcon");
   	    view.setFont(garminFont);
       	view.setColor(Graphics.COLOR_RED);
        view.setText("G");
        
        view = View.findDrawableById("StepsIcon");
   	    view.setFont(garminFont);
       	view.setColor(ForegroundColor);
       	view.setText("I");

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }

		var info = ActivityMonitor.getInfo();
		var steps = info.steps.toString();
		//System.println("Steps taken: " + steps);

		var distance = null;
		if( System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE ) {
			distance = (info.distance/160934.0).format("%.2f")+" mi";
		} else {
			distance = (info.distance/(100000.0)).format("%.2f")+"km";
		}		

		var heart = null;
		heart = Activity.getActivityInfo().currentHeartRate;
		if(heart == null) {
			var HRH = ActivityMonitor.getHeartRateHistory(1, true);
			var HRS = HRH.next();
			if(HRS != null && HRS.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
				heart = HRS.heartRate;
			}
		}
		if(heart != null) {
			heart = heart.toString();
		} else {
			heart = "--";
		}

		var pressure = SensorHistory.getPressureHistory({:period => 1}).next().data;
		if( pressure != null ) {
			pressure = (pressure/100).format("%.1f")+" mbar";
		} else {
			pressure = "--";
		}

        // Show Time
        view = View.findDrawableById("TimeLabel") as Text;
        view.setFont(ccFontBig);
        view.setColor(ForegroundColor);
        view.setText(Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]));
		//view.setText("22:33");
		
        // Show Secs
        if ( showSecs ) {
        	view = View.findDrawableById("SecsLabel") as Text;
	        view.setFont(ccFont);
    	    view.setColor(ForegroundColor);
        	view.setText(Lang.format(".$1$", [clockTime.sec.format("%02d")]));
        	showSecsPrev = true;
        } else if ( !showSecs && showSecsPrev ) {
	        view = View.findDrawableById("SecsLabel");
    		view.setFont(ccFont);
   			view.setColor(Graphics.COLOR_BLACK);
   			view.setText("  ");
   			showSecsPrev = false;
        }

 		// Show bluetooth icon
		if ( System.getDeviceSettings().phoneConnected && !BLEconnectedPrev ) {
	        view = View.findDrawableById("BLEIcon");
   	    	view.setFont(garminFont);
       		view.setColor(Graphics.COLOR_BLUE);
       		view.setText("D");
       		BLEconnectedPrev = true;
		} else if (!System.getDeviceSettings().phoneConnected && BLEconnectedPrev) {
	        view = View.findDrawableById("BLEIcon");
   	    	view.setFont(ccFont);
       		view.setColor(Graphics.COLOR_BLACK);
       		BLEconnectedPrev = false;
		}

        var battery = System.getSystemStats().battery;
		var batteryLow = getApp().getProperty("LowBattery");

        if (battery != batteryPrev || batteryLow != batteryLowPrev) {
			var batteryStr = Lang.format("$1$%", [battery.format("%3d")]);

	        view = View.findDrawableById("BatteryLabel");
    	    view.setFont(ccFontSmall);
    	    if (battery < batteryLow){
	        	view.setColor(Graphics.COLOR_RED);
		        view.setText(batteryStr);

		        view = View.findDrawableById("BatteryIcon");
   	    		view.setFont(garminFont);
       			view.setColor(Graphics.COLOR_RED);
       			view.setText("C"); // "B" battery horizontal - "C" battery vertical
    	    } else {
				view.setColor(ForegroundColor);
		        view.setText(batteryStr);

		        view = View.findDrawableById("BatteryIcon");
   	    		view.setFont(garminFont);
       			view.setColor(Graphics.COLOR_BLACK);
    	    }
	        //view.setText(Lang.format("$1$%", [battery.format("%3d")]));

			batteryPrev = battery;
			batteryLowPrev = batteryLow;
        }

        if (heart != heartPrev) {
	        view = View.findDrawableById("HeartLabel");
    	    view.setFont(ccFont);
        	view.setColor(ForegroundColor);
	        view.setText(heart);
	        heartPrev = heart;
        }

        if (steps != stepsPrev) {
	        view = View.findDrawableById("StepsLabel");
    	    view.setFont(ccFontSmall);
        	view.setColor(ForegroundColor);
	        view.setText(steps);
	        stepsPrev = steps;
        }

        if (distance != distancePrev) {
	        view = View.findDrawableById("DistanceLabel");
    	    view.setFont(ccFontSmall);
        	view.setColor(ForegroundColor);
	        view.setText(distance);
	        distancePrev = distance;
        }

 		// Show do not disturb icon Moon icon
		if ( System.getDeviceSettings().doNotDisturb && !doNotDisturbPrev ) {
	        view = View.findDrawableById("SleepIcon");
   	    	view.setFont(garminFont);
       		view.setColor(Graphics.COLOR_WHITE);
       		view.setText("F");
       		doNotDisturbPrev = true;

		} else if (!System.getDeviceSettings().doNotDisturb && doNotDisturbPrev) {
	        view = View.findDrawableById("SleepIcon");
   	    	view.setFont(ccFont);
       		view.setColor(Graphics.COLOR_BLACK);
       		doNotDisturbPrev = false;
		}

        if (pressure != pressurePrev) {
	        view = View.findDrawableById("PressureLabel");
    	    view.setFont(ccFontSmall);
        	view.setColor(ForegroundColor);
	        view.setText(pressure);
	        pressurePrev = pressure;
        }

		var datenow = Gregorian.info(Time.now(), Time.FORMAT_LONG);
		var datenowStr = Lang.format("$1$ $2$ $3$", [datenow.day_of_week, datenow.day, datenow.month]);
        if (datenowStr != datenowStrPrev) {
	        view = View.findDrawableById("DateLabel");
			if (screen.equals("240x240")) { // Fenix 6S
    	    	view.setFont(ccFontSmall);
			} else {
	    	    view.setFont(ccFont);
			}
        	view.setColor(ForegroundColor);
	        view.setText(datenowStr);
	        datenowStrPrev = datenowStr;
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
		showSecs = true;
		WatchUi.requestUpdate();    
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
		showSecs = false;
		WatchUi.requestUpdate();    
    }

	// updates every second
	//function onPartialUpdate(dc as Dc) as Void {
 	//}

}
