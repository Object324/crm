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

require_once('include/logging.php');
require_once('include/database/PearDatabase.php');
$folderid = vtlib_purify($_REQUEST['folderid']);

if(isset($_REQUEST['idlist']) && $_REQUEST['idlist']!= '')
{
	$id_array = Array();
	$id_array = explode(':',$_REQUEST['idlist']);
	for($i = 0;$i < count($id_array)-1;$i++)
	{
		ChangeFolder($id_array[$i],$folderid);	
	}
	header("Location: index.php?action=ReportsAjax&file=ListView&mode=ajaxdelete&module=Reports");
}elseif(isset($_REQUEST['record']) && $_REQUEST['record']!= '')
{
	$id = vtlib_purify($_REQUEST["record"]);
	ChangeFolder($id,$folderid);	
	header("Location: index.php?action=ReportsAjax&file=ListView&mode=ajaxdelete&module=Reports");
}


/** To Change the Report to another folder
  * @param $reportid -- The report id
  * @param $folderid -- The folderid the which the report to be moved
  * @returns nothing 
 */
function ChangeFolder($reportid,$folderid)
{
	global $adb;
	$imovereportsql = "update ld_report set folderid=? where reportid=?";
	$imovereportsqlresult = $adb->pquery($imovereportsql, array($folderid, $reportid));
}
?>