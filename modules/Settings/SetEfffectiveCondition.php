<?php
/*
edit:duan
date:2022-3-8
reason:源单类型的价税合计和数量控制增加高级查询条件
*/
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$theme;
global $current_user,$list_max_entries_per_page_new,$currentModule;
require_once(globalStatic::$root_directory.'Smarty_setup.php');
$smarty=new lingdangCRM_Smarty();
$frommodule = $_REQUEST['frommodule'];
//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
$module=$frommodule;
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);
$focus=CRMEntity::getInstance($frommodule);
$modulefields=$focus->fieldobj->getListSearchFields();
crm_load_class_file('EffectiveCondition',"modules/Settings");
$advfilterlist = EffectiveCondition::getAdvFilter();
//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
$includeDetail = isset($_REQUEST['includeDetail']) ? $_REQUEST['includeDetail'] : 'yes';
$arr['columns_block'] = EffectiveCondition::getByModule_ColumnsHTML($module,$modulecollist, $includeDetail);//高级查询select option
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$advfilterhtml = EffectiveCondition::getAdvCriteriaHTML('e',$fLabels);
$arr['flabels']=$fLabels;
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['arr_recovery_modules'] = $arr_recovery_modules;	//回收模块
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
$arr['foption']=$advfilterhtml;
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($frommodule);
$arr['advanceFields'] = $controller->getAdvanceFields();
$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("ModuleScope.tpl");
$arr['title']=getFixedLabel("SetTheSourceEntryDetailsRange");
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['fieldinfo']=array_values($modulefields);
$arr['content']=$content;

$json = new Zend_Json();
$advft_criteria = $json->decode($_REQUEST['advft_criteria']);
$advft_criteria_groups = $json->decode($_REQUEST['advft_criteria_groups']);
if (!empty($advft_criteria) && !empty($advft_criteria_groups)){
    $criteria_groups_arr = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $module,'');
    $arr['criteria_groups_arr'] = $criteria_groups_arr;
}

ConvertTojsonString(1,$arr,"success");

?>