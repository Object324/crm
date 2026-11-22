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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'modules/lingdang/EditView.php';
include ($root_directory.'modules/TimeSheet/TimeSheetDetailFieldsHtml.php');
/*
crm_load_class_file('cls_TabDetail_PageRecordValue','include/TabDetailFields');
$obj=new cls_TabDetail_PageRecordValue('TimeSheet','edit',$_REQUEST['record'],'');
$obj->getValues();
echo '<pre>';
print_r($obj->getValues());
echo '</pre>';
exit();*/


$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));

$TabDetailFields = new TabDetailFields($tabid);
$productFields['fields']=$TabDetailFields->getTabDetailFormulaField();
$versiontrade=getVersionTradeInfo();
$productFields['trade']=$versiontrade['trade'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
if($isduplicate == 'true') {
    $focus->mode = 'edit';
    $focus->id = $_REQUEST['record'];
}
$TimeSheetDetailFieldsHtml = new TimeSheetDetailFieldsHtml($focus,$currentModule);
//zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
	$TimeSheetDetailFieldsHtml->tabDetailFieldData->row_mode = 'related_create';
}
$smarty->assign('TREXPENSE',$TimeSheetDetailFieldsHtml->getTabDetailFieldsHtml());
if($isduplicate == 'true') {
    $focus->id = '';
    $focus->mode = '';
}
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 16:48
//$smarty->display("DetailView/EditRelated.tpl");
$arr = $TimeSheetDetailFieldsHtml->detailPopup($smarty,$fields,$productFields);
ConvertTojsonString(1,$arr,"success");
?>