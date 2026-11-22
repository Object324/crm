<?php
require_once('include/ListView/ListViewSession.php');
require_once("include/Popup/PopUpListView.php");

global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$default_language;
global $list_max_entries_per_page_new;
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}
$smarty=new lingdangCRM_Smarty; 
$smarty->assign("LANGUAGETYPE",$languageType);
/*
$customView = new CustomView($currentModule);
if($_REQUEST['viewname']){
    $viewid = $_REQUEST['viewname'];
}
if($viewid==0)
    $viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category,'popup');
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
*/
$search_text = '';
$search_field = '';
$viewid=0;
$listall = 0;



$category = getParentTab();
if(isset($_REQUEST['module']) && $_REQUEST['module'] != '')
    $module = $_REQUEST['module'];
require_once("modules/$module/$module.php");
$focus = new $module();
$order_by = $focus->getOrderBy();
$sorder = $focus->getSortOrder();
if($order_by){
  $order_by.=$order_by.$sorder;
}
$owerinner = " LEFT JOIN ld_tabshare on ld_tabshare.crmid = $focus->table_name.$focus->table_index ";


require('user_privileges/user_privileges_'.$current_user->id.'.php');
if(isset($_REQUEST['search_text']) && $_REQUEST['search_text'] != '')
{
    $search_field = $_REQUEST['search_field'];
    $search_text = $_REQUEST['search_text'];
    $smarty->assign('SEARCHTXT',$search_text);
    $smarty->assign('SEARCHFIELD',$search_field);
    $where .= ' and ';
    if($search_field == 'ld_purchaseorder.purchaseorderid')
        $where .= " ld_purchaseorder.purchaseorder_no like '%$search_text%' ";
    else if($search_field == 'ld_purchaseorder.smownerid')
        $where .= " ld_users.last_name like '%$search_text%' ";
	else if($search_field == 'ld_sendpayment.cpperiodtime')
        $where .= "   ld_sendpayment.cpperiodtime = '$search_text' ";
    else
        $where .= $search_field . '=' . "'".$search_text."'";
}

$query = "select ld_users.last_name,ld_purchaseorder.purchaseorder_no,ld_purchaseorder.purchaseorderid,ld_purchaseorder.total,ld_purchaseorder.currency_id AS purchaseorder_curid,ld_purchaseorder.conversion_rate AS purchaseorder_rate,ld_purchaseorder.currency_symbol AS purchaseorder_symbol,ld_sendpayment.sendpayment_no,ld_sendpayment.cpperiodtime, 
ld_sendpayment.plandate,IFNULL(ld_sendpayment.amount,0) as amount,IFNULL(ld_sendpayment.actualamount,0) as Actualamount,ld_sendpayment.actualdate,
ld_sendpayment.sendpaymentid,ld_sendpayment.currency_id AS sendpayment_curid,ld_sendpayment.conversion_rate AS sendpayment_rate,ld_sendpayment.currency_symbol AS sendpayment_symbol from ld_purchaseorder 
inner join ld_users on ld_users.id = ld_purchaseorder.smownerid $owerinner 
left outer join (select * from ld_sendpayment where  deleted=0  and cpstatus<>'已付' ) 
as ld_sendpayment on ld_sendpayment.purchaseorder_id = ld_purchaseorder.purchaseorderid 
";
$page_list_query = "select distinct ld_purchaseorder.purchaseorderid from ld_purchaseorder 
inner join ld_users on ld_users.id = ld_purchaseorder.smownerid $owerinner 
left outer join (select * from ld_sendpayment where  deleted=0  and cpstatus<>'已付'  ) 
as ld_sendpayment on ld_sendpayment.purchaseorder_id = ld_purchaseorder.purchaseorderid ";
if(vtlib_isModuleActive('SendPayment') == false)
{
    $query = "select ld_users.last_name,ld_purchaseorder.purchaseorder_no,ld_purchaseorder.purchaseorderid,ld_purchaseorder.total from ld_purchaseorder 
inner join ld_users on ld_users.id = ld_purchaseorder.smownerid $owerinner ";
	$page_list_query = "select distinct ld_purchaseorder.purchaseorderid from ld_purchaseorder 
inner join ld_users on ld_users.id = ld_purchaseorder.smownerid $owerinner ";
}
$where = ' where ld_purchaseorder.deleted = 0 and ld_purchaseorder.purchaseorderid > 0 ' . $where;//18304: 付款单--新增界面：选择采购订单窗口，按照【采购订单】【付款计划编号】【付款计划日期】【计划金额】【采购金额】查找，无法查找到数据
if(isset($_REQUEST['vendorid']) && $_REQUEST['vendorid'] > 0)
    $where .= " AND ld_purchaseorder.vendorid = " . $_REQUEST['vendorid'];

$noofrows =$adb->num_rows($adb->pquery($query.$where));
$smarty->assign('NUMOFROWS',$noofrows);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

//$deployarray=getSys_deploy(68);
$frommodule=$_REQUEST['frommodule'];
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
$approve_demand=$focus->get_approve_demand_byModule($frommodule);
if($approve_demand==1){
   
    $ApproveModuleStatus=Approve::getApproveModuleInfo();
    if($ApproveModuleStatus[$currentModule]==$currentModule){
        $tabid = getTabid($currentModule);
        $entityarray = getEntitynameInfo($tabid);
        $where .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
    }
}
//edit:can 14885: 付款单>新增,关于选择采购订单的问题;
$order_by='ld_purchaseorder.duedate';
if(vtlib_isModuleActive('SendPayment') == false)
    $order =' ORDER BY '.$order_by;
elseif($order_by){
    $order =" ORDER BY $order_by,ld_purchaseorder.purchaseorderid desc,ld_sendpayment.cpperiodtime asc "; 
}else{
    $order =" ORDER BY ld_purchaseorder.purchaseorderid desc, ld_sendpayment.cpperiodtime asc "; 
}
$page_list_query = $page_list_query . $where . $order;

if(!isset($_REQUEST['vendorid']) || $_REQUEST['vendorid'] <= 0){
    $page_list_query .= ' limit 0,5';
$query = $query.'inner join ('.$page_list_query.') as temp on temp.purchaseorderid = ld_purchaseorder.purchaseorderid'.$where.$order;

$smarty->assign('DSNCOCOTSTP5TQR', 'DSNCOCOTSTP5TQR');
}else{
    $query = $query.'inner join ('.$page_list_query.') as temp on temp.purchaseorderid = ld_purchaseorder.purchaseorderid'.$where.$order;
}

$smarty->assign('NAVI', 'NAVI');

$result = $adb->pquery($query);
$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
$smarty->assign('ACTION','SendCashBillPopup');
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);
$smarty->assign("NAVIGATION", $navigationOutput);
$listview = $focus->getSalesOrderPaymentPlanInfo($module,$query);
$smarty->assign("PARENT_MODULE", vtlib_purify($_REQUEST['parent_module']));
$smarty->assign("LISTHEADER", $listview['listview_header'][0]);
$smarty->assign("LISTENTITY", $listview['listview_entries']);

$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign('MODULE',$_REQUEST['module']);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('ROWSPAN',4);//合并行
if(vtlib_isModuleActive('SendPayment') == false)
	$smarty->assign('TABLEWIDTH',100);
else
	$smarty->assign('TABLEWIDTH',150);
if(!empty($_REQUEST['listall'])){
	$_REQUEST['listval'] = $_REQUEST['listall'];
}
if(isset($_REQUEST['listval']) && $_REQUEST['listval'] > 0)
{
    $id = explode(',', $_REQUEST['listval']);
    $curcashbill = explode('|',$_REQUEST['idstring']);
    $curcashval = explode(',', $curcashbill[0]);
    for($i=0; $i<count($id); $i++)
    {
        $val[] = $id[$i] . ',' . $curcashval[$i];
    }
    $listall = implode('&',$val) . '|' . $curcashbill[1];
}
$smarty->assign('LISTALL',$listall);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
    $smarty->display("CashPopupContents.tpl");
else
    $smarty->display("CashPopup.tpl");
?>