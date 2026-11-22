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


global $mod_strings;
global $app_strings;
global $app_list_strings;
global $current_user;

//Display the mail send status
$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$sql="select * from ld_systems where server_type = ?";
$result = $adb->pquery($sql, array('email'));
$mail_server = $adb->query_result($result,0,'server');
$mail_server_username = $adb->query_result($result,0,'server_username');
$mail_server_password = $adb->query_result($result,0,'server_password');
$smtp_auth = $adb->query_result($result,0,'smtp_auth');
$from_email_field = $adb->query_result($result, 0, 'from_email_field');
$smtp_ssl=$adb->query_result($result,0,'smtp_ssl');

$servername = vtlib_purify($_REQUEST['server_name']);
$username = vtlib_purify($_REQUEST['server_user']);
$PassWord=vtlib_purify($_REQUEST['server_password']);
$request_smtp_ssl=vtlib_purify($_REQUEST['smtp_ssl']);
if(!empty($servername)) {
    $validInput = validateServerName($servername);
/*if(! $validInput) {
    $servername = '';
 }*/
    $smarty->assign("MAILSERVER",$servername);
} elseif(isset($mail_server)) {
    $smarty->assign("MAILSERVER",$mail_server);
}

if(!empty($username)) {
    $validInput = validateEmailId($username);
if(! $validInput) {
    $username = '';
 }
	$smarty->assign("USERNAME",$username);
} elseif(isset($mail_server_username)) {
	$smarty->assign("USERNAME",$mail_server_username);
}
$smarty->assign("smtp_ssl",$smtp_ssl);
/**
 * AUTHOR:BY LD KEVIN
 * DATE:2013-04-23
 * DECRIPTION:BUG3758
 */ 
 if(!empty($password)){
    $smarty->assign("PASSWORD",$password);
 }
elseif (isset($mail_server_password))
	$smarty->assign("PASSWORD",$mail_server_password);
if(isset($_REQUEST['from_email_field'])){

	$smarty->assign("FROM_EMAIL_FIELD",vtlib_purify($_REQUEST['from_email_field']));
} elseif(isset($from_email_field)) {
	$smarty->assign("FROM_EMAIL_FIELD",$from_email_field);
}
if(isset($_REQUEST['auth_check']))
{
	if($_REQUEST['auth_check'] == 'on')
                $smarty->assign("SMTP_AUTH",'checked');
        else
                $smarty->assign("SMTP_AUTH",'');
}
elseif (isset($smtp_auth))
{
	if($smtp_auth == 'true')
		$smarty->assign("SMTP_AUTH",'checked');
	else
		$smarty->assign("SMTP_AUTH",'');
}

// 注销按钮执行的后台逻辑
if(isset($_REQUEST['emailconfig_mode']) && $_REQUEST['emailconfig_mode'] == 'delete'){
    $sql="select * from ld_systems where server_type = ?";
    $id=$adb->query_result($adb->pquery($sql, array('email')),0,"id");
    $update="update ld_systems set server = ?, server_username = ?, server_password = ?, smtp_auth= ?,
             server_type = ?, server_port= ?, server_path = ?, from_email_field=?,smtp_ssl=? where id = ?";
    $params = array('', '', '', '', '', '', '','','', $id);
    $adb->pquery($update,$params);
    ConvertTojsonString(1,'',"success");
}

if(isset($_REQUEST['emailconfig_mode']) && $_REQUEST['emailconfig_mode'] != '')
	$smarty->assign("EMAILCONFIG_MODE",vtlib_purify($_REQUEST['emailconfig_mode']));
else
	$smarty->assign("EMAILCONFIG_MODE",'view');

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
$labels = array('EmailConfig');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('LBL_MAIL_SERVER_SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('Settings/EmailConfig.tpl');
ConvertTojsonString(1,$arr,"success");
?>