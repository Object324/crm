<?php
$VersionInfo = getVersionInfo();
if($VersionInfo['account']=='shenglawei')
{
    include(globalStatic::$root_directory."modules/CustomForm01/Calendar_ListView.php");
}
else

include(globalStatic::$root_directory."modules/lingdang/ListView.php");
?>