<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

require_once('modules/Calendar/Activity.php');
require_once("config.php");

require_once('modules/Calendar/CalendarCommon.php');
require_once('modules/Reminds/Reminds.php');

global $adb,$theme;
global $current_user;
global $currentModule;

$focus =CRMEntity::getInstance($currentModule);
if($_REQUEST['record']>0){
    $focus->mode='edit';
}
$activity_mode = vtlib_purify($_REQUEST['activity_mode']);
$tab_type = 'Calendar';

//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
 
$focus->column_fields["activitytype"] = '任务';

if(isset($_REQUEST['record']))
{
	$focus->id = $_REQUEST['record'];
    /**
     * edit:kevin
     * date:2013-07-23
     * reason:编辑单据时,更新客户
     */
    ////$account=new Accounts();
   // $account->updateAccountInfo($currentModule,'',1,$focus->id);
    
	//$local_log->debug("id is ".$id);
}

if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}

if((isset($_REQUEST['change_status']) && $_REQUEST['change_status']) && ($_REQUEST['status']!='' || $_REQUEST['eventstatus']!=''))
{
	$_REQUEST['diony']='diony';
	$status ='';
	$activity_type='';
	$return_id = $focus->id;
	if(isset($_REQUEST['status']))
	{
		$status = $_REQUEST['status'];
		$activity_type = "任务";
	}
	elseif(isset($_REQUEST['eventstatus']))
	{
		$status = $_REQUEST['eventstatus'];
		$activity_type = "Events";
	}
	if(isPermitted("Calendar","EditView",$_REQUEST['record']) == 'yes')
	{
		Activity::ChangeStatus($status,$return_id,$activity_type);
	}
	else
	{
		ConvertTojsonString(-1,array(),getFixedLabel('NOPERMITTEDEXECUTE'));
		/*echo "<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>";
		echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
		echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
			<tbody><tr>
			<td rowspan='2' width='11%'><img src='<?php echo lingdang_imageurl('denied.gif', $theme). ?>' ></td>
			<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
			</tr>
			<tr>
			<td class='small' align='right' nowrap='nowrap'>
			<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>								   						     </td>
			</tr>
			</tbody></table>
		</div>";
		echo "</td></tr></table>";die;*/
	}
	$invitee_qry = "select * from ld_invitees where activityid=?";
	$invitee_res = $adb->pquery($invitee_qry, array($return_id));
	$count = $adb->num_rows($invitee_res);
	if($count != 0)
	{
		for($j = 0; $j < $count; $j++)
		{
			$invitees_ids[]= $adb->query_result($invitee_res,$j,"inviteeid");

		}
		$invitees_ids_string = implode(';',$invitees_ids);
		sendInvitation($invitees_ids_string,$activity_type,$mail_data['subject'],$mail_data);
	}
	ConvertTojsonString(1,array(),"success");

}
else
{
	$tabId = getTabid($tab_type);
	foreach($focus->column_fields as $fieldname => $val)
	{
		$fieldInfo = getFieldRelatedInfo($tabId, $fieldname);    
		$uitype = $fieldInfo['uitype'];
		$typeofdata = $fieldInfo['typeofdata'];
		if(isset($_REQUEST[$fieldname]))
		{
			if(is_array($_REQUEST[$fieldname]))
				$value = $_REQUEST[$fieldname];
			else
				$value = trim($_REQUEST[$fieldname]);
			if((($typeofdata == 'T~M') || ($typeofdata == 'T~O')) && ($uitype == 2 || $uitype == 70 )) {
				if(!in_array($fieldname, $timeFields)) {
					$date = DateTimeField::convertToDBTimeZone($value);
					$value = $date->format('H:i');
				}
				$focus->column_fields[$fieldname] = $value;
			}else{
				$focus->column_fields[$fieldname] = $value;
			}
			if(($fieldname == 'notime') && ($focus->column_fields[$fieldname]))
			{	
				$focus->column_fields['duration_hours'] = '';
				$focus->column_fields['duration_minutes'] = '';
			}
			if(($fieldname == 'recurringtype') && ! isset($_REQUEST['recurringcheck']))
				$focus->column_fields['recurringtype'] = '--None--';
		}
	}
	if(isset($_REQUEST['visibility']) && $_REQUEST['visibility']!= '')
	        $focus->column_fields['visibility'] = $_REQUEST['visibility'];
	else
	        $focus->column_fields['visibility'] = '私有';
	if($_REQUEST['assigntype'] == 'U') {
		$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
	}
	$dateField = 'date_start';
	$date = new DateTimeField($_REQUEST[$dateField]);
	$focus->column_fields[$dateField] = $date->getDBInsertDateTimeValue();
	$dateField = 'due_date';	
	$date = new DateTimeField($_REQUEST[$dateField]);
	$focus->column_fields[$dateField] = $date->getDBInsertDateTimeValue();
    /**
     * edit:kevin
     * date:2013-10-21
     * reason:5364
     */ 
		  /**
		   * 客户、联系人、销售机会关联日程安排，不用中间表关联，直接查询日程安排表
			* @reason 0008399
		   * @author Tujt 2014-04-16
		   */
//    if($focus->column_fields['account_id']!='')
//    $_REQUEST['parent_id']=$focus->column_fields['account_id'];
    
	$focus->save($tab_type);

	/* For Followup END -- by Minnie */
	$return_id = $focus->id;
  
      if(isset($_REQUEST['parent_id']))
		{
            $query="insert into ld_seactivityrel(crmid,activityid)values(?,?)";
            $adb->pquery($query,array($_REQUEST['parent_id'],$focus->id));
			//$this->insertIntoEntityTable("ld_seactivityrel", $module);
		}
    //add by tifa 20130301
    $focus_rel = new Reminds();//添加提醒
    //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版）--日程提醒
    $focus_rel->column_fields['remindstype'] = 'CalendarCreateRemind';
    $focus_rel->saveRemindsInfo($module,$return_id);

}
	
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "")
	$return_module = vtlib_purify($_REQUEST['return_module']);
else
	$return_module = "Calendar";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "")
	$return_action = vtlib_purify($_REQUEST['return_action']);
else
	$return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "")
	$return_id = vtlib_purify($_REQUEST['return_id']);

$activemode = "";
if($activity_mode != '')
	$activemode = "&activity_mode=".$activity_mode;

function getRequestData($return_id)
{
	global $adb;
	$cont_qry = "select * from ld_cntactivityrel where activityid=?";
	$cont_res = $adb->pquery($cont_qry, array($return_id));
	$noofrows = $adb->num_rows($cont_res);
	$cont_id = array();
	if($noofrows > 0) {
		for($i=0; $i<$noofrows; $i++) {
			$cont_id[] = $adb->query_result($cont_res,$i,"contactid");
		}
	}
	$cont_name = '';
	foreach($cont_id as $key=>$id) {
		if($id != '') {
			$displayValueArray = getEntityName('Contacts', $id);
			if (!empty($displayValueArray)) {
				foreach ($displayValueArray as $key => $field_value) {
					$contact_name = $field_value;
				}
			}
			$cont_name .= $contact_name .', ';
		}
	}
	$cont_name  = trim($cont_name,', ');
	$mail_data = Array();
	$mail_data['user_id'] = $_REQUEST['assigned_user_id'];
	$mail_data['subject'] = $_REQUEST['subject'];

	$mail_data['status'] = (($_REQUEST['activity_mode']=='Task')?($_REQUEST['taskstatus']):($_REQUEST['eventstatus']));
    $mail_data['activity_mode'] = $_REQUEST['activity_mode'];

	$mail_data['taskpriority'] = $_REQUEST['taskpriority'];
	$mail_data['relatedto'] = $_REQUEST['parent_name'];
	$mail_data['contact_name'] = $cont_name;
	$mail_data['description'] = $_REQUEST['description'];
	$mail_data['assign_type'] = $_REQUEST['assigntype'];
	//$mail_data['group_name'] = getGroupName($_REQUEST['assigned_group_id']);
	$mail_data['mode'] = $_REQUEST['mode'];
    
    $date_start=new DateTimeField($_REQUEST['date_start']);
    $due_end=new DateTimeField($_REQUEST['due_date']);
    $datestart=$date_start->getDBInsertDateValue();
    $timestart=$date_start->getDBInsertTimeValue();
    $dueend=$due_end->getDBInsertDateValue();
    $timeend=$due_end->getDBInsertTimeValue();
    
	$value = getaddEventPopupTime($timestart,$timeend,'24');
	$start_hour = $value['starthour'].':'.$value['startmin'].''.$value['startfmt'];
	$end_hour = $value['endhour'] .':'.$value['endmin'].''.$value['endfmt'];
	$startDate = new DateTimeField($datestart." ".$start_hour);
	$endDate = new DateTimeField($dueend." ".$end_hour);
	$mail_data['st_date_time'] = $startDate->getDBInsertDateTimeValue();
	$mail_data['end_date_time'] = $endDate->getDBInsertDateTimeValue();
	$mail_data['location']=vtlib_purify($_REQUEST['location']);

	return $mail_data;
}

function getFieldRelatedInfo($tabId, $fieldName){
    global $adb;
    $fieldobj=Field::getInstance(getTabname($tabId),$adb);
	$fieldInfo=$fieldobj->getFieldInfoList();;

	return $fieldInfo;
}

if(isset($_REQUEST['contactidlist']) && $_REQUEST['contactidlist'] != '')//联系人
{
	//split the string and store in an array
	$storearray = explode (";",$_REQUEST['contactidlist']);
	$del_sql = "delete from ld_cntactivityrel where activityid=?";
	$adb->pquery($del_sql, array($record));
	$record = $focus->id;
	foreach($storearray as $id)
	{
		if($id != '')
		{

			$sql = "insert into ld_cntactivityrel values (?,?)";
			$adb->pquery($sql, array($id, $record));
			if(!empty($heldevent_id)) {
				$sql = "insert into ld_cntactivityrel values (?,?)";
				$adb->pquery($sql, array($id, $heldevent_id));
			}
		}
	}
}

//code added to send mail to the lingdang_invitees
if(isset($_REQUEST['inviteesid']) && $_REQUEST['inviteesid']!='')
{
	$mail_contents = getRequestData($return_id);
	sendInvitation($_REQUEST['inviteesid'],$_REQUEST['activity_mode'],$_REQUEST['subject'],$mail_contents);
}

//to delete contact account relation while editing event
if(isset($_REQUEST['deletecntlist']) && $_REQUEST['deletecntlist'] != '' && $_REQUEST['mode'] == 'edit')
{
	//split the string and store it in an array
	$storearray = explode (";",$_REQUEST['deletecntlist']);
	foreach($storearray as $id)
	{
		if($id != '')
		{
			$record = $focus->id;
			$sql = "delete from ld_cntactivityrel where contactid=? and activityid=?";
			$adb->pquery($sql, array($id, $record));
		}
	}

}

//to delete activity and its parent table relation
if(isset($_REQUEST['del_actparent_rel']) && $_REQUEST['del_actparent_rel'] != '' && $_REQUEST['mode'] == 'edit')
{
   
	$parnt_id = $_REQUEST['del_actparent_rel'];
	$sql= 'delete from ld_seactivityrel where crmid=? and activityid=?';
	$adb->pquery($sql, array($parnt_id, $record));
}

if(isset($_REQUEST['view']) && $_REQUEST['view']!='')
	$view=vtlib_purify($_REQUEST['view']);
if(isset($_REQUEST['hour']) && $_REQUEST['hour']!='')
	$hour=vtlib_purify($_REQUEST['hour']);
if(isset($_REQUEST['day']) && $_REQUEST['day']!='')
	$day=vtlib_purify($_REQUEST['day']);
if(isset($_REQUEST['month']) && $_REQUEST['month']!='')
	$month=vtlib_purify($_REQUEST['month']);
if(isset($_REQUEST['year']) && $_REQUEST['year']!='')
	$year=vtlib_purify($_REQUEST['year']);
if(isset($_REQUEST['viewOption']) && $_REQUEST['viewOption']!='')
	$viewOption=vtlib_purify($_REQUEST['viewOption']);
if(isset($_REQUEST['subtab']) && $_REQUEST['subtab']!='')
	$subtab=vtlib_purify($_REQUEST['subtab']);

//日程管理新增：开始日期和结束日期不一致时，导致新增单据条目数，是开始日期和结束日期的相差天数
/*if($_REQUEST['recurringcheck']) {
	include_once dirname(__FILE__) . '/RepeatEvents.php';
   
	Calendar_RepeatEvents::repeatFromRequest($focus);
}*/

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '')
	$return_viewname='0';
if($_REQUEST['return_viewname'] != '')
	$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

$parenttab=getParentTab();

if(!empty($_REQUEST['start'])) {
	$page='&start='.vtlib_purify($_REQUEST['start']);
}
if(!empty($_REQUEST['pagenumber'])){
	$page = "&start=".vtlib_purify($_REQUEST['pagenumber']);
}

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    //$arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
$focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
 else  if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    if($_REQUEST['maintab'] == 'Calendar')
	header("Location: index.php?Create=true&action=".$return_action."&module=".$return_module."&view=".$view."&hour=".$hour."&day=".$day."&month=".$month."&year=".$year."&record=".$return_id."&viewOption=".$viewOption."&subtab=".$subtab."&parenttab=$parenttab");
    else
	header("Location: index.php?action=DetailView&Create=true&module=$return_module$view$hour$day$month$year&record=$return_id$activemode&viewname=$return_viewname$page&parenttab=$parenttab$search");

}
else
{
     if($_REQUEST['maintab'] == 'Calendar')
    	header("Location: index.php?action=".$return_action."&module=".$return_module."&view=".$view."&hour=".$hour."&day=".$day."&month=".$month."&year=".$year."&record=".$return_id."&viewOption=".$viewOption."&subtab=".$subtab."&parenttab=$parenttab");
    else
	   header("Location: index.php?action=DetailView&module=$return_module$view$hour$day$month$year&record=$return_id$activemode&viewname=$return_viewname$page&parenttab=$parenttab$search");
}

?>