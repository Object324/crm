<?php

global $current_user;
$arr = [];
$mode = $_REQUEST['mode'];
if ($mode == 'update'){
    $tabid = $_REQUEST['tabid'];
    if (empty($tabid)){
        ConvertTojsonString(-1,'','');
    }
    $clickmodule = $_REQUEST['clickmodule'];
    $tab_tablename = $_REQUEST['tab_tablename'];
    $linkid = $_REQUEST['linkid'];
    if (!empty($linkid)) {
        if ($tab_tablename == 'ld_linkmodulecustom') {
            $clickmodule = '';
        }
        $tabid = $linkid;
    }
    updateModuleUsage($clickmodule.':::'.$tabid.':::'.$tab_tablename);
    ConvertTojsonString(1,'','');
}elseif ($mode == 'getinfo'){
    $type = $_REQUEST['type'];
    //数据库记住
    setUsersettingByLabel('Users',$current_user->id,'ModuleUsageType',$type);
    crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
    $reportobj = new cls_ReportDetailInfoWX(null);
    $getreportname = 'get'.$type;
    $moduleUsage_arr = $reportobj->$getreportname();
    $arr['list1'] = $moduleUsage_arr;
    if ($type == 'commonmodules'){
        $arr['list1']['label'] = getFixedLabel($type);
        $arr['list1']['morelabel'] = getFixedLabel('MORE');
        $deployarr_13 = getAppsys_deploy(13);
        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
        $morelabel_icon = ($is_open13 == 'yes') ? 'crm2022_2/crm_more.png' : 'crm2022/crm_more.png';
        $arr['list1']['morelabel_icon'] = $morelabel_icon;
    }
    ConvertTojsonString(1,$arr,'success');

}



?>