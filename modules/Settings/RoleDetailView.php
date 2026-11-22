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
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/utils/UserInfoUtil.php');
require_once('include/utils/utils.php');

global $mod_strings;
global $app_strings;
global $app_list_strings;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$roleid= vtlib_purify($_REQUEST['roleid']);

/** gives the role info, role profile info and role user info details in an array  for the specified role id
  * @param $roleid -- role id:: Type integer
  * @returns $return_data -- array contains role info, role profile info and role user info. This array is used to construct the detail view for the specified role id :: Type varchar
  *
 */
function getStdOutput($roleid)
{
	//Retreiving the related lingdang_profiles
	$roleProfileArr=getRoleRelatedProfiles($roleid);
	//Retreving the related lingdang_users
	$roleUserArr=getRoleUsers($roleid);

	//Constructing the Profile list
	$profileinfo = Array();
	foreach($roleProfileArr as $profileId=>$profileName)
	{
		$profileinfo[]=$profileId;
		$profileinfo[]=$profileName;
		$profileList .= '<a href="index.php?module=Settings&action=profilePrivileges&profileid='.$profileId.'">'.$profileName.'</a>';
	}
	$profileinfo=array_chunk($profileinfo,2);
	
	//Constructing the Users List
	$userinfo = Array();
	foreach($roleUserArr as $userId=>$userName)
	{
		$userinfo[]= $userId;
		$userinfo[]= $userName;
		$userList .= '<a href="index.php?module=Settings&action=DetailView&record='.$userId.'">'.$userName.'</a>';
	}
	$userinfo=array_chunk($userinfo,2);
	
	//Check for Current User
	global $current_user;
	$current_role = fetchUserRole($current_user->id);
	$return_data = Array('profileinfo'=>$profileinfo,'userinfo'=>$userinfo);
	return $return_data;
}

if(isset($_REQUEST['roleid']) && $_REQUEST['roleid'] != '')
{	
	$roleid= vtlib_purify($_REQUEST['roleid']);
	$mode = vtlib_purify($_REQUEST['mode']);
	$roleInfo=getRoleInformation($roleid);
	$thisRoleDet=$roleInfo[$roleid];
	$rolename = $thisRoleDet[0]; 
	$parent = $thisRoleDet[3]; 
	//retreiving the lingdang_profileid
	$roleRelatedProfiles=getRoleRelatedProfiles($roleid);
 /*
    edit:Can
    date:20130328
    reason:用户授权及控制面板该进
    other:获取角色所对应的权限id,新需求中角色和权限一一对应
    */
    foreach($roleRelatedProfiles as $privKey =>$privName)
    {
        //echo $privKey;
        $smarty->assign('PROFILEID',$privKey);
       
         break;
    }
     $smarty->assign('PROFILENAME',$rolename);
}
$parentname=getProfileName($parent);
//Retreiving the Role Info
$roleInfoArr=getRoleInformation($roleid);
$rolename=$roleInfoArr[$roleid][0];
$smarty->assign("ROLE_NAME",$rolename);
$smarty->assign("ROLEID",$roleid);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("ROLEINFO",getStdOutput($roleid));
$smarty->assign("PARENTNAME",$parentname);

require_once('SetmenuControl.php');
$smarty->display("RoleDetailView.tpl");
?>