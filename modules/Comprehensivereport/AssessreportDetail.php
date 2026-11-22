<?php
/**
 * 更新操作
 * Edit:andrew
 * date:20140116
 * reason:内销报表-考核（龙威）
 * */
global $adb,$mod_strings;

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
if($month!=0){
    $where = " and s.cashbilldate <='".$year.'-'.$month."-31' ";
}

if($month!=0){
    $time = "'".$year."-".$month."-00 00:00:00'";
}else{
    $time = "'".$year."-00-00 00:00:00'";
}
if($month!=0){
    $sqlwhere=" and s.signed_data<='".$year.'-'.$month."-31'";
}
if($month!=0){
    $sqlwhere2=" and s.cashbilldate<='".$year.'-'.$month."-31'";
}
if($month!=0){
        $newsql =" AND MONTH(s.signed_data)=".$month;
    }

if($month!=0){
    $monthsql = " and MONTH(createdtime)=".$month;
}
if($month!=0){
    $monthsql2 = " and MONTH(s.cashbilldate)=".$month;
}
$SQL = "SELECT last_name,ifnull(FORMAT(new_total,2),0) as new_total,ifnull(FORMAT(old_total,2),0) as old_total,
ifnull(FORMAT(ifnull(new_total,0)+ifnull(old_total,0),2),0) as total,ifnull(FORMAT(zh_total,2),0) as zh_total,
ifnull(FORMAT(th_total,2),0) as th_total,ifnull(FORMAT(ifnull(zh_total,0)-ifnull(th_total,0),2),0) as yx_total,
ifnull(FORMAT((ifnull(zh_total,0)/(ifnull(new_total,0)+ifnull(old_total,0)))*100,2),0) as yxzhz,ifnull(ifnull(ys_total1,0)-ifnull(ys_total2,0),0) as ys_total,
ifnull(yxbd_count,0) as yxbd_count,ifnull(ex_total,0) as ex_total,
ifnull(FORMAT(ifnull(ex_total,0)/(ifnull(new_total,0)+ifnull(old_total,0))*100,2),0) as fyzb     
FROM ld_users left JOIN 
(
select smownerid,SUM(ifnull(s.total,0)) as new_total 
from ld_salesorder as s  
where s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' and YEAR(s.signed_data)=$year $newsql 
AND accountid not in(
SELECT accountid 
FROM ld_salesorder as s 
WHERE s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' 
and s.signed_data<=$time) GROUP BY smownerid
) as nt on ld_users.id=nt.smownerid 
LEFT JOIN (
select smownerid,SUM(ifnull(s.total,0)) as old_total 
from ld_salesorder as s  
where s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' and YEAR(s.signed_data)=$year $newsql 
AND accountid in(
SELECT accountid 
FROM ld_salesorder as s 
WHERE s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' 
and s.signed_data<=$time) GROUP BY smownerid) as ot on ot.smownerid=ld_users.id 
LEFT JOIN (
SELECT smownerid,SUM(ifnull(s.total,0)) as zh_total  FROM ld_cashbill as s 
where YEAR(s.cashbilldate)=$year $monthsql2 GROUP BY smownerid
) as zh on zh.smownerid=ld_users.id 
LEFT JOIN(
select smownerid,SUM(ifnull(s.total,0)) as th_total 
from ld_salesorder as s 
where s.deleted=0 and s.salesorderid in 
(SELECT salesorderid from ld_salesback WHERE salesbackstatus<>'中止')
 and YEAR(signed_data)=$year $newsql GROUP BY smownerid) 
as th on th.smownerid=ld_users.id 
LEFT JOIN 
(select smownerid,SUM(ifnull(s.total,0)) as ys_total1 
from ld_salesorder as s 
where s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' and s.deleted=0 $sqlwhere GROUP BY smownerid 
) as ysk on ysk.smownerid=ld_users.id 
LEFT JOIN (
select smownerid,SUM(ifnull(s.total,0)) as ys_total2 
from ld_cashbill as s 
where s.deleted=0 $sqlwhere2 GROUP BY smownerid 
) as ys on ys.smownerid=ld_users.id 
LEFT JOIN(SELECT smownerid,count(accountid) as yxbd_count FROM (
SELECT smownerid,accountid from ld_salesorder 
where sostatus<>'已作废' and ld_salesorder.deleted=0 and stockpresence='全部出库' and accountid not in(SELECT accountid from ld_salesorder as s 
where s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' and s.signed_data<=$time  
GROUP BY s.accountid HAVING SUM(ifnull(s.total,0))>=10000)GROUP BY accountid HAVING SUM(ifnull(total,0))>=10000
) as temp GROUP BY smownerid)
as yxbd on yxbd.smownerid=ld_users.id 
 LEFT JOIN (
SELECT e.smownerid,SUM(ifnull(e.total,0)) as ex_total 
FROM 
ld_expense as e 
INNER JOIN ld_expensedetail as ed on ed.expenseid=e.expenseid 
WHERE e.approvestatus='".constant('D_A_S_APPROVED')."' and ed.expensetype!='物流费用'  
 GROUP BY e.smownerid
) as exc on exc.smownerid=ld_users.id order by ifnull(new_total,0)+ifnull(old_total,0) DESC
;
";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $assess_list[$i][id] =$i+1 ;
        $assess_list[$i][2] = $adb->query_result($result, $i, 'last_name');
        $assess_list[$i][3] = $adb->query_result($result, $i, 'new_total');
        $assess_list[$i][4] = $adb->query_result($result, $i, 'old_total');
        $assess_list[$i][5] = $adb->query_result($result, $i, 'total');
        $assess_list[$i][6] = $adb->query_result($result, $i, 'zh_total');
        $assess_list[$i][7] = $adb->query_result($result, $i, 'th_total');
        $assess_list[$i][8] = $adb->query_result($result, $i, 'yx_total');
        $assess_list[$i][9] = $adb->query_result($result, $i, 'yxzhz')."%";
        $assess_list[$i][10] = getDecimalTwoVal($adb->query_result($result, $i, 'ys_total'));
        $assess_list[$i][11] = $adb->query_result($result, $i, 'yxbd_count');
        $assess_list[$i][12] = $adb->query_result($result, $i, 'ex_total');
        $assess_list[$i][13] = number_format($adb->query_result($result, $i, 'fyzb'))."%";
    }
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);//月
$smarty->assign("ASSESS_LIST",$assess_list);
$smarty->display('Comprehensivereport/AssessreportDetail.tpl');
exit();
?>