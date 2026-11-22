<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $current_language, $currentModule, $theme;
global $adb;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$category = getParentTab($currentModule);
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$record = $_REQUEST['record'];
$publicaccount=0;
if($_REQUEST['publicaccount'])
{
    $publicaccount=$_REQUEST['publicaccount'];
}
$smarty->assign('PUBLICACCOUNT',$publicaccount);
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
}else{
	$focus->mode = 'create';
}

//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（新建及快速创建、复制时判断上限）
if (($focus->mode != 'edit' || $isduplicate) && $publicaccount == 0) {
    //判断是否允许新建普通客户
    $limit_count = $focus->getCommonAccountLimitCount($current_user->id);//普通销售线索数量上限
    if($limit_count<9999999999)
    {
        $haved_count = $focus->getSmowerNumForCommonAccount($current_user->id);//已有销售线索数量
        if ($limit_count <= $haved_count) {
            ConvertTojsonString(-1,[],$public_account['status']=='yes'?getFixedLabel('CreateReacheMaximumLeadsError1'):getFixedLabel('CreateReacheMaximumLeadsError'));
        }
    }
}

if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['callfilename']) && $_REQUEST['callfilename'] != '')
{
      $one_callfiles=explode('\\',$_REQUEST['callfilename']);
     $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
     $callfilenames=explode('_',$two_callfilename);
     $callphone=$callfilenames[0];
     $xinghao_phone= fieldValueUitype::setReportMobileStyle($callphone);
     for($i=0;$i<sizeof($one_callfiles)-1;$i++)
     {
        $filenames.=$one_callfiles[$i].'\\';
     }
    $one_filenames=$filenames.$xinghao_phone.'_'.$callfilenames[1];
    crm_load_class_file('cls_PhoneEncrypt','include');
    $obj=new cls_PhoneEncrypt();
 
    $two_filenames=$filenames.$obj->createToken_Phone($callphone).'_'.$callfilenames[1] ;

    $smarty->assign('CALLFILENAME',$one_filenames);
    $smarty->assign('ENCRYPT_FILENAME',$two_filenames);
	$smarty->assign('CALLTYPE',$_REQUEST['calltype']);
    $smarty->assign('CALLDISPLAY','yes');
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$fieldrulecols=$fieldruleobj->getAllRules();

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
$disp_view = getView($focus->mode);
if(isset($_REQUEST['return_module']))   {
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
}else{
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
//runze
if(!empty($_REQUEST['relatedcreate']) && $_REQUEST['relatedcreate'] == 'yes' && !empty($_REQUEST['fromid']) && $_REQUEST['frommodule'] == 'SalesOrder'){
	$focus->column_fields['salesorder_id'] = $_REQUEST['fromid'];
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['leads_no'] = $value;
}

$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);


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
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ISADMIN',$current_user->is_admin);
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

$validationArray =$focus->fieldobj->split_validationdataArray($validationData);

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
$smarty->assign('ID', $focus->id);

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
    $smarty->assign('CREATE','true');
}else{ 
	$smarty->assign('CREATE','false');
}
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//$smarty->display("DetailView/EditRelated.tpl");

$qcreate_array=$focus->fieldobj->QuickCreate();

$smarty->assign("QUICKCREATE", $qcreate_array['form']);

//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $weixin_user->environment='pc';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $weixin_user->environment='pc';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
//选择模块的字段
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
$arr['approve_arr']=$approve_arr;
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];

$arr['fields']=$fields['fields'];
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
/*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
        if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
// $focus->getModuleLogic($currentModule)->getDetailViewButton();
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;
$arr['filejsondata']=$fieldjsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate($currentModule);
$arr['fieldrulecols']=$fieldrulecols;
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
//敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
crm_load_class_file('cls_fieldSensitiverule','include/fields');
$fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
$arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段
//duan 20240923 在编辑页面结尾对返回值增加统一操作
crm_load_class_file('CommonEditViewReturn','modules/lingdang');
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>