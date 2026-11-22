<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
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
    if($paixi=='是')
        $paixi=1;
    else
        $paixi=0;
    if($benjin=='是')
        $benjin=1;
    else
        $benjin=0;
    $SQL='SELECT * FROM paymentSchedule_dividend WHERE id=? AND zqici=?;';
    $resultselect = $adb->pquery($SQL,array($id,$qici));
    $rowCount = $adb->num_rows($resultselect);
    if($rowCount>0){
        $SQL = 'UPDATE paymentSchedule_dividend SET paixi=?, daydate=?, benjinstatus=? WHERE id=? AND zqici=? AND total=?;';
        $adb->pquery($SQL,array($paixi,$time,$benjin,$id,$qici,$total));
    }else{
        $SQL = 'INSERT INTO paymentSchedule_dividend VALUES (?,?,?,?,?,?,?)';
        $adb->pquery($SQL,array($id,$qici,$paixi,$time,$benjin,'0',$total));
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
    $SQL='SELECT * FROM paymentSchedule_dividend WHERE id=? AND zqici=?;';
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
    //echo $where;
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
          // echo $SQL."<br>";
            $adb->pquery($SQL,array());
                  
            $SQL = "CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable2 IGNORE (
                    	SELECT
                    		ld_purchaseorder.smownerid,
                    		ld_purchaseorder.purchaseorderid,
                    		purchaseorder_no,
                    		cf_1528,
                    		vendor_no,
                    		vendorname,
                    		lastname,
                    		signed_data,
                    		cf_1510,
                    		cf_1512,
                    		cf_1509,
                    		cf_1511,
                    		cf_1516,
                    		cf_1515,
                    		cf_1527,
                    		checkd,
                    		qici,cf_1526
                    	FROM
                    		ld_purchaseorder
                    	LEFT JOIN ld_vendor ON ld_purchaseorder.vendorid = ld_vendor.vendorid 
                    	LEFT JOIN ld_purchaseordercf ON ld_purchaseordercf.purchaseorderid = ld_purchaseorder.purchaseorderid
                    	LEFT JOIN ld_vendorcontacts ON ld_vendorcontacts.vendorcontactsid = ld_purchaseorder.contactid
                    	LEFT JOIN TEMPTABLE ON TEMPTABLE.cd = ld_purchaseordercf.cf_1516
                    	WHERE
                    		ld_purchaseorder.deleted = 0
                    	AND ld_purchaseorder.approvestatus = '已批准'
                    	AND postatus<> '已作废'
                    	AND cf_1515 = '后付'
                    );";
                    //echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
                $SQL="CREATE TEMPORARY TABLE
                        IF NOT EXISTS temptable3 IGNORE (
                        	SELECT
                        		a.*, b.seq,
                        		date_add(
                        			signed_data,
                        			INTERVAL seq * qici MONTH
                        		) AS DAY,
                        		ifnull(
                        			ifnull(cf_1510, 0) * ifnull(cf_1512, 0) / checkd,
                        			0
                        		) AS yingfulixi,
                        		ifnull(cf_1510, 0) AS yingfubenjin
                        	FROM
                        		temptable2 AS a
                        	CROSS JOIN sequence AS b
                        	WHERE
                        		b.seq BETWEEN 1
                        	AND a.checkd
                        );";
                   //echo $SQL."<br>";
               $adb->pquery($SQL,array());    
            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable6 IGNORE (
                    	SELECT
                    		cf_1516 AS cd,
                    		13 checkd,
                    		1 qici
                    	FROM
                    		ld_cf_1516
                    	WHERE
                    		cf_1516 <> '按天'
                    );";
                     $adb->pquery($SQL,array());
                    //echo $SQL.'<br>'; 
                  
           $adb->pquery($SQL,array());
                        $SQL="CREATE TEMPORARY TABLE
                                IF NOT EXISTS temptable4 IGNORE (
                                	SELECT
                                		ld_purchaseorder.smownerid,
                                		ld_purchaseorder.purchaseorderid,
                                		purchaseorder_no,
                                		cf_1528,
                                		vendor_no,
                                		vendorname,
                                		lastname,
                                		signed_data,
                                		cf_1510,
                                		cf_1512,
                                		cf_1509,
                                		cf_1511,
                                		cf_1516,
                                		cf_1515,
                                		cf_1527,
                                		checkd,
                                		qici,cf_1526
                                	FROM
                                		ld_purchaseorder
                                	LEFT JOIN ld_vendor ON ld_purchaseorder.vendorid = ld_vendor.vendorid 
                                	LEFT JOIN ld_purchaseordercf ON ld_purchaseordercf.purchaseorderid = ld_purchaseorder.purchaseorderid
                                	LEFT JOIN ld_vendorcontacts ON ld_vendorcontacts.vendorcontactsid = ld_purchaseorder.contactid
                                	LEFT JOIN temptable6 ON temptable6.cd = ld_purchaseordercf.cf_1516
                                	WHERE
                                		ld_purchaseorder.deleted = 0
                                	AND ld_purchaseorder.approvestatus = '已批准'
                                	AND postatus <> '已作废'
                                	AND cf_1515 = '预付'
                                	AND cf_1516 = '按月'
                                );
                                ";
                    //echo $SQL."<br>";
           $adb->pquery($SQL,array());    
            $SQL2="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    	SELECT
                    		a.*, b.seq,
                    		date_add(
                    			signed_data,
                    			INTERVAL seq * qici - 1 MONTH
                    		) AS DAY,
                    		ifnull(
                    			ifnull(cf_1510, 0) * ifnull(cf_1512, 0) / (checkd-1),
                    			0
                    		) AS yingfulixi,
                    		ifnull(cf_1510, 0) AS yingfubenjin
                    	FROM
                    		temptable4 AS a
                    	CROSS JOIN sequence AS b
                    	WHERE
                    		b.seq BETWEEN 1
                    	AND a.checkd
                    );";
               //echo $SQL2."<br>";
            $adb->pquery($SQL2,array());

            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable7 IGNORE (
                    	SELECT
                    		*
                    	FROM
                    		(
                    			SELECT
                    				*
                    			FROM
                    				temptable5
                    			UNION
                    				SELECT
                    					*
                    				FROM
                    					temptable3
                    		) AS g1
                    	ORDER BY
                    		purchaseorderid,
                    		DAY
                    );";
                     $adb->pquery($SQL,array());
                     //echo $SQL.'<br>';

            $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable8 IGNORE (
                    SELECT 
                            smownerid,
                    		purchaseorderid,
                    		purchaseorder_no,
                    		cf_1528,
                    		vendor_no,
                    		vendorname,
                    		lastname,
                    		signed_data,
                    		cf_1510,
                    		cf_1512,
                    		cf_1509,
                    		cf_1511,
                    		cf_1516,
                    		cf_1515,
                    		cf_1527,
                    		checkd,
                    		qici,cf_1526,
                    		seq,
                    		DAY,
                    		round(yingfulixi,2) AS yingfulixi,
                    		round(yingfubenjin,2) as yingfubenjin,
                    		id,
                    		zqici,
                    		paixi,
                    		daydate,
                    		benjinstatus,
                    		tiqian,total
                     FROM temptable7 
                   	LEFT JOIN paymentSchedule_dividend ON temptable7.purchaseorderid = paymentSchedule_dividend.id
                    and zqici=seq
                     $where and signed_data BETWEEN '$begin_date' AND '$end_date'
                    and cf_1509 BETWEEN '$begin_date2' AND '$end_date2'
                    and cf_1511 BETWEEN '$begin_date3' AND '$end_date3');";
                  //echo $SQL.'<br>';
              $adb->pquery($SQL,array());      
            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable9 IGNORE (
                    	SELECT
                    		''smownerid,
                    		purchaseorderid,
                    		'小计'purchaseorder_no,
                    		''cf_1528,
                    		''vendor_no,
                    		''vendorname,
                    		''lastname,
                    		''signed_data,
                    		''cf_1510,
                    		''cf_1512,
                    		''cf_1509,
                    		''cf_1511,
                    		''cf_1516,
                    		''cf_1515,
                    		''cf_1527,
                    		''checkd,
                    		''qici,cf_1526,
                    		'' seq,
                    		'' DAY,
                    		SUM(yingfulixi) AS yingfulixi,
                    		'' yingfubenjin,
                    		'' id,
                    		'' zqici,
                    		'' paixi,
                    		'' daydate,
                    		'' benjinstatus,
                    		'' tiqian,''total
                    	FROM
                    		temptable8
                    	GROUP BY
                    		purchaseorderid
                    );";
              $adb->pquery($SQL,array());
              //echo $SQL.'<br>';
              $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable10 IGNORE (
                    	SELECT
                    		''smownerid,
                    		'合计'purchaseorderid,
                    		'合计'purchaseorder_no,
                    		''cf_1528,
                    		''vendor_no,
                    		''vendorname,
                    		''lastname,
                    		''signed_data,
                    		''cf_1510,
                    		''cf_1512,
                    		''cf_1509,
                    		''cf_1511,
                    		''cf_1516,
                    		''cf_1515,
                    		''cf_1527,
                    		''checkd,
                    		''qici,''cf_1526,
                    		'' seq,
                    		'' DAY,
                    		SUM(yingfulixi) AS yingfulixi,
                    		'' yingfubenjin,
                    		'' id,
                    		'' zqici,
                    		'' paixi,
                    		'' daydate,
                    		'' benjinstatus,
                    		'' tiqian,''total
                    	FROM
                    		temptable8
                    );";
              $adb->pquery($SQL,array());
              //echo $SQL.'<br>';
              $SQL = "SELECT
                        	*
                        FROM
                        	temptable9
                        UNION
                        	SELECT
                        		*
                        	FROM
                        		temptable8
                        	UNION
                        		SELECT
                        			*
                        		FROM
                        			temptable10
                        		ORDER BY
                        			purchaseorderid,
                        			purchaseorder_no,-seq DESC";           
            $result=$adb->pquery($SQL,array());
            //echo $SQL.'<br>';
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        if($adb->query_result($result, $i, 'tiqian')==1){
            $purchaseorderid=$adb->query_result($result, $i, 'purchaseorderid');
            $tiqianid[] = $purchaseorderid;
        }
        if($purchaseorderid==$adb->query_result($result, $i, 'purchaseorderid')
        &&($adb->query_result($result, $i, 'purchaseorder_no')!='小计'
        &&$adb->query_result($result, $i, 'tiqian')!=1)){
           /* echo $salesorderid.'|'.$adb->query_result($result, $i, 'salesorderid')
            .'|'.$adb->query_result($result, $i, 'salesorder_no').'|'.
            $adb->query_result($result, $i, 'tiqian').'|'.$adb->query_result($result, $i, 'seq').'<br>';*/
            continue;
        }
        $List[$i]['purchaseorderid'] = $adb->query_result($result, $i, 'purchaseorderid');
        $List[$i]['purchaseorder_no'] = $adb->query_result($result, $i, 'purchaseorder_no');
        $List[$i]['cf_1528'] = $adb->query_result($result, $i, 'cf_1528');
        $List[$i]['vendor_no'] = $adb->query_result($result, $i, 'vendor_no');
        $List[$i]['vendorname'] = $adb->query_result($result, $i, 'vendorname');
        $List[$i]['lastname'] = $adb->query_result($result, $i, 'lastname');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['cf_1510'] = $adb->query_result($result, $i, 'cf_1510');
        $List[$i]['cf_1512'] = $adb->query_result($result, $i, 'cf_1512');
        $List[$i]['cf_1509'] = $adb->query_result($result, $i, 'cf_1509');
        $List[$i]['cf_1511'] = $adb->query_result($result, $i, 'cf_1511');
        $List[$i]['cf_1516'] = $adb->query_result($result, $i, 'cf_1516');
        $List[$i]['cf_1515'] = $adb->query_result($result, $i, 'cf_1515');
        $List[$i]['cf_1527'] = $adb->query_result($result, $i, 'cf_1527');
        $List[$i]['checkd'] = $adb->query_result($result, $i, 'checkd');
        $List[$i]['tiqian'] = $adb->query_result($result, $i, 'tiqian');
        $List[$i]['seq'] = trim($adb->query_result($result, $i, 'seq'));
        $List[$i]['cf_1526'] = $adb->query_result($result, $i, 'cf_1526');
        $List[$i]['check']=$purchaseorderidtype;
        if($adb->query_result($result, $i, 'daydate')=='') 
            $List[$i]['day'] =$adb->query_result($result, $i, 'day');
        else
            $List[$i]['day'] =$adb->query_result($result, $i, 'daydate');
        $List[$i]['paixi'] = $adb->query_result($result, $i, 'paixi');
        $List[$i]['benjinstatus'] = $adb->query_result($result, $i, 'benjinstatus');
        
        if($adb->query_result($result, $i, 'tiqian')==1){
	       $d1 = strtotime($List[$i]['day']);
           if($List[$i]['seq'] !='1'){
            $d2 = strtotime($List[$i-1]['day']);
           }else{
            $d2 = strtotime($List[$i]['signed_data']);
           }
           
	       $Days = round(($d1-$d2)/3600/24);
            if($List[$i]['seq']==13&&$List[$i]['cf_1515']=='预付')
                $List[$i]['yingfulixi'] =0;
            else
                $List[$i]['yingfulixi'] = $List[$i]['cf_1510']*$List[$i]['cf_1512']/365*$Days;
            //$List[$i]['yingfulixi'] = $List[$i]['cf_1519'].'|'.$List[$i]['cf_1501']."|".$Days;

        }else{
           $List[$i]['yingfulixi'] = $adb->query_result($result, $i, 'yingfulixi'); 
        }
        $List[$i]['yingfubenjin'] = $adb->query_result($result, $i, 'yingfubenjin');
        if($List[$i]['purchaseorderid']==$adb->query_result($result, $i-1, 'purchaseorderid')){
            if($List[$i]['purchaseorder_no']!='小计'&&$List[$i]['purchaseorder_no']!='合计')
            $List[$i]['purchaseorder_no']='';
            $List[$i]['cf_1528'] = '';
            $List[$i]['vendor_no'] = '';
            $List[$i]['vendorname'] = '';
            $List[$i]['lastname'] = '';
            $List[$i]['signed_data'] = '';
            $List[$i]['cf_1510'] = '';
            $List[$i]['cf_1512'] = '';
            $List[$i]['cf_1509'] = '';
            $List[$i]['cf_1511'] = '';
            $List[$i]['cf_1516'] = '';
            $List[$i]['cf_1527'] = '';
        }
        if($_REQUEST['type']=='tiqian'){
            $SQL = 'UPDATE paymentSchedule_dividend SET total=? WHERE id=? AND zqici=?;';
            $adb->pquery($SQL,array($List[$i]['yingfulixi'],$List[$i]['purchaseorderid'],$List[$i]['seq']));
           // echo $List[$i]['yingfulixi'];
          }
    }
    
    foreach($List as $key=>$arr){
        foreach($tiqianid as $key2=>$arr2){
            if($arr2==$List[$key]['purchaseorderid']){
                $List[$key]['typetiqian']=1;
            }
        }
        if($List[$key]['purchaseorderid']==$List[$key+1]['purchaseorderid']&&$List[$key+1]['purchaseorder_no']!='小计'){
            $List[$key]['yingfubenjin']='';
        }
        if($List[$key]['cf_1515']=='预付'&&$List[$key]['seq']==13){
            $List[$key]['yingfulixi']='';
        }
        if($List[$key]['purchaseorderid']==$List[$key-1]['purchaseorderid']||$List[$key]['purchaseorder_no']=='合计'){
            $List[$key]['cf_1515']='';
        }
        if($List[$key]['purchaseorder_no']=='合计'){
            $List[$key]['cf_1510']='';
        }
    }
    foreach($List as $key=>$arr){

        if(($List[$key]['purchaseorderid']==$List[$key+1]['purchaseorderid']
        ||$List[$key]['purchaseorderid']==$List[$key-1]['purchaseorderid'])
        &&$List[$key]['purchaseorder_no']!='小计'){
            $acc[$List[$key]['purchaseorderid']] += $List[$key]['yingfulixi'];
        }elseif($List[$key]['seq']==1&&$List[$key]['tiqian']==1){
            $acc[$List[$key]['purchaseorderid']] = $List[$key]['yingfulixi'];
        }
        if($List[$key]['purchaseorder_no']!='小计'&&$List[$key]['purchaseorder_no']!='合计'){
            $acc2 += $List[$key]['yingfulixi'];
             
        }
       /* echo '<pre>';
        print_r($List);*/
        if($List[$key]['purchaseorder_no']=='小计'){
               $List[$key]['yingfulixi']=$acc[$List[$key]['purchaseorderid']]; 
               //echo $List[$key]['salesorderid'].'|'.'<br>';
               $SQL='SELECT * FROM paymentSchedule_dividend WHERE id=? AND zqici=0;';
                $resultselect = $adb->pquery($SQL,array($List[$key]['purchaseorderid']));
                $rowCount = $adb->num_rows($resultselect);
                if($rowCount>0){
                    $SQL = 'UPDATE paymentSchedule_dividend set total=? WHERE id=? AND zqici=0;';
                    $adb->pquery($SQL,array($acc[$List[$key]['purchaseorderid']],$List[$key]['purchaseorderid']));
                }else{
                    $SQL = "INSERT INTO paymentSchedule_dividend (id,zqici,total) VALUES (?,?,?)";
                    $adb->pquery($SQL,array($List[$key]['purchaseorderid'],'0',$acc[$List[$key]['purchaseorderid']]));
                }
            }
        if($List[$key]['purchaseorder_no']=='合计'){
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
    $smarty->display('Comprehensivereport/SendPaymentScheduleReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/SendPaymentScheduleReport.tpl');

exit();
?>