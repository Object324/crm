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
        
    $SQL="INSERT INTO shuowei_dividend VALUE ('$sid','$seq','1','$DAY')";
  
    $adb->pquery($SQL,array());
    $sql = 'SELECT accountname,mobile,salesorder_no FROM ld_salesorder
            LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid
            LEFT JOIN ld_accountscf ON ld_account.accountid=ld_accountscf.accountid
            LEFT JOIN ld_contactdetails ON ld_contactdetails.accountid=ld_account.accountid AND reference=1
            WHERE salesorderid='.$sid;

            $result=$adb->pquery($sql,array());
          $accountname = $adb->query_result($result, 0, 'accountname');
          $mobile = $adb->query_result($result, 0, 'mobile');
          $salesorder_no = $adb->query_result($result, 0, 'salesorder_no');
          $accountphone=$mobile . "<".$accountname.">\r"; 
          $smarty->assign('ACCINFO',$accountphone);
         $CONTENT="尊敬的".$accountname."，您签订的".$salesorder_no."号合同，派息".$value."，请注意查收。";
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
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','$end_this_year2')\">".getFixedLabel('ALL')."</a>"; 

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
    $where .=' and mobile like "%'.$cf_1501.'%"';
}
$cf_1483 = $_REQUEST['cf_1483'];
if($cf_1483!=''){
    $where .=' and cf_1490 like "%'.$cf_1483.'%"';
}
$fuxitype = $_REQUEST['fuxitype'];
$List = getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$fuxitype);
/*echo '<pre>';
print_r($List);*/
if($_REQUEST['type']=='export'){

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'产品类型','合同编号','购买日','到期日','预警日','客户姓名','客户手机号','客户身份证','客户银行卡','付息方式','销售人员',
'投标天数','投标时常（单位：月）','利率','购入金额（单位：元）','到期利息（单位：元）','到期本息（单位：元）','每月利息（单位：元）'
);
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
/*
echo '<pre>';
print_r($List);die;*/
foreach($List as $key=>$arr){
    unset($arr['salesorderid']);
    unset($arr['paixi']);
    unset($arr['seq']);
    unset($arr['count']);
    unset($arr['day']);
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($v).($key+2),$arr2,PHPExcel_Cell_DataType::TYPE_STRING); 
       //$activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+($i*$page_count)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
       
       $v++;
    }
}

$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk','Report'));
$objPHPExcel->getActiveSheet()->setTitle('Report');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

$objWriter->save('storage/Report.xls');   

 //下载文件

 $file_name="Report.xls";
 $file_dir="storage/";

$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
}
function getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2,$fuxitype){
    global $adb; 
    //echo $useridSQL;
           /* $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable IGNORE (
            SELECT cf_1487,
            CASE
            WHEN cf_1487='月收宝1个月' THEN 1 
            WHEN cf_1487='季盈宝3个月' THEN 3 
            WHEN cf_1487='赢盈宝6个月' THEN 6 
            WHEN cf_1487='年赢宝12个月' THEN 12 
            WHEN cf_1487='满赢宝24个月' THEN 24 
            WHEN cf_1487='季收宝3个月' THEN 3 
            WHEN cf_1487='赢收宝6个月' THEN 6 
            WHEN cf_1487='年收宝12个月' THEN 12 
            WHEN cf_1487='满收宝24个月' THEN 24 
            END AS value
            FROM ld_cf_1487
            );";
                    //echo $SQL."<br>";
            $adb->pquery($SQL,array());   */
            $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable2 IGNORE (
                    SELECT ld_salesorder.salesorderid,productcategory,salesorder_no,
                    ld_salesorder.signed_data as createdtime,duedate as signed_data,
                    accountname,mobile,cf_1490,cf_1491,cf_1496,last_name,total*quantity as total,ld_cf_1487.cf_1487 AS qici,
                    cf_1497
                    FROM ld_salesorder 
                    LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
                    LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid
                    LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
                    LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid
                    LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
                    LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid
                    LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
                    LEFT JOIN ld_contactdetails ON ld_contactdetails.accountid=ld_account.accountid AND reference=1
                    LEFT JOIN ld_contactscf ON ld_contactdetails.contactid=ld_contactscf.contactid
                    LEFT JOIN ld_cf_1487 ON ld_cf_1487.cf_1487=ld_productcf.cf_1487
                    where ld_salesorder.deleted=0
                    );";
                    //echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
            

            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable9 IGNORE (
                    SELECT
                    	a.*, b.seq,
                    	date_add(
                    		createdtime,
                    		INTERVAL seq MONTH
                    	) AS DAY,
                    	'30' AS count,'按月付息' paixifangshi,
                        (total*30*cf_1497/360/100) AS lixi
                    FROM
                    	temptable2 AS a
                    CROSS JOIN sequence AS b
                    WHERE
                    	b.seq BETWEEN 1
                    AND a.qici AND cf_1496='按月付息');";
                    //echo $SQL."<br>";
            $adb->pquery($SQL,array());
            $SQL2="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable4 IGNORE (
                    SELECT
                        temptable2.*,'1' AS seq,
                        	date_add(
                        		createdtime,
                        		INTERVAL qici MONTH
                        	) AS DAY,
                        	30*qici AS count,
                        '一次性付息' paixifangshi,
                        (total*cf_1497*30*qici/360/100) AS lixi
                        FROM
                        	temptable2 WHERE
                         cf_1496='一次性付息');";
                //echo $SQL2."<br>";
            $adb->pquery($SQL2,array());
           
            if($fuxitype=='1'){
                            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    	SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable9
                    ) AS g1 ORDER BY 
                                        salesorderid,day);";
            }elseif($fuxitype=='2'){
                            $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    	SELECT * FROM (
                    		SELECT
                    			*
                    		FROM
                    			temptable4) AS g1 ORDER BY 
                                        salesorderid,day);";
            }else{
                $SQL="CREATE TEMPORARY TABLE
                    IF NOT EXISTS temptable5 IGNORE (
                    	SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable9
                    	UNION
                    		SELECT
                    			*
                    		FROM
                    			temptable4) AS g1 ORDER BY 
                                        salesorderid,day);";   
            }

                     $adb->pquery($SQL,array());
                     //echo $SQL.'<br>';
            $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable6 IGNORE (
                SELECT salesorderid,SUM(count) AS allcount FROM temptable5 GROUP BY salesorderid
                );";
                     $adb->pquery($SQL,array());
                    //echo $SQL.'<br>'; 
            $SQL="SELECT
                    	*,DATE(DATE_SUB(day, INTERVAL 5 DAY)) as yujin
                    FROM
                    	temptable5
                    LEFT JOIN temptable6 ON temptable5.salesorderid = temptable6.salesorderid
                    LEFT JOIN shuowei_dividend ON shuowei_dividend.id=temptable5.salesorderid 
                    AND shuowei_dividend.zqici=temptable5.seq and
                    shuowei_dividend.daydate=temptable5.day $where and  
                    signed_data BETWEEN '$begin_date' AND '$end_date' 
                    and day BETWEEN '$begin_date2' AND '$end_date2' order by temptable5.salesorderid,day;";
            $result=$adb->pquery($SQL,array());
            //echo $SQL.'<br>';
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['createdtime'] = $adb->query_result($result, $i, 'createdtime');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['yujin'] = $adb->query_result($result, $i, 'yujin');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['mobile'] = $adb->query_result($result, $i, 'mobile');
        $List[$i]['cf_1490'] = $adb->query_result($result, $i, 'cf_1490');
        $List[$i]['cf_1491'] = $adb->query_result($result, $i, 'cf_1491');
        $List[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $List[$i]['paixifangshi'] = $adb->query_result($result, $i, 'paixifangshi');
        $List[$i]['allcount'] = $adb->query_result($result, $i, 'allcount');
        //$List[$i]['cf_1546'] = $adb->query_result($result, $i, 'cf_1546');
        $List[$i]['qici'] = $adb->query_result($result, $i, 'qici');
        $List[$i]['cf_1497'] = $adb->query_result($result, $i, 'cf_1497').'%';
        //$List[$i]['cf_1496'] = $adb->query_result($result, $i, 'cf_1496');
        $List[$i]['total'] = number_format($adb->query_result($result, $i, 'total'),2);
        $List[$i]['seq'] = $adb->query_result($result, $i, 'seq');
        $List[$i]['day'] = $adb->query_result($result, $i, 'day');
        $List[$i]['count'] = $adb->query_result($result, $i, 'count');
        $List[$i]['lixi'] = number_format($adb->query_result($result, $i, 'lixi'),2);
        $List[$i]['total2'] = number_format($adb->query_result($result, $i, 'total'),2);
        $List[$i]['lixi2'] = number_format($adb->query_result($result, $i, 'lixi'),2);
        $List[$i]['paixi'] = $adb->query_result($result, $i, 'paixi');
        
    }
    foreach($List as $key=>$arr){
        if($List[$key]['salesorderid']==$List[$key+1]['salesorderid']){
            $List[$key+1]['productcategory'] = '';
            $List[$key+1]['salesorder_no'] = '';
            $List[$key+1]['createdtime'] = '';
            $List[$key+1]['signed_data'] = '';
            $List[$key+1]['accountname'] = '';
            $List[$key+1]['cf_1490'] = '';
            $List[$key+1]['cf_1491'] = '';
            $List[$key+1]['paixifangshi'] = '';
            $List[$key+1]['cf_1497'] = '';
            //$List[$key+1]['cf_1496'] = '';
            $List[$key+1]['last_name'] = '';
            $List[$key+1]['qici'] = '';
            $List[$key+1]['mobile'] = '';
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
        $result1 = $adb->query($sSQL5);  
    return $List;
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
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/licaodaicontent.tpl');
else
    $smarty->display('Comprehensivereport/licaodai.tpl');

exit();
?>