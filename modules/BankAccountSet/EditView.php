<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;
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
//4600 ends
if($_REQUEST['record']){
    $sqlstus="select confirmed from ld_bankaccountset where bankaccountsetid=".$_REQUEST['record']; 
    $reslutsturs = $adb->pquery($sqlstus);
    $confirmedst = $adb->query_result($reslutsturs,0,'confirmed');
}

if($_REQUEST['isDuplicate']=='true'){
    $confirmedst=0;
}
$smarty->assign("CONFIRMEDST", $confirmedst);
if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
}
//chj:获取币种ID
if($focus->mode == 'edit')
    $smarty->assign('CURRENCYID',$focus->column_fields['currency_id']);
else
    $smarty->assign('CURRENCYID',1);

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    
	setObjectValuesFromRequest($focus);
}
if($isduplicate == 'true') {
    $focus->mode = '';
  
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

if(isset($_REQUEST['salesorder_id']))
{
     $sqlsalesorder="select accountid from ld_salesorder where salesorderid=?";
     $resultsalesorder=$adb->pquery($sqlsalesorder,array($_REQUEST['salesorder_id']));
     if($adb->num_rows($resultsalesorder)>0)
     {
        $focus->column_fields['account_id']=$adb->query_result($resultsalesorder,0,0);
     }
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);
 /**
    * 更新操作
    * edit:can
    * date:20131223
    * reason:添加富文本框
    * */
$richText=$act_data['RichText'];
 unset($act_data['RichText']);
$smarty->assign("BLOCKS",$act_data );
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','');
}

$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('MODULE', $currentModule);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', $currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName =$focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
	//$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

global $adb;
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$now= $tmp_date=date("Y-m"); 
$days = date("t");  
$smarty->assign("NOWMONTHSTART",$now.'-01');
$smarty->assign("NOWMONTHEND",$now.'-'.$days);
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$trExpense='';

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')))
{
       
    $smarty->assign('CREATE','true');
}
else
{
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
     $smarty->assign('CREATE','false');
     
}

if($isduplicate == 'true') {
	$focus->id = '';
	
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
$data = $focus->fieldobj->split_validationdataArray();

$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$qcreate_array=$focus->fieldobj->QuickCreate();

$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
//   $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
//   $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));
//
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
//敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
crm_load_class_file('cls_fieldSensitiverule','include/fields');
$fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
$arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段

//duan 20240923 在编辑页面结尾对返回值增加统一操作
crm_load_class_file('CommonEditViewReturn','modules/lingdang');
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate($currentModule);
 ///保存判断
 $arr["validatasave"]=getValidataSave($currentModule);
 $arr["validatasaverule"]=getAllRule($currentModule);
ConvertTojsonString(1,$arr,"success");
?>