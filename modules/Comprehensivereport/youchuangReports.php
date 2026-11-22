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




$AccountNumber = getReport($year,$month);
$AccountNumberALL = getReport($year,$month,'all');
$productidList = getProduct($year,$month);
$accountList = getAccount($year,$month);
//print_r($AccountNumber);

foreach($AccountNumber as $key=>$arr){
    foreach($arr['pro'] as $key2=>$arr2){
        foreach($productidList['LIST'] as $key3=>$arr3){
            if($AccountNumber[$key]['pro'][$key3]['quantity']){
            //echo $key3.'-'.$key2."<br>";
            }else{
              //  echo $key3.'-'.$key2."<br>";
                $AccountNumber[$key]['pro'][$key3]['productname']=$arr3;
                $AccountNumber[$key]['pro'][$key3]['quantity']='0.00';
                $AccountNumber[$key]['pro'][$key3]['total']='0.00';
            }
        }
            ksort($AccountNumber[$key]['pro']);
    }
}
//print_r($AccountNumber);
//主搜索方法
function getReport($year,$month,$type){
    global $adb;
    if($month!=0){
        $where=" AND MONTH(signed_data)=$month";
    }
    else{
        $month=1;
    }
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT ld_users.id,ld_users.last_name,SUM(ld_salesorderdetail.quantity) AS quantity,
            SUM(ld_salesorderdetail.quantity*ld_salesorderdetail.listprice) AS total,
            concat(ld_products.productname,ld_products.productsheet) as productname,ld_salesorderdetail.productid,IFNULL(F1.newcount,0) AS newcount,IFNULL(F2.allcount,0) AS allcount
            FROM ld_salesorder 
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
            LEFT JOIN ld_users ON ld_salesorder.smownerid=ld_users.id 
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
            LEFT JOIN (SELECT COUNT(DISTINCT ld_account.accountid) AS newcount,ld_account.smownerid FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
            WHERE ld_salesorder.accountid NOT IN 
            (SELECT ld_salesorder.accountid FROM ld_salesorder WHERE signed_data<'$year-$month-01') 
            $where AND YEAR(signed_data)='$year'  GROUP BY ld_salesorder.smownerid ORDER BY signed_data) 
            AS F1 ON F1.smownerid=ld_salesorder.smownerid 
            LEFT JOIN (SELECT COUNT(DISTINCT ld_account.accountid) AS allcount,ld_account.smownerid FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
            GROUP BY ld_salesorder.smownerid ORDER BY signed_data) 
            AS F2 ON F2.smownerid=ld_salesorder.smownerid
            WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废'  AND ld_products.deleted=0 
             $where AND YEAR(signed_data)='$year'
            GROUP BY ld_salesorder.smownerid,ld_salesorderdetail.productid)";
            
     $adb->pquery($SQL,array());
     $SQL = "select * from TempTable";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $uid = $adb->query_result($result, $i, 'id');
        $userNumberList[$uid]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $userNumberList[$uid]['newcount'] = number_format($adb->query_result($result, $i, 'newcount'),2);
        $userNumberList[$uid]['allcount'] = number_format($adb->query_result($result, $i, 'allcount'),2); 
        $productid = $adb->query_result($result, $i, 'productid');
        $userNumberList[$uid]['pro'][$productid]['quantity'] = number_format($adb->query_result($result, $i, 'quantity'),2);
        $userNumberList[$uid]['pro'][$productid]['total'] = number_format($adb->query_result($result, $i, 'total'),2);
        $userNumberList[$uid]['pro'][$productid]['productname'] = $adb->query_result($result, $i, 'productname');

    }

        if($type!=''){
            unset($userNumberList);
            $SQL = "SELECT SUM(quantity) AS quantity,SUM(total) AS total,productid,SUM(newcount) AS newcount,SUM(allcount) AS allcount,productname 
            FROM TempTable GROUP BY productid ORDER BY productid";
            $result3=$adb->pquery($SQL,array());
            $rowCount2 = $adb->num_rows($result3);
            for ($g = 0; $g < $rowCount2; $g++) {    
                $uid = 0;
                $userNumberList['newcount'] = number_format($adb->query_result($result3, $g, 'newcount'),2);
                $userNumberList['allcount'] = number_format($adb->query_result($result3, $g, 'allcount'),2); 
                $productid = $adb->query_result($result3, $g, 'productid');
                $userNumberList['pro'][$productid]['quantity'] = number_format($adb->query_result($result3, $g, 'quantity'),2);
                $userNumberList['pro'][$productid]['total'] = number_format($adb->query_result($result3, $g, 'total'),2);
                $userNumberList['pro'][$productid]['productname'] = $adb->query_result($result3, $g, 'productname');
            }
    //print_r($userNumberList);
        }

        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
    return $userNumberList;
}

function getProduct($year,$month){
    global $adb;
    if($month!=0){
        $where=" AND MONTH(signed_data)=$month";
    }
    $SQL = "SELECT ld_salesorderdetail.productid, concat(ld_products.productname,ld_products.productsheet) as productname
                FROM ld_salesorder 
                LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
                LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid 
                WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_products.deleted=0 AND ld_salesorderdetail.productid<>''  
                $where AND YEAR(signed_data)='$year'
                GROUP BY ld_salesorderdetail.productid ORDER BY ld_salesorderdetail.productid";
                //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $productid = $adb->query_result($result, $i, 'productid');
        $productidList['LIST'][$productid]= $adb->query_result($result, $i, 'productname');
    }
    $productidList['COUNT']=$rowCount;
    return $productidList;
}

function getAccount($year,$month){
    global $adb;
    if($month!=0){
        $where=" AND MONTH(signed_data)=$month";
    }
    $SQL = "SELECT ld_salesorder.smownerid, ld_users.last_name
                FROM ld_salesorder 
                LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
                WHERE ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' AND ld_users.deleted=0 $where AND YEAR(signed_data)='$year'
                GROUP BY ld_salesorder.smownerid ORDER BY ld_salesorder.smownerid;";
                //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $accountid = $adb->query_result($result, $i, 'smownerid');
        $accountList[$accountid]= $adb->query_result($result, $i, 'last_name');
    }
    return $accountList;
    
}


$smarty->assign("AccountNumberALL",$AccountNumberALL);
$smarty->assign("ACCOUNTLIST",$accountList);
$smarty->assign("COUNT",$productidList['COUNT']+2);
$smarty->assign("PRODUCTIDLIST",$productidList['LIST']);
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("roleList",$AccountNumber);
$smarty->display('Comprehensivereport/youchuangReports.tpl');
exit();
?>