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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Activities/OpenListView.php,v 1.22 2005/04/19 17:00:30 ray Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/

/**
 * Function to get Pending/Upcoming activities
 * @param integer  $mode     - number to differentiate upcoming and pending activities
 * return array    $values   - activities record in array format
 */
function getPendingActivities($mode,$view=''){
	
	global $currentModule;
	global $singlepane_view;
	global $theme;
	global $focus;
	global $action;
	global $adb;
	global $current_user;

	$theme_path="themes/".$theme."/";
	$image_path=$theme_path."images/";

	if($_REQUEST['activity_view']==''){
		$activity_view='today';
	}else{
		$activity_view=vtlib_purify($_REQUEST['activity_view']);
	}

	$dbStartDateTime = new DateTimeField(date('Y-m-d H:i:s'));
	$userStartDate = $dbStartDateTime->getDisplayDate();
	$userStartDateTime = new DateTimeField($userStartDate.' 00:00:00');
	$startDateTime = $userStartDateTime->getDBInsertDateTimeValue();

	$userEndDateTime = new DateTimeField($userStartDate.' 23:59:00');
	$endDateTime = $userEndDateTime->getDBInsertDateTimeValue();

	if($view == 'today'){
		$upcoming_condition = " AND (CAST((CONCAT(date_start,' ',time_start)) AS DATETIME) BETWEEN '$startDateTime' AND '$endDateTime'
									OR CAST((CONCAT(ld_recurringevents.recurringdate,' ',time_start)) AS DATETIME) BETWEEN '$startDateTime' AND '$endDateTime')";
		$pending_condition = " AND (CAST((CONCAT(date_start,' ',time_start)) AS DATETIME) BETWEEN '$startDateTime' AND '$endDateTime'
									OR CAST((CONCAT(ld_recurringevents.recurringdate,' ',time_start)) AS DATETIME) BETWEEN '$startDateTime' AND '$endDateTime')";
	}else if($view == 'all'){
		$upcoming_condition = " AND (CAST((CONCAT(date_start,' ',time_start)) AS DATETIME) >= '$startDateTime'
									OR CAST((CONCAT(ld_recurringevents.recurringdate,' ',time_start)) AS DATETIME) >= '$startDateTime')";
		$pending_condition = " AND (CAST((CONCAT(date_start,' ',time_start)) AS DATETIME) <= '$startDateTime'
									OR CAST((CONCAT(ld_recurringevents.recurringdate,' ',time_start)) AS DATETIME) <= '$startDateTime')";
	}

	if($mode != 1){
		$list_query = " select ld_crmentity.crmid,ld_crmentity.smownerid,ld_crmentity.".
		"setype, ld_recurringevents.recurringdate, ld_activity.activityid, ".
		"ld_activity.activitytype, ld_activity.date_start, ld_activity.due_date,".
		"from ld_activity inner join ld_crmentity on ld_crmentity.crmid=".
		"ld_activity.activityid LEFT JOIN ld_groups ON ld_groups.groupid = ".
		"ld_crmentity.smownerid left outer join ld_recurringevents on ".
		"ld_recurringevents.activityid=ld_activity.activityid";
		$list_query .= getNonAdminAccessControlQuery('Calendar',$current_user);
		$list_query .= " WHERE ld_crmentity.deleted=0 and ld_activity.activitytype not in ".
		"('Emails') AND ( ld_activity.status is NULL OR ld_activity.status not in".
		"('Completed','Deferred')) and ( ld_activity.eventstatus is NULL OR ld_activity.".
		"eventstatus not in ('Held','Not Held') )".$upcoming_condition;

	}else{
		$list_query = "select ld_crmentity.crmid,ld_crmentity.smownerid,ld_crmentity".
		"setype, ld_recurringevents.recurringdate, ld_activity.activityid, ld_activity".
		".activitytype, ld_activity.date_start, ld_activity.due_date, from ld_activity".
		"inner join ld_crmentity on ld_crmentity.crmid=ld_activity.activityid ".
		"LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid ".
		"left outer join ld_recurringevents on ld_recurringevents.activityid=".
		"ld_activity.activityid";
		$list_query .= getNonAdminAccessControlQuery('Calendar',$current_user);
		$list_query .= "WHERE ld_crmentity.deleted=0 and (ld_activity.".
		"activitytype not in ('Emails')) AND (ld_activity.status is NULL OR ld_activity.".
		"status not in ('Completed','Deferred')) and (ld_activity.eventstatus is NULL OR ".
		"ld_activity.eventstatus not in ('Held','Not Held')) ".$pending_condition;

		$list_query.= " GROUP BY ld_activity.activityid";
		$list_query.= " ORDER BY date_start,time_start ASC";
		$res = $adb->query($list_query);
		$noofrecords = $adb->num_rows($res);
		$open_activity_list = array();
		$noofrows = $adb->num_rows($res);
		if (count($res)>0){
			for($i=0;$i<$noofrows;$i++){
				$dateValue = $adb->query_result($res,$i,'date_start') . ' ' .
						$adb->query_result($res,$i,'time_start');
				$endDateValue = $adb->query_result($res,$i,'due_date') . ' ' .
						$adb->query_result($res,$i,'time_end');
				$recurringDateValue = $adb->query_result($res,$i,'due_date') . ' ' .
						$adb->query_result($res,$i,'time_start');
				$date = new DateTimeField($dateValue);
				$endDate = new DateTimeField($endDateValue);
				$recurringDate = new DateTimeField($recurringDateValue);

				$open_activity_list[] = Array('name' => $adb->query_result($res,$i,'subject'),
						'id' => $adb->query_result($res,$i,'activityid'),
						'type' => $adb->query_result($res,$i,'activitytype'),
						'module' => $adb->query_result($res,$i,'setype'),
						'date_start' => $date->getDisplayDate(),
						'due_date' => $endDate->getDisplayDate(),
						'recurringdate' => $recurringDate->getDisplayDate(),
						'priority' => $adb->query_result($res,$i,'priority'), // Armando L�scher 04.07.2005 -> �priority -> Desc: Get lingdang_priority from db
						);
			}
		}

	$title=array();
	$title[]=$view;
	$title[]='myUpcoPendAct.gif';
	$title[]='home_myact';
	$title[]='showActivityView';
	$title[]='MyUpcumingFrm';
	$title[]='activity_view';

	$header=array();
	$header[] =$current_module_strings['LBL_LIST_SUBJECT'];
	$header[] ='Type';

	$return_url="&return_module=$currentModule&return_action=DetailView&return_id=" . ((is_object($focus)) ? $focus->id : "");
	$oddRow = true;
	$entries=array();

	foreach($open_activity_list as $event){
		$recur_date=preg_replace('/--/','',$event['recurringdate']);
		if($recur_date!=""){
			$event['date_start']=$event['recurringdate'];
		}
		$font_color_high = "color:#00DD00;";
		$font_color_medium = "color:#DD00DD;";

		switch ($event['priority']){
			case 'High':
				$font_color=$font_color_high;
				break;
			case 'Medium':
				$font_color=$font_color_medium;
				break;
			default:
				$font_color='';
		}

		if($event['type'] != '任务' && $event['type'] != 'Emails' && $event['type'] != ''){
			$activity_type = 'Events';
		}else{
			$activity_type = '任务';
		}
	}
	$entries[$event['id']] = array(
			'0' => '<a href="index.php?action=DetailView&module='.$event["module"].'&activity_mode='.$activity_type.'&record='.$event["id"].''.$return_url.'" style="'.$font_color.';">'.$event["name"].'</a>',
			'IMAGE' => '<IMG src="'.$image_path.$event["type"].'s.gif">',
			);
	}
	$values=Array('noofactivities'=>$noofrecords,'Title'=>$title,'Header'=>$header,'Entries'=>$entries);
	$log->debug("Exiting getPendingActivities method ...");
	return $values;
}

/**
 * Function creates HTML to display ActivityView selection box
 * @param string   $activity_view                 - activity view
 * return string   $ACTIVITY_VIEW_SELECT_OPTION   - HTML selection box
 */
function getActivityview($activity_view)
{
	
	$log->debug("Entering getActivityview(".$activity_view.") method ...");
	$today = DateTimeField::convertToUserFormat(date("Y-m-d"));

	if($activity_view == 'Today')
	{
		$selected1 = 'selected';
	}
	else if($activity_view == 'This Week')
	{
		$selected2 = 'selected';
	}
	else if($activity_view == 'This Month')
	{
		$selected3 = 'selected';
	}
	else if($activity_view == 'This Year')
	{
		$selected4 = 'selected';
	}

	//constructing the combo values for activities
	$ACTIVITY_VIEW_SELECT_OPTION = '<select class=small name="activity_view" onchange="showActivityView(this)">';
	$ACTIVITY_VIEW_SELECT_OPTION .= '<option value="Today" '.$selected1.'>';
	$ACTIVITY_VIEW_SELECT_OPTION .= 'Today';
	$ACTIVITY_VIEW_SELECT_OPTION .= '</option>';
	$ACTIVITY_VIEW_SELECT_OPTION .= '<option value="This Week" '.$selected2.'>';
	$ACTIVITY_VIEW_SELECT_OPTION .= 'This Week';
	$ACTIVITY_VIEW_SELECT_OPTION .= '</option>';
	$ACTIVITY_VIEW_SELECT_OPTION .= '<option value="This Month" '.$selected3.'>';
	$ACTIVITY_VIEW_SELECT_OPTION .= 'This Month';
	$ACTIVITY_VIEW_SELECT_OPTION .= '</option>';
	$ACTIVITY_VIEW_SELECT_OPTION .= '<option value="This Year" '.$selected4.'>';
	$ACTIVITY_VIEW_SELECT_OPTION .= 'This Year';
	$ACTIVITY_VIEW_SELECT_OPTION .= '</option>';
	$ACTIVITY_VIEW_SELECT_OPTION .= '</select>';

	$log->debug("Exiting getActivityview method ...");
	return $ACTIVITY_VIEW_SELECT_OPTION;
}
?>