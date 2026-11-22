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
 * ****************************************************************************** */
/* * *******************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Emails/ListView.php,v 1.12 2005/04/18 10:37:49 samk Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ******************************************************************************* */
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if($_REQUEST['smowner_search_senior']&&$_REQUEST['senioruserid']!='')
{
    include(globalStatic::$root_directory.'modules/Emails/getDbListMail.php');
    exit();
}

require_once('modules/Emails/Emails.php');

global $current_user;
global $app_strings;
global $mod_strings;

global $list_max_entries_per_page_new, $adb;
$list_max_entries_per_page_new = 10;//邮件一页显示10条数据

//$log = LoggerManager::getLogger('email_list');

global $currentModule;

global $image_path;
global $theme;

$url_string = ''; // assigning http url string

//$focus = new Emails();
$focus = CRMEntity::getInstance('Emails');
// Initialize sort by fields
//$focus->initSortbyField('Emails');
// END
$smarty = new lingdangCRM_Smarty;
$other_text = Array();



if (ListViewSession::hasViewChanged($currentModule, $viewid)) {
	$_SESSION['EMAILS_ORDER_BY'] = '';
}

//<<<<<<<<<<<<<<<<<<< sorting - stored in session >>>>>>>>>>>>>>>>>>>>
if ($_REQUEST['order_by'] != '')
	$order_by = $adb->sql_escape_string($_REQUEST['order_by']);
else
	$order_by = (($_SESSION['EMAILS_ORDER_BY'] != '') ? ($_SESSION['EMAILS_ORDER_BY']) : ($focus->default_order_by));

if ($_REQUEST['sorder'] != '')
	$sorder = $adb->sql_escape_string($_REQUEST['sorder']);
else
	$sorder = (($_SESSION['EMAILS_SORT_ORDER'] != '') ? ($_SESSION['EMAILS_SORT_ORDER']) : ($focus->default_sort_order));

$_SESSION['EMAILS_ORDER_BY'] = $order_by;
$_SESSION['EMAILS_SORT_ORDER'] = $sorder;
//<<<<<<<<<<<<<<<<<<< sorting - stored in session >>>>>>>>>>>>>>>>>>>>
// focus_list is the means of passing data to a ListView.
global $focus_list;

//<<<<cutomview>>>>>>>
$oCustomView = new CustomView("Emails");
$viewid = $oCustomView->getViewId($currentModule);

$customviewcombo_html = $oCustomView->getCustomViewCombo2($viewid,$currentModule);
//$viewnamedesc = $oCustomView->getCustomViewByCvid($viewid);
$viewName = $oCustomView->getViewNameDetail($viewid);

//<<<<<customview>>>>>
// Buttons and View options
if (isPermitted('Emails', 'Delete', '') == 'yes') {
	$other_text['del'] = $app_strings[LBL_MASS_DELETE];
}

if ($viewName == 'All') {
	$smarty->assign("ALL", 'All');
}

global $email_title;
$display_title = $mod_strings['LBL_LIST_FORM_TITLE'];
if ($email_title)
	$display_title = $email_title;

// Search
if(isset($_REQUEST['search']) && !empty($_REQUEST['search_text'])){
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$search_text = trim(Input('search_text'));
	$search_text = $json->encode($search_text);
	$search_text = trim($search_text,'"');
	if(substr_count($search_text,'\u') > 1){
		$search_text = str_replace('\u','\\\\\\\\\\\\u',$search_text);
	}
	$url_string .= "&search=" . vtlib_purify($_REQUEST['search']) . "&search_field=" . vtlib_purify($_REQUEST['search_field']) . "&search_text=" . vtlib_purify($_REQUEST['search_text']);
	switch($_REQUEST['search_field']){
	    case 'subject'://主题
			$seatchfld = $adb->sql_escape_string($_REQUEST['search_field']);
	        $where = ' ('.$seatchfld.' like "%'.$search_text.'%" or '.$seatchfld.' like "%'.$_REQUEST['search_text'].'%") ';//两种情况，兼顾中文搜索和英文搜索，因为json会把英文也转码
	        break;
	    case 'join'://主题和收件人
			$where = '((subject like "%'.$_REQUEST['search_text'].'%" or subject like "%'.$search_text.'%")';
			$where .= ' or (ld_users.user_name like "%'.$_REQUEST['search_text'].'%" or ld_users.user_name like "%'.$search_text.'%")';
			$where .= ' or (ld_emaildetails.to_email like "%'.$_REQUEST['search_text'].'%" or ld_emaildetails.to_email like "%'.$search_text.'%"))';
	        break;
		case 'user_name'://发件人
			$seatchfld = $adb->sql_escape_string($_REQUEST['search_field']);
			$where = ' ('.$seatchfld.' like "%'.$search_text.'%" or '.$seatchfld.' like "%'.$_REQUEST['search_text'].'%" or ld_emaildetails.from_email like "%'.$search_text.'%" or ld_emaildetails.from_email like "%'.$_REQUEST['search_text'].'%") ';
	        break;
		default:
			$seatchfld = $adb->sql_escape_string($_REQUEST['search_field']);
            if($seatchfld=='toemail')
	           $where = ' ('.$seatchfld.' like "%'.$search_text.'%" or '.$seatchfld.' like "%'.$_REQUEST['search_text'].'%") ';
            else
                $where = ' (ld_emaildetails.'.$seatchfld.' like "%'.$search_text.'%" or ld_emaildetails.'.$seatchfld.' like "%'.$_REQUEST['search_text'].'%") ';
			break;
	}
}
if(isset($_REQUEST['search_field'])&&$_REQUEST['search_field']!='')
$smarty->assign('SEARCH_FIELD',$_REQUEST['search_field']);
$smarty->assign('SEARCH_TEXT',trim($_REQUEST['search_text']));

//Retreive the list from Database
//<<<<<<<<<customview>>>>>>>>>


//$list_query = getListQuery("Emails");
$columnlist = $oCustomView->getColumnsListByCvid($viewid);
$fromclause = '';
for($i=0;$i<count($columnlist);$i++){
	if(isset($columnlist[$i])){
		 $arrcolumn=explode(":",$columnlist[$i]);
		 if(isset($ismodtable[strtolower($arrcolumn[0])])){
			$arrcolumn[0] = $table_name;
		 }
		 $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
	}
}
$fromclause = strtr($fromclause,array('ld_activity.date_start'=>'ld_activity.createdtime as date_start'));
$list_query = 'SELECT DISTINCT ld_activity.activityid as crmid, ld_activity.smownerid '.$fromclause.' 
				FROM ld_activity 
					LEFT JOIN ld_users
						ON ld_users.id = ld_activity.smownerid
					LEFT JOIN ld_emaildetails
						ON ld_emaildetails.emailid = ld_activity.activityid ';
$controlsql = $focus->getNonAdminAccessControlQuery('Emails',$current_user);
if(!empty($controlsql)){
	$list_query .= $controlsql;
}
$list_query .= ' WHERE ld_activity.activitytype = "Emails" AND ld_activity.deleted = 0 ';
//<<<<<<<<customview>>>>>>>>>
$type=2;
if(empty($_REQUEST['folderid'])){
	$_REQUEST['folderid'] = 2;
}
if(!isset($_REQUEST['folderid'])&&$_SESSION['email_folderid'])
{
    $_REQUEST['folderid']=$_SESSION['email_folderid'];
}

if(isset($_REQUEST['folderid'])&&$_REQUEST['folderid']!=''){
    $type=$_REQUEST['folderid'];
}
if(isset($where) && $where != ''){    
    if ($type) {
	   $list_query .= " AND " . $where;
    }
    else{        
        $list_query .=" AND ld_emaildetails.email_flag='SENT' AND ".$where;
    }
}
else{
    if (!$type) { 
        $list_query .=" AND ld_emaildetails.email_flag='SENT'  ";
    }
}
$smarty->assign('TYPE',$type);

if($_REQUEST['folderid']==1){
    $list_query .=" AND ld_emaildetails.email_flag='SENT'";
}
if ($_REQUEST['folderid'] == '2') {//我的邮件
	//联系人
	//$list_query .= " AND ld_seactivityrel.crmid in (select contactid from ld_contactdetails) AND ld_emaildetails.email_flag ='SENT'";
	$list_query .= 'and ld_activity.smownerid = '.$current_user->id.' and ld_emaildetails.email_flag = "SENT" ';
}
if ($_REQUEST['folderid'] == '3') {//我下属的邮件
	////客户
	//$list_query .= " AND ld_seactivityrel.crmid in (select accountid from ld_account) AND ld_emaildetails.email_flag='SENT'";
	require("user_privileges/user_privileges_".$current_user->id.".php");
	if(!empty($subordinate_roles_users)){
		$usersql = '';
		foreach($subordinate_roles_users as $sub_values){
			if(!empty($sub_values))
				$usersql .= join(',',$sub_values).',';
		}
		$usersql = trim($usersql,',');
		if(!empty($usersql)){
			$list_query .= 'and ld_activity.smownerid in ('.$usersql.') and ld_emaildetails.email_flag = "SENT" ';
		}else{
			$list_query .= 'and 1=2 ';
		}
	}
}

if($_REQUEST['folderid']==7){//草稿箱
    $list_query .=" AND ld_emaildetails.email_flag='SAVED'";
}
$_SESSION['email_folderid']=$_REQUEST['folderid'];
if (isset($order_by) && $order_by != '') {
	$tablename = getTableNameForField('Emails', $order_by);
	$tablename = (($tablename != '') ? ($tablename . ".") : '');
	$list_query .= ' ORDER BY ' . $tablename . $order_by . ' ' . $sorder;
}

if (PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {  
	$count_result = $adb->query(mkCountQuery($list_query));    
	$noofrows = $adb->query_result($count_result,0,'count');
} else {
	$noofrows = null;
}
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);

if (!isset($_REQUEST['start']))
	$start = 1;
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new, $noofrows);

$limit_start_rec = ($start - 1) * $list_max_entries_per_page_new;
if ($adb->dbType == "pgsql")
	$list_result = $adb->pquery($list_query . " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new", array());
else
	$list_result = $adb->pquery($list_query . " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());

//Constructing the list view
$smarty->assign("CUSTOMVIEW_OPTION", $customviewcombo_html);
$smarty->assign("VIEWID", $viewid);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", getTranstab($currentModule));
$smarty->assign("BUTTONS", $other_text);
$category = getParentTab();
$smarty->assign("CATEGORY", $category);

if ($viewid != '')
	$url_string .="&viewname=" . $viewid;
if (isset($_REQUEST['folderid']) && $_REQUEST['folderid'] != '')
	$url_string .= "&folderid=" . vtlib_purify($_REQUEST['folderid']);

$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, $_REQUEST['folderid'], '');
 
$smarty->assign("NAVIGATION", $navigationOutput);
crm_load_class_file("ListView_Special","include/utils");
///$listview_header = ListView_Special::getListViewHeader($focus, "Emails", $url_string, $sorder, $order_by, "", $oCustomView);


//$smarty->assign("LISTHEADER", $listview_header);

//$listview_entries = getListViewEntries($focus, "Emails", $list_result, $navigation_array, "", "", "EditView", "Delete", $oCustomView);
$result=$adb->query($list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new");

for($i=0;$i<$adb->num_rows($result);$i++){
    $to_mail=$adb->query_result($result,$i,"to_email");
	$to_mail = $focus->unicode_decode($to_mail);
    $to_mail=str_replace("["," ",$to_mail);
    $to_mail=str_replace("]"," ",$to_mail);
    $to_mail=strlen($to_mail)>50?mb_substr($to_mail,0,50,$default_charset)."...":$to_mail;
    $listview_entries[$adb->query_result($result,$i,"crmid")]=array("0"=>$adb->query_result($result,$i,"subject"),
    "1"=>$to_mail,
    "2"=>strlen($adb->query_result($result,$i,"date_start"))>16?mb_substr($adb->query_result($result,$i,"date_start"),0,16,$default_charset):$adb->query_result($result,$i,"date_start"),
    
    );
}

//--------------------------added to fix the ticket(4386)------------------------START
if(!empty($listview_entries)){
	foreach ($listview_entries as $key => $value) {
		$sql = "select email_flag from ld_emaildetails where emailid=?";
		$result = $adb->pquery($sql, array($key));
		$email_flag = $adb->query_result($result, 0, "email_flag");
		$emailid[$key] = $email_flag;
	}
}
$smarty->assign("EMAILFALG", $emailid);
//--------------------------added to fix the ticket(4386)------------------------END

$smarty->assign("LISTENTITY", $listview_entries);
$smarty->assign("SELECT_SCRIPT", $view_script);

$smarty->assign("USERID", $current_user->id);
$smarty->assign('IS_ADMIN',$current_user->is_admin);

//批量操作数上线
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
//$check_button = Button_Check($module);
//$check_button['Export'] = 'no';
//$smarty->assign("CHECK", $check_button);
$smarty->assign("theme", $theme);

if ($_REQUEST['ajax'] != ''){
    $smarty->display("EmailContents.tpl");
}	
else{
	$smarty->display("Emails.tpl");
}
?>