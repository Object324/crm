<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('PricePolicyDetailFieldsHtml','modules/PricePolicy');
global  $current_language, $currentModule, $theme, $adb;

$isduplicate=1;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$record = $_REQUEST['record'];

$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyid = 1;//默认币种为人民币

if($record) {
    $focus->id = $record;
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($record, $currentModule);
    if($isduplicate)
    {
        //037436: 单据复制默认值问题：费用报销单、加班单、请假单，自定义表单10-20，日期、日期时间类型的字段复制的时候带出了原来的值
        $focus->mode='create';
        $focus->id=0;
    }
}else{
    $focus->mode = 'create';
}

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    setObjectValuesFromRequest($focus);
}

$disp_view = getView($focus->mode);
$smarty->assign('SERVICE_MODULE_ACTIVATE',vtlib_isModuleActive('ServiceContracts'));

if(isset($_REQUEST['return_module']))
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
}
else
{
    $smarty->assign("RETURN_MODULE", $currentModule);
}
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if($_REQUEST['fromid']>0)
{

}

$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

if($focus->mode!='edit'){
    $value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
    if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
    $focus->column_fields['pricepolicy_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
    $focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
    $focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values,$edit_column_fields_value;

$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));

if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
    $richText=$act_data['RichText'];
    unset($act_data['RichText']);
    $smarty->assign('RICHTEXTBOX',implode(',',$richText));
    $smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
    $smarty->assign('RICHTEXTBOX','');
    $smarty->assign('RICHTEXTCOUNT','0');
}

$smarty->assign("BLOCKS",$act_data);
$smarty->assign('OP_MODE',$disp_view);

$smarty->assign('MODULE', $currentModule);


$smarty->assign('SINGLE_MOD', $currentModule);

$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

if($isduplicate)
    $smarty->assign('MODE','create' );
else
    $smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {

    $recordName = $focus->column_fields[$focus->list_link_field];
    $smarty->assign('NAME', $recordName);
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$focus->fieldobj->split_validationdataArray($validationData);

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);


global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

$now= $tmp_date=date("Y-m");
$days = date("t");
$smarty->assign("NOWMONTHSTART",$now.'-01');
$smarty->assign("NOWMONTHEND",$now.'-'.$days);

$smarty->assign("TOTAL",$focus->column_fields['hdnGrandTotal']);
//$smarty->assign('FORMATTOTAL',number_format($focus->column_fields['hdnGrandTotal'],2));

//联合技术MER特殊控制:根据费用类别控制显示隐藏列
$versioninfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$versioninfo['account']);

crm_load_class_file('TabDetailFields','include/TabDetailFields');
$TabDetailFields = new TabDetailFields($tabid);
$productFields['fields']=$TabDetailFields->getTabDetailFormulaField();
$versiontrade=getVersionTradeInfo();
$productFields['trade']=$versiontrade['trade'];

$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));

$focus->id=$_REQUEST['record'];//一定要这样，不然复制后明细没有了；

$DetailFieldsHtml = new PricePolicyDetailFieldsHtml($focus,$currentModule);
//zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
    $DetailFieldsHtml->tabDetailFieldData->row_mode = 'related_create';
}
$smarty->assign('TREXPENSE',$DetailFieldsHtml->getTabDetailFieldsHtml($entitytypeid));

if($isduplicate == 'true') {
    $focus->id = '';
    $focus->mode = '';
}
$smarty->assign('ID', $focus->id);
setGLobalURLSmarty($smarty);//设置js,css等访问路径

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    $smarty->assign('CREATE','true');
}
else
{

    $smarty->assign('CREATE','false');
}

if( $_REQUEST['fromid']>0 && isset($_REQUEST['selectsourcename']) && $_REQUEST['listval'] > 0){

    $selectsourcename = $_REQUEST['selectsourcename'];
    $listval = $_REQUEST['listval'];
    $entitysubject = getEntityName($selectsourcename,$listval);
    $smarty->assign('SELECTSOURCENAME',$selectsourcename);
    $smarty->assign('LISTVAL',$entitysubject[$listval]);
    $smarty->assign('ENTITYTYPEID',$listval);

    $listval = $_REQUEST['listval'];
}

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);


$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;

$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));



///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);

$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 16:08
$arr = $DetailFieldsHtml->detailPopup($smarty,$fields,$productFields);
if(!is_array($picklistDependencyDatasource))
{
    $picklistDependencyDatasource=[];
}
$picklistDependencyDatasource['pricepolicy_type']['product']['pricepolicy_forms']=["product_discount", "product_reduced", "product_fixed", "product_present"];
$picklistDependencyDatasource['pricepolicy_type']['order']['pricepolicy_forms']=["order_discount", "order_reduced", "order_present"];
//$picklistDependencyDatasource['__DEFAULT__']['pricepolicy_forms']=["", "打折", "减免", "一口价", "买赠", "满折", "满减", "满赠"];
$arr['picklistdepencyfields']['pricepolicy_forms']='pricepolicy_type';

$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['restBlocks'] = $DetailFieldsHtml->getRestBlocks();
ConvertTojsonString(1,$arr,"success");

?>