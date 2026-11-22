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
$end_this_year2=(date('Y')+1).'-12-31';
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
$where='';
$smownerid = $_REQUEST['smownerid'];
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
}
$salesorderno = $_REQUEST['salesorderno'];
if($salesorderno!=''){
    $where .=' and ld_salesorder.salesorder_no like "%'.$salesorderno.'%"';
}
$accountname = $_REQUEST['accountname'];
if($accountname!=''){
    $where .=' and ld_account.accountname like "%'.$accountname.'%"';
}
$cf_1494 = $_REQUEST['cf_1494'];
if($cf_1494!=''){
    $where .=' and cf_1494 like "%'.$cf_1494.'%"';
}
$cf_1469 = $_REQUEST['cf_1469'];
if($cf_1469!=''){
    $where .=' and cf_1469 like "%'.$cf_1469.'%"';
}

$List = getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2);
/*echo '<pre>';
print_r($List);die;*/
if($_REQUEST['type']=='export'){

    include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'合同号','投资人','身份证号','开户银行','卡号','联系手机','理财经理','投资金额（万元）','利率','投资期限限（月）','起始日',
'第一个月到期日','第一个月计息天数','应计利息（元）','第二个月到期日','第二个月计算天数','应计利息（元）',
'第三个月到期日','第三个月计算天数','应计利息（元）','第四个月到期日','第四个月计算天数','应计利息（元）',
'第五个月到期日','第五个月计算天数','应计利息（元）','第六个月到期日','第六个月计算天数','应计利息（元）',
'第七个月到期日','第七个月计算天数','应计利息（元）','第八个月到期日','第八个月计算天数','应计利息（元）',
'第九个月到期日','第九个月计算天数','应计利息（元）','第十个月到期日','第十个月计算天数','应计利息（元）',
'第十一个月到期日','第十一个月计算天数','应计利息（元）','第十二个月到期日','第十二个月计算天数',
'应计利息（元）','总计利息（元）'
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
function getDividend($where,$begin_date,$end_date,$begin_date2,$end_date2){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT
	*
FROM
	(
		SELECT
			salesorder_no,
			accountname,
			cf_1494 AS shengfenzheng,
			cf_1467 AS kaihuyinghang,
			SUBJECT,
			cf_1469 AS lianxishouji,
			ld_users.last_name,
			total,
			sf5,
			signed_data,
			if(sf4>=1,date_add(signed_data, INTERVAL 1 MONTH),'') AS one_day,
			TIMESTAMPDIFF(
				DAY,
				signed_data,
				date_add(signed_data, INTERVAL 1 MONTH)
			) AS one_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				signed_data,
				date_add(signed_data, INTERVAL 1 MONTH)
			) AS one_lixi,
			if(sf4>=2,date_add(signed_data, INTERVAL 2 MONTH),'') AS two_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 1 MONTH),
				date_add(signed_data, INTERVAL 2 MONTH)
			) AS two_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 1 MONTH),
				date_add(signed_data, INTERVAL 2 MONTH)
			) AS two_lixi,
			if(sf4>=3,date_add(signed_data, INTERVAL 3 MONTH),'') AS three_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 2 MONTH),
				date_add(signed_data, INTERVAL 3 MONTH)
			) AS three_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 2 MONTH),
				date_add(signed_data, INTERVAL 3 MONTH)
			) AS three_lixi,
			if(sf4>=4,date_add(signed_data, INTERVAL 4 MONTH),'') AS four_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 3 MONTH),
				date_add(signed_data, INTERVAL 4 MONTH)
			) AS four_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 3 MONTH),
				date_add(signed_data, INTERVAL 4 MONTH)
			) AS four_lixi,
			if(sf4>=5,date_add(signed_data, INTERVAL 5 MONTH),'') AS five_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 4 MONTH),
				date_add(signed_data, INTERVAL 5 MONTH)
			) AS five_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 4 MONTH),
				date_add(signed_data, INTERVAL 5 MONTH)
			) AS five_lixi,
			if(sf4>=6,date_add(signed_data, INTERVAL 6 MONTH),'') AS six_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 5 MONTH),
				date_add(signed_data, INTERVAL 6 MONTH)
			) AS six_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 5 MONTH),
				date_add(signed_data, INTERVAL 6 MONTH)
			) AS six_lixi,
			if(sf4>=7,date_add(signed_data, INTERVAL 7 MONTH),'') AS seven_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 6 MONTH),
				date_add(signed_data, INTERVAL 7 MONTH)
			) AS seven_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 6 MONTH),
				date_add(signed_data, INTERVAL 7 MONTH)
			) AS seven_lixi,
			if(sf4>=8,date_add(signed_data, INTERVAL 8 MONTH),'') AS eight_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 7 MONTH),
				date_add(signed_data, INTERVAL 8 MONTH)
			) AS eight_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 7 MONTH),
				date_add(signed_data, INTERVAL 8 MONTH)
			) AS eight_lixi,
			if(sf4>=9,date_add(signed_data, INTERVAL 9 MONTH),'') AS nine_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 8 MONTH),
				date_add(signed_data, INTERVAL 9 MONTH)
			) AS nine_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 8 MONTH),
				date_add(signed_data, INTERVAL 9 MONTH)
			) AS nine_lixi,
			if(sf4>=10,date_add(
				signed_data,
				INTERVAL 10 MONTH
			),'') AS ten_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 9 MONTH),
				date_add(
					signed_data,
					INTERVAL 10 MONTH
				)
			) AS ten_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(signed_data, INTERVAL 9 MONTH),
				date_add(
					signed_data,
					INTERVAL 10 MONTH
				)
			) AS ten_lixi,
			if(sf4>=11,date_add(
				signed_data,
				INTERVAL 11 MONTH
			),'') AS eleven_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(
					signed_data,
					INTERVAL 10 MONTH
				),
				date_add(
					signed_data,
					INTERVAL 11 MONTH
				)
			) AS eleven_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(
					signed_data,
					INTERVAL 10 MONTH
				),
				date_add(
					signed_data,
					INTERVAL 11 MONTH
				)
			) AS eleven_lixi,
			if(sf4>=12,date_add(
				signed_data,
				INTERVAL 12 MONTH
			),'') AS twelve_day,
			TIMESTAMPDIFF(
				DAY,
				date_add(
					signed_data,
					INTERVAL 11 MONTH
				),
				date_add(
					signed_data,
					INTERVAL 12 MONTH
				)
			) AS twelve_count,
			total / 100 * sf5 / 360 * TIMESTAMPDIFF(
				DAY,
				date_add(
					signed_data,
					INTERVAL 11 MONTH
				),
				date_add(
					signed_data,
					INTERVAL 12 MONTH
				)
			) AS twelve_lixi,
			sf4
            FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id 
            LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid 
            LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id 
            LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid WHERE
            ld_salesorder.deleted = 0 $where and ld_salesorder.signed_data BETWEEN '$begin_date' AND '$end_date' 
            GROUP BY ld_salesorder.salesorderid ORDER BY ld_salesorder.createdtime DESC) as g1 
            where one_day BETWEEN '$begin_date2' AND '$end_date2' or 
            two_day BETWEEN '$begin_date2' AND '$end_date2' or 
            three_day BETWEEN '$begin_date2' AND '$end_date2' or 
            four_day BETWEEN '$begin_date2' AND '$end_date2' or 
            five_day BETWEEN '$begin_date2' AND '$end_date2' or 
            six_day BETWEEN '$begin_date2' AND '$end_date2' or 
            seven_day BETWEEN '$begin_date2' AND '$end_date2' or 
            eight_day BETWEEN '$begin_date2' AND '$end_date2' or 
            nine_day BETWEEN '$begin_date2' AND '$end_date2' or 
            ten_day BETWEEN '$begin_date2' AND '$end_date2' or 
            eleven_day BETWEEN '$begin_date2' AND '$end_date2' or 
            twelve_day BETWEEN '$begin_date2' AND '$end_date2'
            ;";
           //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['shengfenzheng'] = $adb->query_result($result, $i, 'shengfenzheng');
        $List[$i]['kaihuyinghang'] = $adb->query_result($result, $i, 'kaihuyinghang');
        $List[$i]['subject'] = $adb->query_result($result, $i, 'subject');
        $List[$i]['lianxishouji'] = $adb->query_result($result, $i, 'lianxishouji');
        $List[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $List[$i]['total'] = $adb->query_result($result, $i, 'total')/10000;
        $List[$i]['sf_5'] = $adb->query_result($result, $i, 'sf5');
        $List[$i]['sf_4'] = $adb->query_result($result, $i, 'sf4');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        if($adb->query_result($result, $i, 'sf4')>=1){
            $List[$i]['one_day'] = $adb->query_result($result, $i, 'one_day');
            $List[$i]['one_count'] = $adb->query_result($result, $i, 'one_count');
            $List[$i]['one_lixi'] = $adb->query_result($result, $i, 'one_lixi');
        }else{
            $List[$i]['one_day'] = '';
            $List[$i]['one_count'] = '';
            $List[$i]['one_lixi'] = '';
        }
        if($adb->query_result($result, $i, 'sf4')>=2){
            $List[$i]['two_day'] = $adb->query_result($result, $i, 'two_day');
            $List[$i]['two_count'] = $adb->query_result($result, $i, 'two_count');
            $List[$i]['two_lixi'] = $adb->query_result($result, $i, 'two_lixi');
        }else{
            $List[$i]['two_day'] = '';
            $List[$i]['two_count'] = '';
            $List[$i]['two_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=3){
            $List[$i]['three_day'] = $adb->query_result($result, $i, 'three_day');
            $List[$i]['three_count'] = $adb->query_result($result, $i, 'three_count');
            $List[$i]['three_lixi'] = $adb->query_result($result, $i, 'three_lixi');
        }else{
            $List[$i]['three_day'] = '';
            $List[$i]['three_count'] = '';
            $List[$i]['three_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=4){
            $List[$i]['four_day'] = $adb->query_result($result, $i, 'four_day');
            $List[$i]['four_count'] = $adb->query_result($result, $i, 'four_count');
            $List[$i]['four_lixi'] = $adb->query_result($result, $i, 'four_lixi');
        }else{
            $List[$i]['four_day'] = '';
            $List[$i]['four_count'] = '';
            $List[$i]['four_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=5){
            $List[$i]['five_day'] = $adb->query_result($result, $i, 'five_day');
            $List[$i]['five_count'] = $adb->query_result($result, $i, 'five_count');
            $List[$i]['five_lixi'] = $adb->query_result($result, $i, 'five_lixi');
        }else{
            $List[$i]['five_day'] = '';
            $List[$i]['five_count'] = '';
            $List[$i]['five_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=6){
            $List[$i]['six_day'] = $adb->query_result($result, $i, 'six_day');
            $List[$i]['six_count'] = $adb->query_result($result, $i, 'six_count');
            $List[$i]['six_lixi'] = $adb->query_result($result, $i, 'six_lixi');
        }else{
            $List[$i]['six_day'] = '';
            $List[$i]['six_count'] = '';
            $List[$i]['six_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=7){
            $List[$i]['seven_day'] = $adb->query_result($result, $i, 'seven_day');
            $List[$i]['seven_count'] = $adb->query_result($result, $i, 'seven_count');
            $List[$i]['seven_lixi'] = $adb->query_result($result, $i, 'seven_lixi');
        }else{
            $List[$i]['seven_day'] = '';
            $List[$i]['seven_count'] = '';
            $List[$i]['seven_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=8){
            $List[$i]['eight_day'] = $adb->query_result($result, $i, 'eight_day');
            $List[$i]['eight_count'] = $adb->query_result($result, $i, 'eight_count');
            $List[$i]['eight_lixi'] = $adb->query_result($result, $i, 'eight_lixi');
        }else{
            $List[$i]['eight_day'] = '';
            $List[$i]['eight_count'] = '';
            $List[$i]['eight_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=9){
            $List[$i]['nine_day'] = $adb->query_result($result, $i, 'nine_day');
            $List[$i]['nine_count'] = $adb->query_result($result, $i, 'nine_count');
            $List[$i]['nine_lixi'] = $adb->query_result($result, $i, 'nine_lixi');
        }else{
            $List[$i]['nine_day'] = '';
            $List[$i]['nine_count'] = '';
            $List[$i]['nine_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=10){
            $List[$i]['ten_day'] = $adb->query_result($result, $i, 'ten_day');
            $List[$i]['ten_count'] = $adb->query_result($result, $i, 'ten_count');
            $List[$i]['ten_lixi'] = $adb->query_result($result, $i, 'ten_lixi');
        }else{
            $List[$i]['ten_day'] = '';
            $List[$i]['ten_count'] = '';
            $List[$i]['ten_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=11){
            $List[$i]['eleven_day'] = $adb->query_result($result, $i, 'eleven_day');
            $List[$i]['eleven_count'] = $adb->query_result($result, $i, 'eleven_count');
            $List[$i]['eleven_lixi'] = $adb->query_result($result, $i, 'eleven_lixi');
        }else{
            $List[$i]['eleven_day'] = '';
            $List[$i]['eleven_count'] = '';
            $List[$i]['eleven_lixi'] = ''; 
        }
        if($adb->query_result($result, $i, 'sf4')>=12){
            $List[$i]['twelve_day'] = $adb->query_result($result, $i, 'twelve_day');
            $List[$i]['twelve_count'] = $adb->query_result($result, $i, 'twelve_count');
            $List[$i]['twelve_lixi'] = $adb->query_result($result, $i, 'twelve_lixi');
        }else{
            $List[$i]['twelve_day'] = '';
            $List[$i]['twelve_count'] = '';
            $List[$i]['twelve_lixi'] = ''; 
        }

    }
   $ckey = count($List);
    foreach($List as $key=>$arr){
        $List[$key]['subtotal'] = $arr['one_lixi']+$arr['two_lixi']+$arr['three_lixi']+$arr['four_lixi']+$arr['five_lixi']+$arr['six_lixi']+
        $arr['seven_lixi']+$arr['eight_lixi']+$arr['nine_lixi']+$arr['ten_lixi']+$arr['eleven_lixi']+$arr['twelve_lixi'];
    }
    foreach($List as $key=>$arr){
        $List[$ckey]['salesorder_no'] = '';
        $List[$ckey]['accountname'] = '';
        $List[$ckey]['shengfenzheng'] = '';
        $List[$ckey]['kaihuyinghang']='合计';
        $List[$ckey]['subject']='';
        $List[$ckey]['lianxishouji']='';
        $List[$ckey]['last_name']='';
        $List[$ckey]['total'] +=$arr['total'];
        $List[$ckey]['sf_5']='';
        $List[$ckey]['sf_4']='';
        $List[$ckey]['signed_data']='';
        $List[$ckey]['one_day']='';
        $List[$ckey]['one_count']='';
        $List[$ckey]['one_lixi'] +=$arr['one_lixi'];
        $List[$ckey]['two_day']='';
        $List[$ckey]['two_count']='';
        $List[$ckey]['two_lixi'] +=$arr['two_lixi'];
        $List[$ckey]['three_day']='';
        $List[$ckey]['three_count']='';
        $List[$ckey]['three_lixi'] +=$arr['three_lixi'];
        $List[$ckey]['four_day']='';
        $List[$ckey]['four_count']='';
        $List[$ckey]['four_lixi'] +=$arr['four_lixi'];
        $List[$ckey]['five_day']='';
        $List[$ckey]['five_count']='';
        $List[$ckey]['five_lixi'] +=$arr['five_lixi'];
        $List[$ckey]['six_day']='';
        $List[$ckey]['six_count']='';
        $List[$ckey]['six_lixi'] +=$arr['six_lixi'];
        $List[$ckey]['seven_day']='';
        $List[$ckey]['seven_count']='';
        $List[$ckey]['seven_lixi'] +=$arr['seven_lixi'];
        $List[$ckey]['eight_day']='';
        $List[$ckey]['eight_count']='';
        $List[$ckey]['eight_lixi'] +=$arr['eight_lixi'];
        $List[$ckey]['nine_day']='';
        $List[$ckey]['nine_count']='';
        $List[$ckey]['nine_lixi'] +=$arr['nine_lixi'];
        $List[$ckey]['ten_day']='';
        $List[$ckey]['ten_count']='';
        $List[$ckey]['ten_lixi'] +=$arr['ten_lixi'];
        $List[$ckey]['eleven_day']='';
        $List[$ckey]['eleven_count']='';
        $List[$ckey]['eleven_lixi'] +=$arr['eleven_lixi'];
        $List[$ckey]['twelve_day']='';
        $List[$ckey]['twelve_count']='';
        $List[$ckey]['twelve_lixi'] +=$arr['twelve_lixi'];
        $List[$ckey]['subtotal'] +=$arr['subtotal'];

    }
    return $List;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/Dividendcontent.tpl');
else
    $smarty->display('Comprehensivereport/Dividend.tpl');

exit();
?>