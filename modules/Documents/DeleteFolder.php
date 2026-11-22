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
 
require_once('modules/Documents/Documents.php');

global $adb;
global $current_user;
if($current_user->is_admin != 'on')
{
	echo 'NOT_PERMITTED';
	die;	
}
else
{	
	
	if(isset($_REQUEST['folderid']) && $_REQUEST['folderid'] != '')
		$folderId = $_REQUEST['folderid'];
	else
	{
		echo 'FAILURE';
		die;
	}
	if(isset($_REQUEST['deletechk']) && $_REQUEST['deletechk'] == 'true')
	{
		$query = "select notesid from ld_notes INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_notes.notesid WHERE ld_notes.folderid = ? and ld_crmentity.deleted = 0";
		$result = $adb->pquery($query,array($folderId));
		if($adb->num_rows($result) > 0)
		{
			echo 'FAILURE';
		}
		else
		{
			header("Location: index.php?action=DocumentsAjax&file=ListView&mode=ajax&module=Documents");
			exit;
		}
	}
	else
	{
		$sql="delete from ld_attachmentsfolder where (folderid=? and folderid != 1)";
		$adb->pquery($sql,array($folderId));
		header("Location: index.php?action=DocumentsAjax&file=ListView&mode=ajax&module=Documents");
		exit;
	}
}
?>