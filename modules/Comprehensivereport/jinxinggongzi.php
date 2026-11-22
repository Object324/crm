<?php
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

$basicfilterHtml .="<a class='changeday' id='today1' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month1' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','$end_this_year')\">".getFixedLabel('ALL')."</a>"; 

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

$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("basicfilterHtml",$basicfilterHtml);
$where='';
$smownerid = $_REQUEST['smownerid'];
if($smownerid!=''){
    $where .=' and temptable.smownerid in ('.$smownerid.')';
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
            $where .= " and  temptable.SmOwnerid in ( ".$SearchScope.")";
}

$List = getDividend($where,$begin_date,$end_date);

if($_REQUEST['type']=='export'){

    include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array('时间（签约时间）','业务员','个人签约额','个人工资提成','','','团队提成','','','总工资');
$listValue_header2=array('','','','基本工资','提成工资','工资合计','全组签约额','组长提成比例','提成额','');
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
foreach($listValue_header2 as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'2',$arr);
}
foreach($List as $key=>$arr){
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($v).($key+3),$arr2,PHPExcel_Cell_DataType::TYPE_STRING); 
       
       $v++;
    }
}
$objPHPExcel->getActiveSheet()->mergeCells( 'A1:A2'); 
$objPHPExcel->getActiveSheet()->mergeCells( 'B1:B2'); 
$objPHPExcel->getActiveSheet()->mergeCells( 'C1:C2'); 
$objPHPExcel->getActiveSheet()->mergeCells( 'J1:J2'); 
$objPHPExcel->getActiveSheet()->mergeCells( 'D1:F1'); 
$objPHPExcel->getActiveSheet()->mergeCells( 'G1:I1'); 
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
function getDividend($where,$begin_date,$end_date){
    global $adb; 
   // echo $where;
    $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT '$begin_date~$end_date' as signed_data,last_name,id,
                IFNULL(SUM(total),0) AS total,groupid,ld_users.userlevel,
                ld_salesorder.smownerid,
                CASE
                WHEN SUM(total)<=100000 THEN 3000
                WHEN 100000<SUM(total)&&SUM(total)<=150000 THEN 4000
                WHEN 150000<SUM(total)&&SUM(total)<=200000 THEN 4500
                WHEN 200000<SUM(total)&&SUM(total)<=250000 THEN 5000
                WHEN 250000<SUM(total)&&SUM(total)<=300000 THEN 5500
                WHEN 300000<SUM(total)&&SUM(total)<=350000 THEN 6000
                WHEN 350000<SUM(total)&&SUM(total)<=400000 THEN 6500
                WHEN 400000<SUM(total)&&SUM(total)<=450000 THEN 7000
                WHEN 450000<SUM(total)&&SUM(total)<=500000 THEN 7500
                WHEN 500000<SUM(total)&&SUM(total)<=600000 THEN 8500
                WHEN 600000<SUM(total)&&SUM(total)<=700000 THEN 10000
                WHEN 700000<SUM(total)&&SUM(total)<=800000 THEN 11500
                WHEN 800000<SUM(total)&&SUM(total)<=900000 THEN 13000
                WHEN 900000<SUM(total)&&SUM(total)<=1000000 THEN 14500
                WHEN 1000000<SUM(total)&&SUM(total)<=1200000 THEN 16500
                WHEN 1200000<SUM(total)&&SUM(total)<=1400000 THEN 18500
                WHEN 1400000<SUM(total)&&SUM(total)<=1600000 THEN 20500
                WHEN 1600000<SUM(total)&&SUM(total)<=1800000 THEN 22500
                WHEN 1800000<SUM(total)&&SUM(total)<=2000000 THEN 24500
                WHEN 2000000<SUM(total)&&SUM(total)<=2500000 THEN 27000
                WHEN 2500000<SUM(total)&&SUM(total)<=3000000 THEN 29500
                WHEN 3000000<SUM(total)&&SUM(total)<=3500000 THEN 32000
                WHEN 3500000<SUM(total)&&SUM(total)<=4000000 THEN 34500
                WHEN 4000000<SUM(total)&&SUM(total)<=4500000 THEN 37000
                WHEN 4500000<SUM(total)&&SUM(total)<=5500000 THEN 41000
                WHEN 5500000<SUM(total)&&SUM(total)<=6500000 THEN 45000
                WHEN 6500000<SUM(total)&&SUM(total)<=7500000 THEN 49000
                WHEN 7500000<SUM(total)&&SUM(total)<=8500000 THEN 53000
                WHEN 8500000<SUM(total) THEN 57000
                ELSE 0
                END AS jibengz,
                IFNULL(SUM(total)*0.005,0) AS tichenggz
                FROM ld_users  
                LEFT JOIN ld_salesorder ON ld_salesorder.smownerid=ld_users.id 
                LEFT JOIN ld_users2group ON ld_users.id=ld_users2group.userid
               WHERE 1=1  and ld_salesorder.deleted = 0
                and ld_salesorder.signed_data BETWEEN '$begin_date' AND '$end_date' 
                GROUP BY id
                );";   
                $adb->query($SQL);
               
         // echo $SQL.'<br><br>'; 
           
         $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable2 IGNORE (
                SELECT userid,userlevel,ld_users2group.groupid FROM ld_groups 
                LEFT JOIN ld_users2group ON ld_groups.groupid=ld_users2group.groupid
                LEFT JOIN ld_users ON ld_users.id=ld_users2group.userid 
                );"; 
         $adb->query($SQL);
         //echo $SQL.'<br><br>';  
         
         $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable3 IGNORE (
                SELECT f1.qzgz,f1.groupid,
                IF(qzgz>=2000000,ceil((qzgz-2000000)/1000000)*0.05+0.15,0.15) AS qzbl,
                IF(qzgz>=2000000,(ceil((qzgz-2000000)/1000000)*0.05+0.15)*qzgz,0.15*qzgz)/100 as qztc
                FROM (
                SELECT 
                temptable.id,SUM(total) AS qzgz,
                temptable.groupid,temptable2.userlevel
                FROM temptable 
                LEFT JOIN temptable2 ON temptable.id=temptable2.userid 
                GROUP BY temptable.groupid 
                ) AS f1
                );"; 
         $adb->query($SQL);
         //echo $SQL.'<br><br>';
         
         $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable4 IGNORE (
                SELECT temptable.id,'$begin_date~$end_date' as SalesOrder_signed_data,temptable.last_name as Users_last_name,
                temptable.total as SalesOrder_total,
                temptable.jibengz as SalesOrder_jibengz,tichenggz,
                jibengz+tichenggz AS gzhj,
                IF(temptable.userlevel='部门经理',temptable3.qzgz,0) as qzgz,
                CONCAT(IF(temptable.userlevel='部门经理',temptable3.qzbl,0),'%') as gzbl,
                IF(temptable.userlevel='部门经理',qztc,0) as qztc,
                IF(temptable.userlevel='部门经理',qztc,0)+jibengz+tichenggz as zgz
                FROM temptable 
                LEFT JOIN temptable3 ON temptable.groupid=temptable3.groupid 
                where 1=1 $where
                order by temptable3.groupid,temptable.userlevel
                );"; 
         $adb->query($SQL);
        //echo $SQL.'<br><br>'; 
                
          $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable5 IGNORE (
                SELECT '' AS id,'合计' AS SalesOrder_signed_data,'' AS Users_last_name,
                SUM(SalesOrder_total) AS SalesOrder_total,SUM(SalesOrder_jibengz) AS SalesOrder_jibengz,
                SUM(tichenggz) AS tichenggz,SUM(gzhj) AS gzhj,
                SUM(qzgz) AS qzgz,'' AS gzbl,SUM(qztc) AS qztc,SUM(zgz) AS zgz
                FROM temptable4);"; 
         $adb->query($SQL);
         //echo $SQL.'<br><br>';
         
         $SQL="SELECT * FROM temptable4 UNION SELECT * FROM temptable5;";  
           //echo $SQL."<br>";die;
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
            
        $sSQL5="drop TEMPORARY  table if exists temptable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable4;"; 
        $result1 = $adb->query($sSQL5);  
        $sSQL5="drop TEMPORARY  table if exists temptable5;"; 
        $result1 = $adb->query($sSQL5);  
            
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['SalesOrder_signed_data'] = $adb->query_result($result, $i, 'salesorder_signed_data');
        $List[$i]['Users_last_name'] = $adb->query_result($result, $i, 'users_last_name');
        $List[$i]['SalesOrder_total'] = setNumberFormat($adb->query_result($result, $i, 'salesorder_total'));
        $List[$i]['SalesOrder_jibengz'] = setNumberFormat($adb->query_result($result, $i, 'salesorder_jibengz'));
        $List[$i]['tichenggz'] = setNumberFormat($adb->query_result($result, $i, 'tichenggz'));
        $List[$i]['gzhj'] = setNumberFormat($adb->query_result($result, $i, 'gzhj'));
        $List[$i]['qzgz'] = setNumberFormat($adb->query_result($result, $i, 'qzgz'));
        $List[$i]['gzbl'] = $adb->query_result($result, $i, 'gzbl');
        $List[$i]['qztc'] = setNumberFormat($adb->query_result($result, $i, 'qztc'));
        $List[$i]['zgz'] = setNumberFormat($adb->query_result($result, $i, 'zgz'));
    }
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
    $smarty->display('Comprehensivereport/jinxinggongzicontent.tpl');
else
    $smarty->display('Comprehensivereport/jinxinggongzi.tpl');

exit();
?>