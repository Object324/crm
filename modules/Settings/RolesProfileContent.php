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

include('ActionLabel.php');
global $app_strings;
global $mod_strings;
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

if (empty($mode) && isset($_REQUEST['mode']))
    $mode = $_REQUEST['mode'];
else
    $mode = 'edit';
//权限ID
if (empty($profileId) && isset($_REQUEST['profileid']))
    $profileId = $_REQUEST['profileid'];

$profile = new Profile();
if(empty($getRolesProfileObj)){
    global $adb,$current_user;
    crm_load_class_file('cls_RolesProfile','modules/Settings');
    $getRolesProfileObj = new cls_getRolesProfile($adb,$current_user);
}
if (!empty($profileId)) {
    if (!$getRolesProfileObj->profileExists($profileId) || !is_numeric($profileId)) {
        ConvertTojsonString(-1, $arr, getFixedLabel('INVALIDPROFILEID'));
    }
} elseif ($_REQUEST['mode'] != 'create' && $_REQUEST['mode'] != 'view' && $_REQUEST['mode'] != 'edit') {
    ConvertTojsonString(-1, $arr, getFixedLabel('INVALIDPROFILEID'));
}

//caption的控制
if ($_REQUEST['mode'] == 'create') {
    $smarty->assign("RESOURCE", getFixedLabel('NEWROLE'));
} elseif ($_REQUEST['mode'] == 'edit' && $_REQUEST['copyRole'] == '') {
    $smarty->assign("RESOURCE", getFixedLabel('EDIT'));
} elseif ($_REQUEST['mode'] == 'edit' && $_REQUEST['copyRole'] == 'copyRole') {
    $smarty->assign('COPYPROFILEID', $profileId);
    $smarty->assign("RESOURCE", getFixedLabel('COPY'));
}

$oftenusereportid = getTabid("OftenUseReport");//常用报表

//收款单是否启用审批流程
$deployarray = getSys_deploy(133);
$cashbill_approvestatusw = $deployarray['deploy_value'];
//付款单是否启用审批流程
$deployarray = getSys_deploy(134);
$sendcashbill_approvestatusw = $deployarray['deploy_value'];
//出库单是否启用审批流程
$deployarray = getSys_deploy(135);
$outboundorder_approvestatusw = $deployarray['deploy_value'];
//入库单是否启用审批流程
$deployarray = getSys_deploy(136);
$stock_approvestatusw = $deployarray['deploy_value'];

$AllActionsFortab = $profile->getAllActionsFortab();
//require_once(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
$languageType=getLanguageType($current_user);

$sql = 'SELECT * FROM ld_tranlabel WHERE tabid=-2 AND languagetype=? AND trantable=?  ';
$result = $adb->pquery($sql, array($languageType, 'ld_tab'));
$mobilereportlabel = $adb->query_result($result, 0, 'fieldlabel');

$smarty->assign("MOBILEREPORTLABEL", $mobilereportlabel);

$allActionTab = $getRolesProfileObj->getAllActionTab($AllActionsFortab);
//新增
if ($mode == 'create') {
    foreach ($allActionTab as $tabid => $action_array) {
        $stand = array();
        $entity_name = getTabModuleName($tabid);
        if ($entity_name == 'OftenUseReport') {

            $reportnames = $profile->getOfenUseReportNames();
            $relatednames = explode(",", $act_perr_arry[$tabid]['relatednames']);

            foreach ($reportnames as $reportname) {
                $reportlabel = getFixedLabel($reportname);
                if (in_array($reportname, $relatednames))
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $reportname . "\")' checked name='oftenusereport_" . $reportname . "'/> " . $reportlabel;
                else
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $reportname . "\")' name='oftenusereport_" . $reportname . "'/> " . $reportlabel;

            }

        }
        foreach ($action_array as $actionid => $permissions) {
            if($actionid == 49){
                $tmpchk = $getRolesProfileObj->getDisplayOutput(6, $tabid, $actionid);
            }
            else{
                $tmpchk = $getRolesProfileObj->getDisplayOutput(1, $tabid, $actionid);
            }
            if (!empty($tmpchk))//创建人隐藏
                $stand[$actionid] = $tmpchk;

        }


        if ($entity_name == 'MobileReport') {
            //移动端报表
            $reportnames = $profile->getMobileReportNames();

            $relatednames = explode(",", $act_perr_arry[$tabid]['relatednames']);

            foreach ($reportnames as $reportinfo) {
                $reportlabel = $reportinfo['fieldlabel'];
                $name = $reportinfo['name'];


                if (in_array($name, $relatednames))
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' checked name='mobilereport_" . $name . "'/> " . $reportlabel;
                else
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' name='mobilereport_" . $name . "'/> " . $reportlabel;

            }
        }
        $privileges_stand[$tabid] = $stand;
        $isModuleField[$tabid] = $getRolesProfileObj->isModuleField($tabid);
    }
}
//查看
if ($mode == 'view') {
    $act_perr_arry = $profile->getProfileAction_Used($profileId);
    foreach ($allActionTab as $tabid => $action_array) {
        $stand = array();
        $entity_name = getTabModuleName($tabid);
        if ($entity_name == 'OftenUseReport') {

            $reportnames = $profile->getOfenUseReportNames();
            $relatednames = explode(",", $act_perr_arry[$tabid]['relatednames']);
            foreach ($reportnames as $reportname) {
                $reportlabel = getFixedLabel($reportname);
                if (in_array($reportname, $relatednames))
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' disabled=true checked name='oftenusereport_" . $reportname . "'/> " . $reportlabel;
                else
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' disabled=true name='oftenusereport_" . $reportname . "'/> " . $reportlabel;

            }

        }
        foreach ($action_array as $actionid => $permissions) {
            if (isset($act_perr_arry[$tabid]) && isset($act_perr_arry[$tabid][$actionid]))
                $permissions = 0;
            else
                $permissions = 1;
            $tmpchk = $getRolesProfileObj->getDisplayOutput($permissions, $tabid, $actionid);
            if (!empty($tmpchk))//创建人隐藏
                $stand[$actionid] = $tmpchk;

        }

        if ($entity_name == 'MobileReport') {
            //移动端报表
            $reportnames = $profile->getMobileReportNames();
            $relatednames = explode(",", (string)$act_perr_arry[$tabid]['relatednames']);

            foreach ($reportnames as $reportinfo) {
                $reportlabel = $reportinfo['fieldlabel'];
                $name = $reportinfo['name'];

                if (in_array($name, $relatednames))
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' disabled=true onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' checked name='mobilereport_" . $name . "'/> " . $reportlabel;
                else
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' disabled=true onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' name='mobilereport_" . $name . "'/> " . $reportlabel;

            }
        }
        $isModuleField[$tabid] = $getRolesProfileObj->isModuleField($tabid);

        $privileges_stand[$tabid] = $stand;
    }
}
//编辑
$alltabid = [];
if ($mode == 'edit') {
    $act_perr_arry = $profile->getProfileAction_Used($profileId);
    
    foreach ($allActionTab as $tabid => $action_array) {
        $stand = array();

        $entity_name = getTabModuleName($tabid);
        if ($entity_name == 'OftenUseReport') {

            $reportnames = $profile->getOfenUseReportNames();
            $relatednames = explode(",", $act_perr_arry[$tabid]['relatednames']);

            foreach ($reportnames as $reportname) {
                $reportlabel = getFixedLabel($reportname);
                if (in_array($reportname, $relatednames))
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $reportname . "\")' checked name='oftenusereport_" . $reportname . "'/> " . $reportlabel;
                else
                    $stand[$reportname] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $reportname . "\")'  name='oftenusereport_" . $reportname . "'/> " . $reportlabel;

            }

        }

        foreach ($action_array as $actionid => $permissions) {

            if (isset($act_perr_arry[$tabid]) && isset($act_perr_arry[$tabid][$actionid]))
                $permissions = 0;
            else
                $permissions = 1;
            //编辑权限未勾选时，设置推进权限不可用
            //下载权限未勾选时，批量下载不可用
            if($actionid == 49 && !isset($act_perr_arry[$tabid][42])){
                $permissions = 6;
            }
            //BUG0066757 yujun kfbcrm-角色权限-编辑权限-自定义表单-“下载和预览次数”字段应和“下载全部附件”字段一样，不勾选“下载”和“预览”时就不可勾选
            if($actionid == 50 && !isset($act_perr_arry[$tabid][42]) && !isset($act_perr_arry[$tabid][43])){
                $permissions = 6;
            }
            if($actionid == 57){// BUG20240805-42 在后台设置的工商信息设置中关闭批量回填的模块，在角色权限设置中应不显示批量回填按钮
                crm_load_class_file('cls_BusinessInformation', 'modules/Users');
                $businessinformationobj = cls_BusinessInformation::getInstance($entity_name);
                if(!$businessinformationobj->IsEnableBatchbackfill()){
                    continue;
                }
            }
            $tmpchk = $getRolesProfileObj->getDisplayOutput($permissions, $tabid, $actionid);

            if (!empty($tmpchk))//创建人隐藏
                $stand[$actionid] = $tmpchk;
        }


        if ($entity_name == 'MobileReport') {
            //移动端报表
            $reportnames = $profile->getMobileReportNames();
            $relatednames = explode(",", $act_perr_arry[$tabid]['relatednames']);

            foreach ($reportnames as $reportinfo) {
                $reportlabel = $reportinfo['fieldlabel'];
                $name = $reportinfo['name'];

                
                if (in_array($name, $relatednames)){
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' checked id='mobilereport_" . $name . "' name='mobilereport_" . $name . "'/> ";
                }else{
                    $stand[$name] = "<input type='checkbox' tag='module_actionname' onclick='unselectmodule(" . $tabid . ",\"" . $name . "\")' id='mobilereport_" . $name . "' name='mobilereport_" . $name . "'/> ";
                }
                $stand[$name] .= '<label for="mobilereport_' . $name . '">'.$reportlabel.'</label>';
            }
        }
        $alltabid[] = $tabid;
        $privileges_stand[$tabid] = $stand;
        $isModuleField[$tabid] = $getRolesProfileObj->isModuleField($tabid);

    }
}
//zkt 【角色权限，操作权限增加“全选”功能】--选择操作权限下拉框生成
if($mode == 'edit' || $mode == 'create')
{
    //zkt 50666: (https://81mis.com/kfbcrm/index.php [^]) 角色权限全选下拉框中没有下载选项，但需求书里有写
    //wym BUG0072790 角色权限，全局快速授权下拉选项中增加“打印”权限
    $tmpselectarr = array(4,11,1,2,12,13,14,5,6,25,37,42,43,45);//查看、新建、编辑、删除、复制、分配、共享、导入、导出、更改创建人、管理分类、下载、预览、打印
    $selecthtml = '<select name="profileaction" id="profileaction" style="margin:0px 3px;">';
    foreach($tmpselectarr as $tmpactionid)
    {
        if($tmpactionid == 25){
            $tmplabel = '更改创建人';
            if($languageType == 'en'){
                $tmplabel = 'Change Creator';
            }
        }
        else{
            $tmplabel = getActionlabel($tmpactionid, getTabname(6));
        }
        $tmpselected = '';
        if($tmpactionid == 2)
        {
            $tmpselected = 'selected';
        }
        $selecthtml .= '<option value="'.$tmpactionid.'" '.$tmpselected.'>'.$tmplabel.'</option>';
    }
    $selecthtml .= '</select>';
    $arr['profileactionhtml'] = $selecthtml;
    $smarty->assign("profileactionhtml", $selecthtml);
}

$menu_privileges_stand = $getRolesProfileObj->getMenuPrivilegesStand($privileges_stand);

//zkt 【角色权限，操作权限增加“全选”功能】--获取菜单name-label对应关系
$menu_parentlist_key = [];
if(is_array($menu_privileges_stand)){
    $menu_parentlist_key = array_keys($menu_privileges_stand);
}
require(globalStatic::$root_directory.'dataCache/tabdatas/parent_language.php');
$menu_parentlist = $parent_string;
if($languageType == 'en'){
    $menu_parentlist=$enparent_string;
}
$menu_parentlist['Settingup'] = getFixedLabel('UserPermissionManagement');
$menu_parentlist['menuOthertab'] = getFixedLabel('menuOthertab');
$smarty->assign("MENU_STANDARD_PRIV", $menu_privileges_stand);
$smarty->assign("MENU_PARENTLIST", $menu_parentlist);
// 获取所有模块名的拼音
$AllModulePinyin_arr = $getRolesProfileObj->getAllModulePinyin(array_keys($AllActionsFortab));
$arr['AllModulePinyin_arr'] = $AllModulePinyin_arr;


if (isset($_REQUEST['copyRole']) && $_REQUEST['copyRole'] == 'copyRole')//复制角色
{
    $smarty->assign("PROFILEID", "");
    $mode = "create";
} else {
    $smarty->assign('PROFILEID', $profileId);
}
$smarty->assign('ALLTABLEID', implode(',', $alltabid));
$smarty->assign('copyRole', $_REQUEST['copyRole']);


$smarty->assign("STANDARD_PRIV", $privileges_stand);
$smarty->assign('ISMODULEFIELD', $isModuleField);
//获取权限信息
$allprofileinfo = $getRolesProfileObj->getAllRolesBaseInfo();
$profileinfo = $allprofileinfo[$profileId];
$smarty->assign("PROFILE_NAME", $profileinfo['profilename']);
$smarty->assign("PROFILE_DESCRIPTION", $profileinfo['description']);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("IMAGE_PATH", $image_path);
if (isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != '')
    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_module']) && $_REQUEST['return_action'] != '')
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['fieldidsetting']) && $_REQUEST['fieldidsetting'] != '')
    $smarty->assign("FIELDIDSETTING", vtlib_purify($_REQUEST['fieldidsetting']));
if (isset($_REQUEST['blockidsetting']) && $_REQUEST['blockidsetting'] != '')
    $smarty->assign("BLOCKIDSETTING", vtlib_purify($_REQUEST['blockidsetting']));

$smarty->assign("OFTENUSEREPORTTABID", getTabid("OftenUseReport"));
$smarty->assign("OFTENREPORTNAMES", implode(",", $profile->getOfenUseReportNames()));
$mobilereports = $profile->getMobileReportNames();

foreach ($mobilereports as $reportinfo) {
    $names[] = $reportinfo['name'];
}
$smarty->assign("MOBILEREPORTNAMES", implode(",", $names));
if ($mode == 'create') {
    $smarty->assign("ACTION", 'SaveProfile');
} elseif ($mode == 'edit') {
    $smarty->assign("ACTION", 'UpdateProfileChanges');
}

$smarty->assign("MAXACTIONID", $getRolesProfileObj->getMaxActionId());

$_REQUEST['diony'] = 'diony';
if ($mode == 'create') {
    $arr['title'] = getFixedLabel('ADDLESSIONPLAN') . getFixedLabel('LBL_PROFILES');
} else if ($mode == 'edit') {
    $arr['title'] = getFixedLabel('EDIT') . getFixedLabel('LBL_PROFILES');
} else {
    $arr['title'] = getFixedLabel('PROFILES');
}
$arr['oktext'] = getFixedLabel("SAVE");
$arr['canceltext'] = getFixedLabel("CANCEL");
if ($mode == 'view') {
    $arr['oktext'] = getFixedLabel("EDIT");
    $str = $smarty->fetch("ProfileDetailView.tpl");
} else {
    $str = $smarty->fetch("EditProfile.tpl");
}
$arr['content'] = $str;

// ConvertTojsonString(1, $arr, "success");

?>