<?php
/*+*******************************************************************************
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

$notesid = vtlib_purify($_REQUEST['record']);

$dbQuery = "select filename,folderid,filestatus from ld_notes where notesid= ?";
$result = $adb->pquery($dbQuery,array($notesid));
$folderid = $adb->query_result($result,0,'folderid');
$filename = $adb->query_result($result,0,'filename');
$filestatus = $adb->query_result($result,0,'filestatus');

$fileidQuery = "select attachmentsid from ld_seattachmentsrel where crmid = ?";
$fileidRes = $adb->pquery($fileidQuery,array($notesid));
$fileid = $adb->query_result($fileidRes,0,'attachmentsid');

$pathQuery = $adb->pquery("select path from ld_attachments where attachmentsid = ?",array($fileid));
$filepath = $adb->query_result($pathQuery,0,'path');
		
$fileinattachments = $root_directory.$filepath.$fileid.'_'.$filename;
if(!file($fileinattachments))$fileinattachments = $root_directory.$filepath.$fileid."_".$filename;

$newfileinstorage = $root_directory."/storage/$fileid-".$filename;

if($filestatus == 1){
	copy($fileinattachments,$newfileinstorage);
}

echo "<script>window.history.back();</script>";
exit();
?>