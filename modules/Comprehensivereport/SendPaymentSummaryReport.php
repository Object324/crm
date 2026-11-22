<?php
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();
/*echo '<pre>';
print_r($_REQUEST);*/

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
if($year==''){
    $year = date("Y");
}
//本日，昨日，本周，本月，时间获取
$todayselect=  date('Y-m-d',time());
$yesterdayselect=  date("Y-m-d",time()-24*60*60); 
$week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
$week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));     
$month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));    
$month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
//本年
$begin_this_year=date('Y-01-01');
$end_this_year=date('Y-12-31');
$end_this_year2=(date('Y')+100).'-12-31';
$basicfilterHtml .="<a class='changeday' id='today1' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month1' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

$basicfilterHtml2 .="<a class='changeday' id='today2' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month2' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

$basicfilterHtml3 .="<a class='changeday' id='today3' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month3' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

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
    $begin_date = "";
    $begin_date = $month_begin;
    $end_date = "";
    $end_date = $month_end;
}

if($Report_form_query == 'true')
{
    $begin_end_date_arr2=explode(' ',$_REQUEST['begin_date2']);            
    $begin_date2=trim($begin_end_date_arr2[0]);
    $begin_dates2=explode('-',$_REQUEST['begin_date2']);
    $begin_month2=$begin_dates2[1];
    $end_date2=trim($begin_end_date_arr2[2]);
    $end_dates2=explode('-',$end_date2);
    $end_month2=$end_dates2[1];
    $_REQUEST['month2']=$end_month2;
    $_REQUEST['year2']=$end_dates2[0];
}
else
{  
    $begin_date2 = "";
    $begin_date2 = $month_begin;
    $end_date2 = "";
    $end_date2 = $month_end;
}
if($Report_form_query == 'true')
{
    $begin_end_date_arr3=explode(' ',$_REQUEST['begin_date3']);            
    $begin_date3=trim($begin_end_date_arr3[0]);
    $begin_dates3=explode('-',$_REQUEST['begin_date3']);
    $begin_month3=$begin_dates3[1];
    $end_date3=trim($begin_end_date_arr3[2]);
    $end_dates3=explode('-',$end_date3);
    $end_month3=$end_dates3[1];
    $_REQUEST['month3']=$end_month3;
    $_REQUEST['year3']=$end_dates3[0];
}
else
{  
    $begin_date3 = "";
    $begin_date3 = $month_begin;
    $end_date3 = "";
    $end_date3 = $month_end;
}



$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("begin_date2",$begin_date2);
$smarty->assign("end_date2",$end_date2);
$smarty->assign("begin_date3",$begin_date3);
$smarty->assign("end_date3",$end_date3);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$begin_end_date2='';
$begin_end_date2.=$begin_date2.' '.'-'.' '.$end_date2;
$begin_end_date3='';
$begin_end_date3.=$begin_date3.' '.'-'.' '.$end_date3;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("begin_end_date2",$begin_end_date2);
$smarty->assign("begin_end_date3",$begin_end_date3);
$smarty->assign("basicfilterHtml",$basicfilterHtml);
$smarty->assign("basicfilterHtml2",$basicfilterHtml2);
$smarty->assign("basicfilterHtml3",$basicfilterHtml3);
$where='where 1=1 ';

$cf_1528=getcf_1528();
$cf_1528value = $_REQUEST['cf_1528'];
$smarty->assign("cf_1528",$cf_1528);
if($cf_1528value!=''){
   $where .= " and cf_1528 like '%$cf_1528value%'"; 
}
$vendorname = $_REQUEST['vendorname'];
if($vendorname!=''){
    $where .=' and vendorname like "%'.$vendorname.'%"';
}
$cf_1527 = $_REQUEST['cf_1527'];
if($cf_1527!=''){
    $where .=' and cf_1527 like "%'.$cf_1527.'%"';
}
$purchaseorder_no = $_REQUEST['purchaseorder_no'];
if($purchaseorder_no!=''){
    $where .=' and purchaseorder_no like "%'.$purchaseorder_no.'%"';
}

$List = getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3);
//print_r($List);
function getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3){
    global $adb; 
    //echo $useridSQL;
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS TEMPTABLE IGNORE (
            	SELECT
            		cf_1516 AS cd,
            	CASE
            	WHEN cf_1516 = '按月' THEN
            		12
            	WHEN cf_1516 = '按季' THEN
            		4
            	WHEN cf_1516 = '按年' THEN
            		1
            	END AS checkd,
            	CASE
            	WHEN cf_1516 = '按月' THEN
            		1
            	WHEN cf_1516 = '按季' THEN
            		3
            	WHEN cf_1516 = '按年' THEN
            		12
            	END AS qici
            	FROM
            		ld_cf_1516
            	WHERE
            		cf_1516 <> '按天'   
            );";
           //echo $SQL."<br>";
            $adb->pquery($SQL,array());
                  
        $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable2 IGNORE (
            SELECT ld_purchaseorder.purchaseorderid,cf_1528,purchaseorder_no,vendor_no,vendorname,signed_data,cf_1510,cf_1527,cf_1512,cf_1516,cf_1509,
            cf_1511,	IF (count IS NULL, cf_1510, 0) AS yingfubenjin,
	cf_1515,

IF (
	f3.total IS NOT NULL,
	f3.total,
	ROUND(
		cf_1510 * cf_1512 / checkd * qici,
		2
	) * checkd
) AS yingfulixi,
 IFNULL(f1.total, 0) AS yifulixi,

IF (
	f3.total IS NOT NULL,
	f3.total,
	ROUND(
		cf_1510 * cf_1512 / checkd * qici,
		2
	) * checkd
) - IFNULL(f1.total, 0) AS weifulixi
            FROM ld_purchaseorder 
            LEFT JOIN ld_purchaseordercf ON ld_purchaseorder.purchaseorderid=ld_purchaseordercf.purchaseorderid
            LEFT JOIN ld_vendor ON ld_purchaseorder.vendorid=ld_vendor.vendorid
            LEFT JOIN (SELECT SUM(total) AS total,id FROM paymentSchedule_dividend WHERE paixi=1 GROUP BY id) AS f1
            ON f1.id=ld_purchaseorder.purchaseorderid 
            LEFT JOIN (SELECT COUNT(1) as count,id FROM paymentSchedule_dividend WHERE benjinstatus=1 GROUP BY id) AS f2
            ON f2.id=ld_purchaseorder.purchaseorderid 
            LEFT JOIN temptable ON temptable.cd=ld_purchaseordercf.cf_1516 
            LEFT JOIN (SELECT
                        	total,
                        		id
                        	FROM
                        		paymentSchedule_dividend
                        	WHERE
                        		zqici=0
                        ) AS f3 ON ld_purchaseorder.purchaseorderid=f3.id            
            $where and ld_purchaseorder.deleted=0 AND ld_purchaseorder.approvestatus = '已批准' AND postatus<>'已作废' 
            and cf_1516 <> '按天'   
            and signed_data BETWEEN '$begin_date' AND '$end_date'
            and cf_1509 BETWEEN '$begin_date2' AND '$end_date2'
            and cf_1511 BETWEEN '$begin_date3' AND '$end_date3'
            );";
                   // echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
                $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable3 IGNORE (
                    SELECT 
                    ''purchaseorderid,'合计'cf_1528,''purchaseorder_no,''vendor_no,''vendorname,''signed_data,SUM(cf_1510) as cf_1510,
                    ''cf_1527,''cf_1512,''cf_1516,''cf_1509,
                    ''cf_1511,SUM(yingfubenjin) AS yingfubenjin,''cf_1515,
                    SUM(yingfulixi) AS yingfulixi,
                    SUM(yifulixi) AS yifulixi,
                    SUM(weifulixi) AS weifulixi
                    FROM temptable2);";
                   //echo $SQL."<br>";
               $adb->pquery($SQL,array());    
            $SQL="SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable2
                    	UNION
                    		SELECT
                    			*
                    		FROM
                    			temptable3) AS g1
                    ;";
            $result=$adb->pquery($SQL,array());
            //echo $SQL.'<br>';
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['purchaseorderid'] = $adb->query_result($result, $i, 'purchaseorderid');
        $List[$i]['cf_1528'] = $adb->query_result($result, $i, 'cf_1528');
        $List[$i]['purchaseorder_no'] = $adb->query_result($result, $i, 'purchaseorder_no');
        $List[$i]['vendor_no'] = $adb->query_result($result, $i, 'vendor_no');
        $List[$i]['vendorname'] = $adb->query_result($result, $i, 'vendorname');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['cf_1510'] = $adb->query_result($result, $i, 'cf_1510');
        $List[$i]['cf_1527'] = $adb->query_result($result, $i, 'cf_1527');
        $List[$i]['cf_1512'] = $adb->query_result($result, $i, 'cf_1512');
        $List[$i]['cf_1516'] = $adb->query_result($result, $i, 'cf_1516');
        $List[$i]['cf_1509'] = $adb->query_result($result, $i, 'cf_1509');
        $List[$i]['cf_1511'] = $adb->query_result($result, $i, 'cf_1511');
        $List[$i]['yingfubenjin'] = $adb->query_result($result, $i, 'yingfubenjin');
        $List[$i]['cf_1515'] = $adb->query_result($result, $i, 'cf_1515');
        $List[$i]['yingfulixi'] = $adb->query_result($result, $i, 'yingfulixi');
        $List[$i]['yifulixi'] = $adb->query_result($result, $i, 'yifulixi');
        $List[$i]['weifulixi'] = $adb->query_result($result, $i, 'weifulixi');
    }

    /*echo '<pre>';
    print_r($List);*/
        $sSQL5="drop TEMPORARY  table if exists temptable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable1;"; 
        $result1 = $adb->query($sSQL5);  
        $sSQL5="drop TEMPORARY  table if exists temptable;"; 
        
    return $List;
}
function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}
function getcf_1528(){
        global $adb;
    $SQL = 'select cf_1528 from ld_cf_1528';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $cf_1528List[$i]= $adb->query_result($result, $i, 'cf_1528');
        }

    return $cf_1528List;
}

function getthemonth($date)
{
    $firstday = date('Y-m-01', strtotime($date));
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
    return $lastday;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
//print_r($List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/SendPaymentSummaryReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/SendPaymentSummaryReport.tpl');

exit();
?>