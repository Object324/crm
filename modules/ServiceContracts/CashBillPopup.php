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
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user);
$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
$owerinner = $ScopOfAuthority->getModuleListViewQuery();
if($viewid==0)
    $viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
$category = getParentTab();
if(isset($_REQUEST['module']) && $_REQUEST['module'] != '')
    $module = $_REQUEST['module'];
require_once("modules/$module/$module.php");
$focus = new $module();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
$entityInfo = getEntitynameByModulename($currentModule);
$fieldname = $entityInfo['fieldname'];
$sqlwhere=" WHERE 	ld_servicecontracts.deleted = 0  and (ld_servicecontracts.contract_status <> '已作废' or ld_servicecontracts.contract_status is NULL) ";

    if($_REQUEST['frommodule'] == 'CashBill')//去除已经全部收款单合同（销售或服务)
    {
        $sqlselect = 'IFNULL(T2.amount,0)/ld_servicecontracts.conversion_rate as amounts,IFNULL(ld_servicecontracts.total,0)-IFNULL(ld_servicecontracts.received_amount,0) as isamount,';
        /*$sql = ' left join (select IFNULL(sum(amount),0) as amount,entitytypeid 
        from ld_cashbill2paymentplan group by entitytypeid) as T4 
        on T4.entitytypeid = servicecontractsid ';*/
        
        //$sqlwhere .= ' and (IFNULL(ld_servicecontracts.total,0)-IFNULL(T2.amount,0))>0 ';//经过和luyx讨论，去除大于零的条件
    }
    else if($_REQUEST['frommodule'] == 'Invoice')//去除已经全部开票的合同（销售或服务)
    {
      //  $sqlwhere.= ' and (IFNULL(ld_servicecontracts.total,0)-IFNULL(T1.totalsum,0))>0 ';//经过和luyx讨论，去除大于零的条件
    }
    else if($_REQUEST['frommodule'] == 'Commission')
    {
        $sqlselect = 'IFNULL(T4.amount,0) as amount,IFNULL(ld_servicecontracts.total,0)-IFNULL(ld_servicecontracts.received_amount,0) as isamount,';
        $sql = ' left join (select IFNULL(sum(amount),0) as amount,entitytypeid 
        from ld_commission2payment) as T4 
        on  T4.entitytypeid = servicecontractsid ';
        //$sqlwhere .= ' and (IFNULL(ld_servicecontracts.total,0)-IFNULL(T4.amount,0))>0';//经过和luyx讨论，去除大于零的条件
    }
    else
    {
        $sqlselect = ' 0 as amounts,IFNULL(ld_servicecontracts.total,0) as isamount,';
        $sql=' ';
        $sqlwhere .= ' and IFNULL(ld_servicecontracts.total,0)>0';
    }
    $paymentplanselect='';
    $paymentplanjoin='';
	 //已收金额计算时是否统计未审核的收款单
	$focus = CRMEntity::getInstance('CashBill');
	$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
    if(vtlib_isModuleActive('PaymentPlan')){
        $paymentplanselect = "ld_paymentplan.paymentplan_no,
	ld_paymentplan.Periodtime,
	ld_paymentplan.plandate,
	ld_paymentplan.amount as pamount,
	ld_paymentplan.actualamount,
	ld_paymentplan.paymentplanid,
	ld_paymentplan.currency_id as paymentplan_curid,
	ld_paymentplan.currency_symbol as paymentplan_symbol,
	ld_paymentplan.conversion_rate as paymentplan_rate, ";
      $paymentplanjoin = " LEFT OUTER JOIN (
	SELECT
		paymentplan_no,Periodtime,plandate,amount,actualamount,paymentplanid,entitytypeid,currency_id,currency_symbol,conversion_rate 
	FROM
		ld_paymentplan
	WHERE
		paymentstatus <> '已收' and ld_paymentplan.deleted = 0 and ld_paymentplan.entitytype='ServiceContracts' 
    ) AS ld_paymentplan ON ld_servicecontracts.servicecontractsid = ld_paymentplan.entitytypeid ";
    }
  $focus = CRMEntity::getInstance('ServiceContracts');
  $detailtable=$focus->Detail_table;
$query="
SELECT
	ld_servicecontracts.contract_no,$paymentplanselect
    $sqlselect
	temp.invoice_num,ld_servicecontracts.received_amount,
	ld_servicecontracts.servicecontractsid,
	ld_servicecontracts.due_date,
	ld_servicecontracts.contract_type,
	ld_servicecontracts.total,
	ld_servicecontracts.smownerid,
	ld_servicecontracts.currency_symbol,
	ld_servicecontracts.currency_id,
	ld_servicecontracts.conversion_rate,
	temp.invoicedate,
	ld_salesorder.salesorderid,
	ld_account.accountname,
	IFNULL(totalsum,0) as totalsum,
	IFNULL(T2.amount,0) as amount,
	T2.cashbilldate,
	if(ld_servicecontracts.currency_id > 1,IFNULL(ld_servicecontracts.total,0)/ld_servicecontracts.conversion_rate,IFNULL(ld_servicecontracts.total,0))-IFNULL(totalsum,0) as kaipiaoyue  
FROM
    ld_servicecontracts $paymentplanjoin 
    LEFT JOIN ld_salesorder ON ld_servicecontracts.salesorderid = ld_salesorder.salesorderid 
    LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
    LEFT JOIN (
            	SELECT invoice_num,entitytypeid,invoicedate FROM (SELECT DISTINCT
            		ld_invoicecf.invoice_num,
            		ld_invoicedetail.entitytypeid,
            		ld_invoice.invoicedate
            	FROM
            		ld_invoicecf
                	LEFT JOIN ld_invoice ON ld_invoice.invoiceid = ld_invoicecf.invoiceid
                	LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                	ORDER BY ld_invoice.invoicedate DESC) AS c1 GROUP BY c1.entitytypeid
            ) AS temp ON temp.entitytypeid = ld_servicecontracts.servicecontractsid 
    LEFT JOIN (
                     SELECT 
                        ld_invoice.currency_id, 
                        ld_invoicedetail.entitytypeid,
						if(ld_invoice.currency_id>1,ld_invoice.total*ld_invoice.conversion_rate,ld_invoice.total) as totalsum
                    FROM 
                        ld_invoice LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid 
                        where ld_invoice.deleted = 0 and ld_invoice.invoiceid > 0 GROUP BY entitytypeid
            ) as T1 ON T1.entitytypeid=ld_servicecontracts.servicecontractsid  
    LEFT JOIN 
        (
            select ifnull(sum(if(ld_cashbill.currency_id>1,amount*ld_cashbill.conversion_rate,amount)),0) as amount ,max(cashbilldate) as cashbilldate,entitytypeid from ld_cashbill2paymentplan 
            left  join ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID  where 1 $checkoutstatuswhere 
            GROUP BY entitytypeid
        ) as T2 ON T2.entitytypeid=ld_servicecontracts.servicecontractsid  $sql 
   
    ";

if(isset($_REQUEST['search_text']) && $_REQUEST['search_text'] != '')
{
    $search_field = $_REQUEST['search_field'];
    $search_text = $_REQUEST['search_text'];
    $smarty->assign('SEARCHTXT',$search_text);
    $smarty->assign('SEARCHFIELD',$search_field);
    if($search_field == 'ld_servicecontracts.smownerid')
        $sqlwhere .= " ld_users.last_name like '%$search_text%' ";
    else
        $sqlwhere .= ' and ' . $search_field . ' like ' . "'%".$search_text."%'";
}
$modulearray=array('Contacts','Accounts','Users','ContactRecords','Vendors','VendorContact','VendorContactRecords');
//$deployarray=getSys_deploy(68);
$frommodule=$_REQUEST['frommodule'];
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
$approve_demand=$focus->get_approve_demand_byModule($frommodule);
if($approve_demand==1&&!in_array($currentModule,$modulearray)){
   
    $ApproveModuleStatus=Approve::getApproveModuleInfo();
    if($ApproveModuleStatus[$currentModule]==$currentModule){
        $tabid = getTabid($currentModule);
        $entityarray = getEntitynameInfo($tabid);
        $page_list_query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
        $sqlwhere .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
    }
}
$page_list_query=' select  distinct ld_servicecontracts.servicecontractsid '.substr($query,strpos($query,'FROM')) .$sqlwhere;
if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] > 0)
{
    $smarty->assign('ACCOUNTID',$_REQUEST['accountid']);
    $page_list_query .= "  and  ld_servicecontracts.accountid = " . $_REQUEST['accountid'];//accountid 查询，放入分页中
}
    

$noofrows =$adb->num_rows($adb->pquery($page_list_query));//获取总行数
$smarty->assign('NUMOFROWS',$noofrows);  

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
if($noofrows)
{
	if(!$limit_start_rec) $limit_start_rec = 0;
    $pagecount=$noofrows/$limit_start_rec;
    
    if($limit_start_rec>$pagecount*$limit_start_rec)
    {
        $limit_start_rec=0;
    }
}


$recordListRangeMsg = getRecordRangeMessage($now_result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
$smarty->assign('ACTION','CashBillPopup');
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);
$smarty->assign("NAVIGATION", $navigationOutput);
//edit:can reason:13196:收款单新增界面：选择源单：服务合同，调用服务合同窗口没有关联客户名称显示

 if(vtlib_isModuleActive('PaymentPlan') == true){
    $orderby.=" ORDER BY ld_paymentplan.entitytypeid,ld_paymentplan.paymentplanid,ld_servicecontracts.due_date DESC,ld_paymentplan.plandate ASC ";
    $activepaymentplan='true';
    $smarty->assign('ACTIVESENDPAYMENTPLAN',$activepaymentplan);
 }else{

     $orderby.=" ORDER BY ld_paymentplan.paymentplanid,ld_servicecontracts.due_date DESC ";
 } 
$query=$query." inner join ( $page_list_query  $orderby ) as temppage on temppage.servicecontractsid=ld_servicecontracts.servicecontractsid $orderby";

    if(get_file_address($_REQUEST['module'],'ProductDetails'))
        {
		      $isOrder='yes'; $smarty->assign('NAVI', 'NAVI');
        }
     if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] > 0&&isset($_REQUEST['frommodule'])&&$isOrder=='yes'){
		      $query.=" ";
    }elseif($isOrder=='yes'){
            $query.=" LIMIT 0,5";
            $smarty->assign('DSNCOCOTSTP5TQR', 'DSNCOCOTSTP5TQR');
    }
if($_REQUEST['frommodule']=='Invoice'){
    $listview = getServiceListView2($module,$query,$_REQUEST['frommodule']);
}else{
    $listview = getServiceListView($module,$query,$_REQUEST['frommodule']);
}
//echo $query;echo '<br><br>';
if(vtlib_isModuleActive('PaymentPlan')){
    if($_REQUEST['frommodule']=='Invoice')
        $smarty->assign('ROWSPAN',10);//10:发票选择源单序时簿，非产品列为10列
    else
        $smarty->assign('ROWSPAN',8);//10:非发票选择源单序时簿，非产品列为8列
}else{
    $smarty->assign('ROWSPAN',7);//没有回款计划的序时簿，非产品列为7列
}


$smarty->assign("PARENT_MODULE", vtlib_purify($_REQUEST['parent_module']));
$smarty->assign("LISTHEADER", $listview['listview_header'][0]);
$smarty->assign("LISTENTITY", $listview['listview_entries']);

$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category,'popup');
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);

$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign('MODULE',$_REQUEST['module']);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);

$smarty->assign('FIELDNAME',$fieldname);
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
$smarty->assign('TABLEWIDTH',150);
if(!empty($_REQUEST['listall'])){
	$listall = $_REQUEST['listall'];
}
$smarty->assign('LISTALL',$listall);
$smarty->assign('HAVENOCOLUMN','no');//no：表示弹出框列头没有产品明细
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
    $smarty->display("CashPopupContents.tpl");
else
    $smarty->display("CashPopup.tpl");
//非发票选择源单：如：收款单，佣金单，费用报销 选择 服务合同
function getServiceListView($module,$query,$frommodule)
{
    global $adb;
    require_once("modules/$module/$module.php");
    require_once("modules/SalesOrder/SalesOrder.php");
    $other = new SalesOrder();
    $entityInfo = getEntitynameByModulename($module);
    $fieldname = $entityInfo['fieldname'];
   
    $result = $adb->pquery($query);
    $num_rows = $adb->num_rows($result);
    //列头
    $listview_header[] = array(
        0 => getTranstab($module),  //服务合同
        1 => getFixedLabel('DATEOFCONTRACT'), //签约日期
       // 2 => getFixedLabel('SERVICECONTRACTSTYPE'),   //类型
        2 => getFixedLabel('SALESORDERCONTRACTAMOUNT'),    //合同金额
        3 => getFixedLabel('RECEIVED').getFixedLabel('SLAESORDERTOTAL'), //已收总额
        4 => getFixedLabel('THENEWINVOICEDATE'),   //最近开票日期
        5 => getFixedLabel('INVOICENO'),    //发票号
        6 => getFixedLabel('HASBILLINGAMOUNT'), //开票总额
        7 => getFixedLabel('ISRECEIVABLE').getFixedLabel('BALANCE'),   //应收余额
        8 => getFixedLabel('ASSIGNEDTO'),    //负责人
    );
    if(vtlib_isModuleActive('PaymentPlan') && $frommodule == 'CashBill'){
        array_push($listview_header[0],
        getFixedLabel('Numberofpaymentplans'), //回款计划编号
        getFixedLabel('Stages'), //期次
        getFixedLabel('PAYMENTPLANDATE'), //计划回款日期
        getFixedLabel('AMOUNT'), //金额
        getFixedLabel('amountreceived1')); //已收金额  
    }  
    for($i = 0; $i<$num_rows; $i++)
    {
        $servicecontractsid = $adb->query_result($result,$i,'servicecontractsid');
        $paymentplanid = $adb->query_result($result,$i,'paymentplanid');
		$symbol = $adb->query_result($result,$i,'currency_symbol');//服务合同币种符号
		$payment_symbol = $adb->query_result($result,$i,'paymentplan_symbol');
        if($frommodule == 'CashBill')
            $recordid = $servicecontractsid . ',' . $i . ',' . $paymentplanid;
        else
            $recordid = $servicecontractsid . ',00';
        //$amount = getSumAmount($recordid,$_REQUEST['frommodule']);
        //$isamount = $adb->query_result($result,$i,'total') - $amount;
        //if($isamount == '')
            //$isamount = '0';
        $listview_entries[$recordid][0] = $adb->query_result($result,$i,$fieldname);
        $listview_entries[$recordid][1] = $adb->query_result($result,$i,'due_date');
        //$listview_entries[$recordid][2] = $adb->query_result($result,$i,'contract_type');
        $listview_entries[$recordid][2 . '_N'] = $symbol.setNumberFormat($adb->query_result($result,$i,'total'));
        $listview_entries[$recordid][3 . '_N'] = $symbol.setNumberFormat($adb->query_result($result,$i,'received_amount'));
        $listview_entries[$recordid][4] = $adb->query_result($result,$i,'invoicedate');
        $listview_entries[$recordid][5] = $adb->query_result($result,$i,'invoice_num');
        $listview_entries[$recordid][6 . '_N'] = '¥'.setNumberFormat($adb->query_result($result,$i,'totalsum'));
        $listview_entries[$recordid][7 . '_N'] = $symbol . setNumberFormat($adb->query_result($result,$i,'isamount'));
        $listview_entries[$recordid][8] = getOwnerName($adb->query_result($result,$i,'smownerid'));
        if(vtlib_isModuleActive('PaymentPlan') && $frommodule == 'CashBill'){
            $listview_entries[$recordid][9] = $adb->query_result($result,$i,'paymentplan_no');
            $listview_entries[$recordid][10] = $adb->query_result($result,$i,'periodtime');
            $listview_entries[$recordid][11] = $adb->query_result($result,$i,'plandate');
            $listview_entries[$recordid][12 . '_N'] = $payment_symbol . setNumberFormat($adb->query_result($result,$i,'pamount'));
            $listview_entries[$recordid][13 . '_N'] = $payment_symbol . setNumberFormat($adb->query_result($result,$i,'actualamount'));
        }
    }
    /*
     * $listview_header:序时簿列头
     * getSalesOrderList(序时簿内容,当前页数可为空,序时簿总行数,非回款计划列数)
    */
    return $list = array('listview_header'=>$listview_header,'listview_entries'=>$other->getSalesOrderList($listview_entries,'',$num_rows,8));
}
//发票选择源单：服务合同
function getServiceListView2($module,$query,$frommodule)
{ 
    global $adb;
    require_once("modules/$module/$module.php");
    require_once("modules/SalesOrder/SalesOrder.php");
    $other = new SalesOrder();
    //require_once("modules/SalesOrder/SalesOrder.php");
    //$other = new SalesOrder();
    $entityInfo = getEntitynameByModulename($module);
    $fieldname = $entityInfo['fieldname'];
    $result = $adb->pquery($query);
    
    $num_rows = $adb->num_rows($result);
    //列头
    $listview_header[] = array(
        0 => getTranstab($module),  //服务合同
        1 => getTranstab('AccountName'),//客户
        2 => getFixedLabel('DATEOFCONTRACT'), //签约日期
        //3 => getFixedLabel('SERVICECONTRACTSTYPE'),   //类型
        3 => getFixedLabel('SALESORDERCONTRACTAMOUNT'),    //合同金额
        4 => getFixedLabel('THENEWINVOICEDATE'),   //最近开票日期
        5 => getFixedLabel('HASBILLINGAMOUNT'), //开票总额
        6 => getFixedLabel('Billingbalance'),    //开票余额
        7 => getFixedLabel('LATESTDATEOFRECEIPT'),    //最近收款日期
        8 => getFixedLabel('RECEIVED').getFixedLabel('SLAESORDERTOTAL'), //已收总额
        9 => getFixedLabel('ISRECEIVABLE').getFixedLabel('BALANCE'),   //应收余额
        10 => getFixedLabel('ASSIGNEDTO'),    //负责人
    );
    if(vtlib_isModuleActive('PaymentPlan') && $frommodule == 'CashBill'){
        array_push($listview_header[0],
        getFixedLabel('Numberofpaymentplans'), //回款计划编号
        getFixedLabel('Stages'), //期次
        getFixedLabel('PAYMENTPLANDATE'), //计划回款日期
        getFixedLabel('AMOUNT'), //金额
        getFixedLabel('amountreceived1')); //已收金额  
    }
    for($i = 0; $i<$num_rows; $i++)
    {
        $servicecontractsid = $adb->query_result($result,$i,'servicecontractsid');
        $paymentplanid = $adb->query_result($result,$i,'paymentplanid');
		$service_symbol = $adb->query_result($result,$i,'currency_symbol');//服务合同币种符号
		$service_curid = $adb->query_result($result,$i,'currency_curid');
		$service_rate = $adb->query_result($result,$i,'conversion_rate');
		$service_total = $adb->query_result($result,$i,'total'); //服务合同金额
		$service_amount = $adb->query_result($result,$i,'amount');//已收金额
        if($paymentplanid == '')$paymentplanid = 0;
        if($frommodule == 'CashBill')
            $recordid = $servicecontractsid . ',' . $i . ',' . $paymentplanid;
        else
            $recordid = $servicecontractsid . '';//22410: 销售发票新增界面：选择源单-服务合同，选择后提示：未找到任何记录
        $listview_entries[$recordid][0] = $adb->query_result($result,$i,$fieldname);
        $listview_entries[$recordid][1] = $adb->query_result($result,$i,'accountname');
        $listview_entries[$recordid][2] = $adb->query_result($result,$i,'due_date');
        $listview_entries[$recordid][3 . '_N'] = $service_symbol.setNumberFormat($service_total);
        $listview_entries[$recordid][4] = $adb->query_result($result,$i,'invoicedate');
        $listview_entries[$recordid][5 . '_N'] = '¥'.setNumberFormat($adb->query_result($result,$i,'totalsum'));
        $listview_entries[$recordid][6 . '_N'] = '¥'.setNumberFormat($adb->query_result($result,$i,'kaipiaoyue'));
        $listview_entries[$recordid][7] = $adb->query_result($result,$i,'cashbilldate');
        $listview_entries[$recordid][8 . '_N'] = '¥'.setNumberFormat($service_amount);
		if($service_curid == 1)
			$isamount = $service_total - $service_amount;
		else
			$isamount = $service_total - $service_amount/$service_rate;
        $listview_entries[$recordid][9 . '_N'] = $service_symbol.setNumberFormat($isamount);
        $listview_entries[$recordid][10] = getOwnerName($adb->query_result($result,$i,'smownerid'));
       if(vtlib_isModuleActive('PaymentPlan') && $frommodule == 'CashBill'){
            $listview_entries[$recordid][11] = $adb->query_result($result,$i,'paymentplan_no');
            $listview_entries[$recordid][12] = $adb->query_result($result,$i,'periodtime');
            $listview_entries[$recordid][13] = $adb->query_result($result,$i,'plandate');
            $listview_entries[$recordid][14 . '_N'] = setNumberFormat($adb->query_result($result,$i,'pamount'));
            $listview_entries[$recordid][15 . '_N'] = setNumberFormat($adb->query_result($result,$i,'actualamount'));
        }
    }
    /*
     * $listview_header:序时簿列头
     * getSalesOrderList(序时簿内容,当前页数可为空,序时簿总行数,非回款计划列数)
    */
    return $list = array('listview_header'=>$listview_header,'listview_entries'=>$other->getSalesOrderList($listview_entries,'',$num_rows,10));

}
function getSumAmount($servicecontractsid,$frommodule)
{
    global $adb;
    if($frommodule == 'CashBill')
    {
        $sql = "select ifnull(sum(amount),0) as amount from ld_cashbill2paymentplan where entitytypeid = ?";
    }
    else if($frommodule == 'Commission')
    {
        $sql = "select ifnull(sum(amount),0) as amount from ld_commission2payment where entitytypeid = ?";
    }
    else
    {
        return '0';
    }
    $result = $adb->pquery($sql,array($servicecontractsid));
    return $adb->query_result($result,0,0);
}
?>