# garmin-watchface
This is a watchface for the Garmin VivoActive HR smartwatch/activity tracker using the Garmin
Connect IQ development platform.

Features of this watchface are:  
* Round analog dial
* Option to have the hands run backwards in a counter clockwise rotation
* Status icons in the corners of the screen
  * Bluetooth connection. Note that it does not indicate whether Bluetooth is on or not, just whether there
  is a connection to the host device. Bluetooth could be on with no connection, or Bluetooth cold be off
  and there had better be no connection.
  * Battery level of the watch in percent
  * Number of alarms turned on on the watch. Note that the simulator maxes out at three, but the watch can exceed
  that many. I do not know how many it is actually capable of. I hope that I wrote the program such that greater
  than nine alarms should be indicated by a "**_+_**"
  * Number of smart notifications from the host app that have not been dealt with. Currently, all you can do is
  either ignore the notification which does not change the count, or you can dismiss the notification, which
  decrements the number (though it does not necessarily decrement it by just one. Sometimes there are chain
  effects and it can decrement by more than one)
* At the bottom-center of the screen are three lines for
  * Step count and step target
  * Date (currently just a fixed format. I should see if it is possible to query the watch and find out what the
  user's preferred date format is)
  * Time. Since this was completely lifted from the tutorial, it has accommodation for 12 and 24 hour time to
  match the user's preference on the watch. It also has the option to do a military time, which is just 24 hour
  time without the separator colon. This is only active if the user checks the military time option in the user
  settings, _AND_ has the watch in 24 hour time.

There are user settings for:
  * Military time
  * Reverse hand rotation
  * Colors of various things
    * Background
    * Hand colors
    * Hour number color
    * Steps line
    * Date line
    * Digital time line
    
I do need to add more settings for colors of icons and hour/minute markers, but that requires
  changing a bit more behind the scenes, which I'm working on.
