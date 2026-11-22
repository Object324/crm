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
global $adb, $mod_strings;
$rolename = $_REQUEST['rolename'];
$mode = $_REQUEST['mode'];
/*if(isset($_REQUEST['dup_check']) && $_REQUEST['dup_check']!='')
{
	if($mode != 'edit')
	{
		$query = 'select rolename from ld_role where rolename=?';
		$params = array($rolename);
	}
	else
	{
		$roleid=$_REQUEST['roleid'];
		$query = 'select rolename from ld_role where rolename=? and roleid !=?';
		$params = array($rolename, $roleid);
	}
	$result = $adb->pquery($query, $params);
	if($adb->num_rows($result) > 0)
	{
		echo $mod_strings['LBL_ROLENAME_EXIST'];
		die;
	}else
	{
		echo 'SUCCESS';
		die;
	}

}*/

$parentRoleId=$_REQUEST['parentrole'];
//Inserting values into Role Table
if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'edit')
{
	$roleId = $_REQUEST['roleid'];
	//$selected_col_string = 	$_REQUEST['selectedColumnsString'];
//	$profile_array = explode(';',$selected_col_string);
	updateRole($roleId,$rolename,"");
		
}
elseif(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'create')
{
//	$selected_col_string = 	$_REQUEST['selectedColumnsString'];
	//$profile_array = explode(';',$selected_col_string);
	//Inserting into ld_role Table
	$roleId = createRole($rolename,$parentRoleId,"");
  
	if($roleId != '')
	{
		insertRole2Picklist($roleId,$parentRoleId);
	}
	 	
}
/*
 *  * Function to populate default entries for the picklist while creating a new role--vashni
 *   */
function insertRole2Picklist($roleid,$parentroleid)
{
	global $adb;
	$sql = "insert into ld_role2picklist select '".$roleid."',picklistvalueid,picklistid,sortid from ld_role2picklist where roleid=?";
	$adb->pquery($sql, array($parentroleid));
	
}
/*
edit :Can
date:20130329
reason:用户授权及控制面板该进
*/
//$loc = "Location: index.php?action=listroles&module=Settings&parenttab=Settings";
//header($loc);
?>