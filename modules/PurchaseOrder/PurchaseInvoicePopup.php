<?php

global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user;
global $list_max_entries_per_page_new;
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}

$smarty=new lingdangCRM_Smarty; 
$smarty->assign("LANGUAGETYPE",$languageType);

$search_text = '';
$search_field = '';
$listall = 0;


$category = getParentTab();
if(isset($_REQUEST['module']) && $_REQUEST['module'] != '')
    $module = $_REQUEST['module'];
require_once("modules/$module/$module.php");
$focus = new $module();

$smarty->assign('PURCHASESMOWNERLABLE',$focus->fieldobj->getFieldInfoBykeyValue('columnname','smownerid','fieldlabel'));
$entitynamePurchaseOrder=getEntitynameByModulename('PurchaseOrder');
$fieldnamePurchaseOrder=$entitynamePurchaseOrder['fieldname'];
$entitynameAccounts=getEntitynameByModulename('Vendors');
$fieldnameAccounts=$entitynameAccounts['fieldname'];  

require('user_privileges/user_privileges_'.$current_user->id.'.php');

if($_REQUEST['search_field'] == 'ld_sendpayment.cpperiodtime'){
    $sqlPayment = ' and '.$_REQUEST['search_field'] . '=' . "'".$_REQUEST['search_text']."'";
}

if(vtlib_isModuleActive('SendPayment') == false||$_REQUEST['frommodule']=='PurchaseInvoice')
{
   $query = "
    select ld_vendor.vendorname,ld_users.last_name,ld_purchaseorder.purchaseorderid,ld_purchaseorder.signed_data as duedate,
    ld_purchaseorder.PurchaseOrder_no,ld_purchaseorder.total, 
    invoice.purchaseinvoice_no,invoice.purchaseinvoicedate,ld_purchaseorder.currency_symbol,
    	totalsum,
    IFNULL(amounttotal,0) as amounttotal,
	IFNULL(ld_purchaseorder.total,0)-IFNULL(totalsum,0)/ld_purchaseorder.conversion_rate as kaipiaoyue,
	IFNULL(ld_purchaseorder.total,0)-IFNULL(amounttotal,0)/ld_purchaseorder.conversion_rate as yinshouyue,
	T2.sendcashbilldate  
    from ld_purchaseorder 
    LEFT OUTER JOIN (
	SELECT
	   ld_sendpayment.purchaseorder_id,Plandate,Sendpayment_no,CPPeriodtime
	FROM
		ld_sendpayment
	WHERE
		CPStatus <> '已付' and ld_sendpayment.deleted = 0 $sqlPayment 
         GROUP BY ld_sendpayment.purchaseorder_id
    ) AS ld_sendpayment ON ld_purchaseorder.purchaseorderid = ld_sendpayment.purchaseorder_id 
    left join 
    ld_users on ld_users.id = ld_purchaseorder.smownerid
    left join ld_vendor on ld_vendor.vendorid = ld_purchaseorder.vendorid 
    LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_purchaseorder.purchaseorderid
    left outer join 
    (
    select * from (select distinct ld_purchaseinvoicedetail.entitytypeid,ld_purchaseinvoice.purchaseinvoice_no,ld_purchaseinvoice.purchaseinvoicedate 
    from ld_purchaseinvoice inner join 
    ld_purchaseinvoicedetail on ld_purchaseinvoice.purchaseinvoiceid = ld_purchaseinvoicedetail.id 
	where ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoicestatus <> \"已作废\" 
    order by ld_purchaseinvoice.purchaseinvoicedate desc ) as C1 group by C1.entitytypeid
    ) 
    as invoice on ld_purchaseorder.purchaseorderid = invoice.entitytypeid 
    LEFT JOIN (
select sum(if(ld_sendcashbill.currency_id > 1,IFNULL(ld_sendcashbill2payment.amount,0)/ld_sendcashbill.conversion_rate,IFNULL(ld_sendcashbill2payment.amount,0))) as amounttotal ,
		max(ld_sendcashbill.cashbilldate) as sendcashbilldate,
		ld_sendcashbill2payment.purchaseorder_id 
					from ld_sendcashbill2payment 
				inner join ld_sendcashbill on ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid 
				inner join ld_purchaseorder on ld_purchaseorder.purchaseorderid = ld_sendcashbill2payment.purchaseorder_id 
					where  ld_sendcashbill.deleted = 0 and ld_sendcashbill.sendcashbillid > 0 
					
						GROUP BY ld_sendcashbill2payment.purchaseorder_id 
						order by ld_sendcashbill.cashbilldate asc
) AS T2 ON T2.purchaseorder_id=ld_purchaseorder.purchaseorderid 
LEFT JOIN (
select sum(if(ld_purchaseinvoice.currency_id>1,ld_purchaseinvoice.total*ld_purchaseinvoice.conversion_rate,ld_purchaseinvoice.total)) as totalsum,entitytypeid from ld_purchaseinvoice
					inner join 
						(select id,entitytypeid from ld_purchaseinvoicedetail  group by id) 
						as temp on temp.id = ld_purchaseinvoice.purchaseinvoiceid 
				where ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoiceid > 0 GROUP BY entitytypeid
) as T1 ON T1.entitytypeid=ld_purchaseorder.purchaseorderid 
    where ld_purchaseorder.deleted = 0  and ld_purchaseorder.postatus <> \"已作废\"  and ld_purchaseorder.purchaseorderid > 0 
    "; 
}
/**
* @author andrew
* @data 2015-5-19
* @param $ApproveModuleStatus 模块是否开启审批
* @param $deployarray 系统参数设置--关联单据只能选择已审批单据 0：否，1：是
* @param $modulearray 不需要判断的模块
* @param $entityarray 模块信息
*/
$modulearray=array('Contacts','Accounts','Users','ContactRecords','Vendors','VendorContact','VendorContactRecords');
//$deployarray=getSys_deploy(68);
$frommodule=$_REQUEST['frommodule'];
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
$approve_demand=$focus->get_approve_demand_byModule($frommodule);
if($approve_demand==1&&!in_array($currentModule,$modulearray)){
    require_once('modules/Approve/Approve.php');
    $ApproveModuleStatus=Approve::getApproveModuleInfo();
    if($ApproveModuleStatus[$currentModule]==$currentModule){
        $tabid = getTabid($currentModule);
        $entityarray = getEntitynameInfo($tabid);
        $page_list_query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
        $query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
    }
}


if(isset($_REQUEST['search_text']) && $_REQUEST['search_text'] != '')
{
    $search_field = $_REQUEST['search_field'];
    $search_text = $_REQUEST['search_text'];
    $smarty->assign('SEARCHTXT',$search_text);
    $smarty->assign('SEARCHFIELD',$search_field);
    if($search_field == 'ld_purchaseOrder.purchaseorderid')
        $query .= " and ld_purchaseorder.purchaseorder_no like '%$search_text%' ";
    else if($search_field == 'ld_purchaseorder.smownerid')
        $query .= " and ld_users.last_name like '%$search_text%'";
    else if($search_field == 'invoice.invoice_no')
        $query .= " and $search_field like '%$search_text%'";
    else
        $query .= ' and '.$search_field . '=' . "'".$search_text."'";
}
if(isset($_REQUEST['vendor_id']) && $_REQUEST['vendor_id'] > 0){
    $query .= " AND ld_purchaseorder.vendorid = " . $_REQUEST['vendor_id'];
	$smarty->assign('VENDORID',$_REQUEST['vendor_id']);
}
if($current_user->is_admin != 'on'){
	$scopeobj = new ScopOfAuthority($adb,$module);
	if(!empty($scopeobj)){
		$query .= $scopeobj->getSmOwnerSearchSql();	
	}
}
if($_REQUEST['frommodule']=='PurchaseInvoice'){
    $query.=" ORDER BY  ld_purchaseorder.signed_data DESC ";
}else{
    if(vtlib_isModuleActive('SendPayment') == false){
            $query.=" ORDER BY ld_purchaseorder.signed_data DESC ";
    }
    else{
            $query.=" ORDER BY ld_purchaseorder.signed_data DESC,ld_sendpayment.cpperiodtime asc";
    }

}

if(vtlib_isModuleActive('SendPayment') == true){
    $activeSendpayment='true';
    $smarty->assign('ACTIVESENDPAYMENT',$activeSendpayment);
}
//echo $query;echo '<br><br>';
$noofrows =$adb->num_rows($adb->pquery($query));
$smarty->assign('NUMOFROWS',$noofrows);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
if($noofrows)
{
	if($limit_start_rec > 0)
		$pagecount=$noofrows/$limit_start_rec;
	else
		$pagecount = 0;
    
    if($limit_start_rec>$pagecount*$limit_start_rec)
    {
        $limit_start_rec=0;
    }
}
//如果选择供应商不限制条数
if(!isset($_REQUEST['vendor_id']) || $_REQUEST['vendor_id'] < 0){
    $query.= ' limit 5 ';
    $smarty->assign('DSNCOCOTSTP5TQR','DSNCOCOTSTP5TQR');//只显示判断显示5条提示
}

// $query .= ' limit '.$limit_start_rec.','.$list_max_entries_per_page_new.' ';
//echo $query;
$result = $adb->pquery($query,array());
$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
$smarty->assign('ACTION','PurchaseInvoicePopup');
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);
$smarty->assign("NAVIGATION", $navigationOutput);
$frommodule = $_REQUEST['frommodule'];
if($frommodule=='PurchaseInvoice'){
    $listview = $focus->getPurchaseOrderInvoiceInfo($module,$query);//列头和内容

}else{
    $listview = $focus->getPurchaseOrderSendPayment($module,$query);//列头和内容
}

$smarty->assign("PARENT_MODULE", vtlib_purify($_REQUEST['parent_module']));
$smarty->assign("LISTHEADER", $listview['listview_header'][0]);
$smarty->assign("LISTENTITY", $listview['listview_entries']);
//$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category,'popup');
//$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);

$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign('MODULE',$_REQUEST['module']);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('ROWSPAN',7);//合并行
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
//产品行总函数
if(isset($_REQUEST['rowcnt']) && $_REQUEST['rowcnt'] > 0)
    $smarty->assign('ROWCNT',$_REQUEST['rowcnt']);
else
    $smarty->assign('ROWCNT',0);
$smarty->assign('LISTALL',$listall);
$smarty->assign('HAVENOCOLUMN','no');//列头是否有产品列（nO:没有,yes:有)

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
    $smarty->display("PosendcashbillPopupContents.tpl");
else
    $smarty->display("PosendcashbillPopup.tpl");
?>