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

//Getting the Parameters from the Convert Form
$id = vtlib_purify($_REQUEST["record"]);
$module = vtlib_purify($_REQUEST["module"]);
$assigned_user_id = vtlib_purify($_REQUEST["assigned_user_id"]);
$createpotential = vtlib_purify($_REQUEST["createpotential"]);
$potential_name = vtlib_purify($_REQUEST["potential_name"]);
$close_date = vtlib_purify($_REQUEST["closedate"]);
$current_user_id = vtlib_purify($_REQUEST["current_user_id"]);

$idlist=split(';',$_REQUEST['idlist']);

$query='select * from ld_troubletickets';
$rs=$adb->pquery($query, array());
for($i=0;$i<count($idlist);$i++)
{
	$id=$idlist[$i];
	if(isset($_REQUEST['change_status']))
	{
		$changevalue=$_REQUEST['status'];
		$changekey='status';
	}
	if(isset($_REQUEST['change_owner']))
	{
		$resultset=$adb->pquery('select * from ld_users where user_name=?', array($_REQUEST['assigned_user_id']));
		$changevalue=$adb->query_result($resultset,0,"id");
		$changekey='assigned_user_id';
	}
	$sql="update ld_troubletickets set $changekey = ? where id = ?";
	$adb->pquery($sql, array($changevalue, $id));
}
header("Location: index.php?action=index&module=HelpDesk");

?>