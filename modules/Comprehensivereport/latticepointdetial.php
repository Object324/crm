<?php

/**
 * @author andy
 * @龙威总表按网点
 * @copyright 2014
 */
global $adb,$mod_strings;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();
$searchAccount=$_REQUEST['Account_search_text'];
$receiverid=$_REQUEST['receiverid'];
$search_text4=$_REQUEST['search_text4'];
if($searchAccount!=''){
    $searchAccountSQL = " AND a.accountname like '%$searchAccount%' ";
    $smarty->assign("searchAccount",$searchAccount);
}
if($receiverid!=''){
    $receiveridSQL = " AND a.smownerid in ($receiverid) ";
    $smarty->assign("search_text4",$search_text4);
    $smarty->assign("receiverid",$receiverid);
    $receiverid_array=explode(',',$receiverid);
    $smarty->assign("receiverid_array",$receiverid_array);
}
$users_combo = get_user_array(FALSE, "Active");
foreach($users_combo as $userid=>$lastname)
{
  
    $arruser[$lastname]=$userid;
}
$smarty->assign("ARRUSER",$arruser);

$year=$_REQUEST['year'];
$begin_month=$end_month=$_REQUEST['month'];
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
    if($_REQUEST['month']==0){
        $begin_month=1;$end_month=12;
    }
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
$smarty->assign("Report_form_query",$Report_form_query);


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
$smarty->assign("TYPE_DATA",$month);
if($month==1){
    $lastyear = $year-1;
    $lastmonth = 12;
}else{
    $lastyear = $year;
    $lastmonth = $month;
}

if($Report_form_query == 'true')
{
    $Netreport_list = get_reportlistsearch($month,$year,$begin_date,$end_date,$searchAccountSQL,$receiveridSQL);
}
else
{
    $Netreport_list = get_reportlist($month,$year);
}


foreach($product_list as $key=>$row){
    $vals[$key] = $row[10];
}
foreach($Netreport_list as $key=>$row){
    $vals[$key]= $row[salesorder_total];
    //var_dump($vals);
}
//数组排序，已累计销售倒序排序
array_multisort($vals,SORT_DESC,$Netreport_list);

foreach($Netreport_list as $key=>$arr){
    $all['cashbillsubtotal_Balance_oldmonth']+=$arr['cashbillsubtotal_Balance_oldmonth'];
    $all['outOutboundOrder_num_month']+=$arr['outOutboundOrder_num_month'];
    $all['cashback_month_total']+=$arr['cashback_month_total'];
    $all['cashbill_month_subtotal']+=$arr['cashbill_month_subtotal'];
    $all['salesorder_total']+=$arr['salesorder_total'];
    $all['cashback_total']+=$arr['cashback_total'];
    $all['cashbillsubtotal']+=$arr['cashbillsubtotal'];
    $all['cashbillsubtotal_Balance']+=$arr['cashbillsubtotal_Balance'];
    $all['outOutboundOrder_num']+=$arr['outOutboundOrder_num'];
    $all['cashback_percent']+=$arr['cashback_percent'];
    $all['cashbillsubtotal_percent']+=$arr['cashbillsubtotal_percent'];
    foreach($arr as $key2=>$arr2){
        if($key2=='cashbillsubtotal_Balance_oldmonth' ||$key2=='outOutboundOrder_num_month' ||$key2=='cashback_month_total' ||$key2=='cashbill_month_subtotal' 
        ||$key2=='salesorder_total' || $key2=='cashback_total' || $key2=='cashbillsubtotal' || $key2=='cashbillsubtotal_Balance'){
            $Netreport_list[$key][$key2] = getDecimalTwoVal($arr2);
        }
    }
}

function get_reportlist($month,$year){
    global $adb;
      if($month==0){
        $eq='<=';
    }else{
        $eq='=';
    }  
    if($month==0){
        $month=12;
    }
    $month_old=$month-1;
    if($month_old==0){
        $month_old=12;
        $year_old=$year-1;
    }elseif($month_old>0){
        $year_old=$year;
    }elseif($month_old<0){
        $month_old=0;
        $year_old=$year;
    }
    
    $sql = "SELECT
	a.accountid,
	a.siccode,
	a.account_no,
	a.accountname,
	a.account_type,
	a.bill_state,
	a.bill_city,
	IFNULL(F1.salesorder_total, 0) AS salesorder_total,
	IFNULL(F2.outoutboundorder_num, 0) AS outOutboundOrder_num,
	IFNULL(F3.cashback_total, 0) AS cashback_total,
	IFNULL(
		IFNULL(F3.cashback_total, 0)/IFNULL(F1.salesorder_total, 0)
	,0) * 100 AS cashback_percent,
	IFNULL(F4.cashbillsubtotal, 0) AS cashbillsubtotal,
	IFNULL(
		(
			IFNULL(F4.cashbillsubtotal, 0) / IFNULL(F1.salesorder_total, 0) * 100
		),
		0
	) AS cashbillsubtotal_percent,
	(
		IFNULL(F1.salesorder_total, 0) - IFNULL(F4.cashbillsubtotal, 0) - IFNULL(F3.cashback_total, 0)
	) AS cashbillsubtotal_Balance,
	(
		IFNULL(F5.salesorder_total, 0) - IFNULL(F6.cashbillsubtotal, 0) - IFNULL(F7.cashback_total, 0)
	) AS cashbillsubtotal_Balance_oldmonth,
	IFNULL(F8.outoutboundorder_num, 0) AS outOutboundOrder_num_month,
	IFNULL(F9.cashback_total, 0) AS cashback_month_total,
	IFNULL(F10.cashbillsubtotal, 0) AS cashbill_month_subtotal
FROM
	ld_account AS a
LEFT JOIN (
	SELECT
		s.accountid,
		sum(IFNULL(s.total, 0)) AS salesorder_total
	FROM
		ld_salesorder AS s
	WHERE
		stockpresence = '全部出库'
	AND s.sostatus <> '已作废'
	AND s.deleted = 0
	AND MONTH (s.signed_data) <= $month
	AND YEAR (s.signed_data) = $year
	AND s.deleted = 0
	GROUP BY
		s.accountid
) AS F1 ON F1.accountid = a.accountid
LEFT JOIN (
	SELECT
		o.accountid,
		count(o.out_id) AS outoutboundorder_num
	FROM
		ld_outboundorder AS o
	WHERE
		(
			(
				YEAR (o.modifiedtime) = $year
				AND MONTH (o.modifiedtime) $eq $month
			)
			OR (
				YEAR (o.outdate) = $year
				AND MONTH (o.outdate) $eq $month
			)
		)
	AND o.presence = 1
	AND o.deleted = 0
	GROUP BY
		o.accountid
) AS F2 ON F2.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
 ld_SalesBack 
	WHERE
    MONTH (ld_SalesBack.salesbackdate) $eq $month
	AND YEAR (ld_SalesBack.salesbackdate) = $year
	AND deleted = 0
	GROUP BY
		accountid
) AS F3 ON F3.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
		MONTH (c.createdtime) $eq $month
	AND YEAR (c.createdtime) = $year
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F4 ON F4.accountid = a.accountid
LEFT JOIN (
	SELECT
		s.accountid,
		sum(IFNULL(s.total, 0)) AS salesorder_total
	FROM
		ld_salesorder AS s
	WHERE
		stockpresence = '全部出库'
	AND s.sostatus <> '已作废'
	AND s.deleted = 0
	AND MONTH (s.signed_data) <= $month_old
	AND YEAR (s.signed_data) = $year_old
	AND s.deleted = 0
	GROUP BY
		s.accountid
) AS F5 ON F5.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
		MONTH (c.createdtime) $eq $month_old
	AND YEAR (c.createdtime) = $year_old
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F6 ON F6.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
    ld_SalesBack 
	WHERE
     MONTH (salesbackdate) $eq $month_old
	AND YEAR (salesbackdate) = $year_old
	AND deleted = 0
	GROUP BY
		accountid
) AS F7 ON F7.accountid = a.accountid
LEFT JOIN (
	SELECT
		o.accountid,
		sum(o.total) AS outOutboundOrder_num
	FROM
		ld_outboundorder AS o
	WHERE
		(
			(
				YEAR (o.modifiedtime) = $year
				AND MONTH (o.modifiedtime) = $month
			)
			OR (
				YEAR (o.outdate) = $year
				AND MONTH (o.outdate) = $month
			)
		)
	AND o.presence = 1
	AND o.deleted = 0
	GROUP BY
		o.accountid
) AS F8 ON F8.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
    ld_SalesBack 
	WHERE
    MONTH (salesbackdate) = $month
	AND YEAR (salesbackdate) = $year
	AND deleted = 0
	GROUP BY
		accountid
) AS F9 ON F9.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
		MONTH (c.createdtime) = $month
	AND YEAR (c.createdtime) = $year
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F10 ON F10.accountid = a.accountid ";
//echo $sql;
$result=$adb->pquery($sql);
$rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $account_list[$i][accountid] = $adb->query_result($result, $i, 'accountid');
        $account_list[$i][account_no] = $adb->query_result($result, $i, 'account_no');
        $account_list[$i][siccode] = $adb->query_result($result, $i, 'siccode');
        $account_list[$i][accountname] = $adb->query_result($result, $i, 'accountname');
        $account_list[$i][account_type] = $adb->query_result($result, $i, 'account_type');
        $account_list[$i][bill_state] = $adb->query_result($result, $i, 'bill_state');
        $account_list[$i][bill_city] = $adb->query_result($result, $i, 'bill_city');
        $account_list[$i][salesorder_total]=$adb->query_result($result, $i, 'salesorder_total');//累计销售金额
        $account_list[$i][outOutboundOrder_num]=$adb->query_result($result, $i, 'outoutboundorder_num');//累计发货次数
        $account_list[$i][cashback_total] =$adb->query_result($result, $i, 'cashback_total');//累计退货金额
        $account_list[$i][cashback_percent] =round($adb->query_result($result, $i, 'cashback_percent'),2);//累计退货金额/订单金额合计
        $account_list[$i][cashbillsubtotal] =$adb->query_result($result, $i, 'cashbillsubtotal');//有效回笼资金
        $account_list[$i][cashbillsubtotal_percent]=round($adb->query_result($result, $i, 'cashbillsubtotal_percent'),2);//回笼比：本年累计资金回笼/本年累计销售
        $account_list[$i][cashbillsubtotal_Balance]=$adb->query_result($result, $i, 'cashbillsubtotal_balance');//应收款余额：本年累计销售-本年累计资金回笼-累计退货金额
        $account_list[$i][cashbillsubtotal_Balance_oldmonth]=$adb->query_result($result, $i, 'cashbillsubtotal_balance_oldmonth');
        $account_list[$i][outOutboundOrder_num_month]=$adb->query_result($result, $i, 'outoutboundorder_num_month');
        $account_list[$i][cashback_month_total] =$adb->query_result($result, $i, 'cashback_month_total');//累计退货金额
        $account_list[$i][cashbill_month_subtotal] =$adb->query_result($result, $i, 'cashbill_month_subtotal');//有效回笼资金
    }
    
    return $account_list;
}

function get_reportlistsearch($month,$year,$begin_dates,$end_dates,$searchAccountSQL='',$receiveridSQL=''){
    global $adb;
    $month_old=$month-1;
    if($month_old==0){
        $month_old=12;
        $year_old=$year-1;
    }elseif($month_old>0){
        $year_old=$year;
    }elseif($month_old<0){
        $month_old=0;
        $year_old=$year;
    }
    $sql = "SELECT
	a.accountid,
	a.siccode,
	a.account_no,
	a.accountname,
	a.account_type,
	a.bill_state,
	a.bill_city,
	IFNULL(F1.salesorder_total, 0) AS salesorder_total,
	IFNULL(F2.outoutboundorder_num, 0) AS outOutboundOrder_num,
	IFNULL(F3.cashback_total, 0) AS cashback_total,
	IFNULL(
		IFNULL(F3.cashback_total, 0)/IFNULL(F1.salesorder_total, 0)
	,0) * 100 AS cashback_percent,
	IFNULL(F4.cashbillsubtotal, 0) AS cashbillsubtotal,
	IFNULL(
		(
			IFNULL(F4.cashbillsubtotal, 0) / IFNULL(F1.salesorder_total, 0) * 100
		),
		0
	) AS cashbillsubtotal_percent,
	(
		IFNULL(F1.salesorder_total, 0) - IFNULL(F4.cashbillsubtotal, 0) - IFNULL(F3.cashback_total, 0)
	) AS cashbillsubtotal_Balance,
	(
		IFNULL(F5.salesorder_total, 0) - IFNULL(F6.cashbillsubtotal, 0) - IFNULL(F7.cashback_total, 0)
	) AS cashbillsubtotal_Balance_oldmonth,
	IFNULL(F8.outoutboundorder_num, 0) AS outOutboundOrder_num_month,
	IFNULL(F9.cashback_total, 0) AS cashback_month_total,
	IFNULL(F10.cashbillsubtotal, 0) AS cashbill_month_subtotal
FROM
	ld_account AS a
LEFT JOIN (
	SELECT
		s.accountid,
		sum(IFNULL(s.total, 0)) AS salesorder_total
	FROM
		ld_salesorder AS s
	WHERE
		stockpresence = '全部出库'
	AND s.sostatus <> '已作废'
	AND s.deleted = 0
	AND s.signed_data BETWEEN '$begin_dates' AND '$end_dates'
	AND s.deleted = 0
	GROUP BY
		s.accountid
) AS F1 ON F1.accountid = a.accountid
LEFT JOIN (
	SELECT
		o.accountid,
		count(o.out_id) AS outoutboundorder_num
	FROM
		ld_outboundorder AS o
	WHERE
		(
			(
                o.modifiedtime BETWEEN '$begin_dates 00:00:00' AND '$end_dates 23:59:59'
			)
			OR (
                o.outdate BETWEEN '$begin_dates' AND '$end_dates'
			)
		)
	AND o.presence = 1
	AND o.deleted = 0
	GROUP BY
		o.accountid
) AS F2 ON F2.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
     ld_SalesBack
	WHERE
    salesbackdate BETWEEN '$begin_dates' AND '$end_dates'
	AND deleted = 0
	GROUP BY
		accountid
) AS F3 ON F3.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
		c.createdtime BETWEEN '$begin_dates 00:00:00' AND '$end_dates 23:59:59'
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F4 ON F4.accountid = a.accountid
LEFT JOIN (
	SELECT
		s.accountid,
		sum(IFNULL(s.total, 0)) AS salesorder_total
	FROM
		ld_salesorder AS s
	WHERE
		stockpresence = '全部出库'
	AND s.sostatus <> '已作废'
	AND s.deleted = 0
	AND MONTH (s.signed_data) <= $month_old
	AND YEAR (s.signed_data) = $year_old
	AND s.deleted = 0
	GROUP BY
		s.accountid
) AS F5 ON F5.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
		MONTH (c.createdtime) <= $month_old
	AND YEAR (c.createdtime) = $year_old
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F6 ON F6.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
     ld_SalesBack
	WHERE
     MONTH (salesbackdate) <= $month_old
	AND YEAR (salesbackdate) = $year_old
	AND deleted = 0
	GROUP BY
		accountid
) AS F7 ON F7.accountid = a.accountid
LEFT JOIN (
	SELECT
		o.accountid,
		sum(o.total) AS outOutboundOrder_num
	FROM
		ld_outboundorder AS o
	WHERE
		(
			(
				o.modifiedtime BETWEEN '$begin_dates 00:00:00' AND '$end_dates 23:59:59'
			)
			OR (
				o.outdate BETWEEN '$begin_dates' AND '$end_dates'
			)
		)
	AND o.presence = 1
	AND o.deleted = 0
	GROUP BY
		o.accountid
) AS F8 ON F8.accountid = a.accountid
LEFT JOIN (
	SELECT
		accountid,
		sum(IFNULL(total, 0)) AS cashback_total
	FROM
    ld_SalesBack 
	WHERE
     salesbackdate BETWEEN '$begin_dates' AND '$end_dates'
	AND deleted = 0
	GROUP BY
		accountid
) AS F9 ON F9.accountid = a.accountid
LEFT JOIN (
	SELECT
		c.accountid,
		sum(IFNULL(c.total, 0)) AS cashbillsubtotal
	FROM
		ld_cashbill AS c
	WHERE
	c.createdtime BETWEEN '$begin_dates 00:00:00' AND '$end_dates 23:59:59'
	AND c.deleted = 0
	GROUP BY
		c.accountid
) AS F10 ON F10.accountid = a.accountid where 1 $searchAccountSQL $receiveridSQL";
//echo $sql;
$result=$adb->pquery($sql);
$rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $account_list[$i][accountid] = $adb->query_result($result, $i, 'accountid');
        $account_list[$i][account_no] = $adb->query_result($result, $i, 'account_no');
        $account_list[$i][siccode] = $adb->query_result($result, $i, 'siccode');
        $account_list[$i][accountname] = $adb->query_result($result, $i, 'accountname');
        $account_list[$i][account_type] = $adb->query_result($result, $i, 'account_type');
        $account_list[$i][bill_state] = $adb->query_result($result, $i, 'bill_state');
        $account_list[$i][bill_city] = $adb->query_result($result, $i, 'bill_city');
        $account_list[$i][salesorder_total]=$adb->query_result($result, $i, 'salesorder_total');//累计销售金额
        $account_list[$i][outOutboundOrder_num]=$adb->query_result($result, $i, 'outoutboundorder_num');//累计发货次数
        $account_list[$i][cashback_total] =$adb->query_result($result, $i, 'cashback_total');//累计退货金额
        $account_list[$i][cashback_percent] =round($adb->query_result($result, $i, 'cashback_percent'),2);//累计退货金额/订单金额合计
        $account_list[$i][cashbillsubtotal] =$adb->query_result($result, $i, 'cashbillsubtotal');//有效回笼资金
        $account_list[$i][cashbillsubtotal_percent]=round($adb->query_result($result, $i, 'cashbillsubtotal_percent'),2);//回笼比：本年累计资金回笼/本年累计销售
        $account_list[$i][cashbillsubtotal_Balance]=$adb->query_result($result, $i, 'cashbillsubtotal_balance');//应收款余额：本年累计销售-本年累计资金回笼-累计退货金额
        $account_list[$i][cashbillsubtotal_Balance_oldmonth]=$adb->query_result($result, $i, 'cashbillsubtotal_balance_oldmonth');
        $account_list[$i][outOutboundOrder_num_month]=$adb->query_result($result, $i, 'outoutboundorder_num_month');
        $account_list[$i][cashback_month_total] =$adb->query_result($result, $i, 'cashback_month_total');//累计退货金额
        $account_list[$i][cashbill_month_subtotal] =$adb->query_result($result, $i, 'cashbill_month_subtotal');//有效回笼资金
    }
    
    return $account_list;
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
$account_field_obj =Field::getInstance('Accounts',$adb);
$arraccountLabel = $account_field_obj->getFieldLables();


//页面赋值
$smarty->assign("ARRACCOUNTLABEL",$arraccountLabel);//年
$smarty->assign("YEAR",$year);//年
$smarty->assign("ALL",$all);//年
$smarty->assign("MONTH",$month);//
$smarty->assign("Netreport_list",$Netreport_list);
$smarty->display('Comprehensivereport/NetreportDetail.tpl');
exit();
?>