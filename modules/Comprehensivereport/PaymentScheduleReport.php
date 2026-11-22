<?php
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();
/*echo '<pre>';
print_r($_REQUEST);*/
if($_REQUEST['type']=='save'){
    $time = $_REQUEST['time'];
    $paixi = $_REQUEST['paixi'];
    $benjin = $_REQUEST['benjin'];
    $qici = $_REQUEST['qici'];
    $id = $_REQUEST['id'];
    $total = $_REQUEST['total'];
	$sflx = $_REQUEST['sflx'];
    if($paixi=='是')
        $paixi=1;
    else
        $paixi=0;
    if($benjin=='是')
        $benjin=1;
    else
        $benjin=0;
    $SQL='SELECT 1 FROM paymentSchedule_dividend WHERE id=? AND zqici=?;';
    $resultselect = $adb->pquery($SQL,array($id,$qici));
    $rowCount = $adb->num_rows($resultselect);
    if($rowCount>0){
        $SQL = 'UPDATE paymentSchedule_dividend SET paixi=?, daydate=?, benjinstatus=?, sflx=? WHERE id=? AND zqici=? and total=?;';
        $adb->pquery($SQL,array($paixi,$time,$benjin,$sflx,$id,$qici,$total));
    }else{
        $SQL = 'INSERT INTO paymentSchedule_dividend VALUES (?,?,?,?,?,?,?,?)';
        $adb->pquery($SQL,array($id,$qici,$paixi,$time,$benjin,'0',$total,$sflx));
    }
}
if($_REQUEST['type']=='tiqian'){
    $time = $_REQUEST['time'];
    $paixi = $_REQUEST['paixi'];
    $benjin = $_REQUEST['benjin'];
    $qici = $_REQUEST['qici'];
    $id = $_REQUEST['id'];
    if($paixi=='是')
        $paixi=1;
    else
        $paixi=0;
    if($benjin=='是')
        $benjin=1;
    else
        $benjin=0;
    $SQL='SELECT 1 FROM paymentSchedule_dividend WHERE id=? AND zqici=?;';
    $resultselect = $adb->pquery($SQL,array($id,$qici));
    $rowCount = $adb->num_rows($resultselect);
    if($rowCount>0){
        $SQL = 'UPDATE paymentSchedule_dividend SET paixi=?, daydate=?, benjinstatus=?,tiqian=1 WHERE id=? AND zqici=?;';
        $adb->pquery($SQL,array($paixi,$time,$benjin,$id,$qici));
    }else{
        $SQL = 'INSERT INTO paymentSchedule_dividend VALUES (?,?,?,?,?,?)';
        $adb->pquery($SQL,array($id,$qici,$paixi,$time,$benjin,'1'));
    }
}
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
//进款日期
$basicfilterHtml .="<a class='changeday' id='today1' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month1' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 
//项目启动日期
$basicfilterHtml2 .="<a class='changeday' id='today2' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month2' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 
//本金到期日期
$basicfilterHtml3 .="<a class='changeday' id='today3' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month3' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 
//预计付款日  
$basicfilterHtml4 .="<a class='changeday' id='today4' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday4' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week4' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month4' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year4' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all4' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime4(this,'all','1900-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

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
if($Report_form_query == 'true')
{
    $begin_end_date_arr4=explode(' ',$_REQUEST['begin_date4']);            
    $begin_date4=trim($begin_end_date_arr4[0]);
    $begin_dates4=explode('-',$_REQUEST['begin_date4']);
    $begin_month4=$begin_dates4[1];
    $end_date4=trim($begin_end_date_arr4[2]);
    $end_dates4=explode('-',$end_date4);
    $end_month4=$end_dates4[1];
    $_REQUEST['month3']=$end_month4;
    $_REQUEST['year3']=$end_dates4[0];
}
else
{  
    $begin_date4 = "";
    $begin_date4 = $month_begin;
    $end_date4 = "";
    $end_date4 = $month_end;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("begin_date2",$begin_date2);
$smarty->assign("end_date2",$end_date2);
$smarty->assign("begin_date3",$begin_date3);
$smarty->assign("end_date3",$end_date3);
$smarty->assign("begin_date4",$begin_date4);
$smarty->assign("end_date4",$end_date4);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$begin_end_date2='';
$begin_end_date2.=$begin_date2.' '.'-'.' '.$end_date2;
$begin_end_date3='';
$begin_end_date3.=$begin_date3.' '.'-'.' '.$end_date3;
$begin_end_date4='';
$begin_end_date4.=$begin_date4.' '.'-'.' '.$end_date4;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("begin_end_date2",$begin_end_date2);
$smarty->assign("begin_end_date3",$begin_end_date3);
$smarty->assign("begin_end_date4",$begin_end_date4);
$smarty->assign("basicfilterHtml",$basicfilterHtml);
$smarty->assign("basicfilterHtml2",$basicfilterHtml2);
$smarty->assign("basicfilterHtml3",$basicfilterHtml3);
$smarty->assign("basicfilterHtml4",$basicfilterHtml4);
$where='where 1=1 ';
$cf_1523=getcf_1523();
//获取归属团队下拉框内容
$cf_1539 = getFieldSelectValue('cf_1539','SalesOrder');
$smarty->assign('cf_1539',$cf_1539);
//获取理财产品下拉框内容
$cf_1541 = getFieldSelectValue('cf_1541','SalesOrder');
$smarty->assign('cf_1541',$cf_1541);
//获取隶属下拉框内容
$cf_1540 = getFieldSelectValue('cf_1540','SalesOrder');
$smarty->assign('cf_1540',$cf_1540);
//获取代持人下拉框内容
$cf_1542 = getFieldSelectValue('cf_1542','SalesOrder');
$smarty->assign('cf_1542',$cf_1542);

$cf_1523value = $_REQUEST['cf_1523'];
$smarty->assign("cf_1523",$cf_1523);
if($cf_1523value!=''){
   $where .= " and cf_1523 like '%$cf_1523value%'"; 
}
if(!empty($_REQUEST['cf_1539'])){
	$where .= " and cf_1539 = '".$_REQUEST['cf_1539']."'"; 
}
if(!empty($_REQUEST['cf_1541'])){
	$where .= " and cf_1541 = '".$_REQUEST['cf_1541']."'"; 
}
if(!empty($_REQUEST['cf_1540'])){
	$where .= " and cf_1540 = '".$_REQUEST['cf_1540']."'"; 
}
if(!empty($_REQUEST['cf_1542'])){
	$where .= " and cf_1542 = '".$_REQUEST['cf_1542']."'"; 
}
$accountname = $_REQUEST['accountname'];
if($accountname!=''){
    $where .=' and accountname like "%'.$accountname.'%"';
}
$cf_1522 = $_REQUEST['cf_1522'];
if($cf_1522!=''){
    $where .=' and cf_1522 like "%'.$cf_1522.'%"';
}
$salesorder_no = $_REQUEST['salesorder_no'];
if($salesorder_no!=''){
    $where .=' and salesorder_no like "%'.$salesorder_no.'%"';
}

$List = getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3,$begin_date4,$end_date4);
//print_r($List);
function getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3,$begin_date4,$end_date4){
    global $adb; 
   // echo $where;
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS TEMPTABLE IGNORE (
            	SELECT
            		cf_1502 AS cd,
            	CASE
            	WHEN cf_1502 = '按月' THEN
            		12
            	WHEN cf_1502 = '按季' THEN
            		4
            	WHEN cf_1502 = '按年' THEN
            		1
            	END AS checkd,
            	CASE
            	WHEN cf_1502 = '按月' THEN
            		1
            	WHEN cf_1502 = '按季' THEN
            		3
            	WHEN cf_1502 = '按年' THEN
            		12
            	END AS qici
            	FROM
            		ld_cf_1502
            	WHERE
            		cf_1502 <> '按天'
            );";
          // echo $SQL."<br>";
            $adb->pquery($SQL,array());
                  
            $SQL = "CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable2 IGNORE (
                    SELECT ld_salesorder.smownerid,ld_salesorder.salesorderid,salesorder_no,
                    cf_1523,account_no,accountname,cf_1539,cf_1541,cf_1540,cf_1542,lastname,signed_data,cf_1519,
                        cf_1501,duedate,cf_1499,cf_1502,cf_1503,cf_1522,checkd,qici,cf_1521
                        FROM ld_salesorder 
                        LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid
                        LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid=ld_salesorder.salesorderid
                        LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid=ld_salesorder.contactid
                        LEFT JOIN temptable ON temptable.cd=ld_salesordercf.cf_1502 
                        WHERE ld_salesorder.deleted=0 AND ld_salesorder.approvestatus='已批准' AND sostatus<>'已作废'
                        AND cf_1503='后付'
                    );";
                   // echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
                $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable3 IGNORE (
                    SELECT
                    		a.*,
                    		b.seq,
                    		date_add(
                    			date_sub(signed_data,interval 1 day),
                    			INTERVAL seq * qici MONTH
                    		) AS DAY,
                            ifnull(ifnull(cf_1519,0)*ifnull(cf_1501,0)/checkd,0) AS yingfulixi,
                            ifnull(cf_1519,0) as yingfubenjin
                    FROM
                    	temptable2 AS a
                    CROSS JOIN sequence AS b
                    WHERE
                    	b.seq BETWEEN 1
                    AND a.checkd);";
                  // echo $SQL."<br>";
               $adb->pquery($SQL,array());    
            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable6 IGNORE (
                    	SELECT
                    		cf_1502 AS cd,
                    		13 checkd,
                    		1 qici
                    	FROM
                    		ld_cf_1502
                    	WHERE
                    		cf_1502 <> '按天'
                    );";
                     $adb->pquery($SQL,array());
                    //echo $SQL.'<br>'; 
                  
           $adb->pquery($SQL,array());
                        $SQL="CREATE TEMPORARY TABLE
                                IF NOT EXISTS temptable4 IGNORE (
                                	SELECT
                                        ld_salesorder.smownerid,
                                        ld_salesorder.salesorderid,
                                		salesorder_no,
                                		cf_1523,
                                		account_no,
                                		accountname,cf_1539,cf_1541,cf_1540,cf_1542,lastname,
                                		signed_data,
                                		cf_1519,
                                		cf_1501,
                                		duedate,
                                		cf_1499,
                                		cf_1502,
                                		cf_1503,
                                		cf_1522,checkd,qici,cf_1521
                                	FROM
                                		ld_salesorder
                                	LEFT JOIN ld_account ON ld_salesorder.accountid = ld_account.accountid
                                	LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
                                       LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
                                	LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_salesorder.contactid
                                	LEFT JOIN temptable6 ON temptable6 .cd = ld_salesordercf.cf_1502
                                	WHERE ld_salesorder.deleted=0 AND ld_salesorder.approvestatus='已批准' AND sostatus<>'已作废'
                                	 AND cf_1503='预付' AND cf_1502 = '按月'
                                );";
                    //echo $SQL."<br>";
           $adb->pquery($SQL,array());    
            $SQL2="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    SELECT
                    		a.*,
                    		b.seq,
                    		date_add(
                    			date_sub(signed_data,interval 1 day),
                    			INTERVAL seq * qici-1 MONTH
                    		) AS DAY,
                            ifnull(ifnull(cf_1519,0)*ifnull(cf_1501,0)/(checkd-1),0)
                             AS yingfulixi,ifnull(cf_1519,0) as yingfubenjin
                    FROM
                    	temptable4 AS a
                    CROSS JOIN sequence AS b
                    WHERE
                    	b.seq BETWEEN 1
                    AND a.checkd);";
                //echo $SQL2."<br>";
            $adb->pquery($SQL2,array());

            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable7 IGNORE (
                    	SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable5
                    	UNION
                    		SELECT
                    			*
                    		FROM
                    			temptable3) AS g1 ORDER BY 
                                        salesorderid,day);";
                     $adb->pquery($SQL,array());
                    // echo $SQL.'<br>';

            $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable8 IGNORE (
                    SELECT 
                            smownerid,
                    		salesorderid,
                    		salesorder_no,
                  		    cf_1523,
                    		account_no,
                    		accountname,cf_1539,cf_1541,cf_1540,cf_1542,
                    		lastname,
                    		signed_data,
                    		cf_1519,
                    		cf_1501,
                    		duedate,
                    		cf_1499,
                    		cf_1502,
                    		cf_1503,
                    		cf_1522,
                    		checkd,
                    		qici,
                    		cf_1521,
                    		seq,DAY,
                            round(yingfulixi,2) as yingfulixi,
							ifnull(round(sflx,2),round(yingfulixi,2)) as sflx,
                            round(yingfubenjin,2) as yingfubenjin,id,zqici,paixi,date_sub(daydate,interval 1 day) as daydate,benjinstatus,tiqian,total
                     FROM temptable7 
                    left join paymentSchedule_dividend ON temptable7.salesorderid=paymentSchedule_dividend.id 
                    and zqici=seq
                     $where and signed_data BETWEEN '$begin_date' AND '$end_date'
                    and duedate BETWEEN '$begin_date2' AND '$end_date2'
                    and cf_1499 BETWEEN '$begin_date3' AND '$end_date3'
					and DAY BETWEEN '$begin_date4' AND '$end_date4');";
                   // echo $SQL.'<br>';
              $adb->pquery($SQL,array());      
            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable9 IGNORE (
                    SELECT
                            ''smownerid,
                    		salesorderid,
                    		'小计'salesorder_no,
                    		''cf_1523,
                    		''account_no,
                    		''accountname,
							''cf_1539,
							''cf_1541,
							''cf_1540,
							''cf_1542,
                    		''lastname,
                    		''signed_data,
                    		''cf_1519,
                    		''cf_1501,
                    		''duedate,
                    		''cf_1499,
                    		''cf_1502,
                    		''cf_1503,
                    		''cf_1522,
                    		''checkd,
                    		''qici,
                    		''cf_1521,
                    		''seq,''DAY,SUM(yingfulixi) as yingfulixi,SUM(sflx) as sflx,'' yingfubenjin,''id,''zqici,''paixi,''daydate,''benjinstatus,''tiqian,''total
                    FROM
                    	temptable8
                    GROUP BY
                    	salesorderid);";
              $adb->pquery($SQL,array());
             // echo $SQL.'<br>';
              $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable10 IGNORE (
                    SELECT
                            ''smownerid,
                    		'合计'salesorderid,
                    		'合计'salesorder_no,
                    		''cf_1523,
                    		''account_no,
                    		''accountname,
							''cf_1539,
							''cf_1541,
							''cf_1540,
							''cf_1542,
                    		''lastname,
                    		''signed_data,
                    		''cf_1519,
                    		''cf_1501,
                    		''duedate,
                    		''cf_1499,
                    		''cf_1502,
                    		''cf_1503,
                    		''cf_1522,
                    		''checkd,
                    		''qici,
                    		''cf_1521,
                    		''seq,''DAY,SUM(yingfulixi) as yingfulixi,SUM(sflx) as sflx,'' yingfubenjin,''id,''zqici,''paixi,''daydate,''benjinstatus,''tiqian,''total
                    FROM
                    	temptable8);";
              $adb->pquery($SQL,array());
             // echo $SQL.'<br>';
              $SQL = "SELECT * FROM temptable9 UNION SELECT * FROM temptable8  UNION SELECT * FROM temptable10 ORDER BY salesorderid,salesorder_no,-seq DESC";           
            $result=$adb->pquery($SQL,array());
          // echo $SQL.'<br>';
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        if($adb->query_result($result, $i, 'tiqian')==1){
            $salesorderid=$adb->query_result($result, $i, 'salesorderid');
            $tiqianid[] = $salesorderid;
        }
        if($salesorderid==$adb->query_result($result, $i, 'salesorderid')
        &&($adb->query_result($result, $i, 'salesorder_no')!='小计'
        &&$adb->query_result($result, $i, 'tiqian')!=1)){
           /* echo $salesorderid.'|'.$adb->query_result($result, $i, 'salesorderid')
            .'|'.$adb->query_result($result, $i, 'salesorder_no').'|'.
            $adb->query_result($result, $i, 'tiqian').'|'.$adb->query_result($result, $i, 'seq').'<br>';*/
            continue;
        }
        $List[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['cf_1523'] = $adb->query_result($result, $i, 'cf_1523');
        $List[$i]['account_no'] = $adb->query_result($result, $i, 'account_no');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['lastname'] = $adb->query_result($result, $i, 'lastname');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['cf_1519'] = $adb->query_result($result, $i, 'cf_1519');
        $List[$i]['cf_1501'] = $adb->query_result($result, $i, 'cf_1501');
        $List[$i]['duedate'] = $adb->query_result($result, $i, 'duedate');
        $List[$i]['cf_1499'] = $adb->query_result($result, $i, 'cf_1499');
        $List[$i]['cf_1502'] = $adb->query_result($result, $i, 'cf_1502');
        $List[$i]['cf_1503'] = $adb->query_result($result, $i, 'cf_1503');
        $List[$i]['cf_1522'] = $adb->query_result($result, $i, 'cf_1522');
		$List[$i]['cf_1539'] = $adb->query_result($result, $i, 'cf_1539');//归属团队
		$List[$i]['cf_1541'] = $adb->query_result($result, $i, 'cf_1541');//理财产品
		$List[$i]['cf_1540'] = $adb->query_result($result, $i, 'cf_1540');//隶属
		$List[$i]['cf_1542'] = $adb->query_result($result, $i, 'cf_1542');//代持人
        $List[$i]['checkd'] = $adb->query_result($result, $i, 'checkd');
        $List[$i]['tiqian'] = $adb->query_result($result, $i, 'tiqian');
        $List[$i]['seq'] = trim($adb->query_result($result, $i, 'seq'));
        $List[$i]['cf_1521'] = $adb->query_result($result, $i, 'cf_1521');
        $List[$i]['check']=$salesorderidtype;
        if($adb->query_result($result, $i, 'daydate')=='') 
            $List[$i]['day'] =$adb->query_result($result, $i, 'day');
        else
            $List[$i]['day'] =$adb->query_result($result, $i, 'daydate');
        
        if($adb->query_result($result, $i, 'tiqian')==1){
	       $d1 = strtotime($List[$i]['day']);
           if($List[$i]['seq'] !='1'){
            $d2 = strtotime($List[$i-1]['day']);
           }else{
            $d2 = strtotime($List[$i]['signed_data']);
           }
           
	       $Days = round(($d1-$d2)/3600/24);
            if($List[$i]['seq']==13&&$List[$i]['cf_1503']=='预付')
                $List[$i]['yingfulixi'] =0;
            else
                $List[$i]['yingfulixi'] = $List[$i]['cf_1519']*$List[$i]['cf_1501']/365*$Days;
          //  echo $List[$i]['yingfulixi'].'='.$List[$i]['cf_1519'].'*'.$List[$i]['cf_1501']."/365*".$Days.'<br>';
          if($_REQUEST['type']=='tiqian'){
            //echo $List[$i]['yingfulixi'].'|'.$List[$i]['salesorderid'].'|'.$List[$i]['seq'];
            $SQL = 'UPDATE paymentSchedule_dividend SET total=\''.$List[$i]['yingfulixi'].'\' WHERE id='.$List[$i]['salesorderid'].' AND zqici='.$List[$i]['seq'].';';
            $adb->pquery($SQL,array());
            //echo $SQL;
          }
        }else{
           $List[$i]['yingfulixi'] = $adb->query_result($result, $i, 'yingfulixi'); 
        }
		//实付利息 如果实付利息为空 则默认取应付利息
		$sflx = $adb->query_result($result, $i, 'sflx');
		if(!empty($sflx))
			$List[$i]['sflx'] = $sflx; 
		else
			$List[$i]['sflx'] =  $List[$i]['yingfulixi']; 
        $List[$i]['yingfubenjin'] = $adb->query_result($result, $i, 'yingfubenjin');
        if($List[$i]['salesorderid']==$adb->query_result($result, $i-1, 'salesorderid')){
            if($List[$i]['salesorder_no']!='小计'&&$List[$i]['salesorder_no']!='合计')
            $List[$i]['salesorder_no']='';
            $List[$i]['cf_1523'] = '';
            $List[$i]['account_no'] = '';
            $List[$i]['accountname'] = '';
			$List[$i]['cf_1539'] = '';
			$List[$i]['cf_1541'] = '';
			$List[$i]['cf_1540'] = '';
			$List[$i]['cf_1542'] = '';
            $List[$i]['lastname'] = '';
            $List[$i]['signed_data'] = '';
            $List[$i]['cf_1519'] = '';
            $List[$i]['cf_1501'] = '';
            $List[$i]['duedate'] = '';
            $List[$i]['cf_1499'] = '';
            $List[$i]['cf_1502'] = '';
            $List[$i]['cf_1522'] = '';
        }
    }
    foreach($List as $key=>$arr){
        foreach($tiqianid as $key2=>$arr2){
            if($arr2==$List[$key]['salesorderid']){
                $List[$key]['typetiqian']=1;
            }
        }
        if($List[$key]['salesorderid']==$List[$key+1]['salesorderid']&&$List[$key+1]['salesorder_no']!='小计'){
            $List[$key]['yingfubenjin']='';
        }
        if($List[$key]['cf_1503']=='预付'&&$List[$key]['seq']==13){
            $List[$key]['yingfulixi']='0';
        }
        if($List[$key]['salesorderid']==$List[$key-1]['salesorderid']||$List[$key]['salesorder_no']=='合计'){
            $List[$key]['cf_1503']='';
        }
        if($List[$key]['salesorder_no']=='合计'){
            $List[$key]['cf_1519']='';
        }
    }
      /* echo '<pre>';
    print_r($List);
    echo '--------------------';*/
    foreach($List as $key=>$arr){
        if(($List[$key]['salesorderid']==$List[$key+1]['salesorderid']
        ||$List[$key]['salesorderid']==$List[$key-1]['salesorderid'])
        &&$List[$key]['salesorder_no']!='小计'){
            $acc[$List[$key]['salesorderid']] += $List[$key]['yingfulixi'];
        }elseif($List[$key]['seq']==1&&$List[$key]['tiqian']==1){
            $acc[$List[$key]['salesorderid']] = $List[$key]['yingfulixi'];
        }
        if($List[$key]['salesorder_no']!='小计'
        &&$List[$key]['salesorder_no']!='合计'){
            $acc2 += $List[$key]['yingfulixi'];
            
        }
        //echo $List[$key]['salesorder_no'].'|'.$acc[$List[$key]['salesorderid']].'<br>';
        if($List[$key]['salesorder_no']=='小计'&&$acc[$List[$key]['salesorderid']]!=''){
               $List[$key]['yingfulixi']=$acc[$List[$key]['salesorderid']]; 
               
              // echo $List[$key]['salesorderid'].'|'.'<br>';
               
                $SQL='SELECT * FROM paymentSchedule_dividend WHERE id=? AND zqici=0;';
                $resultselect = $adb->pquery($SQL,array($List[$key]['salesorderid']));
                $rowCount = $adb->num_rows($resultselect);
                if($rowCount>0){
                    $SQL = 'UPDATE paymentSchedule_dividend set total=? WHERE id=? AND zqici=0;';
                    $adb->pquery($SQL,array($acc[$List[$key]['salesorderid']],$List[$key]['salesorderid']));
                }else{
                    $SQL = "INSERT INTO paymentSchedule_dividend (id,zqici,total) VALUES (?,?,?)";
                    $adb->pquery($SQL,array($List[$key]['salesorderid'],'0',$acc[$List[$key]['salesorderid']]));
                }
               
            }
        if($List[$key]['salesorder_no']=='合计'){
               $List[$key]['yingfulixi']=$acc2; 
               //echo $List[$key]['salesorderid'].'|'.$acc2.'<br>';
            }      

    }
    /*echo '<pre>';
    print_r($List);*/
        $sSQL5="drop TEMPORARY  table if exists temptable10;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable8;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable9;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable7;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable6;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable5;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable4;";
        $result1 = $adb->query($sSQL5); 
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
function getcf_1523(){
        global $adb;
    $SQL = 'select cf_1523 from ld_cf_1523';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $cf_1523List[$i]= $adb->query_result($result, $i, 'cf_1523');
        }

    return $cf_1523List;
}
function getthemonth($date)
{
    $firstday = date('Y-m-01', strtotime($date));
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
    return $lastday;
}
//获取模块下拉框内容
function getFieldSelectValue($fieldname,$module){
	global $adb;
	$value = '';
	$field_obj=Field::getInstance($module,$adb);
	$showfieldvalue=new ShowFieldValue($field_obj,$module,constant('SHOW_EDITVIEW'));
	$moduleFields=$field_obj->getModuleFields();
	$showvalue=$showfieldvalue->getFieldValueByField($moduleFields[$fieldname],'','');
	if(!empty($showvalue['optionvalue'])){
		foreach($showvalue['optionvalue'] as $key=>$data){
			if(!empty($data[0])){
				$value[$key] = $data[0];
			}
		}
	}
	return $value;
}

//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
//print_r($List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/PaymentScheduleReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/PaymentScheduleReport.tpl');

exit();
?>