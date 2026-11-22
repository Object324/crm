<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
require_once('include/database/PearDatabase.php');
global $adb;

if(isset($_REQUEST['hour_format']) && $_REQUEST['hour_format'] != '')
	$hour_format = $_REQUEST['hour_format'];
else
	$hour_format = 'am/pm';
	
$delquery = "delete from ld_sharedcalendar where userid=?";
$adb->pquery($delquery, array($_REQUEST["current_userid"]));

$selectedid = $_REQUEST['shar_userid'];
$sharedid = explode (";",$selectedid);
if(isset($sharedid) && $sharedid != null)
{
        foreach($sharedid as $sid)
        {
        	if($sid != '')
            {
				$sql = "insert into ld_sharedcalendar values (?,?)";
		        $adb->pquery($sql, array($_REQUEST["current_userid"], $sid));
            }
        }
}
if(isset($_REQUEST['start_hour']) && $_REQUEST['start_hour'] != '')
{
	$sql = "update ld_users set start_hour=? where id=?";
    $adb->pquery($sql, array($_REQUEST['start_hour'], $current_user->id));
}

$sql = "update ld_users set hour_format=? where id=?";
$adb->pquery($sql, array($hour_format, $current_user->id));
//RecalculateSharingRules();
header("Location: index.php?action=index&module=Calendar&view=".vtlib_purify($_REQUEST['view'])."&hour=".vtlib_purify($_REQUEST['hour'])."&day=".vtlib_purify($_REQUEST['day'])."&month=".vtlib_purify($_REQUEST['month'])."&year=".vtlib_purify($_REQUEST['year'])."&viewOption=".vtlib_purify($_REQUEST['viewOption'])."&subtab=".vtlib_purify($_REQUEST['subtab'])."&parenttab=".getParentTab());

?>