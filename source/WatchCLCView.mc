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

class DF
{
	var ValPrev;
    var X;
    var Y;
    var W;
    var H;
    public function initialize(valPrev, x, y, w, h) {
      ValPrev = valPrev;
      X = x;
      Y = y;
      W = w;
      H = h;
    }
    public function set(valPrev, x, y, w, h) {
      ValPrev = valPrev;
      X = x;
      Y = y;
      W = w;
      H = h;
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

	var batteryLowPrev = null as Number;
	var batteryLow = null as Number;

	var showSecs = true;
	var showSecsPrev = false;

	var cando1hz = false;

	var SecsClip = false;
	var SecsAlwaysOnPrev = false;
	
	var df_time = new DF(null, 0, 0, 0, 0);
	var df_secs = new DF(null, 0, 0, 0, 0);
	var df_heart = new DF(null, 0, 0, 0, 0);
	var df_hearti = new DF(null, 0, 0, 0, 0);
	var df_batt = new DF(null, 0, 0, 0, 0);
	var df_batti = new DF(null, 0, 0, 0, 0);
	var df_ble = new DF(true, 0, 0, 0, 0);
	var df_steps = new DF(null, 0, 0, 0, 0);
	var df_stepsi = new DF(null, 0, 0, 0, 0);
	var df_dist = new DF(null, 0, 0, 0, 0);
	var doSleep = false;
	var df_sleep = new DF(true, 0, 0, 0, 0); // do not disturb
	var df_not = new DF(true, 0, 0, 0, 0);
	var df_df1 = new DF(null, 0, 0, 0, 0);
	var df_df1i = new DF(null, 0, 0, 0, 0);
	var df_df2 = new DF(null, 0, 0, 0, 0);
	var df_df2i = new DF(null, 0, 0, 0, 0);

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

		view = View.findDrawableById("BatteryLabel");
		df_batt.X = view.locX;
		df_batt.Y = view.locY;

		view = View.findDrawableById("BatteryIcon");
		df_batti.X = view.locX;
		df_batti.Y = view.locY;

		view = View.findDrawableById("BLEIcon");
		df_ble.X = view.locX;
		df_ble.Y = view.locY;

		view = View.findDrawableById("StepsLabel");
		df_steps.X = view.locX;
		df_steps.Y = view.locY;

		view = View.findDrawableById("StepsIcon");
		df_stepsi.X = view.locX;
		df_stepsi.Y = view.locY;

		view = View.findDrawableById("DistanceLabel");
		df_dist.X = view.locX;
		df_dist.Y = view.locY;

		view = View.findDrawableById("TimeLabel");
		df_time.X = view.locX;
		df_time.Y = view.locY;

		view = View.findDrawableById("HeartIcon");
		df_hearti.X = view.locX;
		df_hearti.Y = view.locY;

		view = View.findDrawableById("HeartLabel");
		df_heart.X = view.locX;
		df_heart.Y = view.locY;

		view = View.findDrawableById("SleepIcon");
		df_sleep.X = view.locX;
		df_sleep.Y = view.locY;

		view = View.findDrawableById("SecsLabel");
		df_secs.X = view.locX;
		df_secs.Y = view.locY;

		view = View.findDrawableById("NotificationIcon");
		df_not.X = view.locX;
		df_not.Y = view.locY;

		view = View.findDrawableById("DF1Icon");
		df_df1i.X = view.locX;
		df_df1i.Y = view.locY;

		view = View.findDrawableById("DF1");
		df_df1.X = view.locX;
		df_df1.Y = view.locY;

		view = View.findDrawableById("DF2Icon");
		df_df2i.X = view.locX;
		df_df2i.Y = view.locY;

		view = View.findDrawableById("DF2");
		df_df2.X = view.locX;
		df_df2.Y = view.locY;

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

		doSleep = System.getDeviceSettings().doNotDisturb;

		if ( cando1hz ){
			//System.println("x=" + x + " y=" + y + " h=" + h + " w=" + w);
			if(SecsClip){
				dc.setColor(BackgroundColor, BackgroundColor);
				dc.clear();
				dc.clearClip();
				SecsClip = false;
			}
			if ( getApp().getProperty("SecsAlwaysOn") ) {
				if (doSleep){
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

			df_hearti = draw_wrap(dc, HEARTICON, "HeartIcon", garminFont, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, df_hearti);
			df_stepsi = draw_wrap(dc, STEPSICON, "StepsIcon", garminFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_stepsi);

			// to refresh all
			df_ble.ValPrev = df_ble.ValPrev ? false : true;
			df_sleep.ValPrev = df_sleep.ValPrev ? false : true;
			df_not.ValPrev = df_not.ValPrev ? false : true;
			df_heart.ValPrev = null;
			df_steps.ValPrev = null;
			df_dist.ValPrev = null;
			df_batt.ValPrev = null;
			df_df1.ValPrev = null;
			df_df1i.ValPrev = null;
			df_df2.ValPrev = null;
			df_df2i.ValPrev = null;

			batteryLowPrev = null;
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
		//test heart = "183";

        // Show Time
		df_time = draw_wrap(dc, Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]), "TimeLabel", ccFontBig, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_time);
		// test "22:33"
		
        // Show Secs
		if ( showSecs ) {
			df_secs = draw_wrap(dc, Lang.format(".$1$", [clockTime.sec.format("%02d")]), "SecsLabel", ccFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_secs);
			showSecsPrev = true;
		} else if ( showSecsPrev ) {
			df_secs = draw_wrap(dc, df_secs.ValPrev, "SecsLabel", ccFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_secs);
			showSecsPrev = false;
		}

 		// Show bluetooth icon if phone is connected
		if ( System.getDeviceSettings().phoneConnected && !df_ble.ValPrev ) {
			df_ble = draw_wrap(dc, BLEICON, "BLEIcon", garminFont, Graphics.COLOR_BLUE, Graphics.TEXT_JUSTIFY_CENTER, df_ble);
       		df_ble.ValPrev = true;
		} else if (!System.getDeviceSettings().phoneConnected && df_ble.ValPrev) {
			df_ble = draw_wrap(dc, "", "BLEIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_ble);
       		df_ble.ValPrev = false;
		}

        var battery = System.getSystemStats().battery;
		var batteryLow = getApp().getProperty("LowBattery");
		var batteryStr = Lang.format("$1$%", [battery.format("%3d")]);

        if (batteryStr != df_batt.ValPrev || batteryLow != batteryLowPrev) {
			var shape = System.getDeviceSettings().screenShape;

    	    if (battery < batteryLow){
				if (shape == System.SCREEN_SHAPE_ROUND){
					df_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFont, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, df_batti);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
					df_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFontSmall, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, df_batti);
				}
				df_batt = draw_wrap(dc, batteryStr, "BatteryLabel", ccFontSmall, Graphics.COLOR_RED, Graphics.TEXT_JUSTIFY_CENTER, df_batt);

    	    } else {
				if (shape == System.SCREEN_SHAPE_ROUND){
					df_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_batti);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
					df_batti = draw_wrap(dc, BATTERYICON, "BatteryIcon", garminFontSmall, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_batti);
				}
				df_batt = draw_wrap(dc, batteryStr, "BatteryLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_batt);
    	    }

			df_batt.ValPrev = batteryStr;
			batteryLowPrev = batteryLow;
        }

        if (heart != df_heart.ValPrev) {
			df_heart = draw_wrap(dc, heart, "HeartLabel", ccFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_heart);
			df_heart.ValPrev = heart;
        }

        if (steps != df_steps.ValPrev) {
			df_steps = draw_wrap(dc, steps, "StepsLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_RIGHT, df_steps);
	        df_steps.ValPrev = steps;
        }

        if (distance != df_dist.ValPrev) {
			df_dist = draw_wrap(dc, distance, "DistanceLabel", ccFontSmall, ForegroundColor, Graphics.TEXT_JUSTIFY_LEFT, df_dist);
	        df_dist.ValPrev = distance;
        }

 		// Show do not disturb icon Moon icon
		if (doSleep && !df_sleep.ValPrev) {
			df_sleep = draw_wrap(dc, SLEEPICON, "SleepIcon", garminFont, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_sleep);
       		df_sleep.ValPrev = true;

		} else if (!doSleep && df_sleep.ValPrev) {
			df_sleep = draw_wrap(dc, SLEEPICON, "SleepIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_sleep);
       		df_sleep.ValPrev = false;
		}

 		// Show do Notification icon
		if (getApp().getProperty("UseNotification")) {
			if ( System.getDeviceSettings().notificationCount > 0 && !df_not.ValPrev ) {
				df_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, Graphics.COLOR_GREEN, Graphics.TEXT_JUSTIFY_CENTER, df_not);
				df_not.ValPrev = true;
			} else if ( System.getDeviceSettings().notificationCount == 0 && df_not.ValPrev ) {
				df_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_not);
				df_not.ValPrev = false;
			}
		} else {
			if (df_not.ValPrev) {
				df_not = draw_wrap(dc, NOTIFICATIONICON, "NotificationIcon", garminFont, BackgroundColor, Graphics.TEXT_JUSTIFY_CENTER, df_not);
				df_not.ValPrev = false;
			}
		}

		printDF(dc, "DF1", df_df1, df_df1i, info);
		printDF(dc, "DF2", df_df2, df_df2i, info);
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
	     	dc.setColor(ForegroundColor,BackgroundColor);
			dc.clear();
     		dc.drawText(df_secs.X, df_secs.Y, ccFont, Lang.format(".$1$", [System.getClockTime().sec.format("%02d")]), Graphics.TEXT_JUSTIFY_CENTER);
		}

 	}

	function setSecsClip(dc as Dc, j as Number) as Void {
		var dim = dc.getTextDimensions(".00", ccFont);

		do_setClip(dc, df_secs.X, df_secs.Y, dim[0], dim[1], j);
		dc.setColor(BackgroundColor, BackgroundColor);
		dc.clear();
		
		showSecsPrev = true;
		SecsClip = true;
	}

	function draw_wrap(dc as Dc, drawtext as Text, drawId as Text, font as WatchUi.Resource, FgColor as Number, j as Number, df) {
	
		// clear prev text
		if (df.W > 0) {
			do_setClip(dc, df.X, df.Y, df.W, df.H, j);
			dc.setColor(BackgroundColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(df.X, df.Y, font, df.ValPrev, j);
			dc.clearClip();
		}

		return drawcc(dc, df.X, df.Y, drawtext, drawId, font, FgColor, j, df);
	}

	function drawcc(dc as Dc, x as Number, y as Number, drawtext as Text, drawId as Text, font as WatchUi.Resource, FgColor as Number, j as Number, df) {
		var dim = dc.getTextDimensions(drawtext, font);
		var w = dim[0];
		var h = dim[1];

		do_setClip(dc, x, y, w, h, j);
		dc.setColor(FgColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, y, font, drawtext, j);
		dc.clearClip();

		df.set(drawtext, x, y, w, h);
		return df;
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

	function printDF(dc, df12, df, dfi, info) {

        var dfp = getApp().getProperty(df12);
		var dfval = null;
		var color = 0;
		var font = null;

		if (dfp == PRESSURE) {
			if (SensorHistory has :getPressureHistory && SensorHistory.getPressureHistory({:period => 1}).next().data != null) {
				dfval = SensorHistory.getPressureHistory({:period => 1}).next().data;
				dfval = (dfval/100).format("%.1f")+" mb";
			}
			//test dfval ="1024.5 mb";

		} else if (dfp == CALORIES) {
			if (info has :calories && info.calories != null) {
				dfval = info.calories.toString();
			}

		} else if (dfp == FLOORSCLIMBED) {
			if (info has :floorsClimbed && info.floorsClimbed != null) {
				dfval = info.floorsClimbed.toString();
			}

		} else if (dfp == FLOORSDESCENDED) {
			if (info has :floorsDescended && info.floorsDescended != null) {
				dfval = info.floorsDescended.toString();
			}

		} else if (dfp == ACTIVEMINUTESDAY) {
			if (info has :activeMinutesDay && info.activeMinutesDay != null) {
				dfval = info.activeMinutesDay.total.toString();
			}

		} else if (dfp == ACTIVEMINUTESWEEK) {
			if (info has :activeMinutesWeek && info.activeMinutesWeek != null) {
				dfval = info.activeMinutesWeek.total.toString();
			}

		} else if (dfp == ACTIVEMINUTESWEEKGOAL) {
			if (info has :activeMinutesWeekGoal && info.activeMinutesWeekGoal != null) {
				dfval = info.activeMinutesWeekGoal.toString();
			}

		} else if (dfp == ALTITUDE) {
			if (Activity has :getActivityInfo && Activity.getActivityInfo().altitude != null) {
				dfval = Activity.getActivityInfo().altitude;
				if( System.getDeviceSettings().elevationUnits == System.UNIT_METRIC ) {
					dfval = (dfval).format("%.0f")+"m";
				} else {
					dfval = (dfval*3.28084).format("%.f")+"ft";
				}
			}

		} else if (dfp == DATE) {
			var datenow = Gregorian.info(Time.now(), Time.FORMAT_LONG);
			dfval = Lang.format("$1$ $2$ $3$", [datenow.day_of_week, datenow.day, datenow.month]);

		} else if (dfp == EMPTY) {
			dfval = "";
		}

		if (dfval == null) {
				dfval = "--";
		}
		//System.println("dfval: " + dfval);

        if (dfval != df.ValPrev) {
			if (df12.equals("DF2") && (screen.equals("260x260") || screen.equals("280x280"))) {
	    	    font = ccFont;
			} else {
    	    	font = ccFontSmall;
			}
			df = draw_wrap(dc, dfval.toString(), df12, font, ForegroundColor, Graphics.TEXT_JUSTIFY_CENTER, df);
			df.ValPrev = dfval;
        }

		dfval = "";
		if (dfp == CALORIES) {
			color = Graphics.COLOR_RED;
			dfval = CALORIESICON;

		} else if (dfp == ALTITUDE) {
			color = ForegroundColor;
			dfval = ALTITUDEICON;

		} else if (dfp == FLOORSCLIMBED) {
			color = ForegroundColor;
			dfval = FLOORSCLIMBEDICON;

		} else if (dfp == FLOORSDESCENDED) {
			color = ForegroundColor;
			dfval = FLOORSDESCENDEDICON;

		} else if (dfp == ACTIVEMINUTESWEEK || dfp == ACTIVEMINUTESDAY) {
			color = ForegroundColor;
			dfval = ACTIVEMINUTESICON;

		} else if (dfp == ACTIVEMINUTESWEEKGOAL) {
			color = ForegroundColor;
			dfval = ACTIVEMINUTESWEEKGOALICON;
		}

        if (dfval != dfi.ValPrev) {
			dfi = draw_wrap(dc, dfval, df12, garminFontSmall, color, Graphics.TEXT_JUSTIFY_CENTER, dfi);
			dfi.ValPrev = dfval;
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
