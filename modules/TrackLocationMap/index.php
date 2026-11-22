<?php
global $adb;
//  <script src="https://map.qq.com/api/gljs?v=1.exp&key=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77"></script>
if($_REQUEST['maptype']&&$_REQUEST['maptype']=='showtrack')
{
    require_once ("modules/TrackLocationMap/ShowLocationTrack.php");
}
require_once ("modules/TrackLocationMap/ShowLocationPosition.php");

?>