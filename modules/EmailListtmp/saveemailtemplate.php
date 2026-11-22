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
require_once('include/utils/utils.php');

global $current_user;
$db = PearDatabase::getInstance();
$folderName = vtlib_purify($_REQUEST["foldername"]);
$templateName = from_html($_REQUEST["templatename"]);
$templateid = vtlib_purify($_REQUEST["templateid"]);
$description = from_html($_REQUEST["description"]);
$subject = from_html($_REQUEST["subject"]);
$body = fck_from_html($_POST["emailbody"]);

if(isset($templateid) && $templateid !='')
{
	
	$sql = "update ld_emailtemplates set foldername =?, templatename =?, subject =?, description =?, body =? where templateid =?";
	$params = array($folderName, $templateName, $subject, $description, $body, $templateid);
	$adb->pquery($sql, $params);
 
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,$arr,"success");
}
else
{
	$templateid = $db->getUniqueID('ld_emailtemplates');
	$sql = "insert into ld_emailtemplates (foldername,templatename,`subject`,description,body,deleted,templateid,smcreatorid)values (?,?,?,?,?,?,?,?)
";
	$params = array($folderName, $templateName, $subject, $description, $body, 0, $templateid,$current_user->id);
	$adb->pquery($sql, $params);

	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,$arr,"success");
}
?>