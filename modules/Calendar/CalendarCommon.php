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
//Code Added by Minnie -Starts
/**
 * To get the lists of sharedids 
 * @param $id -- The user id :: Type integer
 * @returns $sharedids -- The shared lingdang_users id :: Type Array
 */
function getSharedUserId($id)
{
    return array();
	global $adb;
        $sharedid = Array();
        $query = "SELECT ld_users.*,ld_sharedcalendar.* from ld_users left join ld_sharedcalendar on ld_sharedcalendar.sharedid=ld_users.id where userid=?";
        $result = $adb->pquery($query, array($id));
        $rows = $adb->num_rows($result);
        $entity_field_info = getEntityFieldNames('Users');
        $fieldsName = $entity_field_info['fieldname'];
        
        for($j=0;$j<$rows;$j++)
        {

                $id = $adb->query_result($result,$j,'sharedid');
                //$sharedname = getFullNameFromQResult($result, $j, 'Users');
                 $temp_val=$adb->query_result($result, $j, $fieldsName);
                $sharedid[$id]=$temp_val;

        }
	return $sharedid;
}
function getOtherUserName($id)
{
	global $adb;
	$user_details=Array();
		$query="select * from ld_users where deleted=0 and status='Active' and id!=?";
		$result = $adb->pquery($query, array($id));
		$num_rows=$adb->num_rows($result);
		for($i=0;$i<$num_rows;$i++)
		{
			$userid=$adb->query_result($result,$i,'id');
			$username = getFullNameFromQResult($result, $i, 'Users');
			$user_details[$userid]=$username;
		}
		return $user_details;
}
/**
 * To get the lists of lingdang_users id who shared their calendar with specified user
 * @param $sharedid -- The shared user id :: Type integer
 * @returns $shared_ids -- a comma seperated lingdang_users id  :: Type string
 */
function getSharedCalendarId($sharedid)
{
	global $adb;
	$query = "SELECT * from ld_sharedcalendar where sharedid=?";
	$result = $adb->pquery($query, array($sharedid));
	if($adb->num_rows($result)!=0)
	{
		for($j=0;$j<$adb->num_rows($result);$j++)
			$userid[] = $adb->query_result($result,$j,'userid');
		$shared_ids = implode (",",$userid);
	}
	return $shared_ids;
}

/**
 * To get userid and username of lingdang_users in hierarchy level
 * @param $id -- The user id :: Type integer
 * @returns $user_details -- Array in the following format:
 * $user_details=Array($userid1=>$username, $userid2=>$username,............,$useridn=>$username);
 */

function getSharingUserName($id)
{
	global $adb,$current_user;
        $user_details=Array();
	$assigned_user_id = $current_user->id;
	require('user_privileges/user_privileges_'.$current_user->id.'.php');
	//$ScopOfAuthority = ScopOfAuthority::getInstance($adb,'Calendar');
	$user_details = get_user_array(FALSE, "Active", $id);
	unset($user_details[$id]);
	
	return $user_details;
}

/**
 * To get hour,minute and format
 * @param $starttime -- The date&time :: Type string
 * @param $endtime -- The date&time :: Type string
 * @param $format -- The format :: Type string
 * @returns $timearr :: Type Array
*/
function getaddEventPopupTime($starttime,$endtime,$format)
{
	$timearr = Array();
	list($sthr,$stmin) = explode(":",$starttime);
	list($edhr,$edmin)  = explode(":",$endtime);
	if($format == 'am/pm')
	{
		$hr = $sthr+0;
		$timearr['startfmt'] = ($hr > 12) ? "pm" : "am";
		if($hr == 0) $hr = 12;
		$timearr['starthour'] = twoDigit(($hr>12)?($hr-12):$hr);
		$timearr['startmin']  = $stmin;

		$edhr = $edhr+0;
		$timearr['endfmt'] = ($edhr > 12) ? "pm" : "am";
		if($edhr == 0) $edhr = 12;
		$timearr['endhour'] = twoDigit(($edhr>12)?($edhr-12):$edhr);
		$timearr['endmin']    = $edmin;
		return $timearr;
	}
	if($format == '24')
	{
		$timearr['starthour'] = twoDigit($sthr);
		$timearr['startmin']  = $stmin;
		$timearr['startfmt']  = '';
		$timearr['endhour']   = twoDigit($edhr);
		$timearr['endmin']    = $edmin;
		$timearr['endfmt']    = '';
		return $timearr;
	}
}

/**
 *To construct time select combo box
 *@param $format -- the format :: Type string
 *@param $bimode -- The mode :: Type string
 *constructs html select combo box for time selection
 *and returns it in string format.
 */
function getTimeCombo($format,$bimode,$hour='',$min='',$fmt='',$todocheck=false)
{
	global $mod_strings;
	$combo = '';
	$min = $min - ($min%5);
	if($bimode == 'start' && !$todocheck)
		$jsfn = 'onChange="changeEndtime_StartTime(document.EditView.activitytype.value);"';
	else
		$jsfn = null;
	if($format == 'am/pm')
	{
		$combo .= '<select class=small name="'.$bimode.'hr" id="'.$bimode.'hr" '.$jsfn.'>';
		for($i=0;$i<12;$i++)
		{
			if($i == 0)
			{
				$hrtext= 12;
				$hrvalue = 12;
			}
			else
				$hrvalue = $hrtext = twoDigit($i);
			$hrsel = ($hour == $hrvalue)?'selected':'';	
			$combo .= '<option value="'.$hrvalue.'" '.$hrsel.'>'.$hrtext.'</option>';
		}
		$combo .= '</select>&nbsp;';
		$combo .= '<select name="'.$bimode.'min" id="'.$bimode.'min" class=small '.$jsfn.'>';
		for($i=0;$i<12;$i++)
		{
			$value = $i*5;
			$value = twoDigit($value);
			$minsel = ($min == $value)?'selected':'';
			$combo .= '<option value="'.$value.'" '.$minsel.'>'.$value.'</option>';
		}
		$combo .= '</select>&nbsp;';
		$combo .= '<select name="'.$bimode.'fmt" id="'.$bimode.'fmt" class=small '.$jsfn.'>';
		$amselected = ($fmt == 'am')?'selected':'';
		$pmselected = ($fmt == 'pm')?'selected':'';
		$combo .= '<option value="am" '.$amselected.'>AM</option>';
		$combo .= '<option value="pm" '.$pmselected.'>PM</option>';
		$combo .= '</select>';
		}
		else
		{
			$combo .= '<select name="'.$bimode.'hr" id="'.$bimode.'hr" class=small '.$jsfn.'>';
			for($i=0;$i<=23;$i++)
			{
				$hrvalue = twoDigit($i);
				$hrsel = ($hour == $hrvalue)?'selected':'';
				$combo .= '<option value="'.$hrvalue.'" '.$hrsel.'>'.$hrvalue.'</option>';
			}
			$combo .= '</select>'.$mod_strings[LBL_HR].'&nbsp;';
			$combo .= '<select name="'.$bimode.'min" id="'.$bimode.'min" class=small '.$jsfn.'>';
			for($i=0;$i<12;$i++)
			{
				$value = $i*5;
				$value= twoDigit($value);
				$minsel = ($min == $value)?'selected':'';
				$combo .= '<option value="'.$value.'" '.$minsel.'>'.$value.'</option>';
			}
			$combo .= '</select>&nbsp;'.$mod_strings[LBL_MIN].'<input type="hidden" name="'.$bimode.'fmt" id="'.$bimode.'fmt">';
		}
		return $combo;
}

/**
 *Function to construct HTML select combo box
 *@param $fieldname -- the field name :: Type string
 *@param $tablename -- The table name :: Type string
 *constructs html select combo box for combo field
 *and returns it in string format.
 */

function getActFieldCombo($fieldname,$tablename)
{
	global $adb, $mod_strings,$current_user;
	require('user_privileges/user_privileges_'.$current_user->id.'.php');
	$combo = '';
	$js_fn = '';
	if($fieldname == 'eventstatus')
		$js_fn = 'onChange = "getSelectedStatus();"';
	$combo .= '<select name="'.$fieldname.'" id="'.$fieldname.'" class=small '.$js_fn.'>';
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 2:46
	crm_load_class_file("cls_PickList", 'modules/PickList');
	$objpinklist = new cls_PickList();
	$result_pick = $objpinklist->getPickListValues($fieldname);
    foreach($result_pick as $value){
        $combo .= '<option value="'.$value.'">'.getTranslatedString($value).'</option>';
    }
    $combo .= '</select>';
    return $combo;

	/* 旧代码 if($is_admin)
		$q = "select * from ".$tablename;
	else
	{
		$profileid=$current_user->profileid;
		$q="select distinct $fieldname from $tablename inner join ld_role2picklist on ld_role2picklist.picklistvalueid = $tablename.picklist_valueid where profileid ='".$profileid."' and picklistid in (select picklistid from $tablename) order by sortid asc";
	}
	$Res = $adb->query($q);
	$noofrows = $adb->num_rows($Res);

	for($i = 0; $i < $noofrows; $i++)
	{
		$value = $adb->query_result($Res,$i,$fieldname);
		$combo .= '<option value="'.$value.'">'.getTranslatedString($value).'</option>';
	}
	$combo .= '</select>';
	return $combo;*/
}

/*Fuction to get value for Assigned To field
 *returns values of Assigned To field in array format
*/
function getAssignedTo($tabid)
{
	global $current_user,$noof_group_rows,$adb;
	$assigned_user_id = $current_user->id;
	require('user_privileges/user_privileges_'.$current_user->id.'.php');
	$module=getTabModuleName($tabid);
	$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);

	
	if ($is_admin == false && ($ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE or $ScopOfAuthority->getModuleShareInfo() == SHARE_PUBLIC_READONLY)) {
	   $user_arr=get_user_array(FALSE, "Active", $assigned_user_id,'private');
    	$users_combo = get_select_options_array($user_arr, $assigned_user_id);
	}
	else
	{
	   $user_arr=get_user_array(FALSE, "Active", $assigned_user_id);
		$users_combo = get_select_options_array($user_arr, $assigned_user_id);
	}
	if($noof_group_rows!=0)
	{
		do
		{
			$groupname=$nameArray["groupname"];
			$group_option[] = array($groupname=>$selected);

		}while($nameArray = $adb->fetch_array($result));
	}
	$fieldvalue[]=$users_combo;
	$fieldvalue[] = $group_option;
	return $fieldvalue;
}

//Code Added by Minnie -Ends
/**
 * Function to get the ld_activity details for mail body
 * @param   string   $description       - activity description
 * @param   string   $from              - to differenciate from notification to invitation.
 * return   string   $list              - HTML in string format
 */
function getActivityDetails($description,$user_id,$from='')
{
	global $current_user,$current_language;
	global $adb;

	$updated = getFixedLabel('UPDATE');
	$created =getFixedLabel('CREATE');
    $reply = (($description['mode'] == 'edit')?"$updated":"$created");
    $fieldobj=Field::getInstance('Calendar',$adb);
    $subjectlabel=$fieldobj->getFieldInfoBykeyValue('columnname','subject','fieldlabel');
    $starttimelabel=$fieldobj->getFieldInfoBykeyValue('columnname','date_start','fieldlabel');
    $end_date_lable=$fieldobj->getFieldInfoBykeyValue('columnname','due_date','fieldlabel');
    $statuslabel=$fieldobj->getFieldInfoBykeyValue('columnname','eventstatus','fieldlabel');
    $prioritylabel=$fieldobj->getFieldInfoBykeyValue('columnname','priority','fieldlabel');
    $descriptionlabel=$fieldobj->getFieldInfoBykeyValue('columnname','description','fieldlabel');


	$name = getUserFullName($user_id);

	if($from == "invite")
		$msg = '你被邀请参与一个活动';
	else
		$msg = getTranslatedString($mod_strings['LBL_ACTIVITY_NOTIFICATION']);
	//$current_username = getUserFullName($current_user->id);  
    /**
     * AUTHOR:BY LD KEVIN
     * DATE:2013-04-25
     * DESCRIPTION:全局变量$current_user在当前这个文件的值不正确，还没有找到原因
     */ 
    $current_username=getUserFullName($_SESSION['authenticated_user_id']);
        
	$status = $description['status'];
	$list = $name.',';
	$list .= '<br><br>'.$msg.' '.$reply.'.<br> 细节是:<br>';
	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$subjectlabel.$description['subject'];
	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$starttimelabel.':'.$description['st_date_time'];//.' '.DateTimeField::getDBTimeZone()
	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$end_date_lable.':'.$description['end_date_time'];//.' '.DateTimeField::getDBTimeZone()
	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$statuslabel.':'.$status;
	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$prioritylabel.':'.($description['taskpriority']);
	//$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$mod_strings["Related To"].': '.getTranslatedString($description['relatedto']);
	/*if(!empty($description['contact_name']))
	{
        	$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$mod_strings["LBL_CONTACT_LIST"].' '.$description['contact_name'];
	}
	else
		$list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$mod_strings["Location"].' : '.$description['location'];*/
			
        $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$descriptionlabel.':'.$description['description'];
        $list .= '<br><br>感谢和问候 ,';
        $list .= '<br>'.$current_username.'.';
		return $list;
}



function timeString($datetime,$fmt){
	
	$timeStr = formatUserTimeString($datetime, $fmt);
	$date = new DateTimeField($timeStr);
	list($h, $m) = explode(':', $date->getDisplayTime());
	$timeStr = formatUserTimeString(array('hour'=>$h, 'minute'=>$m), $fmt);
	return $timeStr;
}

/**
 *
 * @param type $datetime
 * @param type $fmt
 * @return Date 
 */
function formatUserTimeString($datetime,$fmt){
	
	if(is_object($datetime)){
		$hr = $datetime->hour;
		$min = $datetime->minute;
	} else {
		$hr = $datetime['hour'];
		$min = $datetime['minute'];
	}
	$timeStr = "";
	if($fmt != 'am/pm'){
		$timeStr .= twoDigit($hr).":".twoDigit($min);
	}else{
		$am_pm = array('AM', 'PM');
		$hour = twoDigit($hr%12);
		if($hour == 0) {
			$hour = 12;
		}
        if($hr!=12){
           $formattime=($hr/12)%2; 
        }else{
            $formattime=0;
        }

		$timeStr = $hour.':'.twoDigit($min).$am_pm[$formattime];
	}
	return $timeStr;
}

function sendInvitation($inviteesid,$mode,$subject,$desc)
{
    
	global $current_user,$mod_strings,$adb;
   
	require_once("modules/Emails/mail.php");
	$invites=$mod_strings['INVITATION'];
	$invitees_array = explode(';',$inviteesid);
	$subject = $invites.' : '.$subject;
	$record = $focus->id;
    
	foreach($invitees_array as $inviteeid)
	{
		if($inviteeid != '')
		{
			$description=getActivityDetails($desc,$inviteeid,"invite");
            
			$to_email = getUserEmailId('id',$inviteeid);
            $sql="select * from ld_systems where server_type = ?";
        	$records=$adb->num_rows($adb->pquery($sql, array('email')),0,"id");    
        	if($records != ''){
        	   $sender=$adb->query_result($adb->pquery($sql, array('email')),$i,'server_username');        		
        	} 
           
			send_mail('Calendar',$to_email,$current_user->user_name,$sender,$subject,$description,'','','','','',$sender);
		}
	}
   
            

}

function getActivityMailInfo($return_id,$status,$activity_type)
{
	$mail_data = Array();
	global $adb;
	$qry = "select * from ld_activity where activityid=?";
	$ary_res = $adb->pquery($qry, array($return_id));
	$send_notification = $adb->query_result($ary_res,0,"sendnotification");
	$subject = $adb->query_result($ary_res,0,"subject");
	$priority = $adb->query_result($ary_res,0,"priority");
	$st_date = $adb->query_result($ary_res,0,"date_start");
	$end_date = $adb->query_result($ary_res,0,"due_date");
	$location = $adb->query_result($ary_res,0,"location");
 
	if(!empty($st_time)){
		$date = new DateTimeField($st_date);
		$st_date = $date->getDBInsertDateValue();
		$st_time = $date->getDBInsertTimeValue();
	}

	if(!empty($end_time)){
		$date = new DateTimeField($end_date);
		$end_date = $date->getDBInsertDateValue();
		$end_time = $date->getDBInsertTimeValue();
	}

	$owner_qry = "select smownerid from ld_crmentity where crmid=?";
	$res = $adb->pquery($owner_qry, array($return_id));
	$owner_id = $adb->query_result($res,0,"smownerid");
	
	$usr_res = $adb->pquery("select count(1) as count from ld_users where id=?",array($owner_id));
	if($adb->query_result($usr_res, 0, 'count')>0) {
		$assignType = "U";
		$usr_id = $owner_id;
	}
	else {
		$assignType = "T";
		$group_qry = "select groupname from ld_groups where groupid=?";
		$grp_res = $adb->pquery($group_qry, array($owner_id));
		$grp_name = $adb->query_result($grp_res,0,"groupname");
	}

	$desc_qry = "select description from ld_crmentity where crmid=?";
	$des_res = $adb->pquery($desc_qry, array($return_id));
	$description = $adb->query_result($des_res,0,"description");

		
	$rel_qry = "select case ld_crmentity.setype when 'Leads' then ld_leaddetails.lastname when 'Accounts' then ld_account.accountname when 'Potentials' then ld_potential.potentialname when 'Quotes' then ld_quotes.subject when 'PurchaseOrder' then ld_purchaseorder.subject when 'SalesOrder' then ld_salesorder.subject when 'Invoice' then ld_invoice.subject when 'Campaigns' then ld_campaign.campaignname when 'HelpDesk' then ld_troubletickets.title  end as relname from ld_seactivityrel inner join ld_crmentity on ld_crmentity.crmid=ld_seactivityrel.crmid left join ld_leaddetails on ld_leaddetails.leadid = ld_seactivityrel.crmid  left join ld_account on ld_account.accountid=ld_seactivityrel.crmid left join ld_potential on ld_potential.potentialid=ld_seactivityrel.crmid left join ld_quotes on ld_quotes.quoteid= ld_seactivityrel.crmid left join ld_purchaseorder on ld_purchaseorder.purchaseorderid = ld_seactivityrel.crmid  left join ld_salesorder on ld_salesorder.salesorderid = ld_seactivityrel.crmid left join ld_invoice on ld_invoice.invoiceid = ld_seactivityrel.crmid  left join ld_campaign on ld_campaign.campaignid = ld_seactivityrel.crmid left join ld_troubletickets on ld_troubletickets.ticketid = ld_seactivityrel.crmid where ld_seactivityrel.activityid=?";
	$rel_res = $adb->pquery($rel_qry, array($return_id));
	$rel_name = $adb->query_result($rel_res,0,"relname");

	$relatedContacts = getActivityRelatedContacts($return_id);
	
	$mail_data['mode'] = "edit";
	$mail_data['activity_mode'] = $activity_type;
	$mail_data['sendnotification'] = $send_notification;
	$mail_data['user_id'] = $usr_id;
	$mail_data['subject'] = $subject;
	$mail_data['status'] = $status;
	$mail_data['taskpriority'] = $priority;
	$mail_data['relatedto'] = $rel_name;
	$mail_data['contact_name'] = implode(',', $relatedContacts);
	$mail_data['description'] = $description;
	$mail_data['assign_type'] = $assignType;
	$mail_data['group_name'] = $grp_name;
	$value = getaddEventPopupTime($st_time,$end_time,'24');
	$start_hour = $value['starthour'].':'.$value['startmin'].''.$value['startfmt'];
	if($activity_type != '浠诲姟' )
		$end_hour = $value['endhour'] .':'.$value['endmin'].''.$value['endfmt'];
	$date = new DateTimeField($st_date);
	$endDate = new DateTimeField($end_date);
	$mail_data['st_date_time'] = $date->getDBInsertDateTimeValue();
	$mail_data['end_date_time'] = $endDate->getDBInsertDateValue().' '.
			$endDate->getDBInsertTimeValue();
	$mail_data['location']=$location;

	return $mail_data;


}

// User Select Customization
/**
 * Function returns the id of the User selected by current user in the picklist of the ListView or Calendar view of Current User
 * return String -  Id of the user that the current user has selected
 */
function calendarview_getSelectedUserId() {
	global $current_user, $default_charset;
  
    if(isset($_REQUEST['onlyforuser'])&&$_REQUEST['onlyforuser']!=''){
        $only_for_user = htmlspecialchars(strip_tags($_REQUEST['onlyforuser']),ENT_QUOTES,$default_charset);
    }
    else{
        /**
         * edit:kevin
         * date:2013-10-23
         * 
         */ 
        //$only_for_user='SmOwner_Search_Me';
        $only_for_user='SmOwner_Search_All';
    }
	if(!empty($_REQUEST['SearchScope'])){
		$only_for_user .= '&SearchScope='.$_REQUEST['SearchScope'];
	}
	if(!empty($_REQUEST['senioruserid'])){
		$only_for_user .='&senioruserid='.$_REQUEST['senioruserid'];
	}
	
	if($only_for_user == '') $only_for_user = $current_user->id;
	return $only_for_user;
}

function calendarview_getSelectedUserFilterQuerySuffix() {	
	global $current_user, $adb;
	$only_for_user = calendarview_getSelectedUserId();
	$qcondition = '';
	/*if(!empty($only_for_user)) {
		if($only_for_user != 'ALL') {
			// For logged in user include the group records also.
			if($only_for_user == $current_user->id) {
				$user_group_ids = fetchUserGroupids($current_user->id);
				// User does not belong to any group? Let us reset to non-existent group
				if(!empty($user_group_ids)) $user_group_ids .= ',';
				else $user_group_ids = '';
				$user_group_ids .= $current_user->id;	
				$qcondition = " AND ld_crmentity.smownerid IN (" . $user_group_ids .")";
			} else {
				$qcondition = " AND ld_crmentity.smownerid = "  . $adb->sql_escape_string($only_for_user);
			}
		} 
	}*/
    $qcondition=getSmOwnerSearchSql($only_for_user);
   
	return $qcondition;
}
/**
 * BY LD KEVIN
 * DATE:20130304
 * 鏉冮檺
 */ 
function getSmOwnerSearchSql($id='SmOwner_Search_Me')
     {
        /*
        'SmOwner_Search_All'=>"鍏ㄩ儴",
'SmOwner_Search_Me'=>"鎴戠殑",
'SmOwner_Search_Group'=>"閮ㄩ棬鐨?,
'SmOwner_Search_SubRole'=>"鎴戜笅灞炵殑",
'SmOwner_Search_Create'=>"鎴戝垱寤虹殑",
*/   
global $current_user;
//echo "user_privileges/user_privileges_".$current_user->id.".php";
require("user_privileges/user_privileges_".$current_user->id.".php");
//echo sizeof($user_info);
//echo $user_info['user_name'];
 $user_array=array();
//echo $_REQUEST['SearchScope'];
        $SearchScope=' and ( ';
        if($id)
        {
          switch($id)
          {
            case 'SmOwner_Search_All':
             return "";
            case 'SmOwner_Search_Me':
               $SearchScope .="ld_activity.SmOwnerID=".$current_user->id;
            break;
            case 'SmOwner_Search_Group':
                  $SearchScope=$SearchScope."ld_activity.SmOwnerID in (select groupid from ld_Groups )";
            break;
            case 'SmOwner_Search_Create':
             $SearchScope .="ld_activity.SmCreatorID=".$current_user->id;
            break;
            default:
              $SearchScope .= " ld_activity.SmOwnerID=".$_REQUEST['SearchScope'];
            
          }
          
        
        }
        else 
          {
            return "";
          }
        $SearchScope=$SearchScope ." )";
      
        return $SearchScope;
     }

/**
 * Function returns the data of the user selected by current user in the picklist of the ListView or Calendar view of Current User
 * @param $useridInUse - The Id of the user that the Current User has selected in dropdown picklist in Calendar modules listview or Calendar View
 * return string - The array of the events for the user that the current user has selected 
 */
function calendarview_getUserSelectOptions($useridInUse) {
	global $adb, $app_strings, $current_user, $mod_strings,$currentModule;
    /**
     * AUTHOR:BY LD KEVIN
     *淇敼bug: 3354 
    */

    if(isset($_REQUEST['SearchScope']))
    {
        $useridInUse=$_REQUEST['SearchScope'];
    }
    $MergeSmowner=getCurSmOwnerSearchScope($currentModule);
    unset($MergeSmowner["UserCombo"][$current_user->id]);
    $category = getParentTab();
    $userSelectdata="<div id='dv_calendar_smownerscope'>";
    $userSelectdata .= "<span style='padding-right:8px;float:left;color:#333;line-height:24px;'>" . getFixedLabel('VIEWRANGE') . "</span>";
     $userSelectdata .="<select onchange=SmownerChange(this,'".$_SERVER['QUERY_STRING']."'); name='onlyforuser'  id='onlyforuser' style='display:none'>";
     foreach($MergeSmowner as $user_key=>$user_value){
        foreach($user_value as $user_id=>$user_name){
            foreach($user_name as $user_name_key=>$user_name_value){
                if($user_id==$useridInUse){
                $optText=$user_name_key;
                $userSelectdata .="<option value='{$user_id}' selected='true'>{$user_name_key}</option>";
                }
                else{
                     $userSelectdata .="<option value='{$user_id}'>{$user_name_key}</option>";
                }
            }
        }
     }
     $userSelectdata.="</select>";
     $userSelectdata.= ' <div name="dv_chzn_onlyforuser" class="chzn-container chzn-container-single"   style="width: 126px;" 
                         onMouseLeave="cmb_mouseleave(event,\'onlyforuser\',\'dv_calendar_smownerscope\')">';
     $userSelectdata.='<a style="width:115px;" class="chzn-single" onclick="com_img_change(event,\'onlyforuser\',\'dv_calendar_smownerscope\')" href="javascript:void(0)" tabindex="-1"
                             name="cmb_a_onlyforuser">
                                <span name="cmb_span_optiontext_onlyforuser">'.$optText.' </span>
                                <div>
                                    <b></b>
                                </div>
        				    </a>';
                            
     $userSelectdata.=' <div style=" left:-9000px;width: 123px; top: 20px;" class="chzn-drop" name=\'dv_drop_onlyforuser\' >
        					<div class="chzn-search">
        					<input style="width: 106px;" class="search_bg" type="text" autocomplete="off" tabindex="0"  name=\'txt_search_onlyforuser\' onclick="com_chosen(event,\'onlyforuser\',\'dv_calendar_smownerscope\')" onKeyUp="com_chosen(event,\'onlyforuser\',\'dv_calendar_smownerscope\')">
        					</div>';
                            
    $userSelectdata.='	<ul class="chzn-results" name="cmb_ul_onlyforuser">';
    
    $i=0;					
    foreach($MergeSmowner as $user_key=>$user_value)
    {
        foreach($user_value as $user_id=>$user_name)
        {
            foreach($user_name as $user_name_key=>$user_name_value)
            {
                                                       
                $i++;        				        
                                                
                $userSelectdata.=' <li style="" class="active-result" name="dv_chzn_'.$i.
                                    "_onlyforuser\" onclick=cmb_liclick('".$user_id."','onlyforuser','dv_calendar_smownerscope') 
                                    onmouseover=cmb_limouseover(event,'onlyforuser','dv_calendar_smownerscope')>". $user_name_key."</li>";					
            }
        }
    }
                               
    $userSelectdata.=' <li style="" class="" name="li_chzn_onlyforuser" >'.getFixedLabel('NOMATCHINGITEMS').'</li>
    					 </ul>
				 </div> </div>';
     $userSelectdata.='</div>';
     
	return $userSelectdata;
}
// END

?>