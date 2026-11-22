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
require_once('modules/Users/Profile.class.php');
global $adb;
$del_id =  $_REQUEST['delete_role_id'];
$profileid = $_REQUEST['profileid'];
$profile = new Profile();
//获取该角色下的所有用户
$query = 'select id from ld_users where profileid = ?';
$result = $adb->pquery($query,array($del_id));
$num_rows = $adb->num_rows($result);
if(!empty($profileid)){
     require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
	if($num_rows > 0)
	{
		for($i = 0; $i<$num_rows; $i++)
		{
			$userid = $adb->query_result($result,$i,'id');
			$adb->pquery('update ld_users set profileid = ? where id = ?',array($profileid,$userid));
            //edit:can 2020-10-27 移动端登录是否需要生成相关的用户文件
            @unlink($root_directory.'user_privileges/user_privileges_'.$userid.'.php');
            createUserPrivilegesfile($userid,'');
		}
	}
	$profile->deleteProfile($del_id);

}
 $_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>