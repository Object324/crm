<?php
global $currentModule,$current_user,$adb;
$modulename = $_REQUEST['modulename'];
$currentModule = $modulename;
$tabid = getTabid($currentModule);
$Richtexthide = $_REQUEST['Richtexthide'];


if(isset($Richtexthide) && $Richtexthide!='') {
    setUsersettingByLabel($modulename, $current_user->id, 'Richtexthide', $Richtexthide);
}
ConvertTojsonString(1,array(),'susses');

?>