<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
//require_once('modules/Calendar/CalendarCommon.php');

//require_once('include/utils/UserInfoUtil.php');
//require_once('include/database/PearDatabase.php');
require_once(globalstatic::$root_directory.'modules/Calendar/Activity.php');
class Appointment
{
	var $start_time;
	var $end_time;
	var $subject;
	var $participant;
	var $participant_state;
	var $contact_name;
	var $account_id;
	var $account_name;
	var $creatorid;
	var $creator;
	var $owner;
	var $ownerid;
	var $assignedto;
	var $eventstatus;
	var $priority;
	var $activity_type;
	var $description;
	var $record;
	var $temphour;
	var $tempmin;
	var $image_name;
	var $formatted_datetime;
	var $duration_min;
	var $duration_hour;
	var $shared = false;
	var $recurring;
	var $dur_hour;

	function __construct()
	{
		$this->participant = Array();
		$this->participant_state = Array();
		$this->description = "";
	}
	
	/** To get the events of the specified user and shared events
	  * @param $userid -- The user Id:: Type integer
          * @param $from_datetime -- The start date Obj :: Type Array
          * @param $to_datetime -- The end date Obj :: Type Array
          * @param $view -- The calendar view :: Type String
	  * @returns $list :: Type Array
	 */
	
	static function readAppointment($userid, &$from_datetime, &$to_datetime, $view)
	{
		global $current_user,$adb;
		require('user_privileges/user_privileges_'.$current_user->id.'.php');
		$and = "AND (
					(
						(
							(CAST(CONCAT(date_start) AS DATETIME) >= ? AND CAST(CONCAT(date_start) AS DATETIME) <= ?)
							OR	(CAST(CONCAT(due_date) AS DATETIME) >= ? AND CAST(CONCAT(due_date) AS DATETIME) <= ? )
							OR	(CAST(CONCAT(date_start) AS DATETIME) <= ? AND CAST(CONCAT(due_date) AS DATETIME) >= ?)
						)
						AND ld_recurringevents.activityid is NULL
					)
				OR (
						(CAST(CONCAT(ld_recurringevents.recurringdate) AS DATETIME) >= ?
							AND CAST(CONCAT(ld_recurringevents.recurringdate) AS DATETIME) <= ?)
						OR	(CAST(CONCAT(due_date) AS DATETIME) >= ? AND CAST(CONCAT(due_date) AS DATETIME) <= ?)
						OR	(CAST(CONCAT(ld_recurringevents.recurringdate) AS DATETIME) <= ?
							AND CAST(CONCAT(due_date) AS DATETIME) >= ?)
					)
				)";
		
		$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
							'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
		
        	$q= "select ld_activity.*, 
					ld_users.last_name as user_name
					FROM ld_activity
						LEFT join ld_recurringevents on ld_activity.activityid=ld_recurringevents.activityid 
						LEFT JOIN ld_users ON ld_users.id = ld_activity.smownerid 
                        LEFT JOIN ld_activitycf ON ld_activitycf.activityid = ld_activity.activityid
                            LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_activity.contactid
                            LEFT JOIN ld_seactivityrel ON ld_seactivityrel.activityid = ld_activity.activityid
                            LEFT OUTER JOIN ld_activity_reminder ON ld_activity_reminder.activity_id = ld_activity.activityid
                            LEFT JOIN ld_users ld_users2 ON ld_activity.modifiedby = ld_users2.id
                            LEFT OUTER JOIN ld_account ON ld_account.accountid = ld_activity.accountid
                            LEFT OUTER JOIN ld_account ld_account2 ON ld_account2.accountid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_potential ON ld_potential.potentialid = ld_activity.potentialid
                            LEFT OUTER JOIN ld_troubletickets ON ld_troubletickets.ticketid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_purchaseorder ON ld_purchaseorder.purchaseorderid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_quotes ON ld_quotes.quoteid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_invoice ON ld_invoice.invoiceid = ld_seactivityrel.crmid
                            LEFT OUTER JOIN ld_campaign ON ld_campaign.campaignid = ld_seactivityrel.crmid
                            LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_activity.activityid
					WHERE ld_activity.deleted = 0 and ld_activity.activitytype not in ('Emails','任务') $and ";

		// User Select Customization: Changes should made also in (calendayLaout getEventList) and one more BELOW
		//$query_filter_prefix = calendarview_getSelectedUserFilterQuerySuffix(); 
		//$q .= $query_filter_prefix;
       // echo $query_filter_prefix; 
		// END
		$h = $from_datetime->z_hour;
		$m = $from_datetime->min;
		if(empty($m)) {
			$m = '00';
		}
        crm_load_class_file('DateTimeField','include/fields');
		$startDate = new DateTimeField($from_datetime->year."-".$from_datetime->z_month."-".
				$from_datetime->z_day." $h:$m");
		$h = '23';
		$m = '59';
         
		$endDate = new DateTimeField($to_datetime->year."-".$to_datetime->z_month."-".
				$to_datetime->z_day." $h:$m");
		$params = array(
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue(),
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue(),
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue(),
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue(),
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue(),
			$startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue()
		);
        
		/**
		 * 新增一条相关信息，就会在ld_recurringevents表中插一条记录，所以跟这个条件冲突，先暂时隐藏掉
		 * @reason 0010265 日程安排记录不显示
		 * @author Tujt 2014-07-31
		 */
       //$q .= " AND ld_recurringevents.activityid is NULL ";

		include_once("include/QueryGenerator/QueryGenerator.php");
        $queryGenerator = new QueryGenerator("Calendar", $current_user);
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,'Calendar');
        
		$focus=new Activity();
		$listviewRangeQuery=$ScopOfAuthority->getModuleListViewQuery();
		$q .=$listviewRangeQuery.$queryGenerator->getSmOwnerSearchSql();
		if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] == 'SmOwner_Search_All'){
		  //共享表不用了
          //19625: 日程管理>日历视图：普通用户，点击“月”，选择查看范围为“我的”，然后，再选择查看范围为“全部”。结果：显示了所有用户的日程管理。
		//	$q.="or (ld_activity.smownerid in (SELECT userid FROM ld_sharedcalendar WHERE sharedid=$current_user->id))";
		}
        $q .= " group by ld_activity.activityid ORDER by ld_activity.date_start";
       // echo $q;
       
		$r = $adb->pquery($q, $params);

		$n = $adb->getRowCount($r);
        
        $a = 0;
		$list = Array();
		
        while ( $a < $n )
        {
			
			$result = $adb->fetchByAssoc($r);
            
       
            $datestart=new DateTimeField($result['date_start']);
            $duedate=new DateTimeField($result['due_date']);
           
            $date_start=$datestart->getDBInsertDateValue();//开始日期
            $time_start=$datestart->getDBInsertTimeValue();//开始时间
            // echo $date_start .$time_start;
            $due_date=$duedate->getDBInsertDateValue();//结束日期
            $time_end=$duedate->getDBInsertTimeValue();//结束时间
           //echo $due_date.$time_end;
			$from = strtotime($date_start);
			$to = strtotime($result['due_date']);
			$windowTo = strtotime($endDate->getDBInsertDateTimeValue());
            if(empty($from))
            {
                 continue;
            }
            
			for($j = $from; $j <= $to; $j=$j+(60*60*24))
			{

				$obj = new Appointment();
				$temp_start = date("Y-m-d",$j);
				$endTime = strtotime($temp_start. ' '.  $time_start);
               
				if($endTime > $windowTo) {
					break;
				}
			
				$result["date_start"]= $temp_start ;
				list($obj->temphour,$obj->tempmin) = explode(":",$time_start);
				if($start_timestamp != $end_timestamp && $view == 'day'){
					if($j == $start_timestamp){
						$result["duration_hours"] = 24 - $obj->temphour;
					}elseif($j > $start_timestamp && $j < $end_timestamp){
						list($obj->temphour,$obj->tempmin)= $current_user->start_hour !=''?explode(":",$current_user->start_hour):explode(":","08:00");
						$result["duration_hours"] = 24 - $obj->temphour;
					}elseif($j == $end_timestamp){
						list($obj->temphour,$obj->tempmin)= $current_user->start_hour !=''?explode(":",$current_user->start_hour):explode(":","08:00");
						list($ehr,$emin) = explode(":",$time_end);
						$result["duration_hours"] = $ehr - $obj->temphour;
					}
				}
				$obj->readResult($result,$time_start,$view);
				$list[] = $obj;
				unset($obj);

			}
			$a++;
			
        }
       
		//Get Recurring events
        //Liver 2017-04-13 加载getNonAdminAccessControlQuery bug	0027843: 日程管理-日历视图：更改负责人后，闪过报错
        crm_load_function_file('getNonAdminAccessControlQuery','include/utils','UserInfoUtil');
		$q = "SELECT ld_activity.*,  case when (ld_users.user_name not like '') then $userNameSql else ld_groups.groupname end as user_name , ld_recurringevents.recurringid, ld_recurringevents.recurringdate as date_start ,ld_recurringevents.recurringtype,ld_groups.groupname from ld_activity inner join ld_recurringevents on ld_activity.activityid=ld_recurringevents.activityid 
        LEFT JOIN ld_users ON ld_users.id = ld_activity.smownerid";
		$q .= getNonAdminAccessControlQuery('Calendar',$current_user);
      
		$q.=" where ld_activity.deleted = 0 and ld_activity.activitytype not in ('Emails','任务') AND date_start between ? and ? ";
		//20046: 工作台>日程管理：日程管理-日历视图-周，查看单据时没有负责人为系统管理员的单据，切换到月查看时，查看范围为“我的”，结果显示了负责人不是系统管理员的单据
        $q .=$listviewRangeQuery.$queryGenerator->getSmOwnerSearchSql();
	
		$params = array($startDate->getDBInsertDateTimeValue(), $endDate->getDBInsertDateTimeValue());
													
        $q .= " ORDER by ld_recurringevents.recurringid";
		$r = $adb->pquery($q, $params);
        $n = $adb->getRowCount($r);
        $a = 0;
		while ( $a < $n )
        {
			$obj = new Appointment();
                        $result = $adb->fetchByAssoc($r);
                        $datestart=new DateTimeField($result['date_start']);
            $duedate=new DateTimeField($result['due_date']);
           
            $date_start=$datestart->getDBInsertDateValue();//开始日期
            $time_start=$datestart->getDBInsertTimeValue();//开始时间
                //echo $date_start .$time_start;
            $due_date=$duedate->getDBInsertDateValue();//结束日期
            $time_end=$duedate->getDBInsertTimeValue();//结束时间

			list($obj->temphour,$obj->tempmin) = explode(":",$time_start);

                        $obj->readResult($result,$time_start,$view);
                        $a++;
			$list[] = $obj;
                        unset($obj);
        }


		usort($list,'compare');
		return $list;
	}


	/** To read and set the events value in Appointment Obj
          * @param $act_array -- The ld_activity array :: Type Array
          * @param $view -- The calendar view :: Type String
         */
	function readResult($act_array,$time_start, $view)
	{
		global $adb,$current_user,$app_strings;
		$format_sthour='';
                $format_stmin='';
		$this->description       = $act_array["description"];
		$this->eventstatus       = getRoleBasesdPickList('eventstatus',$act_array["eventstatus"]);
		$this->priority		 = getRoleBasesdPickList('taskpriority',$act_array["priority"]);
		$this->subject           = $act_array["subject"];
		$this->activity_type     = $act_array["activitytype"];
		$this->duration_hour     = $act_array["duration_hours"];
		$this->duration_minute   = $act_array["duration_minutes"];
		$this->creatorid         = $act_array["smcreatorid"];
		//$this->creator           = getUserName($act_array["smcreatorid"]);
		$this->assignedto = $act_array["user_name"];
                $this->owner   = $act_array["user_name"];
		if(!is_admin($current_user))
		{
			if($act_array["smownerid"]!=0 && $act_array["smownerid"] != $current_user->id && $act_array["visibility"] == "Public"){
				$que = "select * from ld_sharedcalendar where sharedid=? and userid=?";
				$row = $adb->pquery($que, array($current_user->id, $act_array["smownerid"]));
				$no = $adb->getRowCount($row);
				if($no > 0)
					$this->shared = true;
			}
		}	
		$this->image_name = $act_array["activitytype"].".gif";
		if(!empty($act_array["recurringid"]) && !empty($act_array["recurringtype"]))
			$this->recurring="Recurring.gif";
		
		$this->record = $act_array["activityid"];
		$date = new DateTimeField($act_array["date_start"].' '.$time_start);
        
		$eventStartDate = DateTimeField::convertToDBFormat($date->getDisplayDate());
       
		list($eventStartHour) = explode(':', $date->getDisplayTime());
		list($styear,$stmonth,$stday) = explode("-",$date->getDBInsertDateValue());
		list($sthour, $stmin) = explode(':', $date->getDBInsertTimeValue());
		if($act_array["notime"] != 1){
			$st_hour = $eventStartHour;
		}else{
			$st_hour = 'notime';
			//$act_array["time_start"] = "00:00";
		}
        $due=new DateTimeField($act_array["due_date"]);
		list($eyear,$emonth,$eday) = explode("-",$due->getDBInsertDateValue());
		list($end_hour,$end_min) = explode(":",$due->getDBInsertTimeValue());
		$start_date_arr = Array(
			'min'   => $stmin,
			'hour'  => $sthour,
			'day'   => $stday,
			'month' => $stmonth,
			'year'  => $styear
		);
		$end_date_arr = Array(
			'min'   => $end_min,
			'hour'  => $end_hour,
			'day'   => $eday,
			'month' => $emonth,
			'year'  => $eyear
		);
                $this->start_time = new vt_DateTime($start_date_arr,true);
                $this->end_time = new vt_DateTime($end_date_arr,true);
		if($view == 'day' || $view == 'week')
		{
			$this->formatted_datetime= DateTimeField::convertToUserFormat($eventStartDate)
					.":".$st_hour;
		}
		elseif($view == 'year')
		{
			list($year,$month,$date) = explode("-",$eventStartDate);
			$this->formatted_datetime = $month;
		}
		else
		{
			$this->formatted_datetime= DateTimeField::convertToUserFormat($eventStartDate);
		}

		return;
	}
	
	
}

/** To two array values
  * @param $a -- The ld_activity array :: Type Array
  * @param $b -- The ld_activity array :: Type Array
  * @returns value 0 or 1 or -1 depends on comparision result
 */
function compare($a,$b)
{
	if ($a->start_time->ts == $b->start_time->ts)
	{
		return 0;
   	}
	return ($a->start_time->ts < $b->start_time->ts) ? -1 : 1;
}
function getRoleBasesdPickList($fldname,$exist_val)
{
	global $adb,$app_strings,$current_user;
	$is_Admin = $current_user->is_admin;
		/*if($is_Admin == 'off' && $fldname != '')
			{
				$profileid=$current_user->profileid;

				//here we are checking wheather the table contains the sortorder column .If  sortorder is present in the main picklist table, then the role2picklist will be applicable for this table...

				$sql="select * from ld_$fldname where $fldname=?";
				$res = $adb->pquery($sql,array(decode_html($exist_val)));
				$picklistvalueid = $adb->query_result($res,0,'picklist_valueid');
				if ($picklistvalueid != null) {
					$pick_query="select * from ld_role2picklist where picklistvalueid=$picklistvalueid and profileid = ?";

					$res_val=$adb->pquery($pick_query,array($profileid));
					$num_val = $adb->num_rows($res_val);
				}
				if($num_val > 0)
				$pick_val = $exist_val;
				else
				$pick_val = $app_strings['LBL_NOT_ACCESSIBLE'];


			}else*/
			$pick_val = $exist_val;

			return $pick_val;
			
}
?>