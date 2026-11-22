<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Activities/DetailView.php,v 1.12 2005/03/17 11:26:49 ray Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/utils/RecurringType.php');

require_once('include/CustomFieldUtil.php');
require_once('modules/Calendar/calendarLayout.php');
/*
edit:can
reasoN:日程管理，点击一个日程主题 进入明细界面之后 报错
date:20130329
*/
//include_once 'modules/Calendar/header.php';
global $mod_strings, $currentModule,$adb, $current_user;
if( $_SESSION['mail_send_error']!="")
{
	echo '<b><font color=red>'. $mod_strings["LBL_NOTIFICATION_ERROR"].'</font></b><br>';
}
//session_unregister('mail_send_error');
unset($_SESSION['mail_send_error']);

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty =  new lingdangCRM_Smarty();
$activity_mode = vtlib_purify($_REQUEST['activity_mode']);
//If activity_mode == null
if($activity_mode =='' || strlen($activity_mode) < 1)
{
	$query = "select activitytype from ld_activity where activityid=?";
	$result = $adb->pquery($query, array($_REQUEST['record']));
	$actType = $adb->query_result($result,0,'activitytype');
	if( $actType == '任务')
	{
		$activity_mode = $actType;	
	}
	elseif($actType != 'Emails')
	{
		$activity_mode = 'Events';
	}		
}	

if($activity_mode == 'Task')
{
        $tab_type = 'Calendar';
	$smarty->assign("SINGLE_MOD",$mod_strings['LBL_TODO']);
}
elseif($activity_mode == 'Events')
{
        $tab_type = 'Events';
	$smarty->assign("SINGLE_MOD",$mod_strings['LBL_EVENT']);
}
$tab_id=getTabid($tab_type);


if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],$tab_type);
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

if (isset($_REQUEST['contactname']) && is_null($focus->contactname)) {
	$focus->contactname = $_REQUEST['contactname'];
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

if (isset($_REQUEST['accountname']) && is_null($focus->parent_name)) {
	$focus->parent_name = $_REQUEST['accountname'];
}
if (isset($_REQUEST['accountid']) && is_null($focus->parent_id)) {
	$focus->parent_id = $_REQUEST['accountid'];
}

$tab_type='Events';
global $detail_column_fields_value;
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$act_data= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

foreach($act_data as $block=>$entry)
{
	foreach($entry as $key=>$value)
	{
		foreach($value as $label=>$field)
		{
			$fldlabel[$field['fldname']] = $label;
			if($field['ui'] == 15 || $field['ui'] == 16)
			{
				if(!empty($field['options'])){
					foreach($field['options'] as $index=>$arr_val)
					{
						if($arr_val[2] == "selected")
						$finaldata[$field['fldname']] = $arr_val[0];
					}
				}
			}
			else
			{
				$fldvalue = $field['value'];
				if($field['fldname'] == 'description') { $fldvalue = nl2br($fldvalue); }
				$finaldata[$field['fldname']] = $fldvalue;
			}	
			
			$finaldata[$field['fldname'].'link'] = $field['link'];
		}
	}
}

//Start
//To set user selected hour format
if($current_user->hour_format == '')
	$format = 'am/pm';
else
	$format = $current_user->hour_format;
list($stdate,$sttime) = explode(' ',$finaldata['date_start']);
list($enddate,$endtime) = explode(' ',$finaldata['due_date']);
$time_arr = getaddEventPopupTime($sttime,$endtime,$format);
$data['starthr'] = $time_arr['starthour'];
$data['startmin'] = $time_arr['startmin'];
$data['startfmt'] = $time_arr['startfmt'];
$data['endhr'] = $time_arr['endhour'];
$data['endmin'] = $time_arr['endmin'];
$data['endfmt'] = $time_arr['endfmt'];
$data['record'] = $focus->id;
if(isset($finaldata['sendnotification']) && $finaldata['sendnotification'] == strtolower(getFixedLabel('YES'))) 
	$data['sendnotification'] = getFixedLabel('YES');
else
	$data['sendnotification'] = getFixedLabel('NO');
$data['subject'] = $finaldata['subject'];
$data['date_start'] = $stdate;
$data['due_date'] = $enddate;
$data['assigned_user_id'] = $finaldata['assigned_user_id'];
if($mod_strings[$finaldata['taskpriority']] != '')
	$data['taskpriority'] = $mod_strings[$finaldata['taskpriority']];
else
	$data['taskpriority'] = $finaldata['taskpriority'];
$data['modifiedtime'] = $finaldata['modifiedtime'];
$data['createdtime'] = $finaldata['createdtime'];
$data['modifiedby'] = $finaldata['modifiedby'];
$data['parent_name'] = $finaldata['parent_id'];

$data['description'] = $finaldata['description'];
if($activity_mode == 'Task')
{
	if($mod_strings[$finaldata['taskstatus']] != '')
		$data['taskstatus'] = $mod_strings[$finaldata['taskstatus']];
	else
		$data['taskstatus'] = $finaldata['taskstatus'];
	$data['activitytype'] = $activity_mode;
	$data['contact_id'] = $finaldata['contact_id'];
	$data['contact_idlink'] = $finaldata['contact_idlink'];
}
elseif($activity_mode == 'Events')
{
	$data['visibility'] = $finaldata['visibility'];
	if($mod_strings[$finaldata['eventstatus']] != '')
		$data['eventstatus'] = $mod_strings[$finaldata['eventstatus']];
	else
		$data['eventstatus'] = $finaldata['eventstatus'];
	$data['activitytype'] = $finaldata['activitytype'];
	$data['location'] = $finaldata['location'];
	//Calculating reminder time
	$rem_days = 0;
	$rem_hrs = 0;
	$rem_min = 0;
	//editor:gyq_109 reason:日程管理模块  2019/4/30 17:11 
    $data = $focus->detail_block_news($data);
	//To set recurring details
	$query = 'SELECT ld_recurringevents.*, ld_activity.date_start,ld_activity.due_date
				FROM ld_recurringevents
					INNER JOIN ld_activity ON ld_activity.activityid = ld_recurringevents.activityid
					WHERE ld_recurringevents.activityid = ?';
	$res = $adb->pquery($query, array($focus->id));
	$rows = $adb->num_rows($res);
	if($rows > 0) {
		$recurringObject = RecurringType::fromDBRequest($adb->query_result_rowdata($res, 0));
		$recurringInfoDisplayData = $recurringObject->getDisplayRecurringInfo();
		$data = array_merge($data, $recurringInfoDisplayData);

	} else  {
		$data['recurringcheck'] =  getFixedLabel('NO');
		$data['repeat_str'] = '';
	}
	$smarty->assign("INVITEDUSERS",$data['invited_users']);
	//$related_array = getRelatedListsInformation("Calendar", $focus);
	
	$entityname = array();
	if(isset($related_array['Contacts'])){
		$fieldsname = $related_array['Contacts']['header'];
		$contact_info = $related_array['Contacts']['entries'];
		if(!empty($contact_info)){
			$entityIds = array_keys($contact_info);
			$displayValueArray = getEntityName('Contacts', $entityIds);
			if (!empty($displayValueArray)) {
				foreach ($displayValueArray as $key => $field_value) {
					$entityname[] = '<a referencemodule="Contacts" referencerecord="'.$related_to.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $field_value . '</a>';
				}
			}
		}
	}
	$smarty->assign("CONTACTS",$entityname);
	
//	$is_fname_permitted = getFieldVisibilityPermission("Contacts", $current_user->id, 'firstname');
//	$smarty->assign("IS_PERMITTED_CNT_FNAME",$is_fname_permitted);


}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$category = getParentTab();
$smarty->assign("CATEGORY",$category);

$smarty->assign("ACTIVITY_MODE", $activity_mode);

if (isset($focus->name)) 
$smarty->assign("NAME", $focus->name);
else 
$smarty->assign("NAME", "");
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
if (isset($_REQUEST['return_module'])) 
$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action'])) 
$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id'])) 
$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string'].'&activity_mode='.$activity_mode);
$smarty->assign("ID", $focus->id);
$smarty->assign("NAME", $focus->name);
$smarty->assign("BLOCKS", $act_data);
$smarty->assign("LABEL", $fldlabel);
$smarty->assign("VIEWTYPE", vtlib_purify($_REQUEST['viewtype']));
$smarty->assign("CUSTOMFIELD", $cust_fld);

$smarty->assign("ACTIVITYDATA", $data);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));



//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

 $tabid = getTabid($tab_type);
 $data2 =$fieldobj->split_validationdataArray();

 $smarty->assign("VALIDATION_DATA_FIELDNAME",$data2['fieldname']);
 $smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data2['datatype']);
 $smarty->assign("VALIDATION_DATA_FIELDLABEL",$data2['fieldlabel']);

$smarty->assign("MODULE",$currentModule);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}


/**
 * edit:andy
 * reason:日程管理增加审批流程
 * data:20140414
 */
 //审批star
//require_once('modules/Approve/Approve.php');
//$approve=new Approve();
$approve = Approve::getInstance($currentModule);
$issubmit=0;
$isapprove=0;
$isedit=0;
$isdelete=0;
$iscancel = 0;
$startapprove=$approve->startBlocksApprove();
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Calendar");
    $focus->id = $_REQUEST['record'];

    if(!empty($startapprove['Calendar'])){
        $approveinfo=$approve->approveStatus($record);
        $approvestatus=$approveinfo['approvestatus'];
        $blockbuttons=$approve->blocksButton($focus->column_fields['assigned_user_id'],$record);
        //审批历史
        //$approvelog=$approve->approveLog($approveinfo['approveid'],$focus->id);
        //编辑、审批提交等按钮是否显示
        $isedit=$blockbuttons[0];
        $issubmit=$blockbuttons[1];
        $isapprove=$blockbuttons[2];
        $isdelete=$blockbuttons[3];
		/**
		 * 判断反审批权限
		 * @project PROT144 审批功能改进
		 * @author Tujt 2014-12-30
		 */
		$iscancel = $approve->getCancelApprovedBtn($currentModule,$record,$focus->column_fields,$blockbuttons);
        //echo "<pre>";
        //var_dump($blockbuttons);
    }
    
}
include('user_privileges/user_language_'.$current_user->id.'.php');
//审批状态图片
if(!empty($startapprove['Calendar'])){
    if($approvestatus=='')
    {
       $approvestatus=0;
    } 
	$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
    if($approvestatus != 0 && $isedit==1)
    {
        $smarty->assign("EDITSTATUS","no");
    }
}

    //if($issubmit == 1){
         //$list_buttons_moreD['del'] = getFixedLabel('DELETE');
    //}
 //}
//if( $check_button['moduleSettings'] == 'yes'){
    //$list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
//}
//审批流程end
//审批流程按钮传值begin
$smarty->assign('ISSUBMIT',$issubmit);
$smarty->assign('ISAPPROVE',$isapprove);
$smarty->assign('ISCANCEL',$iscancel);
//$smarty->assign('APPROVE',$approvelog);
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETES',$isdelete);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
//审批end 
$custom_fields_data = getCalendarCustomFields($tabid,'detail_view',$focus->column_fields);
$smarty->assign("CUSTOM_FIELDS_DATA", $custom_fields_data);
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', false));
//$smarty->display("DetailView.tpl");


//andy
$tabid=getTabid($currentModule);
////打印
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 * 判断数组是否为空
 */
//print_r($list_buttons_moreD);
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//更多信息
/**
 *@edit:andy 
 *@date:20140909
 *@reason:0011247: 日程管理查看界面：左边没有显示 ”相关信息“，相关信息中有附件管理。新增和编辑界面都显示了，希望显示出来
 *@version:
 */
 $is_rel_list=isPresentRelatedLists($currentModule);
 $is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("FROMCALENDAR",$_REQUEST['fromCalendar']);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径

//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
DetailViewReturn($currentModule,$focus,$smarty);
//$smarty->display("DetailView/DetailRelated.tpl");


/** This function returns the related lingdang_tab details for a given entity or a module.
 * Param $module - module name
 * Param $focus - module object
 * Return type is an array
 */
function getRelatedListsInformation($module, $focus) {

	global $adb;
	global $current_user;
	require('user_privileges/user_privileges_' . $current_user->id . '.php');

	$cur_tab_id = getTabid($module);

	//$sql1 = "select * from ld_relatedlists where tabid=? order by sequence";
	// vtlib customization: Do not picklist module which are set as in-active
	$sql1 = "select * from ld_relatedlists where tabid=? and related_tabid not in (SELECT tabid FROM ld_tab WHERE presence = 1) order by sequence";
	// END
	$result = $adb->pquery($sql1, array($cur_tab_id));
	$num_row = $adb->num_rows($result);
	for ($i = 0; $i < $num_row; $i++) {
		$rel_tab_id = $adb->query_result($result, $i, "related_tabid");
		$function_name = $adb->query_result($result, $i, "name");
		$label = $adb->query_result($result, $i, "label");
		$actions = $adb->query_result($result, $i, "actions");
		$relationId = $adb->query_result($result, $i, "relation_id");
		if ($rel_tab_id != 0) {
			if ($profileTabsPermission[$rel_tab_id] == 0) {
				if ($profileActionPermission[$rel_tab_id][3] == 0) {
					// vtlib customization: Send more information (from module, related module)
					// to the callee
					$focus_list[$label] = $focus->$function_name($focus->id, $cur_tab_id,
									$rel_tab_id, $actions);
					// END
				}
			}
		} else {
			// vtlib customization: Send more information (from module, related module)
			// to the callee
			$focus_list[$label] = $focus->$function_name($focus->id, $cur_tab_id, $rel_tab_id,
							$actions);
			// END
		}
	}

	return $focus_list;
}

?>