<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

global $mod_strings,$app_strings,$theme,$currentModule,$current_user;

require_once('Smarty_setup.php');
require_once('include/utils/utils.php');

$focus = CRMEntity::getInstance($currentModule);
$parentab=getParentTab($currentModule);
$focus->mode = '';
$mode = 'sort_view';

$disp_view = getView($focus->mode);

$smarty = new lingdangCRM_Smarty;
$smarty->assign('MODULE',$currentModule);
$smarty->assign('APP',$app_strings);
$smarty->assign('PARENTTAB',$parentab);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

$smarty->assign('MASS_EDIT','1');
$smarty->assign("CATEGORY",getParentTab());

// Field Validation Information
$tabid = getTabid($currentModule);
$viewList=getSortViewList($tabid);
$smarty->assign('VIEWLIST',$viewList);
unsetCacheDirectory('customview');

//@edit:liushuai,2020-07-21,reason:0041912/营销>群发邮件（右上角排序）
if($_REQUEST['module'] == 'Emails'){
    $_REQUEST['diony']='yes';
    $arr['title']=getFixedLabel("LBL_CHANGEORDER");
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$smarty->fetch('NewSortView.tpl');
    ConvertTojsonString(1,$arr,'success');
}
$smarty->display('SortView.tpl');


//add by tifa 20130307 for view sort
function getSortViewList($tabid){
    global $adb;
    //and status!=0
     /*
     edit by LD Can
     date:20130313
     reason:视图全部（all）可以被编辑和删除
       */
     
    $ssql = "select ld_customview.* from ld_customview inner join ld_tab on ld_tab.name = ld_customview.entitytype";
    $ssql .= " where ld_tab.tabid=? and viewname<>'All'";
     if(getTabModuleName($tabid) == 'Accounts')
     {
        $pagepublicaccounttype = $_SESSION['lvsAccount'][getTabModuleName($tabid)]['pagepublicaccounttype'];
        if(empty($pagepublicaccounttype))
            $ssql .= " and customcategory = 'ALLACCOUNT'";
        else
            $ssql .= " and customcategory = '".$pagepublicaccounttype."'";
     }
    $ssql .= " ORDER BY ld_customview.sequence";
    $sparams = array($tabid);
    $result = $adb->pquery($ssql, $sparams);
    $viewList=array();
    while ($cvrow = $adb->fetch_array($result)) {
        $viewList[$cvrow['cvid']]=$cvrow['viewname'];
    }    
    return $viewList;
}
?>