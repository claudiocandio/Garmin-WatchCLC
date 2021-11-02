/*
manifest.xml
 WatchCLC clca prod	App UUID ec609625-0efa-4d2d-8746-e20998c4a5a7
 WatchCLC clca Test	App UUID 3bcd23c4-073a-44b3-a59a-88e60c355e22
 WatchCLC frpi Test	App UUID 679845df-a0bd-45be-ba6e-313c3d99ec83
*/

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.Time.Gregorian;

class DimPrev
{
	var str;
    var w;
    var h;
    public function initialize(new_str, new_w, new_h) {
      str = new_str;
      w = new_w;
      h = new_h;
    }
    public function set(new_str, new_w, new_h) {
      str = new_str;
      w = new_w;
      h = new_h;
    }
}

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

	var cando1hz = false;

	var SecsClip = false;
	var SecsAlwaysOnPrev = false;
	var doNotDisturb = false;

	var xs = 0 as Number;
	var ys = 0 as Number;

	var dim_time = new DimPrev("", 0, 0);
	var dim_secs = new DimPrev("", 0, 0);
	var dim_heart = new DimPrev("", 0, 0);
	var dim_hearthi = new DimPrev("", 0, 0);
	var dim_batt = new DimPrev("", 0, 0);
	var dim_batti = new DimPrev("", 0, 0);
	var dim_ble = new DimPrev("", 0, 0);
	var dim_steps = new DimPrev("", 0, 0);
	var dim_stepsi = new DimPrev("", 0, 0);
	var dim_dist = new DimPrev("", 0, 0);
	var dim_sleep = new DimPrev("", 0, 0);
	var dim_not = new DimPrev("", 0, 0);
	var dim_df1 = new DimPrev("", 0, 0);
	var dim_df2 = new DimPrev("", 0, 0);

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
		// see if 1hz is possible
		cando1hz = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
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

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

		doNotDisturb = System.getDeviceSettings().doNotDisturb;

		if ( cando1hz ){
			//System.println("x=" + x + " y=" + y + " h=" + h + " w=" + w);
			if(SecsClip){
				dc.clear();
				dc.clearClip();
				SecsClip = false;
			}
			if ( getApp().getProperty("SecsAlwaysOn") ) {
				if (doNotDisturb){
					showSecs = false;
				} else {
					showSecs = true;
				}
				SecsAlwaysOnPrev = true;
			} else if (SecsAlwaysOnPrev) {
				showSecs = false;
				SecsAlwaysOnPrev = false;
			}
			/*
			System.println("Yes I can do 1hz");
		} else {
			System.println("No I cannot do 1hz");
			*/
		}

        ForegroundColor = getApp().getProperty("ForegroundColor");
        BackgroundColor = getApp().getProperty("BackgroundColor");

		if(ForegroundColor != ForegroundColorPrev || BackgroundColor != BackgroundColorPrev){
			dc.setColor(ForegroundColor, BackgroundColor);
			dc.clear();

			dim_hearthi = draw_wrap(dc, HEARTICON, "HeartIcon", garminFont, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, dim_hearthi);
			dim_stepsi = draw_wrap(dc, STEPSICON, "StepsIcon", garminFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_stepsi);

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
			showSecsPrev = true;

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
		dim_time = draw_wrap(dc, Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]), "TimeLabel", ccFontBig, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_time);
		//view.setText("22:33");
		
        // Show Secs
		if ( showSecs ) {
			dim_secs = draw_wrap(dc, Lang.format(".$1$", [clockTime.sec.format("%02d")]), "SecsLabel", ccFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_secs);
			showSecsPrev = true;
		} else if ( showSecsPrev ) {
			dim_secs = draw_wrap(dc, "1", "SecsLabel", ccFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_secs);
			showSecsPrev = false;
		}

 		// Show bluetooth icon
		if ( System.getDeviceSettings().phoneConnected && !BLEconnectedPrev ) {
			dim_ble = draw_wrap(dc, BLEICON, "BLEIcon", garminFont, Graphics.COLOR_BLUE, Graphics.TEXT_JUSTIFY_CENTER, dim_ble);
       		BLEconnectedPrev = true;
		} else if (!System.getDeviceSettings().phoneConnected && BLEconnectedPrev) {
			dim_ble = draw_wrap(dc, "", "BLEIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_ble);
       		BLEconnectedPrev = false;
		}

        var battery = System.getSystemStats().battery;
		var batteryLow = getApp().getProperty("LowBattery");

        if (battery != batteryPrev || batteryLow != batteryLowPrev) {
			var batteryStr = Lang.format("$1$%", [battery.format("%3d")]);

    	    if (battery < batteryLow){

				dim_batt = draw_wrap(dc, batteryStr, "BatteryLabel", ccFontSmall, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, dim_batt);

				var shape = System.getDeviceSettings().screenShape;
				if (shape == System.SCREEN_SHAPE_ROUND){
					dim_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFont, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, dim_batti);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
					dim_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFontSmall, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, dim_batti);
				}
    	    } else {
				dim_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFontSmall, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_batti);
				dim_batt = draw_wrap(dc, batteryStr, "BatteryLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_batt);

    	    }

			batteryPrev = battery;
			batteryLowPrev = batteryLow;
        }

        if (heart != heartPrev) {
			dim_heart = draw_wrap(dc, heart, "HeartLabel", ccFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_heart);
			heartPrev = heart;
        }

        if (steps != stepsPrev) {
			dim_steps = draw_wrap(dc, steps, "StepsLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_RIGHT, dim_steps);
	        stepsPrev = steps;
        }

        if (distance != distancePrev) {
			dim_dist = draw_wrap(dc, distance, "DistanceLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_LEFT, dim_dist);
	        distancePrev = distance;
        }

 		// Show do not disturb icon Moon icon
		if ( doNotDisturb && !doNotDisturbPrev ) {
			dim_sleep = draw_wrap(dc, SLEEPICON, "SleepIcon", garminFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_sleep);
       		doNotDisturbPrev = true;

		} else if (!doNotDisturb && doNotDisturbPrev) {
			dim_sleep = draw_wrap(dc, SLEEPICON, "SleepIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_sleep);
       		doNotDisturbPrev = false;
		}

 		// Show do Notification icon
		if (getApp().getProperty("UseNotification")) {
			if ( System.getDeviceSettings().notificationCount > 0 && !notificationPrev ) {
				dim_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, Graphics.COLOR_GREEN, Graphics.TEXT_JUSTIFY_CENTER, dim_not);
				notificationPrev = true;
			} else if ( System.getDeviceSettings().notificationCount == 0 && notificationPrev ) {
				dim_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_not);
				notificationPrev = false;
			}
		} else {
			if (notificationPrev) {
				dim_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_not);
				notificationPrev = false;
			}
		}

		printDF(dc, 1, "DF1", "DF1Icon", "DF1", df1Prev, df1valPrev, info);
		printDF(dc, 2, "DF2", "DF2Icon", "DF2", df2Prev, df2valPrev, info);

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

	// Updates every second
	function onPartialUpdate(dc as Dc) as Void {

		if ( showSecs ) {
			if (!SecsClip) {
				setSecsClip(dc, Graphics.TEXT_JUSTIFY_CENTER);
			}
			dc.clear();
     		dc.drawText(xs, ys, ccFont, Lang.format(".$1$", [System.getClockTime().sec.format("%02d")]), Graphics.TEXT_JUSTIFY_CENTER);
		}

 	}

	function setSecsClip(dc as Dc, j as Number) as Void {
		view = View.findDrawableById("SecsLabel");
		xs = view.locX;
		ys = view.locY;
		var dim = dc.getTextDimensions(".00", ccFont);

		do_setClip(dc, xs, ys, dim[0], dim[1], j);
		dc.setColor(BackgroundColor, BackgroundColor);
		dc.clear();
     	dc.setColor(ForegroundColor,BackgroundColor);
		
		showSecsPrev = true;
		SecsClip = true;
	}

	function draw_wrap(dc as Dc, drawtext as Text, drawId as Text, font as WatchUi.Resource, FgColor as Number, j as Number, dim_prev) {
	
		view = View.findDrawableById(drawId);
		// clear prev text
		if (dim_prev.w > 0) {
			do_setClip(dc, view.locX, view.locY, dim_prev.w, dim_prev.h, j);
			dc.setColor(BackgroundColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(view.locX, view.locY, font, dim_prev.str, j);
			dc.clearClip();
		}

		return drawcc(dc, view.locX, view.locY, drawtext, drawId, font, FgColor, j, dim_prev);
	}

	function drawcc(dc as Dc, x as Number, y as Number, drawtext as Text, drawId as Text, font as WatchUi.Resource, FgColor as Number, j as Number, dim_prev) {
		var dim = dc.getTextDimensions(drawtext, font);
		var w = dim[0];
		var h = dim[1];

		do_setClip(dc, x, y, w, h, j);
		dc.setColor(FgColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, y, font, drawtext, j);
		dc.clearClip();

		dim_prev.set(drawtext, w, h);
		return dim_prev;
 	}

	function do_setClip(dc as Dc, x as Number, y as Number, w as Number, h as Number, j as Number) {
		if (j == Graphics.TEXT_JUSTIFY_CENTER) {
			var x1 = x - (w/2);
			x1 = x1 < 0 ? 0 : x1;
			dc.setClip(x1, y, w, h);
		} else if (j == Graphics.TEXT_JUSTIFY_RIGHT) {
			var x1 = x - w;
			x1 = x1 < 0 ? 0 : x1;
			dc.setClip(x1, y, w, h);
		} else { // Graphics.TEXT_JUSTIFY_LEFT
			dc.setClip(x, y, w, h);
		}
	}

	function printDF(dc, dfnum, DFproperty, DFdrawIcon, DFdrawLabel, dfPrev, dfvalPrev, info) {

        var df = getApp().getProperty(DFproperty);
		var dfval = null;
		var col = 0, icon = "";
		var font = null;

		//System.println("df: " + df);

        if (df != dfPrev) {
			if (df == CALORIES) {
    			col = Graphics.COLOR_RED;
    			icon = CALORIESICON;

			} else if (df == ALTITUDE) {
    			col = ForegroundColor;
	    		icon = ALTITUDEICON;

			} else if (df == FLOORSCLIMBED) {
    			col = ForegroundColor;
	    		icon = FLOORSCLIMBEDICON;

			} else if (df == FLOORSDESCENDED) {
    			col = ForegroundColor;
	    		icon = FLOORSDESCENDEDICON;

			} else if (df == ACTIVEMINUTESWEEK || df == ACTIVEMINUTESDAY) {
    			col = ForegroundColor;
	    		icon = ACTIVEMINUTESICON;

			} else if (df == ACTIVEMINUTESWEEKGOAL) {
    			col = ForegroundColor;
	    		icon = ACTIVEMINUTESWEEKGOALICON;

			}
			if (dfnum == 1){
				dim_df1 = draw_wrap(dc, icon, DFdrawIcon, garminFontSmall, col, Graphics.TEXT_JUSTIFY_CENTER, dim_df1);
				df1Prev = df;
			} else if (dfnum == 2){
				dim_df2 = draw_wrap(dc, icon, DFdrawIcon, garminFontSmall, col, Graphics.TEXT_JUSTIFY_CENTER, dim_df2);
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
			if (dfnum == 2 && (screen.equals("260x260") || screen.equals("280x280"))) { // Fenix 6 or 6X
	    	    font = ccFont;
			} else {
    	    	font = ccFontSmall;
			}

			if (dfnum == 1){
				dim_df1 = draw_wrap(dc, dfval.toString(), DFdrawLabel, font, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_df1);
				df1valPrev = dfval;
			} else if (dfnum == 2){
				dim_df2 = draw_wrap(dc, dfval.toString(), DFdrawLabel, font, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, dim_df2);
				df1valPrev = dfval;
			}
        }

	}

}

class WatchCLCViewDelegate extends WatchUi.WatchFaceDelegate
{
	function initialize() {
		WatchFaceDelegate.initialize();	
	}

    function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) {
        //System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        //System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );

        cando1hz = false;
		if ( getApp().getProperty("SecsAlwaysOn") ) {
			getApp().setProperty("SecsAlwaysOn", false);
		}

    }
}
