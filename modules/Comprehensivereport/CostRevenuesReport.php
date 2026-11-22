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
$where=' ';
$salesorderwhere=' ';
$serverContactwhere=' ';
$cf_1476=getcf_1476();
$cf_1476value = $_REQUEST['cf_1476'];
$smarty->assign("cf_1476",$cf_1476);

$cf_1469=getcf_1469();
$cf_1469value = $_REQUEST['cf_1469'];
$smarty->assign("cf_1469",$cf_1469);

if($cf_1476value!=''){
   $salesorderwhere = " and cf_1476 = '$cf_1476value'"; //Liver因为服务合同和销售合同中字段不同，所以只能用以区别
   $serverContactwhere = " and cf_1534 = '$cf_1476value'"; 
}

if($cf_1469value!=''){
   $salesorderwhere .= " and cf_1469 = '$cf_1469value'"; 
   $serverContactwhere = " and cf_1535 = '$cf_1469value'";
}
$accountname = $_REQUEST['accountname'];
if($accountname!=''){
    $where .=' and accountname like "%'.$accountname.'%"';
}
$cf_1461 = $_REQUEST['cf_1461'];
if($cf_1461!=''){
    $where .=' and cf_1461 like "%'.$cf_1461.'%"';
}
$productname = $_REQUEST['productname'];
if($productname!=''){
    $where .=' and productname like "%'.$productname.'%"';
}
$productsheet = $_REQUEST['productsheet'];
if($productsheet!=''){
    $where .=' and productsheet like "%'.$productsheet.'%"';
}
$fsalesorder_name = $_REQUEST['fsalesorder_name'];
if($fsalesorder_name!=''){
    $query =' and ld_salesorder.parentid in (select salesorderid FROM ld_salesorder WHERE salesorder_no like "%'.$fsalesorder_name.'%")';
     $query2 =' and ld_servicecontracts.salesorderid in (select salesorderid FROM ld_salesorder WHERE salesorder_no like "%'.$fsalesorder_name.'%")';
}

$ordertype=$_REQUEST['ordertype'];

$List = getDividend($where,$begin_date,$end_date,$query,$query2,$ordertype,$salesorderwhere,$serverContactwhere);
if($_REQUEST['type']=='export'){

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'合同编号','采购订单编号','合同主体','客户来源','客户类型','客户/二代名称','广告主名称','客户所属行业','投放媒体','产品线','月份',
'媒体后台到账金额','客户配送（结算）比例','客户折扣比例','客户结算金额','媒体配送比例','媒体折扣比例',
'媒体付款金额','服务费金额','收入','成本','利润','上级合同'
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
function getDividend($where,$begin_date,$end_date,$query,$query2,$ordertype,$salesorderwhere,$serverContactwhere){
    global $adb; 
    
    
    //echo $useridSQL;
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable IGNORE (
            SELECT 
                cf_1529,purchaseorder_no,cf_1476,cf_1469,carrier,
                accountname,cf_1461,cf_1467,productname,productsheet,signed_data,
                IFNULL(sf7,0) as sf7,
                IFNULL(sf727,0) as sf727,
                IFNULL(sf805,0) as sf805,
                IFNULL(IF(carrier='充值类型',ld_servicecontractsdetail.listprice,serin.taxprice),0) AS carrier2,
                IFNULL(purchaseorder.sf963,0) as sf963,
                IFNULL(purchaseorder.sf1042,0) as sf1042,
                IFNULL(purchaseorder.taxprice,0) as taxprice,
                IFNULL(sf5,0) as sf5,
                IFNULL(IF(carrier='充值类型',ld_servicecontractsdetail.listprice,serin.taxprice),0)+IFNULL(sf5,0) as shouru,
                IFNULL(IF(carrier='充值类型',ld_servicecontractsdetail.listprice,serin.taxprice),0)+IFNULL(sf5,0)-IFNULL(purchaseorder.taxprice,0) AS lirun,
				gds.salesorder_no as shangji
                FROM ld_salesorder 
				left join (select salesorderid,salesorder_no from ld_salesorder where deleted=0) as gds on gds.salesorderid=ld_salesorder.parentid
                LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
                LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
                LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id
                LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                LEFT JOIN ld_products ON ld_products.productid=ld_inventoryproductrel.productid
                LEFT JOIN (
                SELECT entitytypeid,purchaseorder_no,sf963,sf1042,taxprice,productid FROM ld_purchaseorder 
                LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid   
                LEFT JOIN ld_purchaseorderdetailscf ON ld_purchaseorderdetailscf.lineitem_id=ld_purchaseorderdetail.lineitem_id
                ) AS purchaseorder ON purchaseorder.entitytypeid=ld_servicecontractsdetail.id and purchaseorder.productid=ld_inventoryproductrel.productid
                LEFT JOIN ld_servicecontracts ON ld_servicecontracts.salesorderid = ld_salesorder.salesorderid 
                LEFT JOIN ld_servicecontractsdetail AS serin ON serin.id=ld_servicecontracts.servicecontractsid
                WHERE ld_salesorder.deleted=0 and cf_1462='执行单' and carrier='充值类型' 
                and signed_data BETWEEN '$begin_date' AND '$end_date' $query 
                $where $salesorderwhere);";
             $adb->pquery($SQL,array());   
            // echo $SQL."<br>";
            $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable2 IGNORE (
                        SELECT
                    	contract_no as cf_1529,
                    	cf_1533 as purchaseorder_no,
                    	cf_1534 as cf_1476,
                    	cf_1535 as cf_1469,
                    	'' carrier,
                    	accountname,
                    	cf_1536 as cf_1461,
                    	cf_1537 as cf_1467,
                    	productname,
                    	productsheet,
                    	cf_1540 AS signed_data,
                    	IFNULL(sf1279, 0) AS sf7,
                    	IFNULL(sf727, 0) AS sf727,
                    	IFNULL(sf805, 0) AS sf805,
                    	IFNULL(
                    			ld_servicecontractsdetail.listprice,
                    		0
                    	) AS carrier2,
                    	IFNULL(sf963, 0) AS sf963,
                    	IFNULL(sf1042, 0) AS sf1042,
                    	IFNULL(sf1358, 0) AS taxprice,
                    	IFNULL(sf1200, 0) AS sf5,
                    	IFNULL(
                    			ld_servicecontractsdetail.taxprice,
                    		0
                    	) + IFNULL(sf1200, 0) AS shouru,
                    	IFNULL(
                    			ld_servicecontractsdetail.taxprice,
                    		0
                    	) + IFNULL(sf1200, 0) - IFNULL(sf1358, 0) AS lirun,
						gds.salesorder_no as shangji
                    FROM
                    	ld_servicecontracts
					left join 
                    (select ld_salesorder.salesorderid,salesorder_no,cf_1469 from ld_salesorder
                        left join ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid where deleted=0)
                     as gds on gds.salesorderid=ld_servicecontracts.salesorderid                 	
                    LEFT JOIN ld_servicecontractscf ON ld_servicecontracts.servicecontractsid = ld_servicecontractscf.servicecontractsid
                    LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
                    LEFT JOIN ld_servicecontractsdetail ON ld_servicecontracts.servicecontractsid = ld_servicecontractsdetail.id
                    LEFT JOIN ld_servicecontractsdetailscf ON ld_servicecontractsdetail.lineitem_id = ld_servicecontractsdetailscf.lineitem_id
                    LEFT JOIN ld_products ON ld_products.productid = ld_inventoryproductrel.productid
                    WHERE
                    	ld_servicecontracts.deleted = 0                  
                 and cf_1540 BETWEEN '$begin_date' AND '$end_date' $query2
                $where $serverContactwhere);";
                $adb->pquery($SQL,array());
          // echo $SQL."<br>";
           if($ordertype==1){
            $SQL="select * from (SELECT * FROM temptable) as F1 ";
            //echo $SQL."<br>";
            }elseif($ordertype==2){
            $SQL="select * from (SELECT * FROM temptable2) as F1 ";
            //echo $SQL."<br>";  
            }else{
            $SQL="select * from (SELECT * FROM temptable UNION SELECT * FROM temptable2) as F1 ";
                //echo $SQL."<br>";  
            }

           //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
      
    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['cf_1529'] = $adb->query_result($result, $i, 'cf_1529');
        $List[$i]['purchaseorder_no'] = $adb->query_result($result, $i, 'purchaseorder_no');
        $List[$i]['cf_1476'] = $adb->query_result($result, $i, 'cf_1476');
        $List[$i]['cf_1469'] = $adb->query_result($result, $i, 'cf_1469');
        $List[$i]['carrier'] = $adb->query_result($result, $i, 'carrier');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['cf_1461'] = $adb->query_result($result, $i, 'cf_1461');
        $List[$i]['cf_1467'] = $adb->query_result($result, $i, 'cf_1467');
        $List[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $List[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $List[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $List[$i]['sf7'] = number_format($adb->query_result($result, $i, 'sf7'),2);
        $List[$i]['sf727'] = number_format($adb->query_result($result, $i, 'sf727'),2);
        $List[$i]['sf805'] = number_format($adb->query_result($result, $i, 'sf805'),2);
        $List[$i]['carrier2'] = number_format($adb->query_result($result, $i, 'carrier2'),2);
        $List[$i]['sf963'] = number_format($adb->query_result($result, $i, 'sf963'),2);
        $List[$i]['sf1042'] = number_format($adb->query_result($result, $i, 'sf1042'),2);
        $List[$i]['taxprice'] = number_format($adb->query_result($result, $i, 'taxprice'));
        $List[$i]['sf5'] = number_format($adb->query_result($result, $i, 'sf5'),2);
        $List[$i]['chenben'] = number_format($adb->query_result($result, $i, 'taxprice'));
        $List[$i]['shouru'] = number_format($adb->query_result($result, $i, 'shouru'),2);
        $List[$i]['lirun'] = number_format($adb->query_result($result, $i, 'lirun'),2);
		$List[$i]['shangji'] = $adb->query_result($result, $i, 'shangji');
    }
        $sSQL5="drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable;"; 
        $result1 = $adb->query($sSQL5);  
    return $List;
}
function getcarrier(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 11:49
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('carrier');
    $productList = array_values($result_pick);
    return $productList;
}
function getcf_1476(){
        global $adb; 
    $SQL = 'select cf_1476 from ld_cf_1476 group by cf_1476';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1476');
        }
    return $productList;
}
function getcf_1469(){
        global $adb; 
    $SQL = 'select cf_1469 from ld_cf_1469 group by cf_1469';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1469');
        }
    return $productList;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/CostRevenuesReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/CostRevenuesReport.tpl');

exit();
?>