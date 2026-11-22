<?php

global $adb;
global $current_user;
if(!is_admin($current_user))
{
    dump("please admin login");
    
}
$userid=$_REQUEST['userid'];


$sql='delete from ld_loginerror where userid=?';

$adb->pquery($sql,array($userid));

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),getFixedLabel('UnlockSuccess'));


?>