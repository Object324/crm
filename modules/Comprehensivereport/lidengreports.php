<?php
global $adb,$mod_strings;
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

$invoicedate = $_REQUEST['invoicedate'];
$smarty->assign("invoicedatevalue",$invoicedate);
if($invoicedate!=''){
   $invoicedateSQL = " and month(ld_invoice.invoicedate) = '$invoicedate'"; 
}

$users=get_users();
$useridc = $_REQUEST['useridc'];
$smarty->assign("useridc",$useridc);
$smarty->assign("users",$users);
if($useridc!=''){
   $useridSQL = " and ld_salesorder.smownerid = '$useridc'"; 
}

$cf_1450 = $_REQUEST['cf_1450'];
$smarty->assign("cf_1450value",$cf_1450);
if($cf_1450!=''){
   $cf_1450SQL = " and ld_salesordercf.cf_1450 = '$cf_1450'"; 
}

$accountname = $_REQUEST['accountname'];
$smarty->assign("accountnamevalue",$accountname);
if($accountname!=''){
   $accountnameSQL = " and ld_account.accountname like '%$accountname%'"; 
}

$cf_1447=getcf_1447();
$cf_1447value = $_REQUEST['cf_1447value'];
$smarty->assign("cf_1447value",$cf_1447value);
$smarty->assign("cf_1447",$cf_1447);
if($cf_1447value!=''){
   $cf_1447SQL = " and ld_productcf.cf_1447 = '$cf_1447value'"; 
}

$productcategory=getproductcategory();
$productcategoryvalue = $_REQUEST['productcategoryvalue'];
$smarty->assign("productcategoryvalue",$productcategoryvalue);
$smarty->assign("productcategory",$productcategory);
if($productcategoryvalue!=''){
   $productcategoryvalueSQL = " and ld_products.productcategory = '$productcategoryvalue'"; 
}

$productname = $_REQUEST['productname'];
$smarty->assign("productnamevalue",$productname);
if($productname!=''){
   $productnameSQL = " and ld_products.productname like '%$productname%'"; 
}


$listValue=getsnowbearCsnostofa($begin_date,$end_date,$invoicedateSQL,$useridSQL,$cf_1450SQL,$accountnameSQL,$cf_1447SQL,$productcategoryvalueSQL,$productnameSQL);

function getsnowbearCsnostofa($begin_date,$end_date,$invoicedateSQL,$useridSQL,$cf_1450SQL,$accountnameSQL,$cf_1447SQL,$productcategoryvalueSQL,$productnameSQL){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT 
            month(ld_invoice.invoicedate) AS invoicedate, 
            ld_salesorder.salesorderid, 
            ld_salesorder.signed_data AS signed_data, 
            ld_users.last_name AS last_name, 
            ld_salesordercf.cf_1450 AS cf_1450, 
            ld_account.accountname AS accountname, 
            ld_contactdetails.lastname AS lastname, 
            ld_accountscf.cf_1448 AS cf_1448, 
            ld_productcf.cf_1447 AS cf_1447, 
            ld_products.productcategory AS productcategory, 
            ld_products.productname AS productname, 
            ld_products.productsheet AS productsheet, 
            format( 
            ld_salesorderdetail.quantity, 
            2 
            ) AS quantity, 
            format( 
            ld_salesorderdetail.taxprice, 
            2 
            ) AS taxprice, 
            format( 
            format( 
            ld_salesorderdetail.quantity, 
            2 
            ) * format( 
            ld_salesorderdetail.taxprice, 
            2 
            ), 
            2 
            ) AS taxpricetotal, 
            format( 
            format( 
            ld_salesorderdetail.quantity, 
            2 
            ) * format( 
            ld_salesorderdetail.taxprice, 
            2 
            ) / 1.17, 
            2 
            ) AS notaxpricetotal, 
            ld_purchaseorder.vendorname AS vendorname, 
            format( 
            ld_purchaseorder.taxprice, 
            2 
            ) AS taxpricejingjia, 
            format( 
            format( 
            ld_purchaseorder.taxprice, 
            2 
            ) * format( 
            ld_salesorderdetail.quantity, 
            2 
            ), 
            2 
            ) AS amountjinghuo, 
            ld_stock.createdate AS createdate, 
            ld_cashbill.cashbilldate AS cashbilldate, 
            format(ld_cashbill.amount, 2) AS cashbillamount, 
            format( 
            ld_salesorder.total - ifnull(ld_cashbill.amount, 0), 
            2 
            ) AS weishouamount, 
            format( 
            ( 
            ( 
            ld_salesorderdetail.taxprice - ifnull( 
            ld_purchaseorder.taxprice, 
            0 
            ) 
            ) * ld_salesorderdetail.quantity 
            ) / 1.17, 
            2 
            ) AS maoli, 
            format( 
            ( 
            ld_salesorderdetail.taxprice - ifnull( 
            ld_purchaseorder.taxprice, 
            0 
            ) 
            ) / ld_salesorderdetail.taxprice * 100, 
            2 
            ) AS 'GM' 
            FROM 
            ld_salesorder 
            LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
            LEFT JOIN ( 
            SELECT DISTINCT 
            ld_invoice.invoicedate, 
            ld_invoicedetail.entitytypeid 
            FROM 
            ld_invoice 
            LEFT JOIN ld_invoicedetail ON ld_invoice.invoiceid = ld_invoicedetail.id 
            WHERE 
            ld_invoice.deleted = 0 
            ) AS ld_invoice ON ld_invoice.entitytypeid = ld_salesorder.salesorderid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid = ld_salesorderdetail.id 
            LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid 
            LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_salesorder.accountid 
            LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid 
            LEFT JOIN ld_productcf ON ld_productcf.productid = ld_salesorderdetail.productid 
            LEFT JOIN ( 
            SELECT 
            ld_purchaseorder.purchaseorderid, 
            ld_vendor.vendorname, 
            ld_purchaseorderdetail.taxprice, 
            ld_purchaseorderdetail.entitytypeid, 
            ld_purchaseorderdetail.productid 
            FROM 
            ld_purchaseorder 
            LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorder.purchaseorderid = ld_purchaseorderdetail.id 
            LEFT JOIN ld_vendor ON ld_vendor.vendorid = ld_purchaseorder.vendorid 
            WHERE 
            ld_purchaseorder.deleted = 0 
            ) AS ld_purchaseorder ON ld_purchaseorder.entitytypeid = ld_salesorder.salesorderid 
            LEFT JOIN ( 
            SELECT DISTINCT 
            ld_stock.createdate, 
            ld_stockdetail.entitytypeid 
            FROM 
            ld_stock 
            LEFT JOIN ld_stockdetail ON ld_stock.stock_id = ld_stockdetail.id 
            WHERE 
            ld_stock.deleted = 0 
            ) AS ld_stock ON ld_stock.entitytypeid = ld_purchaseorder.purchaseorderid 
            LEFT JOIN ( 
            SELECT 
            max(ld_cashbill.cashbilldate) AS cashbilldate, 
            sum( 
            ld_cashbill2paymentplan.amount 
            ) AS amount, 
            ld_cashbill2paymentplan.entitytypeid 
            FROM 
            ld_cashbill 
            LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID 
            WHERE 
            ld_cashbill.deleted = 0 
            GROUP BY 
            ld_cashbill2paymentplan.entitytypeid 
            ) AS ld_cashbill ON ld_cashbill.entitytypeid = ld_salesorder.salesorderid 
            LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_salesorder.contactid 
            LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid 
            WHERE 
            ld_salesorder.deleted = 0 and ld_salesorder.signed_data BETWEEN '$begin_date' AND '$end_date' $invoicedateSQL 
            $useridSQL $cf_1450SQL $accountnameSQL $cf_1447SQL $productcategoryvalueSQL $productnameSQL; 
            ;";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['invoicedate'] = $adb->query_result($result, $i, 'invoicedate');
        $productList[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $productList[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList[$i]['cf_1450'] = $adb->query_result($result, $i, 'cf_1450');
        $productList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList[$i]['lastname'] = $adb->query_result($result, $i, 'lastname');
        $productList[$i]['cf_1448'] = $adb->query_result($result, $i, 'cf_1448');
        $productList[$i]['cf_1447'] = $adb->query_result($result, $i, 'cf_1447');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['quantity'] = $adb->query_result($result, $i, 'quantity');
        $productList[$i]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
        $productList[$i]['taxpricetotal'] = $adb->query_result($result, $i, 'taxpricetotal');
        $productList[$i]['notaxpricetotal'] = $adb->query_result($result, $i, 'notaxpricetotal');
        $productList[$i]['vendorname'] = $adb->query_result($result, $i, 'vendorname');
        $productList[$i]['taxpricejingjia'] = $adb->query_result($result, $i, 'taxpricejingjia');
        $productList[$i]['amountjinghuo'] = $adb->query_result($result, $i, 'amountjinghuo');
        $productList[$i]['createdate'] = $adb->query_result($result, $i, 'createdate');
        $productList[$i]['cashbilldate'] = $adb->query_result($result, $i, 'cashbilldate');
        $productList[$i]['cashbillamount'] = setNumberFormat($adb->query_result($result, $i, 'cashbillamount'));
        $productList[$i]['weishouamount'] = $adb->query_result($result, $i, 'weishouamount');
        $productList[$i]['maoli'] = setNumberFormat($adb->query_result($result, $i, 'maoli'));
        $productList[$i]['GM'] = setNumberFormat($adb->query_result($result, $i, 'gm'));
    }
      //print_r($productList);  
    return $productList;
}

function getproductcategory(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 9:41
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $productList = array_values($result_pick);
        /*global $adb;
    $SQL = 'SELECT productcategory FROM ld_productcategory  group by productcategory';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'productcategory');
        }*/
    return $productList;
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

function getcf_1447(){
        global $adb; 
    $SQL = 'select cf_1447 from ld_cf_1447 group by cf_1447';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1447');
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
$smarty->display('Comprehensivereport/lideng.tpl');
exit();
?>