<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
require_once('include/utils/UserInfoUtil.php');
$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
    if(is_int(intval($_REQUEST['year']))==false)
    {
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
}
$ProductDanwei=$_REQUEST['ProductDanwei'];
$ProductCategories=$_REQUEST['ProductCategories'];
$accounttype = getaccounttype();
$smarty->assign("accounttype",$accounttype);
if($ProductDanwei!=''){
$ProductDanweiSQL = " AND ld_account.accountname like '%$ProductDanwei%' ";
$smarty->assign("ProductDanwei",$ProductDanwei);
}
if($ProductCategories!=''){
$whereProductCategoriesSQL = " AND ld_products.productcategory like '%$ProductCategories%' ";
$smarty->assign("ProductCategories",$ProductCategories);
}
$AccountNumber = getReport($year,$month,'',$ProductDanweiSQL,$whereProductCategoriesSQL);
$AccountNumberALL = getReport($year,$month,'all',$ProductDanweiSQL,$whereProductCategoriesSQL);
$productidList = getProduct($year,$month,$whereProductCategoriesSQL,$ProductDanweiSQL);
$accountList = getAccount($year,$month,$ProductDanweiSQL,$whereProductCategoriesSQL);
//print_r($AccountNumber);

foreach($AccountNumber as $key=>$arr){
    foreach($arr['pro'] as $key2=>$arr2){
        foreach($productidList['LIST'] as $key3=>$arr3){
            if($AccountNumber[$key]['pro'][$key3]['countorder']){
            //echo $key3.'-'.$key2."<br>";
            }else{
              //  echo $key3.'-'.$key2."<br>";
                $AccountNumber[$key]['pro'][$key3]['productname']=$arr3;
                $AccountNumber[$key]['pro'][$key3]['countorder']='0.00';
                $AccountNumber[$key]['pro'][$key3]['ALLcountorder']='0.00';
            }
        }
            ksort($AccountNumber[$key]['pro']);
    }
}
//print_r($AccountNumber);
//主搜索方法
function getReport($year,$month,$type='',$ProductDanweiSQL,$whereProductCategoriesSQL){
    global $adb;
  
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT F1.*,F2.countorder AS ALLcountorder,F2.Alltotal FROM (
            SELECT ld_account.accountid,ld_account.accountname,ld_accountscf.cf_1257,
            SUM(ld_salesorderdetail.quantity) AS countorder,
            ld_salesorderdetail.productid,
            SUM(ld_salesorderdetail.quantity*ld_salesorderdetail.listprice) AS total,concat(ld_products.productname,ld_products.productsheet) as productname
            FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid
            LEFT JOIN ld_accountscf ON ld_account.accountid=ld_accountscf.accountid 
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
            WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_account.deleted=0 AND YEAR(signed_data)='$year' $ProductDanweiSQL $whereProductCategoriesSQL 
            GROUP BY ld_account.accountid,ld_accountscf.cf_1257,ld_salesorderdetail.productid
            ORDER BY ld_account.accountid,ld_accountscf.cf_1257,ld_salesorderdetail.productid 
            ) AS F1 LEFT JOIN (
            SELECT ld_account.accountname,ld_accountscf.cf_1257,SUM(ld_salesorderdetail.quantity) AS countorder,
            SUM(ld_salesorderdetail.quantity*ld_salesorderdetail.listprice) AS Alltotal,ld_products.productname
            FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid
            LEFT JOIN ld_accountscf ON ld_account.accountid=ld_accountscf.accountid 
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
            WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_account.deleted=0 AND ld_products.deleted=0  AND YEAR(signed_data)='$year'
            AND MONTH(signed_data)='$month' $ProductDanweiSQL $whereProductCategoriesSQL
            GROUP BY ld_account.accountid,ld_accountscf.cf_1257,ld_salesorderdetail.productid 
            ORDER BY ld_account.accountid,ld_accountscf.cf_1257,ld_salesorderdetail.productid) AS F2 ON 
            F1.accountname=F2.accountname AND F1.cf_1257=F2.cf_1257 AND F1.productname=F2.productname);";
     //echo $SQL;      
      $adb->pquery($SQL,array());
     $SQL = "select * from TempTable";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $uid = $adb->query_result($result, $i, 'accountid');
        $userNumberList[$uid]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $userNumberList[$uid]['cf_1257'] = $adb->query_result($result, $i, 'cf_1257');
        $userNumberList[$uid]['total'] = number_format($adb->query_result($result, $i, 'total'),2);
        $userNumberList[$uid]['Alltotal'] = number_format($adb->query_result($result, $i, 'alltotal'),2);
        $productid = $adb->query_result($result, $i, 'productid');
        $userNumberList[$uid]['pro'][$productid]['countorder'] = number_format($adb->query_result($result, $i, 'countorder'),2);
        $userNumberList[$uid]['pro'][$productid]['ALLcountorder'] = number_format($adb->query_result($result, $i, 'allcountorder'),2);
        $userNumberList[$uid]['pro'][$productid]['productname'] = $adb->query_result($result, $i, 'productname');

    }
            if($type!=''){
            unset($userNumberList);
            $SQL = "SELECT DISTINCT productname,SUM(countorder) AS quantity,SUM(total) AS total,
            productid,SUM(ALLcountorder) AS newcount,SUM(Alltotal) AS allcount 
            FROM TempTable GROUP BY productid ORDER BY productid";
            $result3=$adb->pquery($SQL,array());
            $rowCount2 = $adb->num_rows($result3);
            for ($g = 0; $g < $rowCount2; $g++) {    
                $uid = 0;
                //$userNumberList['total'] = number_format($adb->query_result($result3, $g, 'total'),2);
                //$userNumberList['allcount'] = number_format($adb->query_result($result3, $g, 'allcount'),2);
                $productid = $adb->query_result($result3, $g, 'productid');
                $userNumberList['pro'][$productid]['allcount'] = number_format($adb->query_result($result3, $g, 'newcount'),2);
                $userNumberList['pro'][$productid]['quantity'] = number_format($adb->query_result($result3, $g, 'quantity'),2);
            }
            $SQL = "SELECT DISTINCT productname,SUM(total) AS total,
            productid,SUM(Alltotal) AS allcount 
            FROM TempTable ORDER BY productid";
            $result4=$adb->pquery($SQL,array());
            $userNumberList['total'] = number_format($adb->query_result($result4, 0, 'total'),2);
            $userNumberList['allcount'] = number_format($adb->query_result($result4, 0, 'allcount'),2);
    //print_r($userNumberList);
        }
        
    $sSQL5="drop TEMPORARY  table if exists TempTable;";
    $result1 = $adb->query($sSQL5); 
    return $userNumberList;
}
function getaccounttype(){
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $proList = array_values($result_pick);
    return $proList;

   /* global $adb;
    $SQL = "SELECT productcategory FROM ld_productcategory";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'productcategory');
    }
    
    return $proList;*/
}

function getProduct($year,$month,$whereProductCategoriesSQL,$ProductDanweiSQL){
    global $adb;
    $SQL = "SELECT ld_salesorderdetail.productid, concat(ld_products.productname,ld_products.productsheet) as productname
                FROM ld_salesorder 
                LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
                LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid 
                LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
                WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_products.deleted=0 AND ld_salesorderdetail.productid<>''  
                $where AND YEAR(signed_data)='$year' $whereProductCategoriesSQL $ProductDanweiSQL
                GROUP BY ld_salesorderdetail.productid ORDER BY ld_salesorderdetail.productid";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $productid = $adb->query_result($result, $i, 'productid');
        $productidList['LIST'][$productid]= $adb->query_result($result, $i, 'productname');
    }
    $productidList['COUNT']=$rowCount;
    return $productidList;
}

function getAccount($year,$month,$ProductDanweiSQL,$whereProductCategoriesSQL){
    global $adb;

    $SQL = "SELECT ld_salesorder.accountid, ld_account.accountname,cf_1257
            FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
            LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid 
            WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_account.deleted=0 AND YEAR(signed_data)=$year AND MONTH(signed_data)=$month 
            $ProductDanweiSQL $whereProductCategoriesSQL
            GROUP BY ld_salesorder.accountid ORDER BY ld_salesorder.accountid;";
                //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $accountid = $adb->query_result($result, $i, 'accountid');
        $accountList[$accountid]['accountname']= $adb->query_result($result, $i, 'accountname');
        $accountList[$accountid]['cf_1257']= $adb->query_result($result, $i, 'cf_1257');
    }
    return $accountList;
    
}


$smarty->assign("AccountNumberALL",$AccountNumberALL);
$smarty->assign("ACCOUNTLIST",$accountList);
$smarty->assign("COUNT",$productidList['COUNT']);
$smarty->assign("PRODUCTIDLIST",$productidList['LIST']);
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("roleList",$AccountNumber);
$smarty->display('Comprehensivereport/youchuangReports2.tpl');
exit();
?>