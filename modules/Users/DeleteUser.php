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

require_once 'modules/Users/Users.php';

global $adb;
$del_id =  $_REQUEST['delete_user_id'];
$tran_id = $_REQUEST['transfer_user_id'];
/**
 * 更新操作
 * edit:kevin
 * date:2013-11-21
 * reason:5713: 控制面板->用户，删除用户，选择的用户负责人，在仓库管理人员中没有替换被删除用户。
 */ 
 
 $query='update ld_account_public_pool set userid_after_transfer=? where  userid_after_transfer=? ';
 $adb->pquery($query,array($tran_id,$del_id));
 $query='update ld_account_public_pool set userid_after_release=? where  userid_after_release=? ';
 $adb->pquery($query,array($tran_id,$del_id));
 $query='update ld_lead_public_pool set userid_after_transfer=? where  userid_after_transfer=? ';
 $adb->pquery($query,array($tran_id,$del_id));
 $query='update ld_lead_public_pool set userid_after_release=? where  userid_after_release=? ';
 $adb->pquery($query,array($tran_id,$del_id));
 
$query='update ld_warehouse2user set userid=? where userid=?';
$adb->pquery($query,array($tran_id,$del_id));
//修改日志
$query = "update ld_modtracker_detail set prevalue = ? where prevalue = ? and fieldname in ('assigned_user_id','servicecasher','creator','smcreatorid')";
$adb->pquery($query,array($tran_id,$del_id));
$query = "update ld_modtracker_detail set postvalue = ? where postvalue = ? and fieldname in ('assigned_user_id','servicecasher','creator','smcreatorid')";
$adb->pquery($query,array($tran_id,$del_id));
$query = 'update ld_bangwo8_supportname set operate_smownerid = ? where operate_smownerid = ?';
$adb->pquery($query,array($tran_id,$del_id));
//@edit:ljj,2023-08-03,reason: XUQIU1001648 工作汇报点评人被删除后，点评人应该被替换显示为删除成员时的指定成员
$query = 'UPDATE ld_workreport2user SET userid =? where userid=? and User_type=5';
$adb->pquery($query,array($tran_id,$del_id));
unlink(globalStatic::$root_directory.'user_privileges/user_privileges_' .$del_id. '.php');//删除文件，防止点评人被删除后不刷新
unlink(globalStatic::$root_directory.'user_privileges/user_language_' .$del_id. '.php');

$userObj = new Users();
$userObj->transformOwnerShipAndDelete($del_id, $tran_id);	


$query = 'update ld_customview set userid = ? where userid = ?';
$adb->pquery($query,array($tran_id,$del_id));

$userObj->delete_user_scope($del_id);//删除用户关联授权范围
$cachekey = 'cache_getusercachenameinfo';
unsetCache($cachekey);
echo 'succcess';
//if check to delete user from detail view
//if(isset($_REQUEST["ajax_delete"]) && $_REQUEST["ajax_delete"] == 'false')
//	header("Location: index.php?action=ListView&module=Users&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
//else
//	header("Location: index.php?action=UsersAjax&module=Users&file=ListView&ajax=true&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
//
?>