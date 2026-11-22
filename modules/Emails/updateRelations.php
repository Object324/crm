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
global $adb, $currentModule;
$idlist = vtlib_purify($_REQUEST['idlist']);
$record = vtlib_purify($_REQUEST["parentid"]);

$storearray = array();
if(!empty($_REQUEST['idlist'])) {
	// Split the string of ids
	$storearray = explode (";",trim($idlist,";"));
} else if(!empty($_REQUEST['entityid'])){
	$storearray = array($_REQUEST['entityid']);
}
foreach($storearray as $id)
{
	if($id != '')
	{			
		$sql = "insert into ld_seactivityrel (crmid,activityid) values (?,?)";
		$adb->pquery($sql, array($id, $record));
	}
}
if(isset($_REQUEST['user_id']) && $_REQUEST['user_id'] != '')
{
	$record = $_REQUEST['record'];
	$sql = "insert into ld_salesmanactivityrel values (?,?)";
	$adb->pquery($sql, array($_REQUEST["user_id"], $record));	
}

header("Location: index.php?action=CallRelatedList&module=Emails&record=".vtlib_purify($record));

?>