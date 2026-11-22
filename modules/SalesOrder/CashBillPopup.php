<?php

require_once(globalStatic ::$root_directory."include/Popup/PopUpListView.php");

global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user;
global $list_max_entries_per_page_new;
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}

$smarty=new lingdangCRM_Smarty; 
$smarty->assign("LANGUAGETYPE",$languageType);
$popuplistview=new PopUpListView();
$customView = new CustomView($currentModule);
$instance = CRMEntity::getInstance($currentModule);
$search_text = '';
$search_field = '';
$listall = 0;
$viewid=0;
if($_REQUEST['viewname']){
    $viewid = $_REQUEST['viewname'];
}
if($_REQUEST['search_field'] == 'ld_paymentplan.periodtime'){
    $sqlPayment = ' and '.$_REQUEST['search_field'] . '=' . "'".$_REQUEST['search_text']."'";
}
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user);
$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
$owerinner = $ScopOfAuthority->getModuleListViewQuery();
$tabid = getTabid($currentModule);
if($viewid==0)
    $viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
$category = getParentTab();
if(isset($_REQUEST['module']) && $_REQUEST['module'] != '')
    $module = $_REQUEST['module'];
require_once("modules/$module/$module.php");
$focus = new $module();

$entitynameSalesOrder=getEntitynameByModulename('SalesOrder');
$fieldnameSalesOrder=$entitynameSalesOrder['fieldname'];
$entitynameAccounts=getEntitynameByModulename('Accounts');
$fieldnameAccounts=$entitynameAccounts['fieldname'];  

require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');
/* editor:gyqX160711 reason: 0023536 ld_salesorder.sostatus增加ifnull判断，否则值为null时对应记录被过滤 date:20160711 */
$sqlwhere="WHERE  ld_salesorder.deleted = 0 and ifnull(ld_salesorder.sostatus,'') <> \"已作废\"  $owerinner";
$query = "
select
 distinct	ld_paymentplan.paymentstatus,
	ld_account.$fieldnameAccounts as accountname,
	ld_users.last_name,
	ld_salesorder.salesorderid,
	ld_salesorder.$fieldnameSalesOrder as salesorder_no,
	ld_salesorder.total,
	ld_salesorder.signed_data AS duedate,
	ld_salesorder.currency_id,
	ld_salesorder.conversion_rate,
	ld_salesorder.currency_symbol,
	if(ld_salesorder.currency_id > 1,samount/ld_salesorder.conversion_rate,samount) as samount,
	ld_paymentplan.paymentplan_no,
	ld_paymentplan.Periodtime,
	ld_paymentplan.plandate,
	ld_paymentplan.amount,
	ld_paymentplan.actualamount,
	ld_paymentplan.paymentplanid,
	ld_paymentplan.currency_symbol as paymentplan_symbol,
	ld_paymentplan.currency_id as paymentplan_curid,
	ld_paymentplan.conversion_rate as paymentplan_rate,
	invoice.invoice_num,
	invoice.invoicedate,
	T3.cashbilldate,
	totalsum,
    IFNULL(ld_salesorder.received_amount,0) as amounttotal,
	IFNULL(ld_salesorder.total,0)-IFNULL(totalsum,0) as kaipiaoyue,
	( IFNULL(ld_salesorder.total,0)-IFNULL(received_amount,0) )as yinshouyue
FROM
	ld_salesorder
INNER JOIN ld_users ON ld_users.id = ld_salesorder.smownerid 
left join ld_tabshare on ld_tabshare.crmid = ld_salesorder.salesorderid 
LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid $owerinner 
LEFT OUTER JOIN (
	SELECT
		paymentstatus,paymentplan_no,Periodtime,plandate,amount,actualamount,paymentplanid,entitytypeid,currency_id,currency_symbol,conversion_rate 
	FROM
		ld_paymentplan
	WHERE
		paymentstatus <> '已收' and ld_paymentplan.deleted = 0 $sqlPayment
) AS ld_paymentplan ON ld_salesorder.salesorderid = ld_paymentplan.entitytypeid
LEFT OUTER JOIN (
	SELECT invoice_num,invoicedate,entitytypeid FROM 
	(SELECT DISTINCT
		ld_invoicedetail.entitytypeid,
		ld_invoice.invoice_no,
		ld_invoice.invoicedate,
		ld_invoicecf.invoice_num
	FROM
		ld_invoice
	INNER JOIN ld_invoicedetail ON ld_invoice.invoiceid = ld_invoicedetail.id
	INNER JOIN ld_invoicecf ON ld_invoicecf.invoiceid = ld_invoice.invoiceid
	ORDER BY
		ld_invoice.invoicedate DESC) as c1 GROUP BY c1.entitytypeid
) AS invoice ON ld_salesorder.salesorderid = invoice.entitytypeid 
LEFT JOIN (
	SELECT  c2.cashbilldate,entitytypeid FROM (SELECT ld_cashbill2paymentplan.entitytypeid,cashbilldate FROM ld_cashbill   
				inner join ld_cashbill2paymentplan on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
	ORDER BY
		ld_cashbill.cashbilldate DESC) as c2 GROUP BY c2.entitytypeid
) as T3 ON T3.entitytypeid=ld_salesorder.salesorderid
left join (
	SELECT SUM(if(ld_cashbill.currency_id > 1,amount/ld_cashbill.conversion_rate,amount)) as samount,entitytypeid FROM ld_cashbill2paymentplan
	LEFT JOIN ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.cashbillid 
	LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid 
	GROUP BY ld_cashbill2paymentplan.entitytypeid 
) as F1 on F1.entitytypeid=ld_salesorder.salesorderid
LEFT JOIN (
select sum(if(ld_invoice.currency_id > 1,ld_invoice.total/ld_invoice.conversion_rate,ld_invoice.total)) as totalsum,entitytypeid from ld_invoice
					inner join 
						(select id,entitytypeid from ld_invoicedetail  group by id) 
						as temp on temp.id = ld_invoice.invoiceid 
				where ld_invoice.deleted = 0 and ld_invoice.invoiceid > 0 GROUP BY entitytypeid
) as T1 ON T1.entitytypeid=ld_salesorder.salesorderid ";
/*
LEFT JOIN (
select sum(IFNULL(ld_cashbill2paymentplan.amount,0)) as amounttotal ,entitytypeid 
					from ld_cashbill2paymentplan 
				inner join ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
				inner join ld_salesorder on ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid 
					where  ld_cashbill.deleted = 0 
					 GROUP BY entitytypeid
) AS T2 ON T2.entitytypeid=ld_salesorder.salesorderid ";*/

//edit:can reason:10909: 【销售发票】、【佣金单】：选择源单【合同订单】选择时，合同订单的回款计划明细应该不用显示。
if(vtlib_isModuleActive('PaymentPlan') == false||$_REQUEST['frommodule']=='Commission'||$_REQUEST['frommodule']=='Invoice')
{
      
   $query = "
    select distinct ld_account.accountname,ld_users.last_name,ld_salesorder.salesorderid,ld_salesorder.signed_data as duedate,
    ld_salesorder.salesorder_no,ld_salesorder.total,
    invoice.invoice_no,invoice.invoicedate,ld_salesorder.currency_id,
	ld_salesorder.conversion_rate,
	ld_salesorder.currency_symbol,
    	totalsum,T2.cashbilldate,
    IFNULL(ld_salesorder.received_amount,0) as amounttotal,
	(IFNULL(ld_salesorder.total,0)-IFNULL(ld_salesorder.received_amount,0)) as yinshouyue,
    IFNULL(ld_salesorder.total,0)-IFNULL(totalsum,0)/ld_salesorder.conversion_rate as kaipiaoyue  
    FROM ld_salesorder inner join 
    ld_users on ld_users.id = ld_salesorder.smownerid 
	left join ld_tabshare on ld_tabshare.crmid = ld_salesorder.salesorderid 
    inner join ld_account on ld_account.accountid = ld_salesorder.accountid $owerinner left outer join 
    (
    select * from (select distinct ld_invoicedetail.entitytypeid,ld_invoice.invoice_no,ld_invoice.invoicedate 
    from ld_invoice inner join 
    ld_invoicedetail on ld_invoice.invoiceid = ld_invoicedetail.id 
    order by ld_invoice.invoicedate desc ) as C1 group by C1.entitytypeid
    ) 
    as invoice on ld_salesorder.salesorderid = invoice.entitytypeid 
    
    LEFT JOIN (
    select max(ld_cashbill.cashbilldate) as cashbilldate,entitytypeid 
    					from ld_cashbill2paymentplan 
    				inner join ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
    				inner join ld_salesorder on ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid 
    					where  ld_cashbill.deleted = 0  
    						GROUP BY entitytypeid
    ) AS T2 ON T2.entitytypeid=ld_salesorder.salesorderid  LEFT JOIN (
                SELECT sum(if(ld_invoice.currency_id > 1,ld_invoice.total/ld_invoice.conversion_rate,ld_invoice.total)) AS totalsum ,
    	               	entitytypeid
    	       FROM
                    ld_invoice
                	left  JOIN  ld_invoicedetail 
                    on ld_invoicedetail.id=ld_invoice.invoiceid
    				where ld_invoice.deleted = 0 and ld_invoice.invoiceid > 0 GROUP BY entitytypeid
    ) as T1 ON T1.entitytypeid=ld_salesorder.salesorderid  "; 
}
if(isset($_REQUEST['search_text']) && $_REQUEST['search_text'] != '')
{
    $search_field = $_REQUEST['search_field'];
    $search_text = $_REQUEST['search_text'];
    $smarty->assign('SEARCHTXT',$search_text);
    $smarty->assign('SEARCHFIELD',$search_field);
	$entityname = getEntitynameInfo($tabid);
    if($search_field == 'ld_salesorder.salesorderid')
        $sqlwhere .= " and ld_salesorder.".$entityname['fieldname']." like '%$search_text%' ";
    else if($search_field == 'ld_salesorder.smownerid')
        $sqlwhere .= " and ld_users.last_name like '%$search_text%'";
    else if($search_field == 'invoice.invoice_no'||$search_field == 'ld_account.accountname')
        $sqlwhere .= " and $search_field like '%$search_text%'";
    else
        $sqlwhere .= ' and '.$search_field . '=' . "'".$search_text."'";
}
$modulearray=array('Contacts','Accounts','Users','ContactRecords','Vendors','VendorContact','VendorContactRecords');
//$deployarray=getSys_deploy(68);
$frommodule=$_REQUEST['frommodule'];
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
$approve_demand=$focus->get_approve_demand_byModule($frommodule);
if($approve_demand==1&&!in_array($currentModule,$modulearray)){
    $ApproveModuleStatus=Approve::getApproveModuleInfo();
    if($ApproveModuleStatus[$currentModule]==$currentModule){
        $entityarray = getEntitynameInfo($tabid);
        $page_list_query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
        $sqlwhere .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
    }
}
if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] > 0){
    $sqlwhere .= " AND ld_salesorder.accountid = " . $_REQUEST['accountid'];
	$smarty->assign('ACCOUNTID',$_REQUEST['accountid']);
}

$page_list_query=' select  distinct ld_salesorder.salesorderid '.substr($query,strpos($query,'FROM')) .$sqlwhere;
if($_REQUEST['frommodule']=='Commission'||$_REQUEST['frommodule']=='Invoice'){
    $orderby.=" ORDER BY  ld_salesorder.signed_data DESC ";
}else{
    if(vtlib_isModuleActive('PaymentPlan') == false)
    $orderby.=" ORDER BY ld_salesorder.signed_data DESC,ld_salesorder.salesorderid desc  ";
    else{
    $activepaymentplan='true';
    $smarty->assign('ACTIVESENDPAYMENTPLAN',$activepaymentplan);
        //15044: 收款单>新增,关于选择合同订单的问题,salesorderid的排列顺序一定不能动，edit：can
    $orderby.=" ORDER BY ld_salesorder.signed_data DESC,ld_salesorder.salesorderid desc,ld_paymentplan.plandate,ld_paymentplan.Periodtime asc";

    }
}
//echo $page_list_query;
$noofrows =$adb->num_rows($adb->pquery($page_list_query));
$smarty->assign('NUMOFROWS',$noofrows);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
if($noofrows)
{
	$pagecount=0;
	if($limit_start_rec > 0)
	    $pagecount=$noofrows/$limit_start_rec;
    
    if($limit_start_rec>$pagecount*$limit_start_rec)
    {
        $limit_start_rec=0;
    }
}



    if(get_file_address($_REQUEST['module'],'ProductDetails'))
        {
		      $isOrder='yes';
              $smarty->assign('NAVI', 'NAVI');
        }
     if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] > 0&&isset($_REQUEST['frommodule'])&&$isOrder=='yes'){
        $query=$query." inner join ( $page_list_query $orderby ) as temppage on temppage.salesorderid=ld_salesorder.salesorderid $orderby";
		     // $query.=" ";
    }elseif($isOrder=='yes'){
        $query=$query." inner join ( $page_list_query  $orderby LIMIT 0,5) as temppage on temppage.salesorderid=ld_salesorder.salesorderid $orderby";
            //$query.=" LIMIT 0,5";
            $smarty->assign('DSNCOCOTSTP5TQR', 'DSNCOCOTSTP5TQR');
    }     
//echo "<br><br>";
//echo $query;
$result = $adb->pquery($query,array());
$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
$smarty->assign('ACTION','CashBillPopup');
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);
$smarty->assign("NAVIGATION", $navigationOutput);
$frommodule = $_REQUEST['frommodule'];

if($frommodule=='Invoice'||$frommodule=='Commission'){
    $listview = $focus->getSalesOrderInvoiceInfo($module,$query);//列头和内容
}else{
    $listview = $focus->getSalesOrderPaymentPlanInfo($module,$query);//列头和内容
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
$smarty->assign('ROWSPAN',9);//合并行
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
if(isset($_REQUEST['listall']))
	$smarty->assign('LISTALL',$_REQUEST['listall']);
else
	$smarty->assign('LISTALL',$listall);
$smarty->assign('HAVENOCOLUMN','no');//列头是否有产品列（nO:没有,yes:有)
$smarty->assign('TABLEWIDTH',150);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
    $smarty->display("CashPopupContents.tpl");
else
    $smarty->display("CashPopup.tpl");
?>