<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//自定义表单 编辑页面代码提取

global   $theme, $currentModule, $current_user;

//added for contact image
$encode_val = vtlib_purify($_REQUEST['encode_val']);
$decode_val = base64_decode((string)$encode_val);

$saveimage = isset($_REQUEST['saveimage']) ? vtlib_purify($_REQUEST['saveimage']) : "false";
$errormessage = isset($_REQUEST['error_msg']) ? vtlib_purify($_REQUEST['error_msg']) : "false";
$image_error = isset($_REQUEST['image_error']) ? vtlib_purify($_REQUEST['image_error']) : "false";
//end

$focus = CRMEntity::getInstance($currentModule);

$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    $focus->firstname = $focus->column_fields['firstname'];
    $focus->lastname = $focus->column_fields['lastname'];
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    //zkt 20230914 BUG0072520 点击基础档案，BU档案，对已维护的一条数据，点击编辑按钮，提示报错
    if(!empty($fieldinfo)){
        if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
        {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
        }
    }
}

if ($image_error == "true") {
    $explode_decode_val = explode("&", $decode_val);
    for ($i = 1; $i < count($explode_decode_val); $i++) {
        $test = $explode_decode_val[$i];
        $values = explode("=", $test);
        $field_name_val = $values[0];
        $field_value = $values[1];
        $focus->column_fields[$field_name_val] = $field_value;
    }
}

if (isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
    $focus->id = "";
    $focus->mode = "";
    /**
     * 复制时，负责人设置为自己
     * @author Tujt 2015-07-20
     */
    $focus->column_fields['assigned_user_id'] = $current_user->id;
}
if (empty($_REQUEST['record']) && $focus->mode != 'edit') {


    setObjectValuesFromRequest($focus);
}


$disp_view = getView($focus->mode);

/**
 * 创建单据时，编号为自动生成后的编�?
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
    $value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
    if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
    $focus->column_fields[$focus->table_code]=$value;
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
    $focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
global $global_pick_list_values;
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
    $focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
    $global_pick_list_values = []; //关联带出时会获取到原模块的字段下拉框值，上级模块存在级联的话，会使得下级字段的下拉框值为空
}
/* 关联创建单据统一处理方法 end */
$smarty->assign('ISADMIN',$current_user->is_admin);

$act_data = getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);


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
$smarty->assign("OP_MODE", $disp_view);

//needed when creating a new contact with a default lingdang_account value passed in
if (isset($_REQUEST['account_name']) && is_null($focus->account_name)) {
    $focus->account_name = $_REQUEST['account_name'];


}
if (isset($_REQUEST['account_id']) && is_null($focus->account_id)) {
    $focus->account_id = $_REQUEST['account_id'];
}

$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$smarty->assign("THEME", $theme);

$contact_name = $focus->lastname;
$contact_name .= ' ' . $focus->firstname;

$smarty->assign("NAME", $contact_name);
if (isset($cust_fld)) {
    $smarty->assign("CUSTOMFIELD", $cust_fld);
}
$smarty->assign("ID", $focus->id);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", $currentModule);

if ($focus->mode == 'edit') {
    //$smarty->assign("UPDATEINFO", updateInfo($focus->id));
    $smarty->assign("MODE", $focus->mode);
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if (isset($_REQUEST['activity_mode']) && $_REQUEST['activity_mode'] != '')
    $smarty->assign("ACTIVITYMODE", vtlib_purify($_REQUEST['activity_mode']));

if (isset($_REQUEST['return_module']))
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action']))
    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id']))
    $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname']))
    $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);

$tabid = getTabid($currentModule);
$data = $fieldObj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$fields=$focus->fieldobj->getFieldListArray();

$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());


$smarty->assign("DUPLICATE", vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

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
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$smarty->assign('VERSION_TRADE',$version_info['trade']);
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{

    $smarty->assign('CREATE','true');
}
else
{
    $smarty->assign('CREATE','false');
}

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);



if(empty($focus->id)||$isduplicate==true)

    $qcreate_array=$focus->fieldobj->QuickCreate();
$tmpquicksize=0;
foreach($qcreate_array['form'] as $index=>$quickinfos)
{
    $tmpquicksize+=sizeof($quickinfos);
}

$modulefields=$focus->fieldobj->getModuleFields();
if($tmpquicksize==sizeof($modulefields))
{
    //�½������չ��������
    $arr['showexpand']='no';
}
else
{
    //�½������չ��������
    $arr['showexpand']='yes';
}

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
$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$arr['approve_arr']=$approve_arr;
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['frommodule']=$_REQUEST['frommodule'];
$arr['fromid']=$_REQUEST['fromid'];
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>
