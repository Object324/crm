<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty = new lingdangCRM_Smarty;
global $current_user, $adb, $languageType;
require('user_privileges/user_privileges_' . $current_user->id . '.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
crm_load_class_file('cls_RolesProfile','modules/Settings');

$ajaxmode = '';
if(isset($_REQUEST['ajaxmode']) && !empty($_REQUEST['ajaxmode'])){
    $ajaxmode = $_REQUEST['ajaxmode'];
}
$selected_profileid = 0;
if(isset($_REQUEST['selected_profileid']) && !empty($_REQUEST['selected_profileid'])){
    $selected_profileid = $_REQUEST['selected_profileid'];
}
$getRolesProfileObj = new cls_getRolesProfile($adb,$current_user);
$profileinfo_arr = [];
if(isset($_REQUEST['profileinfo_arr']) && !empty($_REQUEST['profileinfo_arr'])){
    $profileinfo_arr = $_REQUEST['profileinfo_arr'];
}
$setRolesProfilObj = new cls_setRolesProfile($adb,$current_user,$selected_profileid);

// 弹窗中一些翻译
$LabelsInPopup_arr = [
    'createrole' => getFixedLabel('AddRole'),
    'editrole' => getFixedLabel('EditRole'),
    'copyrole' => getFixedLabel('CopyRole'),
    'rolename' => getFixedLabel('RoleName2'),
    'description' => getFixedLabel('DESCRIPTION'),
];
// 页签内容
$NavBarList = [];
$NavBarList[] = ['label' => getFIxedlabel('PermissionSettings'),'id' => 'setprofile'];
$NavBarList[] = ['label' => getFIxedlabel('SetUsers'),'id' => 'setusers'];

$arr = [];
// 点击事件
if (!empty($ajaxmode)) {

    // 判断角色名是否重复
    if(in_array($ajaxmode,['editrole','createrole','copyrole'])){
        $dup_check_query = "SELECT 1 from ld_profile where profilename = ?";
        $dup_check_result = $adb->pquery($dup_check_query, array($profileinfo_arr['profilename']));

        if ($adb->num_rows($dup_check_result) > 0) {
            ConvertTojsonString(-1,$arr,getFixedLabel('LBL_ROLENAME_EXIST'));
        }
    }

    switch ($ajaxmode) {
        // 切换角色
        case 'selectrole':
            $selected_navbar_type = 'setprofile';
            if(isset($_REQUEST['selected_navbar_type']) && !empty($_REQUEST['selected_navbar_type'])){
                $selected_navbar_type = $_REQUEST['selected_navbar_type'];
            }
            $smarty->assign("navbar_type", $selected_navbar_type);
            if($selected_navbar_type == 'setusers'){
                // 获取角色信息
                $allRolesBaseInfo_arr = $getRolesProfileObj->getAllRolesBaseInfo();
                $profileinfo = $allRolesBaseInfo_arr[$selected_profileid];
                if(empty($profileinfo)){
                    ConvertTojsonString(-1,$arr,getFixedLabel('INVALIDPROFILEID'));
                }
                $smarty->assign("PROFILE_NAME", $profileinfo['profilename']);
                $smarty->assign("PROFILE_DESCRIPTION", $profileinfo['description']);
                // 获取角色下用户
                $setusers_tableheader = $getRolesProfileObj->getSetUsersTableHeader();
                $allUsersInfo_arr = $getRolesProfileObj->getAllUsersInfoByProfileid($selected_profileid);
                $smarty->assign("setusers_tableheader", $setusers_tableheader);
                $smarty->assign("allUsersInfo_arr", $allUsersInfo_arr);
                $arr['allUsersInfo_arr'] = $allUsersInfo_arr;
            }else{
                $profileId = $selected_profileid;
                include('modules/Settings/RolesProfileContent.php');
            }
            $arr['content'] = $smarty->fetch("RolesProfile/ListViewRight.tpl");
            unset($getRolesProfileObj,$setRolesProfilObj);
            ConvertTojsonString(1,$arr,"success");
            break;
        case 'editrole':
            $setRolesProfilObj->editRole($profileinfo_arr);
            $selected_profileid = $profileinfo_arr['profileid'];
            break;

        case 'createrole':
            $selected_profileid = $setRolesProfilObj->createRole($profileinfo_arr);
            break;

        case 'copyrole':
            $selected_profileid = $setRolesProfilObj->copyRole($profileinfo_arr);
            break;

        case 'deleteusers':
            $delete_userid = [];
            if(isset($_REQUEST['delete_userid']) && !empty($_REQUEST['delete_userid'])){
                $delete_userid = $_REQUEST['delete_userid'];
                if(!is_array($delete_userid) && $delete_userid > 0){
                    $delete_userid = [$delete_userid];
                }
            }
            if($setRolesProfilObj->deleteUsersInRole($delete_userid)){
                ConvertTojsonString(1,$arr,getFixedLabel('DELETESUCCESSFUL'));
            }else{
                ConvertTojsonString(-1,$arr,getFixedLabel('DELETEFAILED'));
            }
            break;
        // 切换页签
        case 'changenavbar':
            $navbar_type = 'setprofile';
            if(isset($_REQUEST['navbar_type']) && !empty($_REQUEST['navbar_type'])){
                $navbar_type = $_REQUEST['navbar_type'];
            }
            $smarty->assign("navbar_type", $navbar_type);
            if($navbar_type == 'setusers'){
                $setusers_tableheader = $getRolesProfileObj->getSetUsersTableHeader();
                $allUsersInfo_arr = $getRolesProfileObj->getAllUsersInfoByProfileid($selected_profileid);
                $smarty->assign("setusers_tableheader", $setusers_tableheader);
                $smarty->assign("allUsersInfo_arr", $allUsersInfo_arr);
                $arr['allUsersInfo_arr'] = $allUsersInfo_arr;
            }else{
                $profileId = $selected_profileid;
                include('modules/Settings/RolesProfileContent.php');
            }
            $arr['content'] = $smarty->fetch("RolesProfile/ListViewMainContent.tpl");
            unset($getRolesProfileObj,$setRolesProfilObj);
            ConvertTojsonString(1,$arr,"success");
            break;
        // 上下移动角色
        case 'moveupdown':
            $direction = '';
            if(isset($_REQUEST['direction']) && !empty($_REQUEST['direction'])){
                $direction = $_REQUEST['direction'];
            }
            if(!empty($direction)){
                $setRolesProfilObj->moveUpDown($selected_profileid,$direction);              
            }
            ConvertTojsonString(1,$arr,"success");
            break;
        default:
            break;
    }
    // 刷新内容
    if(in_array($ajaxmode,['editrole','createrole','copyrole'])){
        $allRolesBaseInfo_arr = $getRolesProfileObj->getAllRolesBaseInfo();
        $smarty->assign("allRolesBaseInfo_arr", $allRolesBaseInfo_arr);
        $smarty->assign("selected_profileid", $selected_profileid);
        $arr['selected_profileid'] = $selected_profileid;
        $arr['allRolesBaseInfo_arr'] = $allRolesBaseInfo_arr;
        $arr['LabelsInPopup_arr'] = $LabelsInPopup_arr;
        $arr['NavBarList'] = $NavBarList;
        $profileId = $selected_profileid;
        include('modules/Settings/RolesProfileContent.php');
        $arr['content'] = $smarty->fetch("RolesProfile/ListViewEntries.tpl");
        unset($getRolesProfileObj,$setRolesProfilObj);
        ConvertTojsonString(1,$arr,"success");
    }
}
// 进入角色权限界面
else{
    $allRolesBaseInfo_arr = $getRolesProfileObj->getAllRolesBaseInfo();
    $selected_profileid = current($allRolesBaseInfo_arr)['profileid'];
    $smarty->assign("allRolesBaseInfo_arr", $allRolesBaseInfo_arr);
    $smarty->assign("selected_profileid", $selected_profileid);
    $arr['selected_profileid'] = $selected_profileid;
    $arr['allRolesBaseInfo_arr'] = $allRolesBaseInfo_arr;
    $arr['LabelsInPopup_arr'] = $LabelsInPopup_arr;
    $arr['NavBarList'] = $NavBarList;

    $smarty->assign("THEME", $theme);
    $smarty->assign("IMAGE_PATH",$image_path);
    $smarty->assign("APP", $app_strings);
    $smarty->assign("CMOD", $mod_strings);
    $smarty->assign("ROLETREE", $roleout);
    $smarty->assign("num_rows_show",$num_rows);
    $smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
    $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
    $smarty->assign("OFTENUSEREPORTTABID",getTabid("OftenUseReport"));
    $profile = new Profile();
    $smarty->assign("OFTENREPORTNAMES",implode(",",$profile->getOfenUseReportNames()));
    $mobilereports=$profile->getMobileReportNames();
    foreach($mobilereports as $reportinfo)
    {
        $names[]=$reportinfo['name'];
    }
    $smarty->assign("MOBILEREPORTNAMES",implode(",",$names));
    $smarty->assign('setmember',getFIxedlabel('SETMEMBERS'));

    $_REQUEST['diony']='yes';
    //获取帮助手册入口链接，为空则不显示
    //可能有多个帮助链接需要获取
    $helpUrlArr = array();
    //角色权限帮助
    $labels = array('ListRoles');
    foreach($labels as $label){
        $helpUrlArr['HelpUrl'] = getHelpUrlByLabel('Settings',1,'HelpUrl_'.$label);
    }
    $arr['helpUrl'] = $helpUrlArr;

    $profileId = $selected_profileid;
    include('modules/Settings/RolesProfileContent.php');

    $arr['content'] = $smarty->fetch("RolesProfile/ListViewEntries.tpl");
    ConvertTojsonString(1,$arr,'success');
}
	
?>