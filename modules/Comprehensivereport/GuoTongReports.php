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
//echo $_REQUEST['bill'];
if(isset($_REQUEST['bill'])&&$_REQUEST['bill']!=='ALL'&&$_REQUEST['bill']!==''){
    $where2 = " AND ld_inventoryproductrelscf.sf4='".$_REQUEST['bill']."'";
}
//echo $_REQUEST['accountname'];
if(isset($_REQUEST['accountname'])&&$_REQUEST['accountname']!==''){
    $where3 = " AND ld_account.accountname like '%".$_REQUEST['accountname']."%'";   
}
//echo $_REQUEST['Doctor'];
if(isset($_REQUEST['Doctor'])&&$_REQUEST['Doctor']!==''){
    $where4 = " AND ld_productcf.cf_1181 like '%".$_REQUEST['Doctor']."%'"; 
}
$proxy = $_REQUEST['proxy'];
$bill = $_REQUEST['bill'];
$accountname = $_REQUEST['accountname'];
$Doctor = $_REQUEST['Doctor'];

$AccountNumber = getReport($begin_date,$end_date,$where1,$where2,$where3,$where4);

//主搜索方法
function getReport($begin_date,$end_date,$where1,$where2,$where3,$where4){
        global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(select 
    T1.accountid,
	T1.riqi,
	T1.accounttype,
	T1.accountname,
	T1.yisheng,
	T1.guige,
	sum(T1.salesamount - ifnull(T2.backamount,0))/sum(T1.quantity - ifnull(T2.backquantity,0)) as danjia,
	sum(T1.quantity - ifnull(T2.backquantity,0)) as qty,
	sum(T1.salesamount - ifnull(T2.backamount,0)) as amount,
	sum(T1.costamount - ifnull(T2.backcost,0)) as cost,
	T1.iskaipiao
from
	(
		select
			ld_accountscf.cf_1217 as accounttype,
			ld_account.accountname,
			ld_productcf.cf_1180 as yiyuan,
			ld_productcf.cf_1181 as yisheng,
			ld_productcf.cf_1168 as guige,
			case
		when ld_outboundorderdetail.sf4 = '是' then
			'是'
		else
			'否'
		end as iskaipiao,
		case
	when ifnull(
		ld_outboundorderdetail.sf10,
		'1900-01-01'
	) < '2001-01-01' then
		ld_outboundorder.outdate
	else
		ld_outboundorderdetail.sf10
	end as riqi,
	sum(
		ld_outboundorderdetail.quantity
	) as quantity,
	sum(
		round(
			(
				100 + ifnull(
					ld_outboundorderdetail.tax1,
					0
				) + ifnull(
					ld_outboundorderdetail.tax2,
					0
				) + ifnull(
					ld_outboundorderdetail.tax3,
					0
				)
			) * (
				round(
					ld_outboundorderdetail.quantity * ld_outboundorderdetail.listprice + 0.000001,
					2
				) - round(
					ld_outboundorderdetail.quantity * ld_outboundorderdetail.listprice * ifnull(
						ld_outboundorderdetail.discount_percent,
						0
					) * 0.01 + 0.000001,
					2
				)
			) * 0.01 + 0.000001,
			2
		)
	) as salesamount,
	sum(
		round(
			(
				case
				when ld_outboundorderdetail.productcost = 0.00 then
					ld_products.costprice
				else
					ld_outboundorderdetail.productcost
				end
			) * ld_outboundorderdetail.quantity + 0.000001,
			2
		)
	) as costamount,
	ld_products.productid,ld_account.accountid 
from
	ld_outboundorder
left join ld_outboundorderdetail on ld_outboundorder.out_id = ld_outboundorderdetail.id
left join ld_outboundorderdetailscf on ld_outboundorderdetailscf.lineitem_id = ld_outboundorderdetail.lineitem_id
left join ld_account on ld_account.accountid = ld_outboundorder.accountid
left join ld_accountscf on ld_accountscf.accountid = ld_outboundorder.accountid
left join ld_products on ld_products.productid = ld_outboundorderdetail.productid
left join ld_productcf on ld_productcf.productid = ld_outboundorderdetail.productid
where
	ld_outboundorder.deleted = 0 $where1 $where2 $where3 $where4
group by
	ld_products.productid
	) as T1
left join (
	select
		a.salesorderid,
		b.productid,
		sum(b.quantity) as backquantity,
		sum(
			round(
				(
					100 + ifnull(b.tax1, 0) + ifnull(b.tax2, 0) + ifnull(b.tax3, 0)
				) * (
					round(
						b.quantity * b.listprice + 0.000001,
						2
					) - round(
						b.quantity * b.listprice * ifnull(b.discount_percent, 0) * 0.01 + 0.000001,
						2
					)
				) * 0.01 + 0.000001,
				2
			)
		) as backamount,
		sum(
			round(
				(
					case
					when b.productcost = 0.00 then
						c.costprice
					else
						b.productcost
					end
				) * b.quantity + 0.000001,
				2
			)
		) as backcost,
		c.productid as backproductid
	from
		ld_salesback as a
	left join ld_salesbackdetail as b on a.salesbackid = b.id
	left join ld_products as c on c.productid = b.productid
	where
        a.deleted=0 and 
		a.salesbackstatus <> '中止'
	group by
		b.productid
) as T2 on T1.productid = T2.backproductid
where T1.riqi between '$begin_date' and '$end_date'
group by T1.accountname,T1.yisheng,T1.guige
order by CONV(HEX(left(CONVERT(T1.accounttype USING gbk),1)),16,10) desc,
CONV(HEX(left(CONVERT(T1.accountname USING gbk),1)),16,10),
CONV(HEX(left(CONVERT(T1.yisheng USING gbk),1)),16,10),CONV(HEX(left(CONVERT(T1.guige USING gbk),1)),16,10));
";
 //echo $SQL.'<br><br>';
    $result=$adb->pquery($SQL,array());
$SQL="Create TEMPORARY table IF NOT EXISTS TempTable2 ignore( 
SELECT
	accountid,
	'' AS riqi,
	accounttype,
	accountname,
	'' AS yisheng,
	'' AS guige,
	'小计' AS danjia,
	SUM(qty),
	SUM(amount),
    '' AS cost,
	'' AS iskaipiao
FROM
	TEMPTABLE
GROUP BY
	accountid
 );";
 //echo $SQL.'<br><br>';
$result=$adb->pquery($SQL,array());
$SQL = "Create TEMPORARY table IF NOT EXISTS TempTable4 ignore( 
SELECT
	'' AS accountid,
	'' AS riqi,
	'' AS accounttype,
	'' AS accountname,
	'' AS yisheng,
	'' AS guige,
	'合计' AS danjia,
	SUM(qty) as qty,
	SUM(amount) as amount,
	'' AS cost,
	'' AS iskaipiao
FROM
	TEMPTABLE
);";
 //echo $SQL.'<br><br>';
$result=$adb->pquery($SQL,array());
$SQL = "Create TEMPORARY table IF NOT EXISTS TempTable5 ignore( 
SELECT * FROM (
SELECT * FROM TempTable UNION SELECT * FROM TempTable2
ORDER BY accounttype desc,
accountname ,
yisheng DESC,
guige 
) as T23
);";
 //echo $SQL.'<br><br>';
$result=$adb->pquery($SQL,array());
$SQL = "SELECT * FROM TempTable5 UNION SELECT * FROM TempTable4;";
 //echo $SQL.'<br><br>';
$result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $userNumberList[$i]['accountid'] = $adb->query_result($result, $i, 'accountid');
        $userNumberList[$i]['riqi'] = $adb->query_result($result, $i, 'riqi');
        $userNumberList[$i]['accounttype'] = $adb->query_result($result, $i, 'accounttype');
        $userNumberList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $userNumberList[$i]['yisheng'] = $adb->query_result($result, $i, 'yisheng');
        $userNumberList[$i]['guige'] = $adb->query_result($result, $i, 'guige');
        $userNumberList[$i]['danjia'] = $adb->query_result($result, $i, 'danjia');
        $userNumberList[$i]['qty'] = $adb->query_result($result, $i, 'qty');
        $userNumberList[$i]['amount'] = number_format($adb->query_result($result, $i, 'amount'),2);
        $userNumberList[$i]['cost'] = number_format($adb->query_result($result, $i, 'cost'),2);
        $userNumberList[$i]['iskaipiao'] = $adb->query_result($result, $i, 'iskaipiao');
        
    }
    
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable4;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable5;";
        $result1 = $adb->query($sSQL5); 


        $g=0;
        $f=0;
        foreach($userNumberList as $key=>$arr){

            if($userNumberList[$key]['accountid'] == $userNumberList[$key-1]['accountid'])
               {
                 $g++;
                 $userNumberList[$key]['rowspan']=$g+1;
                 $userNumberList[$key-1]['rowspan']=0;
               }else{
                $g=0;
                $userNumberList[$key]['rowspan']='####error';
               }
               
               if($userNumberList[$key]['yisheng'] == $userNumberList[$key-1]['yisheng'])
               {
                 $f++;
                 $userNumberList[$key]['rowspans']=$f+1;
                 $userNumberList[$key-1]['rowspans']=0;
               }else{
                $f=0;
                $userNumberList[$key]['rowspans']='####error';
               }
    }
    $acount = count($userNumberList);
    for($c=0;$c<$acount;$c++){
        for($j=0;$j<$acount-$c-1;$j++){
            if($userNumberList[$j]['accountid']==$userNumberList[$j+1]['accountid']){
                if($userNumberList[$j]['rowspan']<$userNumberList[$j+1]['rowspan']){
                    $temp = $userNumberList[$j]['rowspan'];
                    $userNumberList[$j]['rowspan'] = $userNumberList[$j+1]['rowspan'];
                    $userNumberList[$j+1]['rowspan'] = $temp;
                }
            }
            
            if($userNumberList[$j]['yisheng']==$userNumberList[$j+1]['yisheng']){
                if($userNumberList[$j]['rowspans']<$userNumberList[$j+1]['rowspans']){
                    $temps = $userNumberList[$j]['rowspans'];
                    $userNumberList[$j]['rowspans'] = $userNumberList[$j+1]['rowspans'];
                    $userNumberList[$j+1]['rowspans'] = $temps;
                }
            }
        } 
    }
   // print_r($userNumberList);
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
$smarty->assign("bill",$bill);
$smarty->assign("accountname",$accountname);
$smarty->assign("Doctor",$Doctor);
$smarty->assign("chengben",$chengben);
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("roleList",$AccountNumber);
$smarty->display('Comprehensivereport/guotongreports.tpl');
exit();
?>