<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/
include ($root_directory.'modules/BusinessApply/BusinessApplyDetailFieldsHtml.php');
global  $current_language, $currentModule, $theme;
global $adb;
//require_once('Smarty_setup.php');
$isduplicate=1;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

$category = getParentTab($currentModule);

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$record = $_REQUEST['record'];
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyid = 1;//默认币种为人民币
//4600 ends

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
   
}else{
	$focus->mode = 'create';
}


if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    
	setObjectValuesFromRequest($focus);
}

$disp_view = getView($focus->mode);


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



$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->mode = '';
 }
/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['businessapply_no'] = $value;
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){

    if($_REQUEST['fromid']>0&&$_REQUEST['frommodule']!="")
    {
            
            //关联创建，引用字段值得获取
                 $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
                 $fromfocus->retrieve_entity_info($_REQUEST['fromid'],$_REQUEST['frommodule']);
                 foreach($fromfocus->column_fields as $fieldname=>$value)
                 {
                     if(array_key_exists($fieldname,$focus->column_fields))
                     {
                        $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                        $bitype='';
                        if($tmpfieldinfo)
                        {
                            $bitype=$tmpfieldinfo->getBigType();
                           
                        }
                        //038019: （51mis.com/kfbcrm）客户新增界面>填写数据点击保存（需要填写备注字段值）>相关创建【服务合同】：客户单据中备注字段值自动带到服务合同中的备注字段上面。（需要补丁）
                        if($bitype=='reference'||$bigtype=='selectsource')
                            $focus->column_fields[$fieldname]=$value;
                     }
                 }
        }
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}

/* 关联创建单据统一处理方法 end */
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
 /**
    * 更新操作
    * edit:can
    * date:20131223
    * reason:添加富文本框
    * */
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

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', $currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

if($isduplicate)
    $smarty->assign('MODE','create' );
else
    $smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
	//$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$focus->fieldobj->split_validationdataArray($validationData);

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);
$smarty->assign('ISADMIN',$current_user->is_admin);

global $adb;
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


crm_load_class_file('TabDetailFields','include/TabDetailFields');
$TabDetailFields = new TabDetailFields($tabid);
$productFields['fields']=$TabDetailFields->getTabDetailFormulaField();
$versiontrade=getVersionTradeInfo();
$productFields['trade']=$versiontrade['trade'];

$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));

$BusinessApplyDetailFieldsHtml = new BusinessApplyDetailFieldsHtml($focus,$currentModule);
//zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
	$BusinessApplyDetailFieldsHtml->tabDetailFieldData->row_mode = 'related_create';
}
$smarty->assign('TREXPENSE',$BusinessApplyDetailFieldsHtml->getTabDetailFieldsHtml($entitytypeid));
if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
$smarty->assign('ID', $focus->id);
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
 $fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;

/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
 ///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($BusinessApplyDetailFieldsHtml->tabDetailFieldData->TabDetailFields->getFieldListArray()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 10:38
//$smarty->display("DetailView/EditRelated.tpl");
$arr = $BusinessApplyDetailFieldsHtml->detailPopup($smarty,$fields,$productFields);
ConvertTojsonString(1,$arr,"success");
?>