<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


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
	$focus->retrieve_entity_info($_REQUEST['record'], "Contacts");
	$focus->firstname = $focus->column_fields['firstname'];
	$focus->lastname = $focus->column_fields['lastname'];
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
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
/**
 * 销售机会创建联系人，客户id为0，报已删除错误
 * 将 $_REQUEST['account_id'] != '' 修改为 > 0
 * @reason 0008483
 * @author Tujt 2014-04-21
 */
if (isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0 && $_REQUEST['record'] == '') {
        
        $focus->column_fields['account_id'] = $_REQUEST['account_id'];
        $acct_focus = CRMEntity::getInstance('Accounts');
	$acct_focus->retrieve_entity_info($_REQUEST['account_id'], "Accounts");
	$focus->column_fields['fax'] = $acct_focus->column_fields['fax'];
	$focus->column_fields['otherphone'] = $acct_focus->column_fields['phone'];
	$focus->column_fields['mailingcity'] = $acct_focus->column_fields['bill_city'];
	$focus->column_fields['othercity'] = $acct_focus->column_fields['ship_city'];
	$focus->column_fields['mailingstreet'] = $acct_focus->column_fields['bill_street'];
	$focus->column_fields['otherstreet'] = $acct_focus->column_fields['ship_street'];
	$focus->column_fields['mailingstate'] = $acct_focus->column_fields['bill_state'];
	$focus->column_fields['otherstate'] = $acct_focus->column_fields['ship_state'];
	$focus->column_fields['mailingzip'] = $acct_focus->column_fields['bill_code'];
	$focus->column_fields['otherzip'] = $acct_focus->column_fields['ship_code'];
	$focus->column_fields['mailingcountry'] = $acct_focus->column_fields['bill_country'];
	$focus->column_fields['othercountry'] = $acct_focus->column_fields['ship_country'];
	$focus->column_fields['mailingpobox'] = $acct_focus->column_fields['bill_pobox'];
	$focus->column_fields['otherpobox'] = $acct_focus->column_fields['ship_pobox'];
}
if (isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->mode = "";
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
      //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if (empty($_REQUEST['record']) && $focus->mode != 'edit') {

    
    setObjectValuesFromRequest($focus);
}


$disp_view = getView($focus->mode);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['contact_no']=$value;
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);

    //BUG0075200 lius 20231108 如果客户目前没有联系人，那么在客户界面相关信息处新建联系人时，应该将首要联系人复选框默认勾上
    if($focus->column_fields['account_id'] > 0){
        $contactid = getreferencecontactid($focus->column_fields['account_id']);
        if(empty($contactid)){//客户目前没有首要联系人时，勾上
            $focus->column_fields['reference'] = 1;
        }
    }
}
/* 关联创建单据统一处理方法 end */
$smarty->assign('ISADMIN',$current_user->is_admin);
global $global_pick_list_values;
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
$smarty->assign("SINGLE_MOD", 'Contact');

if ($focus->mode == 'edit') {
	//$smarty->assign("UPDATEINFO", updateInfo($focus->id));
	$smarty->assign("MODE", $focus->mode);
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if (isset($_REQUEST['activity_mode']) && $_REQUEST['activity_mode'] != '')
	$smarty->assign("ACTIVITYMODE", vtlib_purify($_REQUEST['activity_mode']));

/* Unimplemented until jscalendar language lingdang_files are fixed
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));
*/
if (isset($_REQUEST['campaignid']))
	$smarty->assign("campaignid", vtlib_purify($_REQUEST['campaignid']));
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

$tabid = getTabid("Contacts");
$data = $fieldObj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$fields=$focus->fieldobj->getFieldListArray();

$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
if ($errormessage == 2) {
	$msg = getFixedLabel('FIELDLENERROR');
	$errormessage = "<B><font color='red'>" . $msg . "</font></B> <br><br>";
} else if ($errormessage == 3) {
 	        $msg = getFixedLabel('FILEUPLOADPROBLEMS');
	$errormessage = "<B><font color='red'>" . $msg . "</font></B> <br><br>";
} else if ($errormessage == "image") {
	 	        $msg = getFixedLabel('GIVENFILEJPG');
	$errormessage = "<B><font color='red'>" . $msg . "</font></B> <br><br>";
} else if ($errormessage == "invalid") {
	 	        $msg =geFixedLabel('INVLIDFILEDATA');
	$errormessage = "<B><font color='red'>" . $msg . "</font></B> <br><br>";
} else {
	$errormessage = "";
}
if ($errormessage != "") {
	$smarty->assign("ERROR_MESSAGE", $errormessage);
}


$smarty->assign("DUPLICATE", vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if(isset($_REQUEST['potential_id']) && $_REQUEST['potential_id'] != '')
{
	$smarty->assign('potential_id',$_REQUEST['potential_id']);
}
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

/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-09
 */
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($currentModule));

//diony 2014-10-15 弹屏新增时自动传值
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
/* editor:gyq_11 reason:九维呼叫通话记录id date:20160603*/
if(!empty($_REQUEST['jiuweiid'])){
	$smarty->assign('JiuWeiAccount',$_REQUEST['jiuweiid']);
	$smarty->assign('CALLCENTERSWITCH',$_REQUEST['callcenter_switch']);
}
/*
 *bug 0015129
 *date 20150522
 *edit zyh
 */
$sql="
SELECT 
T1.tabid, 
GROUP_CONCAT(T2.columnname) as columnname
FROM 
( SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME = 'Contacts') AS T1 
LEFT JOIN ( 
SELECT tabid, fieldid,columnname FROM ld_field WHERE uitype IN (11, 1101) AND presence <> 1 and callchecked=1 
) AS T2 ON T1.tabid = T2.tabid 
group by T1.tabid
order by T1.tabsequence";
$list_result = $adb->pquery($sql);
$num_rows=$adb->num_rows($list_result);
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $columnname = $adb->query_result($list_result,$i,'columnname');
    }
}
$smarty->assign("PhoneSteward", $columnname);

$fromuitype=array();
$arr['tablerelfields']="";
if($_REQUEST['frommodule']&&$_REQUEST['fromid']>0)
{
    $fromuitype=cls_module_uitype::getModuleUitype('Contacts', $_REQUEST['frommodule']);
    if(!empty($fromuitype))
     {
        $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("uitype",$fromuitype['uitype']);
        if(!$tmpfieldinfo||$tmpfieldinfo->getFieldName()=='')
        {
            $fromuitype=array();
        }
     }

    if(empty($fromuitype))
    {
        $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
    }
}


$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
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
if($_REQUEST['callfilename1111']||$_REQUEST['callphone1111'])
{
    $smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
    $smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
    ///保存判断
    $smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
	$smarty->assign("VALIDATASAVERULE",ldcrm_json_encode(getAllRule($currentModule)));
    $smarty->display("DetailView/EditRelated.tpl");
    
}
else
{
    if(empty($focus->id)||$isduplicate==true)
    
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
    $arr['approve_arr']=$approve_arr;
    //zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
    $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
    $is_page_setting = "no";
    if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
        $is_page_setting = "yes";
    }
    $arr['is_page_setting'] = $is_page_setting;

    $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
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
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistcontent']=$global_pick_list_values;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
	$arr["validatasaverule"]=getAllRule($currentModule);
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
    //布局规则
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
}
?>