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
	var DrawableById;
    var X;
    var Y;
    var WPrev;
    var HPrev;
	var J;

    public function initialize(valPrev, drawableById, j, w, h) {
		ValPrev = valPrev;
		DrawableById = drawableById;
		J = j;
		WPrev = w;
		HPrev = h;
    }

    public function save(valPrev, w, h) {
      ValPrev = valPrev;
      WPrev = w;
      HPrev = h;
    }
}

class WatchCLCView extends WatchUi.WatchFace {

	var screen = null as Text;
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

	var Secs = 0;
	var SecsPrev = 0;
	var showSecs = false;
	var showSecsPrev = false;
	var SecsClip = false;

	var cando1hz = false;

	var doSleep = false;
	
	var df_batt = new DF("", "BatteryLabel", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_batti = new DF("", "BatteryIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_ble = new DF(true, "BLEIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_steps = new DF("", "StepsLabel", Graphics.TEXT_JUSTIFY_RIGHT, 0, 0);
	var df_stepsi = new DF("", "StepsIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_dist = new DF("", "DistanceLabel", Graphics.TEXT_JUSTIFY_LEFT, 0, 0);
	var df_time = new DF("", "TimeLabel", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_hearti = new DF("", "HeartIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_heart = new DF("", "HeartLabel", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_sleep = new DF(true, "SleepIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_secs = new DF("", "SecsLabel", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_not = new DF(true, "NotificationIcon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_df1i = new DF("", "DF1Icon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_df1 = new DF("", "DF1", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_df2i = new DF("", "DF2Icon", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);
	var df_df2 = new DF("", "DF2", Graphics.TEXT_JUSTIFY_CENTER, 0, 0);

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

	enum {
		SECSDISABLED,
		SECSONGESTURE,
		SECSALWAYSON
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

		var view = View.findDrawableById(df_batt.DrawableById);
		df_batt.X = view.locX;
		df_batt.Y = view.locY;

		view = View.findDrawableById(df_batti.DrawableById);
		df_batti.X = view.locX;
		df_batti.Y = view.locY;

		view = View.findDrawableById(df_ble.DrawableById);
		df_ble.X = view.locX;
		df_ble.Y = view.locY;

		view = View.findDrawableById(df_steps.DrawableById);
		df_steps.X = view.locX;
		df_steps.Y = view.locY;

		view = View.findDrawableById(df_stepsi.DrawableById);
		df_stepsi.X = view.locX;
		df_stepsi.Y = view.locY;

		view = View.findDrawableById(df_dist.DrawableById);
		df_dist.X = view.locX;
		df_dist.Y = view.locY;

		view = View.findDrawableById(df_time.DrawableById);
		df_time.X = view.locX;
		df_time.Y = view.locY;

		view = View.findDrawableById(df_hearti.DrawableById);
		df_hearti.X = view.locX;
		df_hearti.Y = view.locY;

		view = View.findDrawableById(df_heart.DrawableById);
		df_heart.X = view.locX;
		df_heart.Y = view.locY;

		view = View.findDrawableById(df_sleep.DrawableById);
		df_sleep.X = view.locX;
		df_sleep.Y = view.locY;

		view = View.findDrawableById(df_secs.DrawableById);
		df_secs.X = view.locX;
		df_secs.Y = view.locY;

		view = View.findDrawableById(df_not.DrawableById);
		df_not.X = view.locX;
		df_not.Y = view.locY;

		view = View.findDrawableById(df_df1i.DrawableById);
		df_df1i.X = view.locX;
		df_df1i.Y = view.locY;

		view = View.findDrawableById(df_df1.DrawableById);
		df_df1.X = view.locX;
		df_df1.Y = view.locY;

		view = View.findDrawableById(df_df2i.DrawableById);
		df_df2i.X = view.locX;
		df_df2i.Y = view.locY;

		view = View.findDrawableById(df_df2.DrawableById);
		df_df2.X = view.locX;
		df_df2.Y = view.locY;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

		doSleep = System.getDeviceSettings().doNotDisturb;
		Secs = getApp().getProperty("Secs");

		if (SecsClip) {
			dc.setColor(BackgroundColor, BackgroundColor);
			dc.clear();
			dc.clearClip();
			showSecs = false;
			showSecsPrev = false;
			SecsPrev = Secs;
			SecsClip = false;
		}

		if (doSleep) {
			Secs = SECSDISABLED;
			showSecs = false;
		} else if (Secs == SECSALWAYSON) {
			if (cando1hz) {
				showSecs = true;
			} else {
				//should not do this unless I forget the correct settings.xml for the device
				getApp().setProperty("Secs", SECSONGESTURE);
				Secs = SECSONGESTURE;
			 }
		}

        ForegroundColor = getApp().getProperty("ForegroundColor");
        BackgroundColor = getApp().getProperty("BackgroundColor");

		if(
			ForegroundColor != ForegroundColorPrev || 
			BackgroundColor != BackgroundColorPrev
		   ){

			dc.setColor(ForegroundColor, BackgroundColor);
			dc.clear();

			drawcc(dc, HEARTICON, garminFont, Graphics.COLOR_RED, df_hearti);
			drawcc(dc, STEPSICON, garminFont, ForegroundColor, df_stepsi);

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
		drawcc(dc, Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]), ccFontBig, ForegroundColor, df_time);
		// test "22:33"
		
        // Show Secs
		if ( showSecs ) {
			drawcc(dc, Lang.format(".$1$", [clockTime.sec.format("%02d")]), ccFont, ForegroundColor, df_secs);
			showSecsPrev = true;
		} else if ( showSecsPrev ) {
			drawcc(dc, df_secs.ValPrev, ccFont, BackgroundColor, df_secs);
			showSecsPrev = false;
		}

 		// Show bluetooth icon if phone is connected
		if ( System.getDeviceSettings().phoneConnected && !df_ble.ValPrev ) {
			drawcc(dc, BLEICON, garminFont, Graphics.COLOR_BLUE, df_ble);
       		df_ble.ValPrev = true;
		} else if (!System.getDeviceSettings().phoneConnected && df_ble.ValPrev) {
			drawcc(dc, BLEICON, garminFont, BackgroundColor, df_ble);
       		df_ble.ValPrev = false;
		}

        var battery = System.getSystemStats().battery;
		var batteryLow = getApp().getProperty("LowBattery");
		var batteryStr = Lang.format("$1$%", [battery.format("%3d")]);

        if (batteryStr != df_batt.ValPrev || batteryLow != batteryLowPrev) {
			var shape = System.getDeviceSettings().screenShape;

    	    if (battery < batteryLow){
				if (shape == System.SCREEN_SHAPE_ROUND){
					drawcc(dc, BATTERYICON, garminFont, Graphics.COLOR_RED, df_batti);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
					drawcc(dc, BATTERYICON, garminFontSmall, Graphics.COLOR_RED, df_batti);
				}
				drawcc(dc, batteryStr, ccFontSmall, Graphics.COLOR_RED, df_batt);

    	    } else {
				if (shape == System.SCREEN_SHAPE_ROUND){
					drawcc(dc, BATTERYICON, garminFont, BackgroundColor, df_batti);
				} else { // System.SCREEN_SHAPE_SEMI_ROUND & System.SCREEN_SHAPE_RECTANGLE
					drawcc(dc, BATTERYICON, garminFontSmall, BackgroundColor, df_batti);
				}
				drawcc(dc, batteryStr, ccFontSmall, ForegroundColor, df_batt);
    	    }

			df_batt.ValPrev = batteryStr;
			batteryLowPrev = batteryLow;
        }

        if (heart != df_heart.ValPrev) {
			drawcc(dc, heart, ccFont, ForegroundColor, df_heart);
			df_heart.ValPrev = heart;
        }

        if (steps != df_steps.ValPrev) {
			drawcc(dc, steps, ccFontSmall, ForegroundColor, df_steps);
	        df_steps.ValPrev = steps;
        }

        if (distance != df_dist.ValPrev) {
			drawcc(dc, distance, ccFontSmall, ForegroundColor, df_dist);
	        df_dist.ValPrev = distance;
        }

 		// Show do not disturb icon Moon icon
		if (doSleep && !df_sleep.ValPrev) {
			drawcc(dc, SLEEPICON, garminFont, ForegroundColor, df_sleep);
       		df_sleep.ValPrev = true;
		
		} else if (!doSleep && df_sleep.ValPrev) {
			drawcc(dc, SLEEPICON, garminFont, BackgroundColor, df_sleep);
       		df_sleep.ValPrev = false;
		}

 		// Show do Notification icon
		if (getApp().getProperty("UseNotification")) {
			if ( System.getDeviceSettings().notificationCount > 0 && !df_not.ValPrev ) {
				drawcc(dc, NOTIFICATIONICON, garminFont, Graphics.COLOR_GREEN, df_not);
				df_not.ValPrev = true;
			} else if ( System.getDeviceSettings().notificationCount == 0 && df_not.ValPrev ) {
				drawcc(dc, NOTIFICATIONICON, garminFont, BackgroundColor, df_not);
				df_not.ValPrev = false;
			}
		} else {
			if (df_not.ValPrev) {
				drawcc(dc, NOTIFICATIONICON, garminFont, BackgroundColor, df_not);
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

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
		// to refresh with next onUpdate
		ForegroundColorPrev = null;
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

		if ( Secs == SECSALWAYSON ) {
			//drawcc(dc, Lang.format(".$1$", [System.getClockTime().sec.format("%02d")]), ccFont, ForegroundColor, df_secs);
			if (!SecsClip) {
					setSecsClip(dc);
			}
			dc.setColor(ForegroundColor,BackgroundColor);
			dc.clear();
			dc.drawText(df_secs.X, df_secs.Y, ccFont, Lang.format(".$1$", [System.getClockTime().sec.format("%02d")]), df_secs.J);

		} else if(SecsPrev == SECSALWAYSON){
			if (SecsClip) {
				dc.setColor(BackgroundColor, BackgroundColor);
				dc.clear();
				dc.clearClip();
				SecsClip = false;
			}
			showSecs = false;
			showSecsPrev = false;
			SecsPrev = Secs;
		}

 	}

	function setSecsClip(dc as Dc) as Void {
		var dim = dc.getTextDimensions(".00", ccFont);

		do_setClip(dc, df_secs.X, df_secs.Y, dim[0], dim[1], df_secs.J);
		dc.setColor(BackgroundColor, BackgroundColor);
		dc.clear();
		showSecsPrev = true;
		SecsPrev = Secs;
		SecsClip = true;
	}

	function drawcc(dc as Dc, drawtext as Text, font as WatchUi.Resource, FgColor as Number, df as DF) {

		// clear prev text if any
		if (df.WPrev > 0) {
			do_setClip(dc, df.X, df.Y, df.WPrev, df.HPrev, df.J);
			dc.setColor(BackgroundColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(df.X, df.Y, font, df.ValPrev, df.J);
			dc.clearClip();
		}

		var dim = dc.getTextDimensions(drawtext, font);
		var w = dim[0];
		var h = dim[1];

		do_setClip(dc, df.X, df.Y, w, h, df.J);
		dc.setColor(FgColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(df.X, df.Y, font, drawtext, df.J);
		dc.clearClip();

		df.save(drawtext, w, h);
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
			drawcc(dc, dfval, font, ForegroundColor, df);
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
			drawcc(dc, dfval, garminFontSmall, color, dfi);
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
		if ( Secs == SECSALWAYSON ) {
			getApp().setProperty("Secs", SECSONGESTURE);
		}

    }
}
