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

require_once(globalStatic::$root_directory.'include/RelatedListView.php');

require_once(globalStatic::$root_directory.'modules/Products/Products.php');
require_once(globalStatic::$root_directory.'include/utils/UserInfoUtil.php');

// functions added for group calendar	-Jaguar
	/**
	 * Function to get duration
	 * @param string     $time_start            -   activity start time
	 * @param string     $duration_hours        -   duration in hours
	 * @param string     $duration_minutes      -   duration in minutes
	 * return string     $end_time              -   time string
	 */
	function get_duration($time_start,$duration_hours,$duration_minutes)
	{
	
		$time=explode(":",$time_start);
                $time_mins = $time[1];
                $time_hrs = $time[0];
                $mins = ($time_mins + $duration_minutes) % 60;
                $hrs_min = floor(($time_mins + $duration_minutes) / 60);
                if(!isset($hrs))
                        $hrs=0;
		$hrs = $duration_hours + $hrs_min + $time_hrs;
		if($hrs<10)
			$hrs=$hrs;
		if($mins<10)
			$mins="0".$mins;	

		$end_time = $hrs .$mins;
		
		return $end_time;
	}	

	/**
	 * Function to convert time to number 
	 * @param string     $time_start            -   activity start time
	 * return integer    $start_time            -   time
	 */
	function time_to_number($time_start)
	{
		$start_time_array = explode(":",$time_start);
		if(preg_match("/^[0]/",$start_time_array[0]))
		{
			$time_start_hrs=str_replace('0',"",$start_time_array[0]);
		}
		else
		{
			$time_start_hrs=$start_time_array[0];
		}
		$start_time= $time_start_hrs .$start_time_array[1];
		$log->debug("Exiting time_to_number method ...");
		return $start_time;
	}

	/**
	  * Function to status availability of user
	  * @param string     $owner                   -   ownername
	  * @param integer    $userid                  -   userid
	  * @param integer    $activity_id             -   activityid
	  * @param string     $avail_date              -   date in string format
	  * @param string     $activity_start_time     -   time string 
	  * @param string     $activity_end_time       -   time string 
	  * return string     $availability            -   html img tag in string
	  */
	function status_availability($owner,$userid,$activity_id,$avail_date,$activity_start_time,$activity_end_time)	
	{
		global $adb,$image_path,$theme;
		
		$avail_flag="false";
		$avail_date=DateTimeField::convertToDBFormat($avail_date);
		if( $owner != $userid)
		{
			
			$usr_query="select activityid,ld_activity.date_start,ld_activity.due_date, ld_activity.time_start,ld_activity.duration_hours,ld_activity.duration_minutes,ld_crmentity.smownerid from ld_activity,ld_crmentity where ld_crmentity.crmid=ld_activity.activityid and ('".$avail_date."' like date_start) and ld_crmentity.smownerid=? and ld_activity.activityid !=?  and ld_crmentity.deleted=0";
		}
		else
		{
			$usr_query="select activityid,ld_activity.date_start,ld_activity.due_date, ld_activity.time_start,ld_activity.duration_hours,ld_activity.duration_minutes,ld_crmentity.smownerid from ld_activity,ld_crmentity where ld_crmentity.crmid=ld_activity.activityid and ('".$avail_date."' like date_start) and ld_crmentity.smownerid=? and ld_activity.activityid !=? and ld_crmentity.deleted=0";
		}
		$result_cal=$adb->pquery($usr_query, array($userid, $activity_id));   
		$noofrows_cal = $adb->num_rows($result_cal);
		$avail_flag="false";

		if($noofrows_cal!=0)
		{
			while($row_cal = $adb->fetch_array($result_cal)) 
			{
				$usr_date_start=$row_cal['date_start'];
				$usr_due_date=$row_cal['due_date'];
				$usr_time_start=$row_cal['time_start'];
				$usr_hour_dur=$row_cal['duration_hours'];
				$usr_mins_dur=$row_cal['duration_minutes'];
				$user_start_time=time_to_number($usr_time_start);	
				$user_end_time=get_duration($usr_time_start,$usr_hour_dur,$usr_mins_dur);

				if( ( ($user_start_time > $activity_start_time) && ( $user_start_time < $activity_end_time) ) || ( ( $user_end_time > $activity_start_time) && ( $user_end_time < $activity_end_time) ) || ( ( $activity_start_time == $user_start_time ) || ($activity_end_time == $user_end_time) ) )
				{
					$availability= 'busy';
					$avail_flag="true";

				}
			}
		}
		if($avail_flag!="true")
		{
			$recur_query="SELECT ld_activity.activityid, ld_activity.time_start, ld_activity.duration_hours, ld_activity.duration_minutes , ld_crmentity.smownerid, ld_recurringevents.recurringid, ld_recurringevents.recurringdate as date_start from ld_activity inner join ld_crmentity on ld_activity.activityid = ld_crmentity.crmid inner join ld_recurringevents on ld_activity.activityid=ld_recurringevents.activityid where ('".$avail_date."' like ld_recurringevents.recurringdate) and ld_crmentity.smownerid=? and ld_activity.activityid !=? and ld_crmentity.deleted=0";
			$result_cal=$adb->pquery($recur_query, array($userid, $activity_id));   
			$noofrows_cal = $adb->num_rows($result_cal);
			$avail_flag="false";

			if($noofrows_cal!=0)
			{
				while($row_cal = $adb->fetch_array($result_cal)) 
				{
					$usr_date_start=$row_cal['date_start'];
					$usr_time_start=$row_cal['time_start'];
					$usr_hour_dur=$row_cal['duration_hours'];
					$usr_mins_dur=$row_cal['duration_minutes'];
					$user_start_time=time_to_number($usr_time_start);	
					$user_end_time=get_duration($usr_time_start,$usr_hour_dur,$usr_mins_dur);

					if( ( ($user_start_time > $activity_start_time) && ( $user_start_time < $activity_end_time) ) || ( ( $user_end_time > $activity_start_time) && ( $user_end_time < $activity_end_time) ) || ( ( $activity_start_time == $user_start_time ) || ($activity_end_time == $user_end_time) ) )
					{
						$availability= 'busy';
						$avail_flag="true";
						$log->info("Recurring Events:: user start time-- ".$user_start_time."user end time".$user_end_time);
        	                                $log->info("Recurring Events:: Availability ".$availability);
					}
				}
			}

			
		}	
	 	if($avail_flag == "true")
                {
                        $availability=' <IMG SRC="' . lingdang_imageurl('busy.gif', $theme). '">';
                }
                else
                {
                        $availability=' <IMG SRC="' . lingdang_imageurl('free.gif', $theme). '">';
                }
		return $availability;
		
	}

?>