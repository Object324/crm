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

/**	Function to get the list of tickets for the currently loggedin user 最新服务单
**/

//function getMyTickets($maxval,$calCnt)
//{
//
//	global $current_user, $current_language, $adb,$mod_strings,$default_charset;
//	$current_module_strings = return_module_language($current_language, 'HelpDesk');
//	crm_load_function_file('getApproveQuery','modules/Home','HomeUtils');
//    if(!empty($_REQUEST['approve_value'])){
//		$troubletickets_approvestatus = getApproveQuery('ld_troubletickets');
//	}
//	$search_query  = "SELECT ld_troubletickets.*, ld_crmentity.*
//		FROM ld_troubletickets
//		INNER JOIN ld_crmentity on ld_crmentity.crmid = ld_troubletickets.ticketid
//		where ld_crmentity.deleted = 0";
//
//   /*
//    *AUTHOR: BY LD KEVIN
//    *DATE:20130121
//    *$PARA $userPrivileLists当前用户所具有权限
//    */
//    $queryGenerator = new QueryGenerator('HelpDesk', $current_user);
//    $userPrivileLists=$queryGenerator->getPrivile();
//    if(count($userPrivileLists)>0)
//    {
//        foreach($userPrivileLists as $userid)
//        {
//            $userids .=$userid.',';
//        }
//        $userids=mb_substr($userids,0,strlen($userids)-1,$default_charset);
//        $userids ='('.$userids.')';
//        $search_query .=" and ld_troubletickets.smownerid in ".$userids;
//    }
//
//		$search_query .=" and ld_troubletickets.ticketid > 0 and (ld_troubletickets.status <> 'Closed' or ld_troubletickets.status <>'".$mod_strings['Closed']."')".
//		"AND ld_crmentity.setype='HelpDesk' $troubletickets_approvestatus ORDER BY createdtime DESC";
//
//	$search_query .= " LIMIT 12";
//
//	if($calCnt == 'calculateCnt') {
//		$list_result_rows = $adb->pquery(mkCountQuery($search_query), array($current_user->id));
//		return $adb->query_result($list_result_rows, 0, 'count');
//	}
//
//	$tktresult = $adb->pquery($search_query, array($current_user->id));
//	if($adb->num_rows($tktresult))
//	{
//		$title=array();
//		$title[]='myTickets.gif';
//		$title[]=$current_module_strings['LBL_MY_TICKETS'];
//		$title[]='home_mytkt';
//
//		$header=array();
//		$header[]=$current_module_strings['LBL_SUBJECT'];
//		$header[]=$current_module_strings['Related To'];
//
//		$noofrows = $adb->num_rows($tktresult);
//		for ($i=0; $i<$adb->num_rows($tktresult); $i++)
//		{
//			$value=array();
//			$ticketid = $adb->query_result($tktresult,$i,"ticketid");
//			$viewstatus = $adb->query_result($tktresult,$i,"viewstatus");
//            //by kevin
//			if($viewstatus == 'Unread')
//				$value[]= '<a style="color:red;" href="index.php?action=DetailView&module=HelpDesk&record='.mb_substr($adb->query_result($tktresult,$i,"ticketid"),0,18,$default_charset).'">'.$adb->query_result($tktresult,$i,"title").'</a>';
//			elseif($viewstatus == 'Marked')
//				$value[]= '<a style="color:yellow;" href="index.php?action=DetailView&module=HelpDesk&record='.mb_substr($adb->query_result($tktresult,$i,"ticketid"),0,18,$default_charset).'">'.$adb->query_result($tktresult,$i,"title").'</a>';
//			else
//				$value[]= '<a href="index.php?action=DetailView&module=HelpDesk&record='.mb_substr($adb->query_result($tktresult,$i,"ticketid"),0,18,$default_charset).'">'.mb_substr($adb->query_result($tktresult,$i,"title"),0,18,$default_charset).'</a>';
//
//			$parent_id = $adb->query_result($tktresult,$i,"parent_id");
//			$parent_name = '';
//			if($parent_id != '' && $parent_id != NULL)
//			{
//				$parent_name = getParentLink($parent_id);
//			}
//
//			$value[]=$parent_name;
//			$entries[$ticketid]=$value;
//		}
//
//		$advft_criteria_groups = array('1' => array('groupcondition' => null));
//		$advft_criteria = array(
//			array (
//				'groupid' => 1,
//				'columnname' => 'ld_troubletickets:status:ticketstatus:HelpDesk_Status:V',
//				'comparator' => 'n',
//				'value' => 'Closed',
//				'columncondition' => 'and'
//			),
//			array (
//				'groupid' => 1,
//				'columnname' => 'ld_crmentity:smownerid:assigned_user_id:HelpDesk_Assigned_To:V',
//				'comparator' => 'e',
//				'value' => $current_user->last_name,
//				'columncondition' => null
//			)
//		);
//		$search_qry = '&advft_criteria='.Zend_Json::encode($advft_criteria).'&advft_criteria_groups='.Zend_Json::encode($advft_criteria_groups).'&searchtype=advance&query=true';
//
//		$values=Array('ModuleName'=>'HelpDesk','Title'=>$title,'Header'=>$header,'Entries'=>$entries,'search_qry'=>$search_qry);
//		if ( ($noofrows == 0 ) || ($noofrows>0) )
//		{
//
//			return $values;
//		}
//	}
//
//}

/**	Function to get the parent (Account or Contact) link
  *	@param int $parent_id -- parent id of the ticket (accountid or contactid)
  *	return string $parent_name -- return the parent name as a link
**/
//function getParentLink($parent_id)
//{
//
//	$log->debug("Entering getParentLink(".$parent_id.") method ...");
//	global $adb;
//
//	// Static caching
//	static $__cache_listtickets_parentlink = Array();
//	if(isset($__cache_listtickets_parentlink[$parent_id])) {
//		return $__cache_listtickets_parentlink[$parent_id];
//	}
//
//	//$sql = 'select setype from ld_crmentity where crmid=? limit 1;';
//	//$parent_module = $adb->query_result($adb->pquery($sql, array($parent_id)),0,'setype');
//	$parent_module = getEntitySetype($parent_id);//获取setype字段方法 tujt 2014-07-31
//	if($parent_module == 'Contacts')
//	{
//		$sql = "select firstname,lastname from ld_contactdetails where contactid=?";
//		$res = $adb->pquery($sql, array($parent_id));
//		$parentname = $adb->query_result($res,0,'firstname');
//		$parentname .= ' '.$adb->query_result($res,0,'lastname');
//	        $parent_name = '<a href="index.php?action=DetailView&module='.$parent_module.'&record='.$parent_id.'">'.$parentname.'</a>';
//	}
//	if($parent_module == 'Accounts')
//	{
//		$sql = "select accountname from ld_account where accountid=?";
//		$parentname = $adb->query_result($adb->pquery($sql, array($parent_id)),0,'accountname');
//	        $parent_name = '<a href="index.php?action=DetailView&module='.$parent_module.'&record='.$parent_id.'">'.$parentname.'</a>';
//	}
//
//	// Add to cache
//	$__cache_listtickets_parentlink[$parent_id] = $parent_name;
//
//
//	return $parent_name;
//}
?>