<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

require_once(globalStatic::$root_directory.'include/upload_file.php');




global $currentModule;
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;

        /*
        新增操作，by andy,知识管理增加审批流程20131213
        */
//审批流程begin
//判断该单据是否显示审批按钮
//审批状态图片
//审批历史
//require_once('modules/Approve/Approve.php');
//$approve=new Approve();
//详情页整理按钮 tujt 2015-06-04
//$approve = Approve::getInstance();
//$issubmit=0;
//$isapprove=0;
//$isedit=0;
//$isdelete=0;

//$startapprove=$approve->startBlocksApprove();
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Documents");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];

   
    
}
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片

$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
//审批流程按钮传值end

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}

//needed when creating a new note with default values passed in
if (isset($_REQUEST['contact_name']) && is_null($focus->contact_name)) {
	$focus->contact_name = $_REQUEST['contact_name'];
}
if (isset($_REQUEST['contact_id']) && is_null($focus->contact_id)) {
	$focus->contact_id = $_REQUEST['contact_id'];
}
if (isset($_REQUEST['opportunity_name']) && is_null($focus->parent_name)) {
	$focus->parent_name = $_REQUEST['opportunity_name'];
}
if (isset($_REQUEST['opportunity_id']) && is_null($focus->parent_id)) {
	$focus->parent_id = $_REQUEST['opportunity_id'];
}
if (isset($_REQUEST['account_name']) && is_null($focus->parent_name)) {
	$focus->parent_name = $_REQUEST['account_name'];
}
if (isset($_REQUEST['account_id']) && is_null($focus->parent_id)) {
	$focus->parent_id = $_REQUEST['account_id'];
}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$filename=$focus->column_fields['filename'];
$folderid = $focus->column_fields['folderid'];
$filestatus = $focus->column_fields['filestatus'];
$filelocationtype = $focus->column_fields['filelocationtype'];
//ls 2022-03-15 0050428: （合创广虹）http://124.70.71.1:85/crm/index.php [^] 销售员权限有下载附件按钮但是登录账号不能下载知识管理的附件
//ld_field表的filestatus字段在V8.4.5.1被zkt脚本删掉，所以$filestatus永远为空，但是AttachmentField.tpl的212行有该判断$FILE_STATUS eq 1，所以先这样处理。
if (empty($filestatus)) {
    $filestatus = 1;
}

$fileattach = "select ld_attachments.attachmentsid,ld_attachments.`name`,ld_attachments.path,ld_attachments.size from ld_notes 
LEFT JOIN ld_seattachmentsrel on ld_seattachmentsrel.crmid = ld_notes.notesid 
LEFT JOIN ld_attachments on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
where ld_notes.notesid = ? limit 1";
$res = $adb->pquery($fileattach,array($focus->id));
$fileid = $adb->query_result($res,0,'attachmentsid');
$filepath = $adb->query_result($res,0,'path');


if($filelocationtype == 'I'){
	$filename = $adb->query_result($res,0,'name');
}else if($filelocationtype=='E'){
    $sql='select filename from ld_notes where notesid=?';
    $result=$adb->pquery($sql,array($_REQUEST['record']));
    $filename=$adb->query_result($result,0,0);
	$filepath = $filename;
}

$smarty->assign("FILEID",$fileid);


global $detail_column_fields_value;
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$flag = 0;
foreach($allblocks as $blocks)
{
	foreach($blocks as $block_entries)
	{
		if(!empty($block_entries['附件']['value']))
			$flag = 1;
	}
}
if($flag == 1)
	$smarty->assign("FILE_EXIST","yes");
elseif($flag == 0)
	$smarty->assign("FILE_EXIST","no");

//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

$smarty->assign("FILENAME", $filename);

if (isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);

//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);


$smarty->assign("SINGLE_MOD", 'Document');

$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
 $data =$fieldobj->split_validationdataArray();

 $smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
 $smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
 $smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
 if(is_admin($current_user))
{
 	$smarty->assign("CHECK_INTEGRITY_PERMISSION","yes");
    $smarty->assign("ADMIN","yes");
}

if($current_user->id==$focus->column_fields['assigned_user_id']){//当前用户是否为单据负责人
    $smarty->assign("ISASSIGNED","yes");
}

$smarty->assign("FILE_STATUS",$filestatus);
 $smarty->assign("DLD_TYPE",$filelocationtype);
 $smarty->assign("NOTESID",$focus->id);
 $smarty->assign("FOLDERID",$folderid);
 $smarty->assign("DLD_PATH",$filepath);

$smarty->assign("MODULE",$currentModule);


//0014773: 知识管理>明细：上一条、下一条功能失效。
//这里chj注释掉了，出现bug
if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
   
	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);

	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

//打印
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate(getTabid($currentModule)));

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

////andy
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);
//$smarty->display("DetailView/DetailRelated.tpl");
?>