<?php
global $currentModule,$current_user,$adb;
$modulename = $_REQUEST['modulename'];
$currentModule = $modulename;
$tabid = getTabid($currentModule);
$setype = $_REQUEST['setype'];
$Autohideafterfinding = $_REQUEST['Autohideafterfinding'];

if(isset($Autohideafterfinding) && $Autohideafterfinding!='') {
    setUsersettingByLabel($modulename, $current_user->id, 'Autohideafterfinding', $Autohideafterfinding);
}

?>