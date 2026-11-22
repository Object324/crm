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
$check=$_REQUEST['check'];
global $default_charset;
$id='';
if($_REQUEST['check']== 'reportCheck')
{
	$reportName = $_REQUEST['reportName'];
	$sSQL="select * from ld_report where reportname=?";
	
	$sqlresult = $adb->pquery($sSQL, array(trim($reportName)));
	echo $adb->num_rows($sqlresult);

}
else if($_REQUEST['check']== 'folderCheck')
{
	$folderName = function_exists(iconv) ? @iconv("UTF-8",$default_charset, $_REQUEST['folderName']) : $_REQUEST['folderName'];
	$folderName =str_replace(array("'",'"'),'',$folderName);
	if($folderName == "" || !$folderName)
	{
		echo "999";
	}else
	{
		$SQL="select * from ld_reportfolder where foldername=?";
		$sqlresult = $adb->pquery($SQL, array(trim($folderName)));
		$id = $adb->query_result($sqlresult,0,"folderid");
		echo trim($adb->num_rows($sqlresult)."::".$id);
	}
}

?>