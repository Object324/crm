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
global $adb;
$smarty = new lingdangCRM_Smarty;
require_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
$json = doCorpInfo('get_auth_info',array());

//$file_path = $root_directory . "dataCache/weixin/auth_gyq_info.txt";
if($json){
	//$json = file_get_contents($file_path);
	$json_arr = json_decode($json);
	//企业微信号
	if(!empty($json_arr->crm->auth_corp_info)){
		$smarty->assign('corp_name',$json_arr->crm->auth_corp_info->corp_name);
	}
	//应用授权人
	if(!empty($json_arr->crm->auth_user_info)){
		// $userid = $json_arr->crm->auth_user_info->userid;
		// if(!empty($userid)){
		// 	$query = 'select last_name from ld_users where wx_userid = ?';
		// 	$result = $adb->pquery($query,array($userid));
		// 	if($adb->num_rows($result) >= 1){
		// 		$username = $adb->query_result($result,0,0);
		// 	}
		// }
		// $smarty->assign('username',$username);
		$smarty->assign('username',$json_arr->crm->auth_user_info->name);
	}
	//应用授权日期
	$smarty->assign('expired_time',$json_arr->crm->create_time);
}
//判断是否是客户001版本
$focus = CRMEntity::getInstance('Users');
if($focus->getAuthType() == 'yes'){
	$smarty->assign('KEHU','yes');
}
//require_once('SetmenuControl.php');
//
$arr=array();
$arr['content']=$smarty->fetch('Settings/WeChat.tpl');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');
?>