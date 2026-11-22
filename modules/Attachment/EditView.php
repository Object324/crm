<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


$smarty = new lingdangCRM_Smarty();

global $theme,$currentModule,$current_user;

$module = vtlib_purify($_REQUEST['module']);
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

$smarty->assign("UPLOADSIZE", $upload_maxsize/1000000); //Convert to MB
$smarty->assign("UPLOAD_MAXSIZE",$upload_maxsize);
if($_REQUEST['upload_error'] == true)
{
	echo '<br><b><font color="red"> '.$mod_strings['FILE_HAS_NO_DATA'].'.</font></b><br>';
}

if(isset($_REQUEST['record']) && $_REQUEST['record'] !='')
{
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'],"Attachment");
    //$focus->name=$focus->column_fields['notes_title'];
}
//18706: 附件管理>新建：负责人显示空白。
if(empty($smownerid) && $focus->mode == ''){
	$smownerid = $current_user->id;
}
if($focus->mode != 'edit')
{
	if(isset($_REQUEST['parent_id']) && isset($_REQUEST['return_module']))
	{
		$owner = getRecordOwnerId($_REQUEST['parent_id'],'Attachment');
		if(isset($owner['Users']) && $owner['Users'] != '') {
			$permitted_users = get_user_array('true', 'Active',$current_user->id);
			if(!in_array($owner['Users'],$permitted_users)){
				$owner['Users'] = $current_user->id;
			}
			$focus->column_fields['assigntype'] = 'U';
			$focus->column_fields['assigned_user_id'] = $owner['Users'];
		} elseif(isset($owner['Groups']) && $owner['Groups'] != '') {
			$focus->column_fields['assigntype'] = 'T';
			$focus->column_fields['assigned_user_id'] = $owner['Groups'];
		}
	}
}


if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    
	setObjectValuesFromRequest($focus);
}
 if($_REQUEST['user_id']>0)
     {
        $focus->column_fields['related_to']=$_REQUEST['user_id'];
         $focus->column_fields['reltab']='Users';
         $focus->column_fields['assigned_user_id']=$_REQUEST['user_id'];
         
     }

/*
*新增操作，附件上传重新指定目录
*by andy 
*20140107
*/
if(isset($_REQUEST['parent_id']) && $focus->mode != 'edit') {
	$myatt_id=vtlib_purify($_REQUEST['parent_id']);
    $setype = getEntitySetype($myatt_id);
	$smarty->assign("PARENTID",$myatt_id);
    $smarty->assign("PARENTMODULE", $setype);
    decideFilePaths($setype,$myatt_id);
	/**
	 * 相关信息创建附件，负责人默认为单据的负责人
	 * @reason 0014900: 客户>查看界面：关联创建-创建附件，结果新增附件界面没有显示：负责人、相关模块、相关对象字段，导致保存后负责人为空-如图
	 * @author Tujt 2015-05-12
	 */
	//begin
    
	$entityarr = getEntitynameInfo(getTabid($setype));
    $settype_focus=CRMEntity::getInstance($setype);
    $setype_table=$settype_focus->table_name;
	$parent_tabname = $entityarr['tablename'];
	$parent_tabidx = $entityarr['entityidfield'];
	$parent_fieldname = $entityarr['fieldname'];
    
	$parentselect = 'select smownerid,'.$parent_fieldname.' as name from ' .$setype_table;
    if($setype_table!=$parent_tabname)
    {
        //超链接为自定义字段
        $parentselect .=' left join '.$parent_tabname. ' on '.$parent_tabname.'.'.$settype_focus->tab_name_index[$parent_tabname].'='.$setype_table.'.'.$settype_focus->table_index;
    }
    $parentselect.= ' where '.$setype_table.'.'.$settype_focus->table_index.'='.$myatt_id.' limit 1;';

    $parentresult = $adb->pquery($parentselect,array());
	$parentrows = $adb->num_rows($parentresult);
	//if(1 == $parentrows)
		//$smownerid = $adb->query_result($parentresult,0,'smownerid');
	$parentname = $adb->query_result($parentresult,0,'name');

	$smarty->assign("PARENTNAME", $parentname);
	//end
}elseif(isset($_REQUEST['return_id']) && $focus->mode == 'edit'){
    $myatt_id=$_REQUEST['return_id'];
    $smarty->assign("PARENTID",$myatt_id);
    $setype = getEntitySetype($myatt_id);
    $smarty->assign("PARENTMODULE", $setype);
    decideFilePaths($setype,$myatt_id);
}
if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
}
//setting default flag value so due date and time not required
if (!isset($focus->id)) $focus->date_due_flag = 'on';
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
//needed when creating a new case with default values passed in
if (isset($_REQUEST['contact_name']) && is_null($focus->contact_name)) {
	$focus->contact_name = $_REQUEST['contact_name'];
}
if (isset($_REQUEST['contact_id']) /* && is_null($focus->contact_id) */ ) {
	$focus->contact_id = $_REQUEST['contact_id'];
}
if (isset($_REQUEST['parent_name']) && is_null($focus->parent_name)) {
	$focus->parent_name = $_REQUEST['parent_name'];
}
if (isset($_REQUEST['parent_id']) /* && is_null($focus->parent_id) */ ) {
	$focus->parent_id = $_REQUEST['parent_id'];
}
if (isset($_REQUEST['parent_type'])) {
	$focus->parent_type = $_REQUEST['parent_type'];
}
elseif (!isset($focus->parent_type)) {
	$focus->parent_type = $app_list_strings['record_type_default_key'];
}
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['attachment_no'] = $value;
}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$disp_view = getView($focus->mode);

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
    //zkt 20220621 BUG0053062附件管理关联项目立项创建。项目类型不会被带出来（引用的项目立项的项目类型）。需要再选择一次项目立项，才会带出来。详情见附件。
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
$blocks=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);
//wym 231229 BUG0078101 如果模块存在富文本框字段,block里会有RichText,需要获取到它再unset掉,参考客户模块
$richText=$blocks['RichText'];
unset($blocks['RichText']);
if(!empty($richText))
    $smarty->assign('RICHTEXTBOX',implode(',',$richText));
else
    $smarty->assign('RICHTEXTBOX','');

	$smarty->assign("BLOCKS",$blocks);
/*else
{
	$smarty->assign("BASBLOCKS",getBlocks($currentModule,$disp_view,$mode,$focus->column_fields,'BAS'));
}*/
$smarty->assign("OP_MODE",$disp_view);
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$account_field_obj=Field::getInstance('Attachment',$adb);
$arrfileLabel=$account_field_obj->getFieldLables();
$smarty->assign('ARRFIELDLABEL',$arrfileLabel);
$record = $_REQUEST['record'];

$smarty->assign("ID", $recordid);
 //$smarty->assign('smownerid',$smownerid);
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'Document');

if (isset($attname))
$smarty->assign("NAME", $attname);
else
$smarty->assign("NAME", "");

if($focus->mode == 'edit')
{
	//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
    $smarty->assign("MODE", $focus->mode);
}
else
{
	$smarty->assign("MODE",'create');
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if (isset($_REQUEST['return_module']))
$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
$smarty->assign("RETURN_MODULE","Attachment");
//30929: 附件管理明细界面：点击【编辑】，打开弹出层，保存，结果界面跳转到附件管理序时簿界面了
//if (isset($_REQUEST['return_action']))
  //  $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
//else
//$smarty->assign("RETURN_ACTION","index");
if (isset($_REQUEST['return_id']))
$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['email_id']))
$smarty->assign("EMAILID", vtlib_purify($_REQUEST['email_id']));
if (isset($_REQUEST['ticket_id'])) $smarty->assign("TICKETID", vtlib_purify($_REQUEST['ticket_id']));
if (isset($_REQUEST['fileid']))
$smarty->assign("FILEID", vtlib_purify($_REQUEST['fileid']));
if (isset($_REQUEST['record']))
{
         $smarty->assign("CANCELACTION", "DetailView");
}
else
{
         $smarty->assign("CANCELACTION", "index");
}
if (isset($_REQUEST['return_viewname']))
$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("ID", '');
}else{
	$smarty->assign("ID", $focus->id);
}
$smarty->assign("OLD_ID", $old_id );
if (isset($focus->parent_type) && $focus->parent_type != "") {
        $change_parent_button = "<input title='".$app_strings['LBL_CHANGE_BUTTON_TITLE']."' accessKey='".$app_strings['LBL_CHANGE_BUTTON_KEY']."' lingdang_tabindex='3' type='button' class='button' value='".$app_strings['LBL_CHANGE_BUTTON_LABEL']."' name='button' LANGUAGE=javascript onclick='return window.open(\"index.php?module=\"+ document.EditView.parent_type.value + \"&action=Popup&html=Popup_picker&form=TasksEditView\",\"test\",\"width=600,height=400,resizable=1,scrollbars=1\");'>";
        $smarty->assign("CHANGE_PARENT_BUTTON", $change_parent_button);
}
if ($focus->parent_type == "Account") $smarty->assign("DEFAULT_SEARCH", "&query=true&account_id=$focus->parent_id&account_name=".urlencode($focus->parent_name));

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$data = $fieldobj->split_validationdataArray();

//$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
//$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
//$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
//$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

global $adb;


// Gather the help information associated with fields
//$smarty->assign('FIELDHELPINFO', vtlib_getFieldHelpInfo($currentModule));
// END
$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $current_user->id);
$smarty->assign('USERCOMBO',$users_combo);
//crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
//$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", Zend_Json::encode($picklistDependencyDatasource));

//读取可上传文件的类型
$file_path = "modules/Attachment/attachments.txt";
$filehandle = fopen($file_path,"r");
$smarty->assign('FIELDTYPE',fgets($filehandle));
/*用户详情页- 创建附件  传入user_id
zyh
用户详情页增加附件
PROT197 
20150420
*/
$smarty->assign('USERID',$_REQUEST['user_id']);
$smarty->assign('SWID',$_REQUEST['swid']);
fclose($filehandle);
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());//收款信息明细html

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

$qcreate_array=$focus->fieldobj->QuickCreate();
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
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1108,'fieldname')!=''){
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1108,'fieldname')]=json_decode( getAttachmentForBills($tmp_record,$currentModule));
}
   
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);


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
$arr['picklistcontent']=$global_pick_list_values;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate($currentModule);
 ///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
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
//}
?>