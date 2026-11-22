<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();

if($_REQUEST['type']=='paixi'){
    $sid=$_REQUEST['sid'];
    $seq=$_REQUEST['seq'];
    $DAY=$_REQUEST['DAY'];
    $accountname=$_REQUEST['accountname'];
    $value=$_REQUEST['value'];
    
        if($seq=='暑假旅游基金'){
            $seq='-1';
        }elseif($seq=='开学礼'){
            $seq='-2';
        }elseif($seq=='毕业后创业基金'){
           $seq='-3';
        }
        
    $SQL="INSERT INTO shuowei_dividend VALUE ('$sid','$seq','1','$DAY')";
  
    $adb->pquery($SQL,array());
    $sql = 'SELECT accountname,cf_1501,salesorder_no FROM ld_salesorder
            LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid
            LEFT JOIN ld_accountscf ON ld_account.accountid=ld_accountscf.accountid
            WHERE salesorderid='.$sid;
  
            $result=$adb->pquery($sql,array());
          $accountname = $adb->query_result($result, 0, 'accountname');
          $cf_1501 = $adb->query_result($result, 0, 'cf_1501');
          $salesorder_no = $adb->query_result($result, 0, 'salesorder_no');
          $accountphone=$cf_1501 . "<".$accountname.">\r"; 
          $smarty->assign('ACCINFO',$accountphone);
         $CONTENT="尊敬的".$accountname."，您签订的".$salesorder_no."号合同，派息".$value."，请注意查收。【投融无忧】";
         $smarty->assign("SENDACCOUNTTYPE",'yes');
         $smarty->assign("FROMMODULE",'SalesOrder');
         $smarty->assign("ACCOUNTNAME",$accountname);
         $smarty->assign("settype",'no');
          $smarty->assign("TABID",'22');
          $smarty->assign("CONTENT",$CONTENT);
          
          $smarty->display("modules/MassSMS/SendInform.tpl");
    exit();
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
$end_this_year2=(date('Y')+10).'-12-31';
$basicfilterHtml .="<a class='changeday' id='today1' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month1' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','$end_this_year')\">".getFixedLabel('ALL')."</a>"; 

$basicfilterHtml2 .="<a class='changeday' id='today2' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month2' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all2' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime2(this,'all','2000-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

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
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("begin_date2",$begin_date2);
$smarty->assign("end_date2",$end_date2);
$begin_end_date='';
$begin_end_date.=$begin_date2.' '.'-'.' '.$end_date2;
$begin_end_date2='';
$begin_end_date2.=$begin_date2.' '.'-'.' '.$end_date2;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("begin_end_date2",$begin_end_date2);
$smarty->assign("basicfilterHtml",$basicfilterHtml);
$smarty->assign("basicfilterHtml2",$basicfilterHtml2);
$where='where 1=1 ';
/*$smownerid = $_REQUEST['smownerid'];
if($smownerid!=''){
    $where .=' and ld_salesorder.smownerid in ('.$smownerid.')';
}else{
            $Smownerids= getCurSmOwnerSearchScope('SalesOrder');
            $SearchScope="";
            foreach($Smownerids['UserCombo']as $userid=>$userinfo)
            {
                 if($SearchScope == "")
                {
                    $SearchScope .=$userid; 
                }
                else
                {
                    $SearchScope .=",".$userid; 
                }	
                
            }
            $where .= " and  ld_salesorder.SmOwnerid in ( ".$SearchScope.")";
}*/

$accountname = $_REQUEST['accountname'];
if($accountname!=''){
    $where .=' and accountname like "%'.$accountname.'%"';
}
$cf_1501 = $_REQUEST['phone'];
if($cf_1501!=''){
    $where .=' and cf_1501 like "%'.$cf_1501.'%"';
}
$cf_1483 = $_REQUEST['cf_1483'];
if($cf_1483!=''){
    $where .=' and cf_1483 like "%'.$cf_1483.'%"';
}

$List = getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2);

function getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2){
    global $adb; 
    //echo $useridSQL;
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable IGNORE (
            SELECT cf_1547,
            CASE
            WHEN cf_1547='1个月' THEN 1 
            WHEN cf_1547='3个月' THEN 3 
            WHEN cf_1547='6个月' THEN 6 
            WHEN cf_1547='1年' THEN 12 
            WHEN cf_1547='2年' THEN 24 
            WHEN cf_1547='3年' THEN 36 
            WHEN cf_1547='4年' THEN 48 
            END AS value
            FROM ld_cf_1547
            );";
           //echo $SQL."<br>";
            $adb->pquery($SQL,array());
          $SQL = "CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable7 IGNORE (
                    SELECT cf_1546 as cd,
                    CASE
                    WHEN cf_1546='月支付' THEN 1 
                    WHEN cf_1546='季支付' THEN 3 
                    WHEN cf_1546='年支付' THEN 12 
                    END AS checkd
                    FROM ld_cf_1546
                    );";
           //echo $SQL."<br>";
            $adb->pquery($SQL,array());
                  
            $SQL = "CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable2 IGNORE (
                    SELECT ld_salesorder.salesorderid,productcategory,productname,salesorder_no,
                    ld_salesorder.createdtime,duedate as signed_data,
                    accountname,cf_1501,cf_1483,cf_1517,
                    cf_1515,last_name,cf_1546,value/checkd as 'qici',
                    cf_1550,total*quantity as total ,checkd
                    FROM ld_salesorder 
                    LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
                    LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid
                    LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
                    LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
                    LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid
                    LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
                    LEFT JOIN temptable ON temptable.cf_1547=ld_salesordercf.cf_1547 
                    LEFT JOIN temptable7 ON temptable7.cd=ld_salesordercf.cf_1546 
                    where ld_salesorder.deleted=0
                    );";
                   // echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
            

            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable9 IGNORE (
                    select a.*,b.seq,
                    date_add(signed_data,interval seq*checkd month) AS day,
                    CASE
	WHEN cf_1546 = '月支付' THEN
		DAY (
			LAST_DAY(
				date_add(
					signed_data,
					INTERVAL seq MONTH
				)
			)
		)
	WHEN cf_1546 = '季支付' THEN
		datediff(
			date_add(
				signed_data,
				INTERVAL seq + 3 MONTH
			),
			date_add(
				signed_data,
				INTERVAL seq MONTH
			)
		)
	WHEN cf_1546 = '年支付' THEN
		datediff(
			date_add(
				signed_data,
				INTERVAL seq + 12 MONTH
			),
			date_add(
				signed_data,
				INTERVAL seq MONTH
			)
		)
	END AS count,
                    seq as es
                    from temptable2 AS a CROSS JOIN sequence AS b where 
                    b.seq BETWEEN 1 
                    AND a.qici AND productcategory='安盈系列'
                    );";
                   // echo $SQL."<br>";
           $adb->pquery($SQL,array());
                $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable8 IGNORE (
                SELECT salesorderid,SUM(count) AS allcount2 FROM temptable9 GROUP BY salesorderid
                );";
                  // echo $SQL."<br>";
           $adb->pquery($SQL,array());
                        $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable3 IGNORE (
                    select temptable9.*,
                    CASE 
                    WHEN cf_1546='月支付' THEN  
                    total/365*allcount2*cf_1550/365*day(LAST_DAY(date_add(signed_data,interval seq month)))/100
                    WHEN cf_1546='季支付' THEN  
                    total/365*allcount2*cf_1550/365*
                    datediff(date_add(signed_data,interval seq+3 month),date_add(signed_data,interval seq month))/100
                    WHEN cf_1546='年支付' THEN  
                    total/365*allcount2*cf_1550/365*
                    datediff(date_add(signed_data,interval seq+12 month),date_add(signed_data,interval seq month))/100
                    END as VALUE
                    from temptable9 
                    left join temptable8 on temptable8.salesorderid=temptable9.salesorderid
                    );";
                  //  echo $SQL."<br>";
           $adb->pquery($SQL,array());    
            $SQL2="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable4 IGNORE (
                select c.*,d.seq,
                date_add(signed_data,interval seq month) AS day,
                day(LAST_DAY(date_add(signed_data,interval seq month))) AS count,seq as es,
                CASE 
                WHEN productname='轻松学' THEN 1000 
                WHEN productname='舒心学' THEN 2000 
                WHEN productname='欢乐学' THEN 3000 
                WHEN productname='梦想学' THEN 8000 
                END AS VALUE
                from temptable2 AS c CROSS JOIN sequence AS d where 
                d.seq BETWEEN 1 
                AND c.qici AND productcategory='学无忧'
                );";
              //  echo $SQL2."<br>";
            $adb->pquery($SQL2,array());
            $SQL3='select DISTINCT * from temptable4 order by salesorderid,seq';
            $resultTEST=$adb->pquery($SQL3,array());
            $rowCount2 = $adb->num_rows($resultTEST);
      
             for ($i = 0; $i < $rowCount2; $i++) {
                if(date(n,strtotime($adb->query_result($resultTEST, $i, 'day')))==7
                    &&date(d,strtotime($adb->query_result($resultTEST, $i, 'day')))>=15){
                        $salesorderid = $adb->query_result($resultTEST, $i, 'salesorderid');
                        $productcategory = $adb->query_result($resultTEST, $i, 'productcategory');
                        $productname = $adb->query_result($resultTEST, $i, 'productname');
                        $salesorder_no = $adb->query_result($resultTEST, $i, 'salesorder_no');
                        $createdtime = $adb->query_result($resultTEST, $i, 'createdtime');
                        $signed_data = $adb->query_result($resultTEST, $i, 'signed_data');
                        $accountname = $adb->query_result($resultTEST, $i, 'accountname');
                        $cf_1501 = $adb->query_result($resultTEST, $i, 'cf_1501');
                        $cf_1483 = $adb->query_result($resultTEST, $i, 'cf_1483');
                        $cf_1517 = $adb->query_result($resultTEST, $i, 'cf_1517');
                        $cf_1515 = $adb->query_result($resultTEST, $i, 'cf_1515');
                        $last_name = $adb->query_result($resultTEST, $i, 'last_name');
                        $cf_1546 = $adb->query_result($resultTEST, $i, 'cf_1546');
                        $qici = $adb->query_result($resultTEST, $i, 'qici');
                        $cf_1550 = $adb->query_result($resultTEST, $i, 'cf_1550');
                        $total = $adb->query_result($resultTEST, $i, 'total');
                        $seq = $adb->query_result($resultTEST, $i, 'seq');
                        $day = $adb->query_result($resultTEST, $i, 'day');
                        $count = $adb->query_result($resultTEST, $i, 'count');
                        $value = $adb->query_result($resultTEST, $i, 'value');
                        
                        if($adb->query_result($resultTEST, $i, 'productname')=='轻松学'){
                            $value=2000;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='舒心学'){
                            $value=3000;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='欢乐学'){
                            $value=5000;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='梦想学'){
                            $value=10000;
                        }
                        
                    $sqlinsert="INSERT INTO temptable4 
                                VALUES 
                                ($salesorderid,'$productcategory', '$productname', '$salesorder_no', '$createdtime', '$signed_data', 
                                '$accountname','$cf_1501', '$cf_1483', '$cf_1517','$cf_1515', '$last_name', 
                                '$cf_1546', '$qici', '$cf_1550', $total,'', -1,'$day', 0, '$value',$seq); ";
                              //  echo $sqlinsert.'<br>';
                                $adb->pquery($sqlinsert,array());
                }
                if($adb->query_result($resultTEST, $i, 'seq')==1){
                        $salesorderid = $adb->query_result($resultTEST, $i, 'salesorderid');
                        $productcategory = $adb->query_result($resultTEST, $i, 'productcategory');
                        $productname = $adb->query_result($resultTEST, $i, 'productname');
                        $salesorder_no = $adb->query_result($resultTEST, $i, 'salesorder_no');
                        $createdtime = $adb->query_result($resultTEST, $i, 'createdtime');
                        $signed_data = $adb->query_result($resultTEST, $i, 'signed_data');
                        $accountname = $adb->query_result($resultTEST, $i, 'accountname');
                        $cf_1501 = $adb->query_result($resultTEST, $i, 'cf_1501');
                        $cf_1483 = $adb->query_result($resultTEST, $i, 'cf_1483');
                        $cf_1517 = $adb->query_result($resultTEST, $i, 'cf_1517');
                        $cf_1515 = $adb->query_result($resultTEST, $i, 'cf_1515');
                        $last_name = $adb->query_result($resultTEST, $i, 'last_name');
                        $cf_1546 = $adb->query_result($resultTEST, $i, 'cf_1546');
                        $qici = $adb->query_result($resultTEST, $i, 'qici');
                        $cf_1550 = $adb->query_result($resultTEST, $i, 'cf_1550');
                        $total = $adb->query_result($resultTEST, $i, 'total');
                        $seq = $adb->query_result($resultTEST, $i, 'seq');
                        $day = $adb->query_result($resultTEST, $i, 'day');
                        $count = $adb->query_result($resultTEST, $i, 'count');
                        $value = $adb->query_result($resultTEST, $i, 'value');
                        
                        if($adb->query_result($resultTEST, $i, 'productname')=='轻松学'){
                            $value=-1;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='舒心学'){
                            $value=-2;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='欢乐学'){
                            $value=-3;
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='梦想学'){
                            $value=-4;
                        }
                        
                    $sqlinsert="INSERT INTO temptable4 
                                VALUES 
                                ($salesorderid,'$productcategory', '$productname', '$salesorder_no', '$createdtime', '$signed_data', 
                                '$accountname','$cf_1501', '$cf_1483', '$cf_1517','$cf_1515', '$last_name', 
                                '$cf_1546', '$qici', '$cf_1550', $total, '',-2,'$day', 0, '$value','0'); ";
                              //  echo $sqlinsert.'<br>';
                                $adb->pquery($sqlinsert,array());
                }
                if($adb->query_result($resultTEST, $i, 'productcategory')=='学无忧'&&
                $adb->query_result($resultTEST, $i, 'salesorderid')!=$adb->query_result($resultTEST, $i+1, 'salesorderid')
                ){
                        $salesorderid = $adb->query_result($resultTEST, $i, 'salesorderid');
                        $productcategory = $adb->query_result($resultTEST, $i, 'productcategory');
                        $productname = $adb->query_result($resultTEST, $i, 'productname');
                        $salesorder_no = $adb->query_result($resultTEST, $i, 'salesorder_no');
                        $createdtime = $adb->query_result($resultTEST, $i, 'createdtime');
                        $signed_data = $adb->query_result($resultTEST, $i, 'signed_data');
                        $accountname = $adb->query_result($resultTEST, $i, 'accountname');
                        $cf_1501 = $adb->query_result($resultTEST, $i, 'cf_1501');
                        $cf_1483 = $adb->query_result($resultTEST, $i, 'cf_1483');
                        $cf_1517 = $adb->query_result($resultTEST, $i, 'cf_1517');
                        $cf_1515 = $adb->query_result($resultTEST, $i, 'cf_1515');
                        $last_name = $adb->query_result($resultTEST, $i, 'last_name');
                        $cf_1546 = $adb->query_result($resultTEST, $i, 'cf_1546');
                        $qici = $adb->query_result($resultTEST, $i, 'qici');
                        $cf_1550 = $adb->query_result($resultTEST, $i, 'cf_1550');
                        $total = $adb->query_result($resultTEST, $i, 'total');
                        $seq = $adb->query_result($resultTEST, $i, 'seq');
                        $day = $adb->query_result($resultTEST, $i, 'day');
                        $count = $adb->query_result($resultTEST, $i, 'count');
                        $value = $adb->query_result($resultTEST, $i, 'value');
                        
                        if($adb->query_result($resultTEST, $i, 'productname')=='轻松学'){
                            $value='100000';
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='舒心学'){
                            $value='200000';
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='欢乐学'){
                            $value='300000';
                        }elseif($adb->query_result($resultTEST, $i, 'productname')=='梦想学'){
                            $value='1000000';
                        }
                        
                    $sqlinsert="INSERT INTO temptable4 
                                VALUES 
                                ($salesorderid,'$productcategory', '$productname', '$salesorder_no', '$createdtime', '$signed_data', 
                                '$accountname','$cf_1501', '$cf_1483', '$cf_1517','$cf_1515', '$last_name', 
                                '$cf_1546', '$qici', '$cf_1550', $total,'', -3,'$day', 0, '$value','90'); ";
                               // echo $sqlinsert.'<br>';
                                $adb->pquery($sqlinsert,array());
                }
             }

            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    	SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable3
                    	UNION
                    		SELECT
                    			*
                    		FROM
                    			temptable4) AS g1 ORDER BY 
                                        salesorderid,day,
                                        es);";
                     $adb->pquery($SQL,array());
                  //   echo $SQL.'<br>';
            $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable6 IGNORE (
                SELECT salesorderid,SUM(count) AS allcount FROM temptable5 GROUP BY salesorderid
                );";
                     $adb->pquery($SQL,array());
                  //  echo $SQL.'<br>'; 
            $SQL="SELECT
                    	*
                    FROM
                    	temptable5
                    LEFT JOIN temptable6 ON temptable5.salesorderid = temptable6.salesorderid
                    LEFT JOIN shuowei_dividend ON shuowei_dividend.id=temptable5.salesorderid 
                    AND shuowei_dividend.zqici=temptable5.seq and
                    shuowei_dividend.daydate=temptable5.day $where and  
                    signed_data BETWEEN '$begin_date' AND '$end_date' 
                    and day BETWEEN '$begin_date2' AND '$end_date2';";
            $result=$adb->pquery($SQL,array());
          //  echo $SQL.'<br>';
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['cf_1501'] = $adb->query_result($result, $i, 'cf_1501');
        $List[$i]['cf_1483'] = $adb->query_result($result, $i, 'cf_1483');
        $List[$i]['cf_1517'] = $adb->query_result($result, $i, 'cf_1517');
        $List[$i]['cf_1515'] = $adb->query_result($result, $i, 'cf_1515');
        $List[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $List[$i]['cf_1546'] = $adb->query_result($result, $i, 'cf_1546');
        $List[$i]['qici'] = $adb->query_result($result, $i, 'qici');
        $List[$i]['cf_1550'] = $adb->query_result($result, $i, 'cf_1550');
        $List[$i]['total'] = number_format($adb->query_result($result, $i, 'total'),2);
        $List[$i]['seq'] = $adb->query_result($result, $i, 'seq');
        $List[$i]['day'] = $adb->query_result($result, $i, 'day');
        $List[$i]['count'] = $adb->query_result($result, $i, 'count');
        $List[$i]['allcount'] = $adb->query_result($result, $i, 'allcount');
        $List[$i]['value'] = number_format($adb->query_result($result, $i, 'value'),2);
        $List[$i]['paixi'] = $adb->query_result($result, $i, 'paixi');
        
    }
    foreach($List as $key=>$arr){
        if($arr['seq']==-1){
            $List[$key]['seq']='暑假旅游基金';
        }elseif($arr['seq']==-2){
            $List[$key]['seq']='开学礼';
        }elseif($arr['seq']==-3){
            $List[$key]['seq']='毕业后创业基金';
        }
       /* if($arr['seq']>0&&$arr['productcategory']=='学无忧'){
             $List[$key]['seq']='生活基金'.$List[$key]['seq'];
        }*/
        if($arr['value']=='-1'){
             $List[$key]['value']='iphone6';
        }elseif($arr['value']=='-2'){
            $List[$key]['value']='苹果笔记本';
        }elseif($arr['value']=='-3'){
            $List[$key]['value']='iphone6+苹果笔记本';
        }elseif($arr['value']=='-4'){
            $List[$key]['value']='别克英朗轿车';
        }
        if($List[$key]['salesorderid']==$List[$key+1]['salesorderid']){
            $List[$key+1]['productcategory'] = '';
            $List[$key+1]['salesorder_no'] = '';
            $List[$key+1]['createdtime'] = '';
            $List[$key+1]['signed_data'] = '';
            $List[$key+1]['accountname'] = '';
            $List[$key+1]['cf_1501'] = '';
            $List[$key+1]['cf_1483'] = '';
            $List[$key+1]['cf_1517'] = '';
            $List[$key+1]['cf_1515'] = '';
            $List[$key+1]['last_name'] = '';
            $List[$key+1]['cf_1546'] = '';
            $List[$key+1]['qici'] = '';
            $List[$key+1]['cf_1550'] = '';
            $List[$key+1]['total'] = '';
            $List[$key+1]['allcount'] = '';
        }
    }
   /* echo '<pre>';
    print_r($List);*/
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
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/shuoweicontent.tpl');
else
    $smarty->display('Comprehensivereport/shuowei.tpl');

exit();
?>