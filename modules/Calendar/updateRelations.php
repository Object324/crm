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
$idlist = $_REQUEST['idlist'];

if(isset($_REQUEST['idlist']) && $_REQUEST['idlist'] != '' && $_REQUEST['destination_module'] == 'Contacts')
{
	//split the string and store in an array
	$storearray = explode (";",trim($idlist,";"));
	foreach($storearray as $id)
	{
		if($id != '')
		{
			$record = vtlib_purify($_REQUEST['parentid']);
			$sql = "insert into ld_cntactivityrel values (?,?)";
			$adb->pquery($sql, array($id, $_REQUEST["parentid"]));
		}
	}
		header("Location: index.php?action=CallRelatedList&module=Calendar&activity_mode=Events&record=".$record);
	
}
elseif(isset($_REQUEST['entityid']) && $_REQUEST['entityid'] != '' && $_REQUEST['destination_module'] == 'Contacts')
{
	$record = vtlib_purify($_REQUEST["parentid"]);
	$sql = "insert into ld_cntactivityrel values (?,?)";
	$adb->pquery($sql, array($_REQUEST["entityid"], $_REQUEST["parentid"]));
	header("Location: index.php?action=DetailView&module=Calendar&activity_mode=Events&record=".$record);
}

//This if for adding the lingdang_users
if(isset($_REQUEST['idlist']) && $_REQUEST['idlist'] != '' && $_REQUEST['destination_module'] == 'Users')
{
	//split the string and store in an array
	$storearray = explode (";",$idlist);
	foreach($storearray as $id)
	{
		if($id != '')
		{
			$record = vtlib_purify($_REQUEST['parentid']);
			$sql = "insert into ld_salesmanactivityrel values (?,?)";
			$adb->pquery($sql, array($id, $_REQUEST["parentid"]));
		}
	}
	header("Location: index.php?action=DetailView&module=Calendar&activity_mode=Events&record=".$record);
}
elseif(isset($_REQUEST['entityid']) && $_REQUEST['entityid'] != '' && $_REQUEST['destination_module'] == 'Users')
{
	$record = vtlib_purify($_REQUEST['parentid']);
	$sql = "insert into ld_salesmanactivityrel values (?,?)";
	$adb->pquery($sql, array($_REQUEST["entityid"], $_REQUEST["parentid"]));
	header("Location: index.php?action=DetailView&module=Calendar&activity_mode=Events&record=".$record);
	
}

?>