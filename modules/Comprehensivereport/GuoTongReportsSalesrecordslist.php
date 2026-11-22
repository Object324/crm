<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
require_once('include/utils/UserInfoUtil.php');
$smarty=new lingdangCRM_Smarty();
//echo $_REQUEST['search_text'];
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


if(isset($_REQUEST['begin_date']) && isset($_REQUEST['end_date'])){
    $begin_date = $_REQUEST['begin_date'];
    $end_date = $_REQUEST['end_date'];
}


if(!isset($_REQUEST['begin_date']) && !isset($_REQUEST['end_date'])){
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
    //判断为年度表
    if($month == "0")
    {
        $begin_month = "1";
        $end_month = "12";
    }
    else
    {
        $begin_month = $month;
        $end_month = $month;
    }
    
        //判断2月是否是闰年
       if ($_REQUEST['year']%4==0 && ($_REQUEST['year']%100!=0 || $_REQUEST['year']%400==0))
       {
        //是闰年
        $monthday = "1";
       }
       else
       {
        //不是闰年
        $monthday = "2";
       }
	
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01";  
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}

if(isset($_REQUEST['proxy'])&&$_REQUEST['proxy']!=='ALL'&&$_REQUEST['proxy']!==''){
    $where1 = " AND ld_accountscf.cf_1217='".$_REQUEST['proxy']."'";
}
//echo $_REQUEST['accountname'];
if(isset($_REQUEST['accountname'])&&$_REQUEST['accountname']!==''){
    $where3 = " AND ld_account.accountname like '%".$_REQUEST['accountname']."%'";   
}
if(isset($_REQUEST['Hospital'])&&$_REQUEST['Hospital']!==''){
    $where2 = " AND ld_productcf.cf_1180 like '%".$_REQUEST['Hospital']."%'";   
}
//echo $_REQUEST['Doctor'];
if(isset($_REQUEST['Doctor'])&&$_REQUEST['Doctor']!==''){
    $where4 = " AND ld_productcf.cf_1181 like '%".$_REQUEST['Doctor']."%'"; 
}
$proxy = $_REQUEST['proxy'];
$Hospital = $_REQUEST['Hospital'];
$accountname = $_REQUEST['accountname'];
$Doctor = $_REQUEST['Doctor'];

$AccountNumber = getReport($begin_date,$end_date,$where1,$where2,$where3,$where4);
$AccountNumber2 = $AccountNumber['cefe'];
unset($AccountNumber1['cefe']);

//主搜索方法
function getReport($begin_date,$end_date,$where1,$where2,$where3,$where4){
        global $adb;
    $SQL = "SELECT
	accountid,
	accounttype,
	accountname,
	yiyuan,
	yisheng,
	signed_data,
	rukudate,
	chukudate,
	xuliehao,
	xinghao,
	dushu,
	huanzhe,
	CASE
WHEN (
	rukudate IS NOT NULL
	AND chukudate IS NOT NULL
) THEN
	'√'
WHEN (
	rukudate IS NOT NULL
	AND chukudate IS NULL
) THEN
	'X'
ELSE
	''
END AS '/',
 zuoyouyan,
 iszengpin,
 CASE
WHEN (
	xinghao LIKE 'TICM%'
	AND iszengpin = '否'
) THEN
	round(outquantity, 0)
ELSE
	''
END AS 'TICM',
 CASE
WHEN (
	xinghao LIKE 'ICM%'
	AND iszengpin = '否'
) THEN
	round(outquantity, 0)
ELSE
	''
END AS 'ICM',
 CASE
WHEN (iszengpin = '是') THEN
	round(outquantity, 0)
ELSE
	''
END AS 'zengpian',
 concat(
	date_format(salesbackdate, '%c'),
	'月'
) AS salesbackdate,
 concat('-', round(backquantity, 0)) AS backquantity,
 CASE
WHEN fapiaodate > '2000-01-01' THEN
	concat(
		date_format(fapiaodate, '%c'),
		'月开票'
	)
ELSE
	''
END AS fapiaodate,
 description,ICM as BICM,TICM AS BTICM,zengpian AS Bzengpian
FROM
	(
		SELECT
			T1.accounttype,
			T1.accountid,
			T1.accountname,
			T1.yiyuan,
			T1.yisheng,
			T1.signed_data,
			T3.rukudate,
			T4.chukudate,
			T1.xuliehao,
			T1.xinghao,
			T1.dushu,
			T1.huanzhe,
			T1.zuoyouyan,
			T1.iszengpin,
			T4.outquantity,
			T5.salesbackdate,
			T5.quantity AS backquantity,
			T4.sf10 AS fapiaodate,
			T1.description,
                        T5.ICM,
			T5.TICM,
			T5.zengpian
		FROM
			(
				SELECT
					ld_accountscf.cf_1217 AS accounttype,
					ld_account.accountid,
					ld_account.accountname,
					ld_productcf.cf_1180 AS yiyuan,
					ld_productcf.cf_1181 AS yisheng,
					ld_salesorder.signed_data,
					ld_productcf.cf_1155 AS xuliehao,
					ld_productcf.cf_1168 AS xinghao,
					ld_productcf.cf_1171 AS dushu,
					ld_productcf.cf_1184 AS huanzhe,
					ld_productcf.cf_1157 AS zuoyouyan,
					ld_productcf.cf_1187 AS iszengpin,
					ld_salesorderdetail.description,
					ld_salesorder.salesorderid,
					ld_products.productid
				FROM
					ld_salesorder
				LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid = ld_salesorderdetail.id
				LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid
				LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_salesorder.accountid
				LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
				LEFT JOIN ld_productcf ON ld_productcf.productid = ld_salesorderdetail.productid
				WHERE
					ld_salesorder.deleted = 0
				AND ld_salesorder.sostatus <> '已作废' and ld_salesorder.signed_data BETWEEN '$begin_date' and '$end_date' $where1 $where3 $where2 $where4 
				GROUP BY
					ld_salesorder.salesorderid,
					ld_salesorderdetail.productid
				ORDER BY
					ld_salesorder.signed_data
			) AS T1
		LEFT JOIN (
			SELECT
				ld_purchaseorderdetail.entitytypeid AS salesorderid,
				ld_purchaseorderdetail.productid,
				ld_purchaseorder.purchaseorderid
			FROM
				ld_purchaseorder
			LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorder.purchaseorderid = ld_purchaseorderdetail.id
			WHERE
				ld_purchaseorder.deleted = 0
			AND ld_purchaseorder.postatus <> '已作废'
			GROUP BY
				ld_purchaseorderdetail.entitytypeid,
				ld_purchaseorderdetail.productid
			ORDER BY
				ld_purchaseorderdetail.entitytypeid
		) AS T2 ON (
			T1.salesorderid = T2.salesorderid
			AND T1.productid = T2.productid
		)
		LEFT JOIN (
			SELECT
				ld_stockdetail.entitytypeid AS purchaseorderid,
				ld_stockdetail.productid,
				ld_stock.createdate AS rukudate
			FROM
				ld_stock
			LEFT JOIN ld_stockdetail ON ld_stock.stock_id = ld_stockdetail.id
			WHERE
				ld_stock.deleted = 0
		) AS T3 ON (
			T3.purchaseorderid = T2.purchaseorderid
			AND T3.productid = T2.productid
		)
		LEFT JOIN (
			SELECT
				ld_outboundorderdetail.entitytypeid AS salesorderid,
				ld_outboundorderdetail.productid,
				ld_outboundorder.outdate AS chukudate,
				ld_outboundorderdetail.quantity AS outquantity,
				ld_outboundorderdetailscf.sf10
			FROM
				ld_outboundorder
			LEFT JOIN ld_outboundorderdetail ON ld_outboundorder.out_id = ld_outboundorderdetail.id
			LEFT JOIN ld_outboundorderdetailscf ON ld_outboundorderdetailscf.lineitem_id = ld_outboundorderdetail.lineitem_id
			WHERE
				ld_outboundorder.deleted = 0
		) AS T4 ON (
			T4.salesorderid = T1.salesorderid
			AND T4.productid = T1.productid
		)
		LEFT JOIN (
			SELECT
				ld_salesback.salesorderid,
				ld_salesbackdetail.productid,
				ld_salesback.salesbackdate,
				ld_salesbackdetail.quantity,
 CASE
WHEN (
	cf_1168 LIKE 'TICM%'
	AND cf_1187 = '否'
) THEN
	round(quantity, 0)
ELSE
	''
END AS 'TICM',
 CASE
WHEN (
	cf_1168 LIKE 'ICM%'
	AND cf_1187 = '否'
) THEN
	round(quantity, 0)
ELSE
	''
END AS 'ICM',
 CASE
WHEN (cf_1187 = '是') THEN
	round(quantity, 0)
ELSE
	''
END AS 'zengpian'
			FROM
				ld_salesback
			LEFT JOIN ld_salesbackdetail ON ld_salesbackdetail.id = ld_salesback.salesbackid
				LEFT JOIN ld_products ON ld_products.productid = ld_salesbackdetail.productid
				LEFT JOIN ld_productcf ON ld_productcf.productid = ld_salesbackdetail.productid
			WHERE
				ld_salesback.deleted = 0
			AND ld_salesback.salesbackstatus <> '中止'
		) AS T5 ON (
			T5.salesorderid = T1.salesorderid
			AND T5.productid = T1.productid
		)
		UNION ALL
			(
				SELECT
					T6.accounttype,
					T6.accountid,
					T6.accountname,
					T6.yiyuan,
					T6.yisheng,
					T6.signed_data,
					T7.rukudate,
					T6.chukudate,
					T6.xuliehao,
					T6.xinghao,
					T6.dushu,
					T6.huanzhe,
					T6.zuoyouyan,
					T6.iszengpin,
					T6.quantity AS outquantity,
					'' AS salesbackdate,
					'' AS backquantity,
					T6.sf10 AS fapiaodate,
					T6.description,
					'' AS ICM,
					'' AS TICM,
					'' as zengpian
				FROM
					(
						SELECT
							ld_accountscf.cf_1217 AS accounttype,
              ld_account.accountid,
							ld_account.accountname,
							ld_outboundorder.outdate AS chukudate,
							ld_productcf.cf_1180 AS yiyuan,
							ld_productcf.cf_1181 AS yisheng,
							ld_outboundorder.outdate AS signed_data,
							ld_productcf.cf_1155 AS xuliehao,
							ld_productcf.cf_1168 AS xinghao,
							ld_productcf.cf_1171 AS dushu,
							ld_productcf.cf_1184 AS huanzhe,
							ld_productcf.cf_1157 AS zuoyouyan,
							ld_productcf.cf_1187 AS iszengpin,
							ld_outboundorderdetail.quantity,
							ld_outboundorderdetailscf.sf10,
							ld_outboundorderdetail.description,
							ld_outboundorderdetail.productid
						FROM
							ld_outboundorder
						LEFT JOIN ld_outboundorderdetail ON ld_outboundorder.out_id = ld_outboundorderdetail.id
						LEFT JOIN ld_outboundorderdetailscf ON ld_outboundorderdetailscf.lineitem_id = ld_outboundorderdetail.lineitem_id
						LEFT JOIN ld_productcf ON ld_productcf.productid = ld_outboundorderdetail.productid
						LEFT JOIN ld_account ON ld_account.accountid = ld_outboundorder.accountid
						LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_outboundorder.accountid
						WHERE
                                                 ld_outboundorder.outdate BETWEEN '$begin_date' and '$end_date'
							and ld_outboundorder.deleted = 0 $where1 $where3 $where2 $where4 
						AND ld_productcf.cf_1187 = '是'
					) AS T6
				LEFT JOIN (
					SELECT
						ld_stockdetail.productid,
						ld_stock.createdate AS rukudate
					FROM
						ld_stockdetail
					LEFT JOIN ld_stockdetail ON ld_stock.stock_id = ld_stockdetail.id
					WHERE
						ld_stock.deleted = 0
				) AS T7 ON T7.productid = T6.productid
			)
	) AS T
ORDER BY
	signed_data,
	CONV(
		HEX(
			LEFT (
				CONVERT (accountname USING gbk),
				1
			)
		),
		16,
		10
	),
	CONV(
		HEX(
			LEFT (CONVERT(yisheng USING gbk), 1)
		),
		16,
		10
	);";
 //echo $SQL.'<br><br>';

$result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {  
        $userNumberList[$i]['accountid'] = $adb->query_result($result, $i, 'accountid');
        $userNumberList[$i]['accounttype'] = $adb->query_result($result, $i, 'accounttype');
        $userNumberList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $userNumberList[$i]['yiyuan'] = $adb->query_result($result, $i, 'yiyuan');
        $userNumberList[$i]['yisheng'] = $adb->query_result($result, $i, 'yisheng');
        $userNumberList[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $userNumberList[$i]['rukudate'] = $adb->query_result($result, $i, 'rukudate');
        $userNumberList[$i]['chukudate'] = $adb->query_result($result, $i, 'chukudate');
        $userNumberList[$i]['xuliehao'] = $adb->query_result($result, $i, 'xuliehao');
        $userNumberList[$i]['xinghao'] = $adb->query_result($result, $i, 'xinghao');
        $userNumberList[$i]['dushu'] = $adb->query_result($result, $i, 'dushu');
        $userNumberList[$i]['huanzhe'] = $adb->query_result($result, $i, 'huanzhe');
        $userNumberList[$i]['sasasas'] = $adb->query_result($result, $i, '/');
        $userNumberList[$i]['zuoyouyan'] = $adb->query_result($result, $i, 'zuoyouyan');
        $userNumberList[$i]['iszengpin'] = $adb->query_result($result, $i, 'iszengpin');
        $userNumberList[$i]['TICM'] = $adb->query_result($result, $i, 'ticm');
        $userNumberList[$i]['ICM'] = $adb->query_result($result, $i, 'icm');
        $userNumberList[$i]['zengpian'] = $adb->query_result($result, $i, 'zengpian');
        $userNumberList[$i]['salesbackdate'] = $adb->query_result($result, $i, 'salesbackdate');
        $userNumberList[$i]['backquantity'] = $adb->query_result($result, $i, 'backquantity');
        $userNumberList[$i]['fapiaodate'] = $adb->query_result($result, $i, 'fapiaodate');
        $userNumberList[$i]['description'] = $adb->query_result($result, $i, 'description');
        $userNumberList[$i]['BTICM'] = $adb->query_result($result, $i, 'bticm');
        $userNumberList[$i]['BICM'] = $adb->query_result($result, $i, 'bicm');
        $userNumberList[$i]['Bzengpian'] = $adb->query_result($result, $i, 'bzengpian');
        $userNumberList['cefe']['TICM'] += $adb->query_result($result, $i, 'ticm');
        $userNumberList['cefe']['ICM'] += $adb->query_result($result, $i, 'icm');
        $userNumberList['cefe']['zengpian'] += $adb->query_result($result, $i, 'zengpian');
        $userNumberList['cefe']['BTICM'] += $adb->query_result($result, $i, 'bticm');
        $userNumberList['cefe']['BICM'] += $adb->query_result($result, $i, 'bicm');
        $userNumberList['cefe']['Bzengpian'] += $adb->query_result($result, $i, 'bzengpian');
    }

//print_r($userNumberList);

    return $userNumberList;
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

//print_r($salesList['slist']);
//页面赋值
$chengben = $_REQUEST['rtype'];
$smarty->assign("proxy",$proxy);
$smarty->assign("TICM",$AccountNumber2['TICM']);
$smarty->assign("ICM",$AccountNumber2['ICM']);
$smarty->assign("zengpian",$AccountNumber2['zengpian']);
$smarty->assign("BTICM",$AccountNumber2['BTICM']);
$smarty->assign("BICM",$AccountNumber2['BICM']);
$smarty->assign("Bzengpian",$AccountNumber2['Bzengpian']);
$smarty->assign("Hospital",$Hospital);
$smarty->assign("accountname",$accountname);
$smarty->assign("Doctor",$Doctor);
$smarty->assign("chengben",$chengben);
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("roleList",$AccountNumber);
$smarty->display('Comprehensivereport/guotongreportsSalesrecordslist.tpl');
exit();
?>