import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.Time.Gregorian;

class WatchCLCView extends WatchUi.WatchFace {

	var screen = null as Text;
    var view = null as Text;
	var ccFontBig = null;
	var ccFont = null;
	var ccFontSmall = null;
	
	var garminFont = null;
	var garminFontSmall = null;
	
	var ForegroundColor = null as Number;
	var BackgroundColor = null as Number;

	var ForegroundColorPrev = null as Number;
	var BackgroundColorPrev = null as Number;
	var BLEconnectedPrev = true;
	var doNotDisturbPrev = true;
	var notificationPrev = true;
	var heartPrev = null as Text;
	var stepsPrev = null as Text;
	var distancePrev = null as Text;
	var batteryPrev = null as Number;
	var batteryLowPrev = null as Number;
	var df1Prev = null;
	var df1valPrev = null;
	var df2Prev = null;
	var df2valPrev = null;
	var datenowStrPrev = null;

	var batteryLow = null as Number;
	var showSecs = true;
	var showSecsPrev = false;

	enum {
		CALORIES,
		DATE,
		PRESSURE,
		ALTITUDE,
		FLOORSCLIMBED,
		FLOORSDESCENDED,
		ACTIVEMINUTESDAY,
		ACTIVEMINUTESWEEK,
		ACTIVEMINUTESWEEKGOAL,
		EMPTY
	}

	enum {
		NOTIFICATIONICON = "A",
		STEPSICON = "B",
		ACTIVEMINUTESWEEKGOALICON = "C",
		ALTITUDEICON = "D",
		FLOORSCLIMBEDICON = "E",
		FLOORSDESCENDEDICON = "F",
		BATTERYICON = "G",
		BLEICON = "H",
		CALORIESICON = "I",
		SLEEPICON = "J",
		HEARTICON = "K",
		ACTIVEMINUTESICON = "L"
	}

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

		// System.println("screen: " + System.getDeviceSettings().screenWidth + "x" + System.getDeviceSettings().screenHeight);
		screen = System.getDeviceSettings().screenWidth + "x" + System.getDeviceSettings().screenHeight;
		screen = screen.toString();

		if (screen.equals("215x180")) { // Forerunner 735xt
	        setLayout(Rez.Layouts.Screen215x180(dc));
	        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont90px);
    	    ccFont = WatchUi.loadResource(Rez.Fonts.ccFont40px);
        	ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont30px);
		
		} else if (screen.equals("218x218")) { // Fenix 5S
	        setLayout(Rez.Layouts.Screen218x218(dc));
	        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont90px);
    	    ccFont = WatchUi.loadResource(Rez.Fonts.ccFont40px);
        	ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont30px);
		
		} else if (screen.equals("240x240")) { // Fenix 6S
	        setLayout(Rez.Layouts.Screen240x240(dc));
	        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont100px);
    	    ccFont = WatchUi.loadResource(Rez.Fonts.ccFont40px);
        	ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont35px);
		
		} else if (screen.equals("260x260")) { // Fenix 6
	        setLayout(Rez.Layouts.Screen260x260(dc));
	        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont105px);
    	    ccFont = WatchUi.loadResource(Rez.Fonts.ccFont50px);
        	ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont40px);
		
		} else if (screen.equals("280x280")) { // Fenix 6X
	        setLayout(Rez.Layouts.Screen280x280(dc));
	        ccFontBig = WatchUi.loadResource(Rez.Fonts.ccFont110px);
    	    ccFont = WatchUi.loadResource(Rez.Fonts.ccFont50px);
        	ccFontSmall = WatchUi.loadResource(Rez.Fonts.ccFont40px);
		
		} else { // should not get here
			System.println("NO SCREEN = " + screen);
			System.exit();
		}
        
        garminFont = WatchUi.loadResource(Rez.Fonts.garminFont40px);
        garminFontSmall = WatchUi.loadResource(Rez.Fonts.garminFont30px);
        
        view = View.findDrawableById("HeartIcon");
   	    view.setFont(garminFont);
       	view.setColor(Graphics.COLOR_RED);
        view.setText(HEARTICON);
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        ForegroundColor = getApp().getProperty("ForegroundColor");
        BackgroundColor = getApp().getProperty("BackgroundColor");

		if(ForegroundColor != ForegroundColorPrev || BackgroundColor != BackgroundColorPrev){
	        view = View.findDrawableById("StepsIcon");
   	    	view.setFont(garminFont);
	       	view.setColor(ForegroundColor);
       		view.setText(STEPSICON);

			// to refresh all
			BLEconnectedPrev = BLEconnectedPrev ? false : true;
			doNotDisturbPrev = doNotDisturbPrev ? false : true;
			notificationPrev = notificationPrev ? false : true;
			heartPrev = null;
			stepsPrev = null;
			distancePrev = null;
			batteryPrev = null;
			batteryLowPrev = null;
			df1Prev = null;
			df1valPrev = null;
			df2Prev = null;
			df2valPrev = null;
			datenowStrPrev = null;

			ForegroundColorPrev = ForegroundColor;
			BackgroundColorPrev = BackgroundColor;
		}

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

		var distance = null;
		if (info has :distance && info.distance != null) {
			if( System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE ) {
				distance = (info.distance/160934.0).format("%.2f")+" mi";
			} else {
				distance = (info.distance/(100000.0)).format("%.2f")+"km";
			}
		} else {
			distance = "--";
		}
		//System.println("distance: " + distance);

		var steps = null;
		if (info has :steps && info.steps != null) {
			steps = info.steps.toString();
		} else {
			steps = "--";
		}

		var heart = null;
		if (Activity has :getActivityInfo && Activity.getActivityInfo() != null) {
			heart = Activity.getActivityInfo().currentHeartRate;
		}
		if(heart == null) {
			if (ActivityMonitor has :getHeartRateHistory && ActivityMonitor.getHeartRateHistory(1, true) != null) {
				var HRH = ActivityMonitor.getHeartRateHistory(1, true);
				var HRS = HRH.next();
				if(HRS != null && HRS.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
					heart = HRS.heartRate;
				}
			}
		}
		if(heart != null) {
			heart = heart.toString();
		} else {
			heart = "--";
		}
		//heart = "183";

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
        } else if ( showSecsPrev ) {
	        view = View.findDrawableById("SecsLabel");
    		view.setFont(ccFont);
   			view.setColor(BackgroundColor);
   			showSecsPrev = false;
        }

 		// Show bluetooth icon
		if ( System.getDeviceSettings().phoneConnected && !BLEconnectedPrev ) {
	        view = View.findDrawableById("BLEIcon");
   	    	view.setFont(garminFont);
       		view.setColor(Graphics.COLOR_BLUE);
       		view.setText(BLEICON);
       		BLEconnectedPrev = true;
		} else if (!System.getDeviceSettings().phoneConnected && BLEconnectedPrev) {
	        view = View.findDrawableById("BLEIcon");
   	    	view.setFont(ccFont);
       		view.setColor(BackgroundColor);
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
				var shape = System.getDeviceSettings().screenShape;
				if (shape == System.SCREEN_SHAPE_ROUND){
	   	    		view.setFont(garminFont);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
	   	    		view.setFont(garminFontSmall);
				}
       			view.setColor(Graphics.COLOR_RED);
       			view.setText(BATTERYICON);
    	    } else {
				view.setColor(ForegroundColor);
		        view.setText(batteryStr);

		        view = View.findDrawableById("BatteryIcon");
   	    		view.setFont(garminFontSmall);
       			view.setColor(BackgroundColor);
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
       		view.setColor(ForegroundColor);
       		view.setText(SLEEPICON);
       		doNotDisturbPrev = true;

		} else if (!System.getDeviceSettings().doNotDisturb && doNotDisturbPrev) {
	        view = View.findDrawableById("SleepIcon");
   	    	view.setFont(ccFont);
       		view.setColor(BackgroundColor);
       		doNotDisturbPrev = false;
		}

 		// Show do Notification icon
		if (getApp().getProperty("UseNotification")) {
			if ( System.getDeviceSettings().notificationCount > 0 && !notificationPrev ) {
				view = View.findDrawableById("NotificationIcon");
				view.setFont(garminFont);
				view.setColor(Graphics.COLOR_GREEN);
				view.setText(NOTIFICATIONICON);
				notificationPrev = true;

			} else if ( System.getDeviceSettings().notificationCount == 0 && notificationPrev ) {
				view = View.findDrawableById("NotificationIcon");
				view.setFont(ccFont);
				view.setColor(BackgroundColor);
				notificationPrev = false;
			}
		} else {
			if (notificationPrev) {
				view = View.findDrawableById("NotificationIcon");
				view.setFont(ccFont);
				view.setColor(BackgroundColor);
				notificationPrev = false;
			}
		}

		printDF(1, "DF1", "DF1Icon", "DF1", df1Prev, df1valPrev, info);
		printDF(2, "DF2", "DF2Icon", "DF2", df2Prev, df2valPrev, info);

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

	function printDF(dfnum, DFproperty, DFdrawIcon, DFdrawLabel, dfPrev, dfvalPrev, info) {

        var df = getApp().getProperty(DFproperty);
		var dfval = null;
		//System.println("df: " + df);

        if (df != dfPrev) {
	        view = View.findDrawableById(DFdrawIcon);
		   	view.setFont(garminFontSmall);
   			view.setColor(BackgroundColor);

			if (df == CALORIES) {
    			view.setColor(Graphics.COLOR_RED);
    			view.setText(CALORIESICON);

			} else if (df == ALTITUDE) {
    			view.setColor(ForegroundColor);
	    		view.setText(ALTITUDEICON);

			} else if (df == FLOORSCLIMBED) {
    			view.setColor(ForegroundColor);
	    		view.setText(FLOORSCLIMBEDICON);

			} else if (df == FLOORSDESCENDED) {
    			view.setColor(ForegroundColor);
	    		view.setText(FLOORSDESCENDEDICON);

			} else if (df == ACTIVEMINUTESWEEK || df == ACTIVEMINUTESDAY) {
    			view.setColor(ForegroundColor);
	    		view.setText(ACTIVEMINUTESICON);

			} else if (df == ACTIVEMINUTESWEEKGOAL) {
    			view.setColor(ForegroundColor);
	    		view.setText(ACTIVEMINUTESWEEKGOALICON);

			}
			if (dfnum == 1){
				df1Prev = df;
			} else if (dfnum == 2){
				df2Prev = df;
			}
		}

		if (df == PRESSURE) {
			if (SensorHistory has :getPressureHistory && SensorHistory.getPressureHistory({:period => 1}).next().data != null) {
				dfval = SensorHistory.getPressureHistory({:period => 1}).next().data;
				dfval = (dfval/100).format("%.1f")+" mb";
			}
			//dfval ="1024.5 mb";

		} else if (df == CALORIES) {
			if (info has :calories && info.calories != null) {
				dfval = info.calories;
			}

		} else if (df == FLOORSCLIMBED) {
			if (info has :floorsClimbed && info.floorsClimbed != null) {
				dfval = info.floorsClimbed.toString();
			}

		} else if (df == FLOORSDESCENDED) {
			if (info has :floorsDescended && info.floorsDescended != null) {
				dfval = info.floorsDescended.toString();
			}

		} else if (df == ACTIVEMINUTESDAY) {
			if (info has :activeMinutesDay && info.activeMinutesDay != null) {
				dfval = info.activeMinutesDay.total.toString();
			}

		} else if (df == ACTIVEMINUTESWEEK) {
			if (info has :activeMinutesWeek && info.activeMinutesWeek != null) {
				dfval = info.activeMinutesWeek.total.toString();
			}

		} else if (df == ACTIVEMINUTESWEEKGOAL) {
			if (info has :activeMinutesWeekGoal && info.activeMinutesWeekGoal != null) {
				dfval = info.activeMinutesWeekGoal.toString();
			}

		} else if (df == ALTITUDE) {
			if (Activity has :getActivityInfo && Activity.getActivityInfo().altitude != null) {
				dfval = Activity.getActivityInfo().altitude;
				if( System.getDeviceSettings().elevationUnits == System.UNIT_METRIC ) {
					dfval = (dfval).format("%.0f")+"m";
				} else {
					dfval = (dfval*3.28084).format("%.f")+"ft";
				}
			}

		} else if (df == DATE) {
			var datenow = Gregorian.info(Time.now(), Time.FORMAT_LONG);
			dfval = Lang.format("$1$ $2$ $3$", [datenow.day_of_week, datenow.day, datenow.month]);

		} else if (df == EMPTY) {
			dfval = "";
		}
		if (dfval == null) {
				dfval = "--";
		}
		//System.println("dfval: " + dfval);

        if (dfval != dfvalPrev) {
			view = View.findDrawableById(DFdrawLabel);

			if (dfnum == 2 && (screen.equals("260x260") || screen.equals("280x280"))) { // Fenix 6 or 6X
	    	    view.setFont(ccFont);
			} else {
    	    	view.setFont(ccFontSmall);
			}

        	view.setColor(ForegroundColor);
			view.setText(dfval.toString());
			if (dfnum == 1){
				df1valPrev = dfval;
			} else if (dfnum == 2){
				df1valPrev = dfval;
			}
        }

	}


}
