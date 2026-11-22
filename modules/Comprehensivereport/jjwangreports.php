<?php
global $adb,$mod_strings;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['year']))
{
    if(is_int(intval($_REQUEST['year']))==false)
    {
        echo '报表年份错误！';
        exit();
    }
        if($_REQUEST['year']!=''){
        $year = $_REQUEST['year'];
    }else{
        $year = date('Y',time());
    }
}
//print_r($_REQUEST);
$Report_form_query=$_REQUEST['Report_form_query'];
if($Report_form_query == 'true')
{
    $begin_end_date_arr=explode(' ',$_REQUEST['begin_date']);            
    $begin_date=trim($begin_end_date_arr[0]);
    $begin_dates=explode('-',$_REQUEST['begin_date']);
    $begin_month=$begin_dates[1];
    $end_date=trim($begin_end_date_arr[2]);
    $end_dates=explode('-',$end_date);
    $end_month=$end_dates[1];
    $_REQUEST['month']=$end_month;
    $_REQUEST['year']=$end_dates[0];
}
else
{  
    $begin_month=1;$end_month=12;
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01"; 
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);

$cf_1764=getcf_1764();
$Factoryprojectstatus = $_REQUEST['Factoryprojectstatus'];
$smarty->assign("Factoryprojectstatus",$Factoryprojectstatus);
$smarty->assign("cf_1764",$cf_1764);
if($Factoryprojectstatus!=''){
   $FactoryprojectstatusSQL = " and ld_accountscf.cf_1764 = '$Factoryprojectstatus'"; 
}

$sales_stage=getsales_stage();
$sales_stagevalue = $_REQUEST['sales_stagevalue'];
$smarty->assign("sales_stagevalue",$sales_stagevalue);
$smarty->assign("sales_stage",$sales_stage);
if($sales_stagevalue!=''){
   $sales_stagevalueSQL = " and ld_potential.sales_stage = '$sales_stagevalue'"; 
}

$postatus=get_postatus();
$postatusvalue = $_REQUEST['postatusvalue'];
$smarty->assign("postatusvalue",$postatusvalue);
$smarty->assign("postatus",$postatus);
if($postatusvalue!=''){
   $postatusSQL = " and ld_PurchaseOrder.postatus = '$postatusvalue'"; 
}

$cf_1699=getcf_1699();
$cf_1699value = $_REQUEST['cf_1699value'];
$smarty->assign("cf_1699value",$cf_1699value);
$smarty->assign("cf_1699",$cf_1699);
if($cf_1699value!=''){
   $cf_1699SQL = " and ld_salesordercf.cf_1782 = '$cf_1699value'"; 
}

$users=get_users();
$useridc = $_REQUEST['useridc'];
$smarty->assign("useridc",$useridc);
$smarty->assign("users",$users);
if($useridc!=''){
   $useridSQL = " and ld_salesorder.smownerid = '$useridc'"; 
}


$cf_1513value = $_REQUEST['cf_1513'];
$smarty->assign("cf_1513value",$cf_1513value);
if($cf_1513value!=''){
   $cf_1513SQL = " and ld_quotescf.cf_1513 = '$cf_1513value'"; 
}

$cf_1603value = $_REQUEST['cf_1603'];
$smarty->assign("cf_1603value",$cf_1603value);
if($cf_1603value!=''){
   $cf_1603SQL = " and ld_projectcf.cf_1603 = '$cf_1603value'"; 
}

$cf_1604value = $_REQUEST['cf_1604'];
$smarty->assign("cf_1604value",$cf_1604value);
if($cf_1604value!=''){
   $cf_1604SQL = " and ld_projectcf.cf_1604 = '$cf_1604value'"; 
}

$accountnamevalue = $_REQUEST['accountname'];
$smarty->assign("accountnamevalue",$accountnamevalue);
if($accountnamevalue!=''){
   $accountnameSQL = " and ld_products.productname  = '$accountnamevalue'"; 
}
$Projectaddressvalue = $_REQUEST['Projectaddress'];
$smarty->assign("Projectaddressvalue",$Projectaddressvalue);
if($Projectaddressvalue!=''){
   $ProjectaddressSQL = " and ld_accounts.accountname  = '$Projectaddressvalue'"; 
}

$cf_1408=getcf_1408();
$cf_1408value = $_REQUEST['cf_1408value'];
$smarty->assign("cf_1408value",$cf_1408value);
$smarty->assign("cf_1408",$cf_1408);
if($cf_1408value!=''){
   $cf_1408SQL = " and ld_accountscf.cf_1408 = '$cf_1408value'"; 
}

$product = $_REQUEST['product'];
$smarty->assign("product",$product);
if($product!=''){
   $productSQL = " and ld_products.productname = '$product'"; 
}

$projectstatus=getprojectstatus();
$projectstatusvalue = $_REQUEST['projectstatusvalue'];
$smarty->assign("projectstatusvalue",$projectstatusvalue);
$smarty->assign("projectstatus",$projectstatus);
if($projectstatusvalue!=''){
   $projectstatusSQL = " and ld_project.projectstatus = '$projectstatusvalue'"; 
}
$listValue=getsnowbearCsnostofa($ProjectaddressSQL,$begin_date,$end_date,$FactoryprojectstatusSQL,$productSQL,$cf_1408SQL,$sales_stagevalueSQL,$cf_1699SQL,$postatusSQL,$useridSQL,$accountnameSQL,$cf_1513SQL,$cf_1603SQL,$cf_1604SQL,$projectstatusSQL);

function getsnowbearCsnostofa($ProjectaddressSQL,$begin_date,$end_date,$FactoryprojectstatusSQL,$productSQL,$cf_1408SQL,$sales_stagevalueSQL,$cf_1699SQL,$postatusSQL,$useridSQL,$accountnameSQL,$cf_1513SQL,$cf_1603SQL,$cf_1604SQL,$projectstatusSQL){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT 
            ld_project.projectstatus as projectstatus, ld_account.accountid ,ld_salesorder.salesorderid,
            ld_salesorder.salesorder_no AS salesorder_no, 
            ld_account.account_no AS account_no, 
            ld_account.createdtime as createdtime, 
            ld_accountscf.cf_1713 as cf_1713, 
            ld_salesordercf.cf_1782 as cf_1782, 
            ld_users.last_name as last_name, 
            ld_projectcf.cf_1607 as cf_1607, 
            ld_projectcf.cf_1603 as cf_1603, 
            ld_projectcf.cf_1604 as cf_1604, 
            ld_contactdetails.lastname as lastname, 
            CONCAT(ld_contactdetails.mobile,'/',ld_contactdetails.phone) as phone, 
            ld_account.accountname as accountname, 
            ld_accountscf.cf_1408 as cf_1408, 
            ld_products.productcategory as productcategory, 
            ld_products.productname as productname, 
            ld_products.productsheet as productsheet, 
            ld_salesorderdetail.quantity as quantity, 
           	FF1.total as backtotal,
            ld_salesorder.signed_data as signed_data, 
            IFNULL(if(ld_salesorder.currency_id > 1,ld_salesorder.total*ld_salesorder.conversion_rate,ld_salesorder.total),0) as total,
            IFNULL(ld_salesordercf.cf_1535,0) as cf_1535, 
            IFNULL(ld_salesordercf.cf_1536,0) as cf_1536,
            IFNULL(F1.amount,0) as yishou,
            (if(ld_salesorder.currency_id > 1,ld_salesorder.total*ld_salesorder.conversion_rate,ld_salesorder.total)-IFNULL(F1.amount,0)) AS weishou,
            F2.total as kaipiao
            FROM 
            ld_salesorder 
            LEFT JOIN (
            select IFNULL(SUM(ld_salesback.total),0) AS total,ld_salesorder.salesorderid from ld_salesorder
            LEFT JOIN ld_salesback ON ld_salesback.salesorderid=ld_salesorder.salesorderid  
            GROUP BY ld_salesorder.salesorderid
            ) AS FF1 ON FF1.salesorderid=ld_salesorder.salesorderid 
            LEFT JOIN ld_salesback ON ld_salesback.salesorderid=ld_salesorder.salesorderid 
            LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
            LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid 
            LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid 
            LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_salesorder.contactid 
            left JOIN ld_users on ld_users.id=ld_salesorder.smownerid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid = ld_salesorderdetail.id 
            LEFT JOIN ld_project on ld_project.salesorderid=ld_salesorder.salesorderid 
            left join ld_projectcf on ld_projectcf.projectid=ld_project.projectid 
            left JOIN ld_products on ld_products.productid=ld_salesorderdetail.productid 
            LEFT JOIN ld_Potential on ld_potential.potentialid=ld_salesorder.potentialid 
            LEFT JOIN ld_purchaseorder ON ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid
            LEFT JOIN ld_quotescf ON ld_quotesdetail.id = ld_quotescf.quoteid
            LEFT JOIN (
            SELECT SUM(if(ld_cashbill.currency_id > 1,amount*ld_cashbill.conversion_rate,amount)) AS amount,entitytypeid FROM ld_cashbill2paymentplan 
            LEFT JOIN ld_cashbill ON ld_cashbill2paymentplan.CashBillID=ld_cashbill.cashbillid WHERE ld_cashbill.deleted = 0
            GROUP BY entitytypeid
            ) AS F1 ON F1.entitytypeid=ld_salesorder.salesorderid 
            left join (SELECT ld_invoice.salesorderid,if(ld_invoice.currency_id > 1,ld_invoice.total*ld_invoice.conversion_rate,ld_invoice.total) as total 
            FROM ld_invoice where ld_invoice.deleted=0 GROUP BY salesorderid) as F2 
            ON F2.salesorderid=ld_salesorder.salesorderid 
            where ld_salesorder.deleted=0 
            and ld_salesorder.signed_data BETWEEN '$begin_date' AND '$end_date' 
            $FactoryprojectstatusSQL $productSQL $cf_1408SQL $sales_stagevalueSQL $cf_1699SQL $postatusSQL $useridSQL 
            $accountnameSQL $cf_1513SQL $cf_1603SQL $cf_1604SQL $projectstatusSQL  $ProjectaddressSQL
            order by ld_account.createdtime;";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['backtotal'] = $adb->query_result($result, $i, 'backtotal');
        $productList[$i]['accountid'] = $adb->query_result($result, $i, 'accountid');
        $productList[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');
        $productList[$i]['projectstatus'] = $adb->query_result($result, $i, 'projectstatus');
        $productList[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $productList[$i]['account_no'] = $adb->query_result($result, $i, 'account_no');
        $productList[$i]['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList[$i]['cf_1713'] = $adb->query_result($result, $i, 'cf_1713');
        $productList[$i]['cf_1782'] = $adb->query_result($result, $i, 'cf_1782');
        $productList[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList[$i]['cf_1607'] = $adb->query_result($result, $i, 'cf_1607');
        $productList[$i]['cf_1603'] = $adb->query_result($result, $i, 'cf_1603');
        $productList[$i]['cf_1604'] = $adb->query_result($result, $i, 'cf_1604');
        $productList[$i]['lastname'] = $adb->query_result($result, $i, 'lastname');
        $productList[$i]['phone'] = $adb->query_result($result, $i, 'phone');
        $productList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList[$i]['cf_1408'] = $adb->query_result($result, $i, 'cf_1408');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['quantity'] = setNumberFormat($adb->query_result($result, $i, 'quantity'));
        $productList[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $productList[$i]['total'] = setNumberFormat($adb->query_result($result, $i, 'total'));
        $productList[$i]['cf_1535'] = setNumberFormat($adb->query_result($result, $i, 'cf_1535'));
        $productList[$i]['cf_1536'] = setNumberFormat($adb->query_result($result, $i, 'cf_1536'));
        $productList[$i]['yishou'] = setNumberFormat($adb->query_result($result, $i, 'yishou'));
        $productList[$i]['weishou'] = setNumberFormat($adb->query_result($result, $i, 'weishou'));
        $productList[$i]['kaipiao'] = setNumberFormat($adb->query_result($result, $i, 'kaipiao'));
    }
      //print_r($productList);  
    return $productList;
}
function getcf_1764(){
        global $adb; 
    $SQL = 'select cf_1764 from ld_cf_1764 group by cf_1764';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1764');
        }
    return $productList;
}

function getsales_stage(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:03
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('sales_stage');
    $proList = array_values($result_pick);
    return $proList;
        /*global $adb;
    $SQL = 'SELECT sales_stage FROM ld_sales_stage  group by sales_stage';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'sales_stage');
        }
    return $productList;*/
}

function get_postatus(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:28
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('postatus');
    $productList = array_values($result_pick);
    return $productList;
        /*global $adb;
    $SQL = 'select postatus from ld_postatus group by postatus';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'postatus');
        }
    return $productList;*/
}

function get_users(){
        global $adb; 
    $SQL = 'SELECT last_name,id FROM ld_users';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $id=$adb->query_result($result, $i, 'id');
            $productList[$id]= $adb->query_result($result, $i, 'last_name');
        }
    return $productList;
}

function getcf_1699(){
        global $adb; 
    $SQL = 'select cf_1699 from ld_cf_1699 group by cf_1699';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1699');
        }
    return $productList;
}

function getcf_1408(){
        global $adb; 
    $SQL = 'select cf_1408 from ld_cf_1408 group by cf_1408';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1408');
        }
    return $productList;
}

function getprojectstatus(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 11:35
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('projectstatus');
    $productList = array_values($result_pick);
        /*global $adb;
    $SQL = 'select projectstatus from ld_projectstatus group by projectstatus';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'projectstatus');
        }*/
    return $productList;
}
function getcf_1513(){
        global $adb; 
    $SQL = 'select cf_1513 from ld_cf_1513 group by cf_1513';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1513');
        }
    return $productList;
}
function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}

function getthemonth($date)
{
    $firstday = date('Y-m-01', strtotime($date));
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
    return $lastday;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$listValue);
$smarty->display('Comprehensivereport/jjwang.tpl');
exit();
?>