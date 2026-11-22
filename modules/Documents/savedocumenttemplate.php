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


$db = PearDatabase::getInstance();
$folderName = vtlib_purify($_REQUEST["foldername"]);
$templateName = from_html($_REQUEST["templatename"]);
$templateid = vtlib_purify($_REQUEST["templateid"]);
$description = from_html($_REQUEST["description"]);
$subject = from_html($_REQUEST["subject"]);
$body = fck_from_html($_POST["body"]);
if(!empty($templateName) && !empty($_REQUEST['SaveCheck']) && $_REQUEST['SaveCheck'] == 'yes'){
    $query="select templateName from ld_documenttemplates where templateName=?";
    if(!empty($templateid)){
        $query .= ' and templateid != ' . $templateid;
    }   
    $result = $adb->pquery($query,array($templateName));
    $num_rows=$adb->num_rows($result);
    $error = 'success';
	$_REQUEST['diony']='diony';
    if($num_rows >= 1){
		ConvertTojsonString(-1,array('log'=>'模板名称已存在！'),"success");
    }else{
		ConvertTojsonString(1,array(),"success");
	}
}


if(isset($templateid) && $templateid !='')
{
	$sql = "update ld_documenttemplates set foldername =?, templatename =?, subject =?, description =?, body =? where templateid =?";
	$params = array($folderName, $templateName, $subject, $description, $body, $templateid);
	$adb->pquery($sql, $params);
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
else
{
	$sql = "insert into ld_documenttemplates (foldername,templatename,description,body,deleted) values (?,?,?,?,?)";
    
    $params = array($folderName, $templateName, $description, $body, 0);
	$adb->pquery($sql,$params);
    $templateid=$adb->getLastInsertID();
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
?>