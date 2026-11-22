<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

require_once('include/database/PearDatabase.php');
global $default_charset;
global $adb;
$conv_sub = function_exists(iconv) ? @iconv("UTF-8",$default_charset, $_REQUEST['notifysubject']) : $_REQUEST['notifysubject'];
$conv_body = function_exists(iconv) ? @iconv("UTF-8",$default_charset, $_REQUEST['notifybody']) : $_REQUEST['notifybody'];
$notifysubject =str_replace(array("'",'"'),'',$conv_sub);
$notifybody =str_replace(array("'",'"'),'',$conv_body);

if($notifysubject != '' && $notifybody != '')
{
	if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
	{	
		$query="UPDATE ld_notificationscheduler set notificationsubject=?, notificationbody=?, active =? where schedulednotificationid=?";
		$params = array($notifysubject, $notifybody, $_REQUEST['active'], $_REQUEST['record']);
		$adb->pquery($query, $params);	
	}
	$loc = "Location: index.php?action=SettingsAjax&file=listnotificationschedulers&module=Settings&directmode=ajax";
	header($loc);
}
else
{
	echo ":#:FAILURE";
}

?>