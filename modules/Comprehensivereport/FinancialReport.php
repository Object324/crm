<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();


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
$end_this_year2=date('Y-12-31');
$end_this_year3=date('Y-12-31');
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
$basicfilterHtml3 .="<a class='changeday' id='today3' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month3' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all3' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime3(this,'all','2000-01-01','$end_this_year3')\">".getFixedLabel('ALL')."</a>"; 

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
$begin_end_date.=$begin_date2.' '.'-'.' '.$end_date2;
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
$where=' ';

/*echo '<pre>';
print_r($MergeSmowner);
*/
$accountname = $_REQUEST['accountname'];
if($accountname!=''){
    $where .=' and accountname like "%'.URLdecode($accountname).'%"';
}
$cf_1484 = $_REQUEST['cf_1484'];
if($cf_1484!=''){
    $where .=' and cf_1484 like "%'.URLdecode($cf_1484).'%"';
}
$cf_1486 = $_REQUEST['cf_1486'];
if($cf_1486!=''){
    $where .=' and cf_1486 like "%'.URLdecode($cf_1486).'%"';
}
$cf_1504 = $_REQUEST['cf_1504'];
if($cf_1504!=''){
    $where .=' and cf_1520 like "%'.URLdecode($cf_1504).'%"';
}
$cf_1506 = $_REQUEST['cf_1506'];
if($cf_1506!=''){
    $where .=' and cf_1519 like "%'.URLdecode($cf_1506).'%"';
}
$approvestatus = $_REQUEST['approvestatus'];
$approvestatus=substr($approvestatus,0,strlen($approvestatus)-1);
if($approvestatus!=''){
    $where .=' and ld_salesorder.approvestatus in ('.$approvestatus.')';
}
$listprice = $_REQUEST['listprice'];
if($listprice==1){
    $where .=' and listprice < 1000000';
}elseif($listprice==2){
    $where .=' and listprice >= 1000000 && listprice >= 9999999';
}elseif($listprice==3){
    $where .=' and listprice >= 10000000 ';
}

$List = getComValue($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3);

if($_REQUEST['type']=='export'){

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'姓名','身份证号','手机号','银行全称','银行账号','理财合同号','计划名称','期限','金额','利率','还款方式','银行到账日期','余额',
'充值到账户日期','债权匹配日期','对公充值','审批状态'
);
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
/*
echo '<pre>';
print_r($List);die;*/
foreach($List as $key=>$arr){
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
function getComValue($where,$begin_date,$end_date,$begin_date2,$end_date2,$begin_date3,$end_date3){
    global $adb; 
   // echo $query;
   if($begin_date!='2000-01-01'){
    $date1="and cf_1497 BETWEEN '$begin_date' AND '$end_date'";
   }
   if($begin_date2!='2000-01-01'){
    $date2="and cf_1499 BETWEEN '$begin_date2' AND '$end_date2'";
   }
   if($begin_date3!='2000-01-01'){
    $date3="and cf_1496 BETWEEN '$begin_date3' AND '$end_date3'";
   }
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable IGNORE (
            SELECT accountname,cf_1484,cf_1486,cf_1526 as cf_1488,cf_1527 as cf_1490,cf_1523 as salesorder_no,productname,
            cf_1520 as cf_1504,taxprice AS listprice,cf_1519 as cf_1506,cf_1521 as cf_1494,cf_1496,cf_1497,cf_1499,ld_salesorder.approvestatus,
            sf998,sf1077
            FROM ld_salesorder 
            LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
            LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id
            LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid
            LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid
            LEFT JOIN ld_accountscf ON ld_account.accountid=ld_accountscf.accountid
            WHERE ld_salesorder.deleted=0  
             $date1 $date2 $date3
           $where
            );";
        //echo $SQL."<br>";
           $adb->pquery($SQL,array());
           
           $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable2 IGNORE (
                SELECT '合计'accountname,''cf_1484,''cf_1486,''cf_1488,
                ''cf_1490,''salesorder_no,''productname,''cf_1504,
                SUM(listprice) as listprice,''cf_1506,''cf_1494,
                ''cf_1496,''cf_1497,''cf_1499,''approvestatus,SUM(sf998) as sf998,sum(sf1077) as sf1077
				FROM temptable);";
                $adb->pquery($SQL,array());
              //echo $SQL."<br>";   
           $SQL="select * from (SELECT * FROM temptable UNION SELECT * FROM temptable2) as f1 ";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['cf_1484'] = $adb->query_result($result, $i, 'cf_1484');
        $List[$i]['cf_1486'] = $adb->query_result($result, $i, 'cf_1486');
        $List[$i]['cf_1488'] = $adb->query_result($result, $i, 'cf_1488');
        $List[$i]['cf_1490'] = $adb->query_result($result, $i, 'cf_1490');
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $List[$i]['cf_1504'] = $adb->query_result($result, $i, 'cf_1504');  
        $List[$i]['listprice'] = $adb->query_result($result, $i, 'listprice');  
        $List[$i]['cf_1506'] = $adb->query_result($result, $i, 'cf_1506');
        $List[$i]['cf_1494'] = $adb->query_result($result, $i, 'cf_1494');     
        $List[$i]['cf_1496'] = $adb->query_result($result, $i, 'cf_1496');
        $List[$i]['sf998'] = $adb->query_result($result, $i, 'sf998');   
        $List[$i]['cf_1497'] = $adb->query_result($result, $i, 'cf_1497');      
        $List[$i]['cf_1499'] = $adb->query_result($result, $i, 'cf_1499');    
        $List[$i]['sf1077'] = $adb->query_result($result, $i, 'sf1077'); 
        $List[$i]['approvestatus'] = $adb->query_result($result, $i, 'approvestatus');   
    }
        $sSQL5="drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable;"; 
        $result1 = $adb->query($sSQL5);  
        /*echo '<pre>';
print_r($List);   */
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
    $smarty->display('Comprehensivereport/FinancialReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/FinancialReport.tpl');

exit();
?>