<?php
global $current_user,$adb;
$languageType= getLanguageType($current_user);
$smarty = new lingdangCRM_Smarty();
crm_load_class_file("cls_LinkModuleCustom", 'include/utils');
$boardid = 0;
$sql = 'select boardid from ld_homeboard where boardtype = "prmMobileHome";';
$result = $adb->pquery($sql,array());
if($adb->num_rows($result) > 0){
    $boardid = $adb->query_result($result,0,'boardid');
    //BUG20241231-36 	后台设置--经销商渠道定制-移动端工作台定制-经销商渠道首页定制需要显示设置的组件
    crm_load_class_file("Homeboard",'modules/Home');
    $Homeboardobj = Homeboard::getInstance($boardid,'Home');
    $Homeboard_content = $Homeboardobj->get_Homeboard_info($boardid);
    $boardAllStuffNameList = $Homeboardobj->getHomeBoardAllStuffNameList();
    $boardAllStuffNameStr = implode('、',$boardAllStuffNameList);
}
$smarty->assign('boardAllStuffNameStr',$boardAllStuffNameStr);
$smarty->assign('boardid',$boardid);
//功能菜单模块名称
$query = 'select * from ld_appparenttab 
          where  menu_user_type=? ORDER BY sequence limit 1';
$moduleresult = $adb->pquery($query, array('prm'));
$modulerows = $adb->num_rows($moduleresult);
$module_name = [];
if($modulerows>0){
    $moduleblockid = $adb->query_result($moduleresult,0,'blockid');

    $blocksql= 'SELECT * FROM
        (
            SELECT app.blockid,app.tabid,app.sequence,ld_tab.presence,tab_tablename
            FROM ld_appparenttabrel app
            INNER JOIN ld_tab ON ld_tab.tabid = app.tabid
            and tab_tablename="ld_tab"
              UNION
            SELECT blockid,tabid,sequence,0,"ld_tab" as tab_tablename
            FROM ld_appparenttabrel WHERE tabid < -1
            union 
                SELECT app.blockid,app.tabid,app.sequence,0 as presence,tab_tablename
            FROM ld_appparenttabrel app
            INNER JOIN ld_linkmodulecustom ON ld_linkmodulecustom.id = app.tabid
            and tab_tablename="ld_linkmodulecustom"
        ) a
        WHERE blockid = ? AND presence <> 1 ORDER BY sequence;';

    $res = $adb->pquery($blocksql,array($moduleblockid));
    $res_num_rows = $adb->num_rows($res);
    for($j = 0;$j<$res_num_rows; $j++){
        $tabid = $adb->query_result($res,$j,'tabid');
        $tab_tablename=$adb->query_result($res,$j,'tab_tablename');
        if($tab_tablename=='ld_tab')
        {
            if($tabid>=-1){
                $tabname = getTabname($tabid);
                if(vtlib_isModuleActive($tabname)){
                    $module_name[] = getTranstab($tabname);
                }
            }else{
                if($tabid == -12 && vtlib_isModuleActive('SalesOrder')){
                    $module_name[] = getFixedLabel('shopping');	//订单商城
                }else{
                    $spemodule = getWxSpecialModule();
                    if(!array_key_exists($tabid,$spemodule)) continue;
                    $module_name[] = $spemodule[$tabid]['tabname'];
                }
            }
        }
        else
        {
            $linkinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
            if($languageType=='zh')
                $module_name[]=$linkinfo['zh_label'];
            else  if($languageType=='en')
                $module_name[]=$linkinfo['en_label'];
        }
    }
}
$smarty->assign('module_name_str',implode('、',$module_name));
$smarty->assign('moduleblockid',$moduleblockid);

//报表菜单模块名称
$profile = new Profile();
$reports = $profile->getMobileReportNames();
$mobile_report_list = array();
foreach ($reports as $key=>$value){
    $mobile_report_list[$value['id']] = $value;
}
$query = 'select * from ld_mobile_report_parent_tab 
          where  menu_user_type=? ORDER BY sequence desc limit 1 ; ';
$mobilereportresult = $adb->pquery($query, array('prm'));
$mobilereportrows = $adb->num_rows($mobilereportresult);
$report_name_arr = [];
if($mobilereportrows>0){
    $reportblockid = $adb->query_result($mobilereportresult,0,'block_id');

    $sql = 'select * from ld_mobile_report_tab_rel where block_id=? order by sequence asc  ';//这个区块只有一个
    $reportresult = $adb->pquery($sql, array($reportblockid));
    $reportrows = $adb->num_rows($reportresult);
    for ($k = 0; $k < $reportrows; $k++) {
        $tab_tablename = $adb->query_result($reportresult, $k, 'tab_tablename');
        $tabid = $adb->query_result($reportresult, $k, 'tabid');
        if ($tab_tablename == 'ld_tab') {
            if(isset($mobile_report_list[$tabid]))
                $report_name_arr[] = $mobile_report_list[$tabid]['fieldlabel'];
        } else {
            $linkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
            if ($languageType == 'zh')
                $report_name_arr[] = $linkinfo['zh_label'];
            else if ($languageType == 'en')
                $report_name_arr[] = $linkinfo['en_label'];
        }
    }
}
$smarty->assign('report_name_str',implode('、',$report_name_arr));
$smarty->assign('reportblockid',$reportblockid);

$arr = [];
if($_REQUEST['ajax'] && $_REQUEST['ajax'] != ''){
    $arr['content']= $smarty->fetch('Settings/prmmobilesettings_content.tpl');
}else{
    $arr['content']= $smarty->fetch('Settings/prmmobilesettings.tpl');
}


ConvertTojsonString(1,$arr,'success');

?>