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

require_once 'modules/Users/Role.php';
require_once ('config.php');
global $adb;
$del_id =  $_REQUEST['delete_role_id'];
$tran_id = $_REQUEST['user_role'];

$role = lingdang_Role::getInstanceById($del_id);
$targetRole = lingdang_Role::getInstanceById($tran_id);
$role->delete($targetRole);

/*
edit:can
date:20130329
reason:用户授权
other:一下代码来自：users/DeleteProfile.php
*/
//$del_id =  $_REQUEST['delete_prof_id'];
//$tran_id = $_REQUEST['transfer_prof_id'];
$SqlDelProfile="select ld_profile.profileID from ld_profile inner join ld_role2Profile  on ld_profile.profileid=ld_role2profile.profileid  where  ld_role2Profile.roleid='". $_REQUEST['delete_role_id']."'";
$DelProId=$adb->pquery($SqlDelProfile);
$SqlTranProfile="select ld_profile.profileID from ld_profile inner join ld_role2Profile on ld_profile.profileid=ld_role2profile.profileid  where ld_role2Profile.roleid='".$_REQUEST['user_role']."'";
$tranProid=$adb->pquery($SqlTranProfile);

for($i=0;$i<$adb->num_rows($DelProId);$i++)
{
    $tran_id=$adb->query_result($tranProid,0,0);
    echo $tran_id;
    $del_id=$adb->query_result($DelProId,$i,0);
    deleteProfile($del_id,$tran_id);
}

header("Location: index.php?action=listroles&module=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
?>