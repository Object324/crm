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

global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;
$profDetails=getAllProfileInfo();
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$description="";
if(isset($_REQUEST['roleid']) && $_REQUEST['roleid'] != '')
{	
	$roleid= vtlib_purify($_REQUEST['roleid']);
	$mode = vtlib_purify($_REQUEST['mode']);
	$roleInfo=getRoleInformation($roleid);
    /*if(isset($_REQUEST['copyRole'])&& $_REQUEST['copyRole']=='copyRole')
    {
        
    }*/
	$thisRoleDet=$roleInfo[$roleid];
	$rolename = $thisRoleDet[0]; 
	$parent = $thisRoleDet[3]; 
    $description=$thisRoleDet[4];
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
elseif(isset($_REQUEST['parent']) && $_REQUEST['parent'] != '')
{
	$mode = 'create';
	$parent=vtlib_purify($_REQUEST['parent']);
    $smarty->assign('PROFILEID',"");
     $smarty->assign('PROFILENAME',"");
}
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("THEME", $theme);

$parentname=getProfileName($parent);
$smarty->assign("RETURN_ACTION",vtlib_purify($_REQUEST['returnaction']));
$smarty->assign("copyRole","");
if(isset($_REQUEST['copyRole'])&& $_REQUEST['copyRole']=='copyRole')//复制角色
{
$smarty->assign("copyRole","copyRole");
}

$smarty->assign("ROLEID",$roleid);        
           
$smarty->assign("MODE",$mode);            
$smarty->assign("PARENT",$parent);            
$smarty->assign("PARENTNAME",$parentname);            
$smarty->assign("ROLENAME",$rolename);            
$smarty->assign("DESCRIPTION",$description);

$profile_entries=array();
foreach($profDetails as $profId=>$profName)
{
	$profile_entries[]=$profId;
	$profile_entries[]=$profName;
}
$profile_entries=array_chunk($profile_entries,2);
$smarty->assign("PROFILELISTS",$profile_entries);

if($mode == 'edit')
{
	$selected_profiles = array();
	foreach($roleRelatedProfiles as $relProfId => $relProfName)
	{
		$selected_profiles[]=$relProfId;
		$selected_profiles[]=$relProfName;
	}
	$selected_profiles=array_chunk($selected_profiles,2);
	$smarty->assign("SELPROFILELISTS",$selected_profiles);
}

$smarty->display("RoleEditView.tpl");
?>