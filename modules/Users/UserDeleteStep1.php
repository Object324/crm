<?php

/* * *******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 * ****************************************************************************** */


global $mod_strings, $app_strings,$adb;
global $theme;
$theme_path = "themes/" . $theme . "/";
$smarty=new lingdangCRM_Smarty();

$delete_user_id = $_REQUEST['record'];
$query = "select last_name,wx_userid from ld_users where id = ?";
$result = $adb->pquery($query,array($delete_user_id));
$wx_userid=$adb->query_result($result,0,'wx_userid');

$delete_user_name = $adb->query_result($result,0,0);
$userObj=new Users();
$userObj->last_name=$delete_user_name;
$userObj->wx_userid=$wx_userid;
$delete_user_name=getUserlastName($userObj);
$smarty->assign("delete_user_id",$delete_user_id);
$smarty->assign("blockidsetting",$_REQUEST['blockidsetting']);
$smarty->assign("fieldidsetting",$_REQUEST['fieldidsetting']);
$smarty->assign("delete_user_name",$delete_user_name);
//离职成员不显示了，因为kehu001
$sql = "select * from ld_users where
 id<>$delete_user_id   and `status`='active'
 ORDER BY CONVERT (last_name USING gbk) COLLATE gbk_chinese_ci ASC";
$result = $adb->pquery($sql, array());
$temprow = $adb->fetch_array($result);
do {
	$user_name =$temprow['last_name'];
	$user_id = $temprow["id"];
    $wx_userid=$temprow['wx_userid'];
    $userobj=new Users();
    $userobj->id=$user_id;
    $userobj->wx_userid=$wx_userid;
    $userobj->last_name=$user_name;

    $userList[getUserlastName($userobj)]=$user_id;
} while ($temprow = $adb->fetch_array($result));

$smarty->assign("blockidsetting1",$_REQUEST['blockidsetting']);
$smarty->assign("fieldidsetting1",$_REQUEST['fieldidsetting']);
$smarty->assign("userList",$userList);

//ZXM 20230815  kfbcrm-成员管理-删除成员，转换负责任下拉框搜索功能不生效  将弹出层改成统一的弹出层
$arr['content'] = $smarty->fetch('UserDeleteStep1.tpl');
$arr['title'] = getFixedLabel('DELETE').getTranstab('Users');
$arr['delete_user_id'] = $delete_user_id;
$arr['blockidsetting1'] = $_REQUEST['blockidsetting'];
$arr['fieldidsetting1'] = $_REQUEST['fieldidsetting'];
$arr['picklistcontent']=$userList;

ConvertTojsonString(1, $arr, getFixedLabel('SUCCESS'));
?>