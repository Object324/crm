<?php
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['accountid']))
{
    if(is_int(intval($_REQUEST['accountid']))==false)
    {
        echo '立项号错误';
        exit();
    }
}

$accountid = $_REQUEST['accountid'];
$salesorderid = $_REQUEST['salesorderid'];
$listValue=getsnowbearCsnostofa($accountid);
$PotentialsValue=getPotentials($accountid);
$quotesValue = getquotes($accountid);
$salesorderValue=getsalesorder($accountid,$salesorderid);
$ProjectValue= getProject($accountid);
$SalesBackValue=getSalesBack($accountid);
$PurchaseOrder=getPurchaseOrder($accountid);
$OutboundOrder=getOutboundOrder($accountid);
$HelpDesk=getHelpDesk($accountid);
$CashBill=getCashBill($accountid);

function getCashBill($accountid){
    global $adb; 
    $SQL = "SELECT cashbilldate,paymentmethod,Total FROM ld_cashbill 
            LEFT JOIN ld_cashbillscf ON ld_cashbill.cashbillid=ld_cashbillscf.cashbillid
            LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.cashbillid=ld_cashbill.cashbillid 
            WHERE ld_cashbill.accountid=$accountid and ld_cashbill.deleted=0";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['cashbilldate'] = $adb->query_result($result, $i, 'cashbilldate');
        $productList['paymentmethod'] = $adb->query_result($result, $i, 'paymentmethod');
        $productList['Total'] = $adb->query_result($result, $i, 'total');
        $productList['count'] = $rowCount;
    }
    return $productList;
}

function getHelpDesk($accountid){
    global $adb; 
    $SQL = "SELECT ld_users.last_name,ld_troubletickets.createdtime,ld_account.accountname,
            cf_1667,cf_1669,cf_1670,cf_1668,hopetime,cf_1793,cf_1794,cf_1678,realtime,cf_1795,cf_1796 
            FROM ld_troubletickets 
            LEFT JOIN ld_ticketcf ON ld_ticketcf.ticketid=ld_troubletickets.ticketid
            LEFT JOIN ld_users ON ld_users.id=ld_troubletickets.smcreatorid 
            LEFT JOIN ld_account ON ld_account.accountid=ld_troubletickets.accountid
            WHERE ld_troubletickets.accountid=$accountid and ld_troubletickets.deleted=0 ORDER BY createdtime DESC LIMIT 1";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList['cf_1667'] = $adb->query_result($result, $i, 'cf_1667');
        $productList['cf_1669'] = $adb->query_result($result, $i, 'cf_1669');
        $productList['cf_1670'] = $adb->query_result($result, $i, 'cf_1670');
        $productList['cf_1668'] = $adb->query_result($result, $i, 'cf_1668');
        $productList['hopetime'] = $adb->query_result($result, $i, 'hopetime');
        $productList['cf_1793'] = $adb->query_result($result, $i, 'cf_1793');
        $productList['cf_1794'] = $adb->query_result($result, $i, 'cf_1794');
        $productList['cf_1678'] = $adb->query_result($result, $i, 'cf_1678');
        $productList['realtime'] = $adb->query_result($result, $i, 'realtime');
        $productList['cf_1795'] = $adb->query_result($result, $i, 'cf_1795');
        $productList['cf_1796'] = $adb->query_result($result, $i, 'cf_1796');
    }
    return $productList;
}
function getOutboundOrder($accountid){
    global $adb; 
    $SQL = "SELECT ld_products.productid as out_id,ld_warehouse.name,cf_1430,cf_1791,cf_1545,cf_1546,ld_products.productname,productsheet,usageunit,quantity
						FROM ld_outboundorder 
            LEFT JOIN ld_outboundordercf ON ld_outboundordercf.out_id=ld_outboundorder.out_id 
						LEFT JOIN ld_warehouse ON ld_warehouse.id=ld_outboundorder.wareid
            LEFT JOIN ld_outboundorderdetail ON ld_outboundorder.out_id=ld_outboundorderdetail.id 
            LEFT JOIN ld_products ON ld_products.productid=ld_outboundorderdetail.productid
            WHERE ld_outboundorder.accountid=$accountid and ld_outboundorder.deleted=0";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['name'] = $adb->query_result($result, $i, 'name');
        $productList['cf_1430'] = $adb->query_result($result, $i, 'cf_1430');
        $productList['cf_1791'] = $adb->query_result($result, $i, 'cf_1791');
        $productList['cf_1545'] = $adb->query_result($result, $i, 'cf_1545');
        $productList['cf_1546'] = $adb->query_result($result, $i, 'cf_1546');
        $out_id = $adb->query_result($result, $i, 'out_id');
        $productList['rowCount'] = $rowCount;
        $productList['pro'][$out_id]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList['pro'][$out_id]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList['pro'][$out_id]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $productList['pro'][$out_id]['quantity'] = $adb->query_result($result, $i, 'quantity');
    }
    if($rowCount==0){
       $productList['rowCount']=1; 
    }
    return $productList;
}    
function getPurchaseOrder($accountid){
    global $adb; 
    $SQL = "SELECT ld_products.productid as purchaseorderid,ld_purchaseorder.createdtime,subject,cf_1378,cf_1589,cf_1790,
    ld_products.productname,productsheet,usageunit,quantity
     FROM ld_purchaseorder 
            LEFT JOIN ld_purchaseordercf ON ld_purchaseorder.purchaseorderid=ld_purchaseordercf.purchaseorderid 
            LEFT JOIN ld_outboundorderdetail ON ld_purchaseorder.purchaseorderid=ld_outboundorderdetail.id 
            LEFT JOIN ld_products ON ld_products.productid=ld_outboundorderdetail.productid
            WHERE ld_purchaseorder.accountid=$accountid and ld_purchaseorder.deleted=0";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['subject'] = $adb->query_result($result, $i, 'subject');
        $productList['cf_1378'] = $adb->query_result($result, $i, 'cf_1378');
        $productList['cf_1589'] = $adb->query_result($result, $i, 'cf_1589');
        $productList['cf_1790'] = $adb->query_result($result, $i, 'cf_1790');
        $purchaseorderid = $adb->query_result($result, $i, 'purchaseorderid');
        $productList['rowCount'] = $rowCount;
        $productList['pro'][$purchaseorderid]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList['pro'][$purchaseorderid]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList['pro'][$purchaseorderid]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $productList['pro'][$purchaseorderid]['quantity'] = $adb->query_result($result, $i, 'quantity');
    }
    if($rowCount==0){
       $productList['rowCount']=1; 
    }
    return $productList;
}    
function getSalesBack($accountid){
    global $adb; 
    $SQL = "SELECT ld_salesback.createdtime,last_name,cf_1716,cf_1717,ld_salesback.modifiedtime,ld_products.productid as salesbackid,
        ld_products.productname,productsheet,usageunit,quantity,
        ld_salesback.total,taxprice
            FROM ld_salesback
            LEFT JOIN ld_users ON ld_users.id=ld_salesback.smcreatorid
            LEFT JOIN ld_salesbackscf ON ld_salesback.salesbackid=ld_salesbackscf.salesbackid
            LEFT JOIN ld_salesbackdetail ON ld_salesback.salesbackid=ld_salesbackdetail.id 
            LEFT JOIN ld_products ON ld_products.productid=ld_salesbackdetail.productid
            WHERE ld_salesback.accountid=$accountid and ld_salesback.deleted=0";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList['cf_1716'] = $adb->query_result($result, $i, 'cf_1716');
        $productList['cf_1717'] = $adb->query_result($result, $i, 'cf_1717');
        $productList['modifiedtime'] = $adb->query_result($result, $i, 'modifiedtime');
        $salesbackid = $adb->query_result($result, $i, 'salesbackid');
        $productList['rowCount'] = $rowCount;
        $productList['pro'][$salesbackid]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList['pro'][$salesbackid]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList['pro'][$salesbackid]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $productList['pro'][$salesbackid]['quantity'] = $adb->query_result($result, $i, 'quantity');
        $productList['pro'][$salesbackid]['total'] = $adb->query_result($result, $i, 'total');
        $productList['pro'][$salesbackid]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
    }
    if($rowCount==0){
       $productList['rowCount']=1; 
    }
    return $productList;
}
function getsnowbearCsnostofa($accountid){
    global $adb; 
    $SQL = "SELECT DISTINCT account_no,ld_account.createdtime,ld_contactdetails2.lastname as lastname2,companyname,cf_1424,ld_users.last_name,cf_1699,ld_users2.last_name as last_name2,
            ld_contactdetails.lastname,ld_contactdetails2.pphone,
            CONCAT(bill_country,bill_state,bill_city,cf_1569,'路',cf_1571,'弄',cf_1573,'之弄',cf_1577,'室',cf_1575,'号') as
             address,
            ld_contactdetails.mobile,cf_1400,accountname,cf_1746,cf_1713,cf_1408,cf_1402,cf_1414,cf_1416,cf_1721
            FROM ld_account 
            LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid 
            LEFT JOIN ld_users ON id=ld_account.smcreatorid
            LEFT JOIN ld_users AS ld_users2 ON ld_users2.id=ld_account.smownerid 
            LEFT JOIN ld_salesorder ON ld_account.accountid=ld_salesorder.accountid 
            LEFT JOIN ld_contactdetails AS ld_contactdetails2 ON ld_contactdetails2.accountid=ld_account.accountid 
            LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid=ld_salesorder.contactid WHERE ld_account.accountid=$accountid  
            and ld_account.deleted=0  
            ;";
           // echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList['account_no'] = $adb->query_result($result, $i, 'account_no');
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['companyname'] = $adb->query_result($result, $i, 'companyname');
        $productList['lastname2'] = $adb->query_result($result, $i, 'lastname2');
        $productList['cf_1746'] = $adb->query_result($result, $i, 'cf_1746');
        $productList['pphone'] = $adb->query_result($result, $i, 'pphone');
        $productList['cf_1424'] = $adb->query_result($result, $i, 'cf_1424');
        $productList['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList['cf_1699'] = $adb->query_result($result, $i, 'cf_1699');
        $productList['last_name2'] = $adb->query_result($result, $i, 'last_name2');
        $productList['lastname'] = $adb->query_result($result, $i, 'lastname');
        $productList['mobile'] = $adb->query_result($result, $i, 'mobile');
        $productList['cf_1400'] = $adb->query_result($result, $i, 'cf_1400');
        $productList['address'] = $adb->query_result($result, $i, 'address');
        $productList['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList['cf_1713'] = $adb->query_result($result, $i, 'cf_1713');
        $productList['cf_1408'] = $adb->query_result($result, $i, 'cf_1408');
        $productList['cf_1402'] = $adb->query_result($result, $i, 'cf_1402');
        $productList['cf_1414'] = $adb->query_result($result, $i, 'cf_1414');
        $productList['cf_1416'] = $adb->query_result($result, $i, 'cf_1416');
        $productList['cf_1721'] = $adb->query_result($result, $i, 'cf_1721');
        
    }
      //print_r($productList);  
    return $productList;
}
function getPotentials($accountid){
    global $adb; 
    $SQL = "SELECT potentialtype,Competitors,cf_1731,cf_1732,cf_1735,cf_1736,cf_1738,cf_1737,
    cf_1778,cf_1780,cf_1779,cf_1781 FROM ld_Potential 
    LEFT JOIN ld_potentialscf ON ld_potential.potentialid=ld_potentialscf.potentialid 
    where ld_Potential.accountid=$accountid and ld_Potential.deleted=0;";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['potentialtype'] = $adb->query_result($result, $i, 'potentialtype');
        $productList['Competitors'] = $adb->query_result($result, $i, 'Competitors');
        $productList['cf_1731'] = $adb->query_result($result, $i, 'cf_1731');
        $productList['cf_1732'] = $adb->query_result($result, $i, 'cf_1732');
        $productList['cf_1735'] = $adb->query_result($result, $i, 'cf_1735');
        $productList['cf_1736'] = $adb->query_result($result, $i, 'cf_1736');
        $productList['cf_1737'] = $adb->query_result($result, $i, 'cf_1737');
        $productList['cf_1738'] = $adb->query_result($result, $i, 'cf_1738');
        $productList['cf_1778'] = $adb->query_result($result, $i, 'cf_1778');
        $productList['cf_1780'] = $adb->query_result($result, $i, 'cf_1780');
        $productList['cf_1779'] = $adb->query_result($result, $i, 'cf_1779');
        $productList['cf_1781'] = $adb->query_result($result, $i, 'cf_1781');
    }
    return $productList;
}

function getquotes($accountid){
    global $adb; 
    $SQL = "SELECT createdtime,cf_1513,cf_1508,cf_1514,cf_1720 FROM ld_quotes 
            LEFT JOIN ld_quotescf ON ld_quotes.quoteid=ld_quotescf.quoteid 
            WHERE accountid=$accountid and ld_quotes.deleted=0 ORDER BY createdtime DESC LIMIT 1";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['cf_1513'] = $adb->query_result($result, $i, 'cf_1513');
        $productList['cf_1508'] = $adb->query_result($result, $i, 'cf_1508');
        $productList['cf_1514'] = $adb->query_result($result, $i, 'cf_1514');
        $productList['cf_1720'] = $adb->query_result($result, $i, 'cf_1720');
    }
    return $productList;
}
function getProject($accountid){
    global $adb; 
    $SQL = "SELECT cf_1740,cf_1608,cf_1607,cf_1609,cf_1604,cf_1603,cf_1611,
    cf_1783,cf_1619,cf_1620,cf_1787,cf_1622,cf_1623,cf_1788,cf_1613,cf_1614,cf_1617,cf_1786,cf_1805,cf_1806 FROM ld_project 
            LEFT JOIN ld_projectcf ON ld_projectcf.projectid=ld_project.projectid 
            WHERE accountid=$accountid and deleted=0";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $productList['cf_1740'] = $adb->query_result($result, $i, 'cf_1740');
        $productList['cf_1608'] = $adb->query_result($result, $i, 'cf_1608');
        $productList['cf_1607'] = $adb->query_result($result, $i, 'cf_1607');
        $productList['cf_1609'] = $adb->query_result($result, $i, 'cf_1609');
        $productList['cf_1783'] = $adb->query_result($result, $i, 'cf_1783');
        
        $productList['cf_1619'] = $adb->query_result($result, $i, 'cf_1619');
        $productList['cf_1620'] = $adb->query_result($result, $i, 'cf_1620');
        $productList['cf_1787'] = $adb->query_result($result, $i, 'cf_1787');
        
        $productList['cf_1622'] = $adb->query_result($result, $i, 'cf_1622');
        $productList['cf_1623'] = $adb->query_result($result, $i, 'cf_1623');
        $productList['cf_1788'] = $adb->query_result($result, $i, 'cf_1788');
        
        $productList['cf_1613'] = $adb->query_result($result, $i, 'cf_1613');
        $productList['cf_1614'] = $adb->query_result($result, $i, 'cf_1614');
        $productList['cf_1617'] = $adb->query_result($result, $i, 'cf_1617');
        $productList['cf_1786'] = $adb->query_result($result, $i, 'cf_1786');   
        $productList['cf_1805'] = $adb->query_result($result, $i, 'cf_1805');
        $productList['cf_1806'] = $adb->query_result($result, $i, 'cf_1806');
    }
    return $productList;
}
function getsalesorder($accountid,$salesorderid){
    global $adb; 
    $SQL = "SELECT ld_products.productid as salesorder_no,ld_salesorder.createdtime,cf_1535,cf_1532,cf_1534,
    ld_salesorder.modifiedtime,cf_1694,cf_1536,cf_1540,cf_1762,
    ld_products.productname,productsheet,usageunit,quantity,
    IFNULL(ld_salesorderdetail.discount_percent,ld_salesorderdetail.discount_amount) as discount_amount,total,taxprice 
    FROM ld_salesorder 
            LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid 
            LEFT JOIN ld_salesorderdetail ON ld_salesordercf.salesorderid=ld_salesorderdetail.id 
LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
            WHERE ld_salesorder.salesorderid=$salesorderid and ld_salesorder.deleted=0
            ";
           // echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
        $salesorder_no = $adb->query_result($result, $i, 'salesorder_no');
        $productList['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $productList['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $productList['cf_1535'] = $adb->query_result($result, $i, 'cf_1535');
        $productList['cf_1532'] = $adb->query_result($result, $i, 'cf_1532');
        $productList['cf_1534'] = $adb->query_result($result, $i, 'cf_1534');
        $productList['modifiedtime'] = $adb->query_result($result, $i, 'modifiedtime');
        $productList['cf_1694'] = $adb->query_result($result, $i, 'cf_1694');
        $productList['cf_1536'] = $adb->query_result($result, $i, 'cf_1536');
        $productList['cf_1540'] = $adb->query_result($result, $i, 'cf_1540');
        $productList['cf_1762'] = $adb->query_result($result, $i, 'cf_1762');
        $productList['rowCount'] = $rowCount;
        $productList['pro'][$salesorder_no]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList['pro'][$salesorder_no]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList['pro'][$salesorder_no]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $productList['pro'][$salesorder_no]['quantity'] = $adb->query_result($result, $i, 'quantity');
        $productList['pro'][$salesorder_no]['discount_amount'] = $adb->query_result($result, $i, 'discount_amount');
        $productList['pro'][$salesorder_no]['total'] = $adb->query_result($result, $i, 'total');
        $productList['pro'][$salesorder_no]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
    }
        if($rowCount==0){
       $productList['rowCount']=1; 
    }
    return $productList;
}
//页面赋值
$smarty->assign("CashBill",$CashBill);
$smarty->assign("HelpDesk",$HelpDesk);
$smarty->assign("OutboundOrder",$OutboundOrder);
$smarty->assign("PurchaseOrder",$PurchaseOrder);
$smarty->assign("SalesBackValue",$SalesBackValue);
$smarty->assign("ProjectValue",$ProjectValue);
$smarty->assign("salesorderValue",$salesorderValue);
$smarty->assign("quotesValue",$quotesValue);
$smarty->assign("listValue",$listValue);
$smarty->assign("PotentialsValue",$PotentialsValue);
$smarty->display('Comprehensivereport/accountjjwang.tpl');
exit();
?>