<?php

require_once("include/Popup/PopUpListView.php");
require_once("include/ProductDetails/ProductDetails.php");
require_once('data/PopInventory.php');
global $app_strings, $default_charset;
global $currentModule, $current_user;
global $theme, $adb;
$languageType= getLanguageType($current_user);
$url_string = '';
$smarty = new lingdangCRM_Smarty;
if (!isset($where)) $where = "";

$parent_tab=getParentTab();
$smarty->assign("CATEGORY",$parent_tab);

$url = '';
$popuptype = '';
$fromModule = '';
/*
相关对象弹窗没有popuptype
*/
$popuptype = vtlib_purify($_REQUEST["popuptype"]);
$warehouseid = $_REQUEST['wareid'];
$smarty->assign('WAREHOUSEID',$warehouseid);
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign("MODULE",$currentModule);
$customView = new CustomView($currentModule);
/**
更新操作
edit：andrew
date：20140214
reason：添加数据分类
**/
$viewid=0;
if($_REQUEST['viewname']){
    $viewid = $_REQUEST['viewname'];
}
if($viewid==0)
    $viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
$category = getParentTab();

$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category,'popup');
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
$accounttype="ALLACCOUNT";
$smarty->assign("ACCOUNTTYPE",$accounttype);
$smarty->assign('PAGEWIDTHPERCENT', $customView->pageWidthPercent);

$form = vtlib_purify($_REQUEST['form']);
//added to get relatedto field value for todo, while selecting from the popup list, after done the alphabet or basic search.
if(isset($_REQUEST['maintab']) && $_REQUEST['maintab'] != '')
{
        $act_tab = vtlib_purify($_REQUEST['maintab']);
        $url = "&maintab=".$act_tab;
}
$smarty->assign("MAINTAB",$act_tab);
			
// This is added to support the type of popup and callback
if(isset($_REQUEST['popupmode']) && isset($_REQUEST['callback'])) {
	$url = "&popupmode=".$_REQUEST['popupmode']."&callback=".$_REQUEST['callback'];
	$smarty->assign("POPUPMODE", $_REQUEST['popupmode']);
	$smarty->assign("CALLBACK", $_REQUEST['callback']);
}	

switch($currentModule)
{
	case 'Accounts':
		require_once("modules/$currentModule/Accounts.php");
		$focus = new Accounts();
		$log = LoggerManager::getLogger('account_list');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		$smarty->assign("SINGLE_MOD",'Account');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		else
			$smarty->assign("RETURN_MODULE",'Emails');
		$alphabetical = AlphabeticalSearch($currentModule,'Popup','accountname','true','basic',$popuptype,"","",$url);
		break;

	default:
		require_once("modules/$currentModule/$currentModule.php");
		$focus = new $currentModule();
		$smarty->assign("SINGLE_MOD", $currentModule);		
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		$alphabetical = AlphabeticalSearch($currentModule,'Popup',$focus->def_basicsearch_col,'true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		break;
	// END

}


// vtlib customization: Initialize focus to get generic popup
if($_REQUEST['form'] == 'vtlibPopupView') {

}
// END

$smarty->assign("RETURN_ACTION",vtlib_purify($_REQUEST['return_action']));
//Retreive the list from Database
if(isset($_REQUEST['recordid']) && $_REQUEST['recordid'] != '')
{
	$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
	$url_string .='&recordid='.vtlib_purify($_REQUEST['recordid']);
    	$where_relquery = getRelCheckquery($currentModule,$_REQUEST['return_module'],$_REQUEST['recordid']);
}
if(isset($_REQUEST['relmod_id']) || isset($_REQUEST['fromPotential']))
{
	if($_REQUEST['relmod_id'] !='')
	{
		$mod = vtlib_purify($_REQUEST['parent_module']);
		$id = vtlib_purify($_REQUEST['relmod_id']);
	}
	else if($_REQUEST['fromPotential'] != '')
	{
		$mod = "Accounts";
		$id= vtlib_purify($_REQUEST['acc_id']);
	}

	$smarty->assign("mod_var_name", "parent_module");
	$smarty->assign("mod_var_value", $mod);
	$smarty->assign("recid_var_name", "relmod_id");
	$smarty->assign("recid_var_value",$id);
//	$where_relquery.= getPopupCheckquery($currentModule,$mod,$id);
}
else if(isset($_REQUEST['task_relmod_id']))
{
	$smarty->assign("mod_var_name", "task_parent_module");
	$smarty->assign("mod_var_value", vtlib_purify($_REQUEST['task_parent_module']));
	$smarty->assign("recid_var_name", "task_relmod_id");
	$smarty->assign("recid_var_value",vtlib_purify($_REQUEST['task_relmod_id']));
//	$where_relquery.= getPopupCheckquery($currentModule,$_REQUEST['task_parent_module'],$_REQUEST['task_relmod_id']);
}

//Avoiding Current Record to show up in the popups When editing.
if($currentModule == 'Accounts' && $_REQUEST['recordid']!=''){
	$where_relquery .=" and ld_account.accountid!=".$adb->sql_escape_string($_REQUEST['recordid']);
	$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
}
//*查询语句
//$query = getListQuery($currentModule,$where_relquery);
$popuplistview=new PopUpListView();
//$query = $popuplistview->getpopupquery($currentModule,$current_user,$viewid);

if(get_file_address($currentModule,'ProductDetails'))
{
    crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
    $controller = new ProductDetail_ListController($adb, $current_user, $popuplistview->queryGenerator);
}
else if(get_file_address($currentModule,$currentModule.'DetailFieldsHtml')){

    crm_load_class_file('TabDetailListViewController','include/ListView','TabDetailListViewController');
    $controller = new TabDetailListViewController($adb, $current_user, $popuplistview->queryGenerator,$currentModule);
}
else
{
    $controller = new ListViewController($adb, $current_user, $popuplistview->queryGenerator);
}



/**
 * 用户弹出框特别处理
 * @reason 0008999 审批委托人 无法选择用户
 * @author Tujt 2014-05-26
 */
if($currentModule != 'Users'){
	$query = $popuplistview->getpopupquery($currentModule,$current_user,$viewid);
}else{
	$query = 'SELECT distinct ld_users.*,ld_role.rolename  
				FROM ld_users 
						left join ld_user2role 
							on ld_user2role.userid = ld_users.id 
						left join ld_role 
							on ld_role.roleid = ld_user2role.roleid 
					WHERE ld_users.status = "Active" AND ld_users.id > 0 ';
	if(isset($_REQUEST['search_text']) && !empty($_REQUEST['search_text'])){
		if($_REQUEST['search_field'] == 'roleid'){
			$_REQUEST['search_field'] = 'rolename';
		}
		$query .= ' and '.$_REQUEST['search_field'].' like "%'.$_REQUEST['search_text'].'%" ';
	}
}
$page_list_query=$popuplistview->getPageListQuery();  

if(isset($_REQUEST['frommodule']) && $_REQUEST['frommodule'] != "" || isset($_REQUEST['fromModule']) && $_REQUEST['fromModule'] != "")
{
    if(isset($_REQUEST['frommodule']))
        $fromModule = $_REQUEST['frommodule'];
    else
        $fromModule = $_REQUEST['fromModule'];
    $smarty->assign("FROMMODULE",vtlib_purify($fromModule));
    
}

if($currentModule == 'Products' && $_REQUEST['record_id'] && ($popuptype == 'inventory_prod' || $popuptype == 'inventory_prod_po'))
{
	$product_name = getModuleHref('Products',$_REQUEST['record_id']);
	$smarty->assign("PRODUCT_NAME", $product_name);
	$smarty->assign("RECORD_ID", vtlib_purify($_REQUEST['record_id']));
}

$smarty->assign("ALPHABETICAL", $alphabetical);

$smarty->assign("ACCOUNTID",$_REQUEST['accountid']);
$smarty->assign('VENDORID',$_REQUEST['vendorid']);
//Added to fix the issue #2307 
//$order_by = $focus->getOrderBy();

//$sorder = $focus->getSortOrder();
if(get_file_address($_REQUEST['module'],'ProductDetails'))
{
   $listview_header_search = $popuplistview->queryGenerator->productDetails->getListViewHeaderSearch();
}
else
{
    $listview_header_search=$popuplistview->getPopupBasicSearch();
    
}
if($popuptype=='set_return_groupmasssms'){
    $page_list_query .= " AND ld_contactdetails.mobile<>''";
}
if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true){

    $customsortorder = $customView->getCustomViewOrderBy($viewid);
    $count_result = $adb->query( $page_list_query);
   	$noofrows = $adb->num_rows($count_result);
    //if(isset($order_by) && $order_by != '')
    //{
        //$page_list_query .= ' ORDER BY ' .$customsortorder.$order_by.' '.$sorder;
    //}

}else{
	$noofrows = null;
}
// vtlib customization: To override module specific popup query for a given field
$override_query = false;
if(method_exists($focus, 'getQueryByModuleField')) {
	$override_query = $focus->getQueryByModuleField(vtlib_purify($_REQUEST['srcmodule']), vtlib_purify($_REQUEST['forfield']), vtlib_purify($_REQUEST['forrecord']), $query);
	if($override_query) {
		$query = $override_query;
	}
}
//Retreiving the start value from request
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
	$start = vtlib_purify($_REQUEST['start']);
	if($start == 'last'){
		$count_result = $adb->query( mkCountQuery($query));
		$noofrows = $adb->query_result($count_result,0,"count");
		if($noofrows > 0){
			$start = ceil($noofrows/$list_max_entries_per_page_new);
		}
	}
	if(!is_numeric($start)){
		$start = 1;
	}elseif($start < 1){
		$start = 1;
	}
	$start = ceil($start);
} else {
	$start = 1;
}
$limstart=($start-1)*$list_max_entries_per_page_new;
  
//echo $page_list_query;
/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

$query.=" inner join ( $page_list_query limit $limstart,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
$query.=$popuplistview->queryGenerator->getWhereClause();
$query.=$popuplistview->queryGenerator->getPopupwhereclause();

$listview_header_search = $popuplistview->queryGenerator->productDetails->getListViewHeaderSearch();
$smarty->assign("SEARCHLISTHEADER", $listview_header_search);
$list_result = $adb->query($query);

$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new,$noofrows);

//Retreive the List View Table Header
///$focus->initSortbyField($currentModule);
$focus->list_mode="search";
$focus->popup_type=$popuptype;
$url_string .='&popuptype='.$popuptype;
if(isset($_REQUEST['select']) && $_REQUEST['select'] == 'enable')
	$url_string .='&select=enable';
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != '')
	$url_string .='&return_module='.vtlib_purify($_REQUEST['return_module']);
//by ld kevin
if($popuptype == 'set_return_emails'||$popuptype=='set_return_groupemails'){
	$tabid = getTabid($currentModule);
	$mail_arr = getMailFields($tabid); 
	
	if(!empty($mail_arr)){
		$tablename = str_replace("ld_","",$mail_arr['tablename']);
		$fieldname = $mail_arr['fieldname'];
		$fieldlabel = $mail_arr['fieldlabel'];
		$focus->search_fields[$fieldlabel] = Array($tablename=>$fieldname);
		$focus->search_fields_name[$fieldlabel] = $fieldname;
	}
}

//列头
$listview = getSearchListViewHeader($focus,"$currentModule",$url_string,$sorder,$order_by,$popuplistview->queryGenerator);

$listview_header = $listview['listview_header'];

$smarty->assign('LISTHEADERWIDTH',$listview['listview_width']);
$smarty->assign('LISTVIEWTOTALWIDTH',$listview['listview_totalwidth']);
$smarty->assign("CHKBOXWIDTH",$listview['listview_checkboxwidth']);

$smarty->assign("LISTHEADER", $listview_header);
$header_count = count($listview_header)+1;
$smarty->assign("HEADERCOUNT",$header_count);
//内容
//弹出选择框序时簿内容
$listview_entries = getSearchListViewEntries($focus,"$currentModule",$list_result,$navigation_array,$form,$popuplistview->queryGenerator);
//$smarty->assign("LISTENTITY", $listview_entries);
$row_count = $popuplistview->queryGenerator->getMainColumnCount();
$smarty->assign('ROW_COUNT',$row_count);
$smarty->assign('POPHTML',PopInventory::createPopWithDetailhtml($listview_entries,$_REQUEST['select'],$row_count,$header_count,0,$controller));
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,$currentModule,"Popup");
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("POPUPTYPE", $popuptype);
$smarty->assign("PARENT_MODULE", vtlib_purify($_REQUEST['parent_module']));
$smarty->assign('FROMLINK',$_REQUEST['fromlink']);  
/**
更新操作
edit：cdw
date：20131204
reason：营销群发短信选择联系人界面改进
**/
$smarty->assign("html_contact_SMS",$html_contact_SMS);
$smarty->assign("num_rows_contact",$num_rows_contact);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发短信选择客户界面改进
**/
$smarty->assign("html_accounttype_SMS",$html_accounttype_SMS);
$smarty->assign("num_rows_account",$num_rows_account);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发邮件选择联系人界面改进
**/
$smarty->assign("html_contact_Email",$html_contact_Email);
$smarty->assign("num_rows_contact_Email",$num_rows_contact_Email);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发邮件选择联系人界面改进
**/
$smarty->assign("html_accounttype_Email",$html_accounttype_Email);
$smarty->assign("num_rows_account_Email",$num_rows_account_Email);
$smarty->assign('LANGUAGETYPE',$languageType);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    $smarty->display("ListPopupContents.tpl");
}
else
{
    $smarty->display("Popup.tpl");   
}
?>