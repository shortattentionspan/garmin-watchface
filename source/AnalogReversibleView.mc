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
    
    //part of sleep mode workaround
    var profile = UserProfile.getProfile();  
    var sleep=profile.sleepTime.value();
    var wake=profile.wakeTime.value();
    
    //var fontheight = 15; //Gfx.Dc.getFontHeight(font);
    var markers;
    
    function initialize() {
    	//markers = new Rez.Drawables.bkgnd();
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
    	//setLayout(Rez.Layouts.WatchFace(dc));
        BTOn = Ui.loadResource(Rez.Drawables.id_BTOn);
        battlevel = Ui.loadResource(Rez.Drawables.id_batt);
        notificationicon = Ui.loadResource(Rez.Drawables.id_notification);
        AlarmClock = Ui.loadResource(Rez.Drawables.id_alarm);
        markers = Ui.loadResource(Rez.Drawables.id_markers);
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
        //var fontwidth = dc.getFontWidth(Gfx.FONT_NUMBER_MILD);
        var actinfo = Act.getInfo();
        var SleepMsg = "Go to sleep";
        var dev = Sys.getDeviceSettings();
        var stats = Sys.getSystemStats();
        var batt = "Battery: xx%";
        var inboard = 2;
        var i = 1;
        var j = 1;
        var dialShift = 0;   //how much to shift the dial down from the top
        
        var timeFormat = "$1$:$2$";
    
        var width = dc.getWidth();
        var height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        //var sleepmode = actinfo.isSleepMode;

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
        
        // Clear the screen
        //dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.setColor(App.getApp().getProperty("BackgroundColor"), Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0,0,dc.getWidth(), dc.getHeight());
        //dc.clear();
        
        //markers.draw(dc);
        dc.drawBitmap(0,dialShift,markers);
        
        // Draw the gray rectangle
        //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
        //dc.fillPolygon([[0,0],[dc.getWidth(), 0],[dc.getWidth(), dc.getHeight()],[0,dc.getHeight()]]);
        // Draw the numbers
        //dc.setColor(App.getApp().getProperty("ForegroundColor"), Gfx.COLOR_TRANSPARENT);
        //dc.setColor(App.getApp().getProperty("ForegroundColor"), App.getApp().getProperty("BackgroundColor"));
        //dc.setColor(App.getApp().getProperty("NumberColor"), Gfx.COLOR_TRANSPARENT);
        dc.setColor(App.getApp().getProperty("NumberColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText((width/2),inboard+dialShift,Gfx.FONT_NUMBER_MILD,"12",Gfx.TEXT_JUSTIFY_CENTER);
        if (App.getApp().getProperty("DisplayReverse"))
        {
        	//dc.drawText(width-inboard-6,width/2-fontheight/2+dialShift-2,Gfx.FONT_NUMBER_MILD,"9", Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.drawText(inboard+4,width/2-fontheight/2+dialShift -2,Gfx.FONT_NUMBER_MILD,"3",Gfx.TEXT_JUSTIFY_LEFT);
        }
        else
        {
        	//dc.drawText(width-inboard-6,width/2-fontheight/2+dialShift-2,Gfx.FONT_NUMBER_MILD,"3", Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.drawText(inboard+5,width/2-fontheight/2+dialShift -2,Gfx.FONT_NUMBER_MILD,"9",Gfx.TEXT_JUSTIFY_LEFT);
        }
        dc.drawText(width/2,width-fontheight-2-inboard+dialShift,Gfx.FONT_NUMBER_MILD,"6", Gfx.TEXT_JUSTIFY_CENTER);
        


		// Write the date
        //dc.drawText(width/2,(width/4)+dialShift,Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(App.getApp().getProperty("DateColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2,height-42,Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        
        //date in place of number
        dc.drawText(width-inboard-6,width/2-fontheight/2+dialShift,Gfx.FONT_LARGE,info.day, Gfx.TEXT_JUSTIFY_RIGHT);
        
        // Write "Go to sleep" if sleep mode
        dc.setColor(App.getApp().getProperty("StepsColor"), Gfx.COLOR_TRANSPARENT);
        //if (mySleepMode())
        //if (actinfo.isSleepMode)
        	//{
        	//dc.drawText(width/2, width + dialShift -4, Gfx.FONT_SMALL, SleepMsg , Gfx.TEXT_JUSTIFY_CENTER);
        	//} 
        	//else
        	//{
        	dc.drawText(width/2, width +dialShift -4, Gfx.FONT_MEDIUM, ""+actinfo.steps + " / "+actinfo.stepGoal , Gfx.TEXT_JUSTIFY_CENTER);
        	//}
        	
        	
        // Draw blue bluetooth icon if connected to phone
        if (dev.phoneConnected)
        	{
        	dc.drawBitmap(width-16,1,BTOn);
        	}
        	
        //Show alarm number
        //j =  width + dc.getFontHeight(Gfx.FONT_SMALL) -3;
        //j = width - 24;
        j = height - dc.getFontHeight(Gfx.FONT_MEDIUM);
        if (dev.alarmCount>0)
        {
        
        dc.drawBitmap(1,j+1,AlarmClock);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        batt=dev.alarmCount;
        dc.drawText(13,j,Gfx.FONT_MEDIUM,batt,Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        //Show message number
        // j = width + dc.getFontHeight(Gfx.FONT_SMALL)-3 + dc.getFontHeight(Gfx.FONT_TINY)-3;
        
        if (dev.notificationCount>0)
        {
        //j=width-24;
        dc.drawBitmap(width-30,j+4,notificationicon);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        batt = dev.notificationCount;
        i= width - 15;
        if (dev.notificationCount==10 || (dev.notificationCount >11 && dev.notificationCount<20))
        {i=i-1;}   //hack for kerning of number 1
        //j = height - dc.getFontHeight(Gfx.FONT_MEDIUM) - 2;
        dc.drawText(i, j ,Gfx.FONT_MEDIUM,batt,Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        //Show battery percentage
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        batt = stats.battery.format("%d");
        //j = 1; //width + dc.getFontHeight(Gfx.FONT_SMALL) -3;
        i = 1 ; //width-21;
        dc.drawBitmap(i,1,battlevel);
        dc.drawText(16,-3 ,Gfx.FONT_MEDIUM, batt ,Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the hash marks
        //drawHashMarks(dc);
        // Draw the hour. Convert it to minutes and
        // compute the angle.
        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        dc.setColor(App.getApp().getProperty("HourHandColor"), Gfx.COLOR_TRANSPARENT);
        drawHand(dc, hour, 42, 6,dialShift);
        // Draw the minute
        min = ( clockTime.min / 60.0) * Math.PI * 2;
        dc.setColor(App.getApp().getProperty("MinuteHandColor"), Gfx.COLOR_TRANSPARENT);
        drawHand(dc, min, 62, 4, dialShift);
        // Draw the inner circle
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.fillCircle(width/2, width/2+dialShift, 5);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(width/2, width/2+dialShift, 5);
        
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

/*class ReversibleWatch extends App.AppBase
{
    function onStart()
    {
    }

    function onStop()
    {
    }

    function getInitialView()
    {
        return [new Reversible()];
    }
}
*/