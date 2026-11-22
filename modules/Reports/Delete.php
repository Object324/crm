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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Reports/Reports.php');
require_once('include/logging.php');
require_once('include/database/PearDatabase.php');

$is_admin=is_admin($current_user);
global $current_user,$adb,$is_admin;

if(isset($_REQUEST['idlist']) && $_REQUEST['idlist']!= '')
{
	$id_array = Array();
	$id_array = explode(':',$_REQUEST['idlist']);
	
	$query = $adb->pquery("select userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '".$current_user_parent_role_seq."::%'",array());
	$subordinate_users = Array();
	for($i=0;$i<$adb->num_rows($query);$i++){
		$subordinate_users[] = $adb->query_result($query,$i,'userid'); 
	}

	for($i=0;$i<count($id_array)-1;$i++)
	{
		$own_query = $adb->pquery("SELECT reportname,owner FROM ld_report WHERE reportid=?",array($id_array[$i]));
		$owner = $adb->query_result($own_query,0,"owner");
		if($is_admin==true || in_array($owner,$subordinate_users) || $owner==$current_user->id){
			DeleteReport($id_array[$i]);	
		} else {
			$del_failed []= $adb->query_result($own_query,0,"reportname");
		}
	}
	
	if(!empty($del_failed))
		header("Location: index.php?action=ReportsAjax&file=ListView&mode=ajax&module=Reports&del_denied=".implode(",",$del_failed));
	else
		header("Location: index.php?action=ReportsAjax&file=ListView&mode=ajax&module=Reports");
}elseif(isset($_REQUEST['record']) && $_REQUEST['record']!= '')
{
	$id = vtlib_purify($_REQUEST["record"]);
	DeleteReport($id);	
	header("Location: index.php?action=ReportsAjax&file=ListView&mode=ajaxdelete&module=Reports");
}

/** To Delete a Report 
  * @param $reportid -- The report id
  * @returns nothing
  */
       
function DeleteReport($reportid)
{
	global $adb;
	$idelreportsql = "delete from ld_selectquery where queryid=?";
	$idelreportsqlresult = $adb->pquery($idelreportsql, array($reportid));

	$ireportsql = "delete from ld_report where reportid=?";
    $ireportsqlresult = $adb->pquery($ireportsql, array($reportid));

	$reportsql = 'DELETE FROM ld_scheduled_reports WHERE reportid=?';
	$adb->pquery($reportsql, array($reportid));

/******************** Mnolithic Phase 6 Customization****************/

    $query = "SELECT * FROM ld_homereportchart WHERE reportid=?";
    $result =$adb->pquery($query,array($reportid));
    $num_rows = $adb->num_rows($result);
    if($num_rows){
        for($i=0;$i<$num_rows;$i++){
            $stuffid = $adb->query_result($result,$i,'stuffid');
            $delHomeSql="delete from ld_homestuff where stuffid=?";
            $delResult=$adb->pquery($delHomeSql, array($stuffid));
        }
    }

    /*================ End of Customization =========================*/
}
?>