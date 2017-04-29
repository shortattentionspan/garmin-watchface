//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Act;

//! This implements an analog watch face
//! Original design by Austen Harbour

class ReversibleView extends Ui.WatchFace {
    var font;
    var BTOn;
    var battlevel;
    var notificationicon;
    var AlarmClock;
    var iconFont;
    
    //part of sleep mode workaround
    var profile = UserProfile.getProfile();  
    var sleep=profile.sleepTime.value();
    var wake=profile.wakeTime.value();
    
    var markerFont;
    
    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
    	iconFont = Ui.loadResource(Rez.Fonts.id_font_icons);
        markerFont = Ui.loadResource(Rez.Fonts.id_font_markers);
    }


    //workaround for sleep mode from https://forums.garmin.com/showthread.php?350295
    function mySleepMode()
    {
    	
    	var sleepMode=false;
    	if(sleep==wake) { return sleepMode; }
    	var nowT=Sys.getClockTime();
    	var now=nowT.hour*3600+nowT.min*60+nowT.sec;
    	if(sleep>wake) {
    		if(now>=sleep || now<=wake)	{sleepMode=true; }
    	} else {
    		if(now<=wake && now>=sleep)	{sleepMode=true; }  	
    	}
    	////Sys.println("t="+now+" "+wake+" "+sleep+" "+sleepDefault);
    	return sleepMode;
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Draw the watch hand
    //! @param dc Device Context to Draw
    //! @param angle Angle to draw the watch hand
    //! @param length Length of the watch hand
    //! @param width Width of the watch hand
    function drawHand(dc, angle, length, width, dialdrop)
    {
        // Map out the coordinates of the watch hand
        var coords = [ [-(width/2),0], [-(width/2), -length], [width/2, -length], [width/2, 0] ];
        var result = new [4];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getWidth() / 2 + dialdrop;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            if (App.getApp().getProperty("DisplayReverse"))
            {
            result[i] = [ centerX-x, centerY+y];
            }
            else
            {
            result[i] = [ centerX+x, centerY+y];
            }
        }

        // Draw the polygon
        dc.fillPolygon(result);
        dc.fillPolygon(result);
    }


    //! Handle the update event
    function onUpdate(dc)
    {
        var screenWidth = dc.getWidth();
        var clockTime = Sys.getClockTime();
        var hour;
        var min;
        var fontheight = dc.getFontHeight(Gfx.FONT_NUMBER_MILD);
        var actinfo = Act.getInfo();
        var SleepMsg = "Go to sleep";
        var dev = Sys.getDeviceSettings();
        var stats = Sys.getSystemStats();
        var batt = "Battery: xx%";
        var inboard = 2;
        var i = 1;
        var j = 1;
        
        var timeFormat = "$1$:$2$";
    
        var width = dc.getWidth();
        var height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        //var sleepmode = actinfo.isSleepMode;

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
        var backgroundColor = App.getApp().getProperty("BackgroundColor");
        
        // Clear the screen
        dc.clear();
        //there's probably a more elegant way to draw the background other than drawing a large rectangle...
        if (backgroundColor == 0x000001) {
        	backgroundColor=App.getApp().getProperty("BackgroundColorR")+App.getApp().getProperty("BackgroundColorG")+App.getApp().getProperty("BackgroundColorB");
        }
        dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0,0,dc.getWidth(), dc.getHeight());
        
        //draw markers
        dc.setColor(App.getApp().getProperty("MarkerColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(0, 0, markerFont, "1", Gfx.TEXT_JUSTIFY_LEFT);
        
        // Draw the numbers
        dc.setColor(App.getApp().getProperty("NumberColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText((width/2),inboard ,Gfx.FONT_NUMBER_MILD,"12",Gfx.TEXT_JUSTIFY_CENTER);
        if (App.getApp().getProperty("DisplayReverse"))
        {
        	//dc.drawText(width-inboard-6,width/2-fontheight/2-2,Gfx.FONT_NUMBER_MILD,"9", Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.drawText(inboard+4,width/2-fontheight/2 -2,Gfx.FONT_NUMBER_MILD,"3",Gfx.TEXT_JUSTIFY_LEFT);
        }
        else
        {
        	//dc.drawText(width-inboard-6,width/2-fontheight/2-2,Gfx.FONT_NUMBER_MILD,"3", Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.drawText(inboard+5,width/2-fontheight/2 -2,Gfx.FONT_NUMBER_MILD,"9",Gfx.TEXT_JUSTIFY_LEFT);
        }
        dc.drawText(width/2,width-fontheight-2-inboard,Gfx.FONT_NUMBER_MILD,"6", Gfx.TEXT_JUSTIFY_CENTER);
        


		// Write the date
        //dc.drawText(width/2,(width/4),Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(App.getApp().getProperty("DateColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2,height-42,Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        
        //date in place of number
        dc.drawText(width-inboard-6,width/2-fontheight/2,Gfx.FONT_LARGE,info.day, Gfx.TEXT_JUSTIFY_RIGHT);
        
        // show steps
        dc.setColor(App.getApp().getProperty("StepsColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2, width  -4, Gfx.FONT_MEDIUM, ""+actinfo.steps + " / "+actinfo.stepGoal , Gfx.TEXT_JUSTIFY_CENTER);
        	
        // Draw blue bluetooth icon if connected to phone
        if (dev.phoneConnected)
        	{
        	dc.setColor(App.getApp().getProperty("BTIconColor"), Gfx.COLOR_TRANSPARENT);
        	dc.drawText(width-2,0,iconFont,"4",Gfx.TEXT_JUSTIFY_RIGHT);
        	}
        	
        //Show alarm number
        //j =  width + dc.getFontHeight(Gfx.FONT_SMALL) -3;
        //j = width - 24;
        j = height - dc.getFontHeight(Gfx.FONT_MEDIUM);
        if (dev.alarmCount>0)
        {
        
        dc.setColor(App.getApp().getProperty("AlarmIconColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(1,j,iconFont,"3",Gfx.TEXT_JUSTIFY_LEFT);
        batt=dev.alarmCount;
        dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(13,j,Gfx.FONT_MEDIUM,batt,Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        //Show message number
        // j = width + dc.getFontHeight(Gfx.FONT_SMALL)-3 + dc.getFontHeight(Gfx.FONT_TINY)-3;
        
        if (dev.notificationCount>0)
        {
        //j=width-24;
        dc.setColor(App.getApp().getProperty("NotificationIconColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(width-30,j+3,iconFont,"2",Gfx.TEXT_JUSTIFY_LEFT);
        batt = dev.notificationCount;
        i= width - 15;
        if (dev.notificationCount==10 || (dev.notificationCount >11 && dev.notificationCount<20))
        {i=i-1;}   //hack for kerning of number 1
        //j = height - dc.getFontHeight(Gfx.FONT_MEDIUM) - 2;
        dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(i, j ,Gfx.FONT_MEDIUM,batt,Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        //Show battery percentage
        dc.setColor(App.getApp().getProperty("BatteryIconColor"), Gfx.COLOR_TRANSPARENT);
        batt = stats.battery.format("%d");
        //j = 1; //width + dc.getFontHeight(Gfx.FONT_SMALL) -3;
        i = 1 ; //width-21;
        dc.drawText(i,0,iconFont,"1",Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(16,-3 ,Gfx.FONT_MEDIUM, batt ,Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the hour. Convert it to minutes and
        // compute the angle.
        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        dc.setColor(App.getApp().getProperty("HourHandColor"), Gfx.COLOR_TRANSPARENT);
        drawHand(dc, hour, 42, 6,0);
        // Draw the minute
        min = ( clockTime.min / 60.0) * Math.PI * 2;
        dc.setColor(App.getApp().getProperty("MinuteHandColor"), Gfx.COLOR_TRANSPARENT);
        drawHand(dc, min, 62, 4, 0);
        // Draw the inner circle
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.fillCircle(width/2, width/2, 5);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(width/2, width/2, 5);
        
        //Print digital time at bottom
        j = height - dc.getFontHeight(Gfx.FONT_MEDIUM)+2;
        dc.setColor(App.getApp().getProperty("DigitalTimeColor"), Gfx.COLOR_TRANSPARENT);
        //batt=clockTime.hour +":"+clockTime.min;
        hour = clockTime.hour;
        if (!Sys.getDeviceSettings().is24Hour)
        	{
            hour = hour % 12;
            hour = (hour == 0) ? 12 : hour;
        	}
        else
        	{
            if (App.getApp().getProperty("UseMilitaryFormat"))
            	{
                timeFormat = "$1$$2$";
                hour = hour.format("%02d");
            	}
        	}
        	
        batt = Lang.format(timeFormat, [hour, clockTime.min.format("%02d")]);
      
        
        
        //hour = clockTime.hour % 12;
        //hour = (hour == 0) ? 12 : hour;
        //min = clockTime.min;
        //batt = Lang.format("$1$:$2$",[hour, min.format("%02d")]);
       
        //dc.drawText(width/2,j,Gfx.FONT_MEDIUM,clockTime.hour +":"+clockTime.min,Gfx.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(width/2,j,Gfx.FONT_MEDIUM,batt,Gfx.TEXT_JUSTIFY_CENTER);

    }


    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}

