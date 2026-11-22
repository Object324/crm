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

$cf_1476=getcf_1476();
$cf_1476value = $_REQUEST['cf_1476'];
$smarty->assign("cf_1476",$cf_1476);
if($cf_1476value!=''){
   $where .= " and cf_1476 = '$cf_1476value'"; 
}
$cf_1469=getcf_1469();
$cf_1469value = $_REQUEST['cf_1469'];
$smarty->assign("cf_1469",$cf_1469);
if($cf_1469value!=''){
   $where .= " and cf_1469 = '$cf_1469value'"; 
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

$List = getDividend($where,$begin_date,$end_date,$query,$query2,$ordertype,$fsalesorder_name);

if($_REQUEST['type']=='export'){

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'合同编号','合同主体','客户/二代名称','客户简称','客户来源','广告主名称','投放媒体','产品线','应收款时间','应收款金额','已开票金额',
'已回款金额','应收未收回款项','上级合同'
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
function getDividend($where,$begin_date,$end_date,$query,$query2,$ordertype,$fsalesorder_name){
    global $adb; 
    //echo $useridSQL;
    $SQL = "CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable IGNORE (
            SELECT 
            	cf_1529 as salesorder_no,
            	cf_1476,
            	accountname,
            	cf_1459,
            	cf_1469,
            	cf_1461,
            	productname,
            	productsheet,
            	ld_invoice_date.cf_1518,
            	ld_invoice_date.total,
                IFNULL(cashbill.Total,0) as yishou,
 			    IFNULL(ld_invoice_date.total,0) - IFNULL(cashbill.Total,0) AS weishou,
				gds.salesorder_no as shangji
            FROM
            	ld_salesorder
			left join (select salesorderid,salesorder_no from ld_salesorder where deleted=0) as gds on gds.salesorderid=ld_salesorder.parentid
            LEFT JOIN (
            	SELECT
            		salesorderid,
            		productid
            	FROM
            		ld_salesorder
            	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
            	GROUP BY
            		salesorderid
            ) AS salesorder_info ON salesorder_info.salesorderid = ld_salesorder.salesorderid
            LEFT JOIN ld_products ON ld_products.productid = salesorder_info.productid
            LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
            LEFT JOIN ld_account ON ld_salesorder.accountid = ld_account.accountid
            LEFT JOIN (
            	SELECT 
            		ld_invoice.invoice_no,
            		ld_invoice.invoiceid,
            		SUM(ld_invoice.total) AS total,
            		CASE
            	WHEN cf_1518 is not NULL THEN
            		cf_1518
            	WHEN cf_1518 <> '' THEN
            		cf_1518
            	WHEN cf_1518 IS NULL THEN
            		date_add(cf_1519, INTERVAL cf_1517 DAY)
            	WHEN cf_1518 = '' THEN
            		date_add(cf_1519, INTERVAL cf_1517 DAY)
            	END AS cf_1518,
            	entitytypeid
            FROM
            	ld_invoice
            LEFT JOIN ld_invoicecf ON ld_invoice.invoiceid = ld_invoicecf.invoiceid
            LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
            LEFT JOIN ld_salesorder ON ld_invoicedetail.entitytypeid = ld_salesorder.salesorderid
            LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
            WHERE
            	ld_invoicedetail.entitytype = 'SalesOrder' GROUP BY entitytypeid
            ) AS ld_invoice_date ON ld_invoice_date.entitytypeid = ld_salesorder.salesorderid
            LEFT JOIN 
            (
			SELECT 	entitytypeid,
						sum(Total) AS total 
			FROM (
					SELECT
						entitytypeid,
						Total AS total,
						ld_cashbill.cashbillid
					FROM
						ld_cashbill
					LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
					GROUP BY ld_cashbill.cashbillid ) AS fe3
					GROUP BY
						entitytypeid
            ) AS cashbill ON ld_salesorder.salesorderid=cashbill.entitytypeid
            WHERE
            	ld_salesorder.deleted = 0 AND ld_salesordercf.cf_1518 is not NULL and cf_1462='执行单' and carrier='充值类型' $query);";
       // echo $SQL."<br>";
           $adb->pquery($SQL,array());
           
           $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable2 IGNORE (
                SELECT 
                	cf_1529 as salesorder_no,
                	cf_1476,
                	accountname,
                	cf_1459,
                	cf_1469,
                	cf_1461,
                	productname,
                	productsheet,
                	ld_invoice_date.cf_1518,
                	ld_invoice_date.total,
                    IFNULL(cashbill.Total,0) as yishou,
         			IFNULL(ld_invoice_date.total,0) - IFNULL(cashbill.Total,0) AS weishou,
					gds.salesorder_no as shangji
                FROM
                	ld_salesorder
				left join (select salesorderid,salesorder_no from ld_salesorder where deleted=0) as gds on gds.salesorderid=ld_salesorder.parentid
                LEFT JOIN (
                	SELECT
                		salesorderid,
                		productid
                	FROM
                		ld_salesorder
                	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
                	GROUP BY
            		salesorderid
                ) AS salesorder_info ON salesorder_info.salesorderid = ld_salesorder.salesorderid
                LEFT JOIN ld_products ON ld_products.productid = salesorder_info.productid
                LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
                LEFT JOIN ld_account ON ld_salesorder.accountid = ld_account.accountid
                LEFT JOIN (
                	SELECT 
                		ld_invoice.invoice_no,
                		ld_invoice.invoiceid,
                		ld_invoice.total,
                		CASE
                	WHEN cf_1518 <> '' THEN
                		cf_1518
                	WHEN cf_1518 IS NULL THEN
                		date_add(cf_1519, INTERVAL cf_1517 DAY)
                	WHEN cf_1518 = '' THEN
                		date_add(cf_1519, INTERVAL cf_1517 DAY)
                	END AS cf_1518,
                	entitytypeid
                FROM
                	ld_invoice
                LEFT JOIN ld_invoicecf ON ld_invoice.invoiceid = ld_invoicecf.invoiceid
                LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                LEFT JOIN ld_salesorder ON ld_invoicedetail.entitytypeid = ld_salesorder.salesorderid
                LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
                WHERE
                	ld_invoicedetail.entitytype = 'SalesOrder'
                ) AS ld_invoice_date ON ld_invoice_date.entitytypeid = ld_salesorder.salesorderid
                LEFT JOIN 
                (
					SELECT cf_1532,
                    SUM(Total) AS total FROM (
                    SELECT
                    cf_1532,
                    Total AS total,ld_cashbill.cashbillid
                    FROM
                    ld_cashbill
                    LEFT JOIN ld_cashbillscf ON ld_cashbill.cashbillid = ld_cashbillscf.cashbillid
										GROUP BY ld_cashbill.cashbillid 
									) AS sdf3
                    GROUP BY
                    cf_1532
                ) AS cashbill ON ld_invoice_date.invoice_no=cashbill.cf_1532
                WHERE
                	ld_salesorder.deleted = 0 AND ld_salesordercf.cf_1518 is NULL and cf_1462='执行单' 
                    and carrier='充值类型' 
                    $query);";
                $adb->pquery($SQL,array());
             // echo $SQL."<br>";   
              
            $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable3 IGNORE (
                    SELECT
                	contract_no AS salesorder_no,
                	cf_1534 as cf_1476,
                	accountname,
                	cf_1542 as cf_1459,
                	cf_1535 as cf_1469,
                	cf_1536 as cf_1461,
                	productname,
                	productsheet,
                	ld_invoice_date.cf_1538 as cf_1518,
                	ld_invoice_date.total,
                	IFNULL(cashbill.Total, 0) AS yishou,
                	IFNULL(ld_invoice_date.total, 0) - IFNULL(cashbill.Total, 0) AS weishou,
					gds.salesorder_no as shangji
                FROM
                	ld_servicecontracts
				left join (select salesorderid,salesorder_no from ld_salesorder where deleted=0) as gds on gds.salesorderid=ld_servicecontracts.salesorderid
                LEFT JOIN (
                	SELECT
                		servicecontractsid,
                		productid
                	FROM
                		ld_servicecontractsdetail
                	LEFT JOIN ld_servicecontractsdetail ON ld_servicecontractsdetail.id = ld_servicecontracts.servicecontractsid
                	GROUP BY
                		servicecontractsid
                ) AS servicecontracts_info ON servicecontracts_info.servicecontractsid = ld_servicecontracts.servicecontractsid
                LEFT JOIN ld_products ON ld_products.productid = servicecontracts_info.productid
                LEFT JOIN ld_servicecontractscf ON ld_servicecontractscf.servicecontractsid = ld_servicecontracts.servicecontractsid
                LEFT JOIN ld_account ON ld_servicecontracts.accountid = ld_account.accountid
                LEFT JOIN (
                	SELECT
                		ld_invoice.invoice_no,
                		ld_invoice.invoiceid,
                		SUM(ld_invoice.total) AS total,
                		CASE
                	WHEN cf_1538 IS NOT NULL THEN
                		cf_1538
                	WHEN cf_1538 <> '' THEN
                		cf_1538
                	WHEN cf_1538 IS NULL THEN
                		date_add(cf_1519, INTERVAL cf_1539 DAY)
                	WHEN cf_1538 = '' THEN
                		date_add(cf_1519, INTERVAL cf_1539 DAY)
                	END AS cf_1538,
                	entitytypeid
                FROM
                	ld_invoice
                LEFT JOIN ld_invoicecf ON ld_invoice.invoiceid = ld_invoicecf.invoiceid
                LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                LEFT JOIN ld_servicecontracts ON ld_invoicedetail.entitytypeid = ld_servicecontracts.servicecontractsid
                LEFT JOIN ld_servicecontractscf ON ld_servicecontractscf.servicecontractsid = ld_servicecontracts.servicecontractsid
                WHERE
                	ld_invoicedetail.entitytype = 'ServiceContracts'
                GROUP BY
                	entitytypeid
                ) AS ld_invoice_date ON ld_invoice_date.entitytypeid = ld_servicecontracts.servicecontractsid
                LEFT JOIN (
				SELECT 	entitytypeid,
					sum(Total) AS total 
				FROM (
					SELECT
			entitytypeid,
			Total AS total,
			ld_cashbill.cashbillid
		FROM
			ld_cashbill
		LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
		GROUP BY ld_cashbill.cashbillid ) AS fe3
		GROUP BY
			entitytypeid
                ) AS cashbill ON ld_servicecontracts.servicecontractsid = cashbill.entitytypeid
                WHERE
                	ld_servicecontracts.deleted = 0
                AND ld_servicecontractscf.cf_1538 IS NOT NULL $query2);";
                
               //   echo $SQL."<br>";   
            $adb->pquery($SQL,array());
            $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable4 IGNORE (
                    SELECT
                    contract_no AS salesorder_no,
                    cf_1534 as cf_1476,
                    accountname,
                    cf_1542 as cf_1459,
                    cf_1542 as cf_1469,
                    cf_1536 as cf_1461,
                    productname,
                    productsheet,
                    ld_invoice_date.cf_1538 as cf_1518,
                    ld_invoice_date.total,
                    IFNULL(cashbill.Total, 0) AS yishou,
                    IFNULL(ld_invoice_date.total, 0) - IFNULL(cashbill.Total, 0) AS weishou,
					gds.salesorder_no as shangji
                    FROM
                    ld_servicecontracts
					left join (select salesorderid,salesorder_no from ld_salesorder where deleted=0) as gds on gds.salesorderid=ld_servicecontracts.salesorderid
                    LEFT JOIN (
                    SELECT
                    servicecontractsid,
                    productid
                    FROM
                    ld_servicecontracts
                    LEFT JOIN ld_servicecontractsdetail ON ld_servicecontractsdetail.id = ld_servicecontracts.servicecontractsid
                    GROUP BY
                    servicecontractsid
                    ) AS servicecontracts_info ON servicecontracts_info.servicecontractsid = ld_servicecontracts.servicecontractsid
                    LEFT JOIN ld_products ON ld_products.productid = servicecontracts_info.productid
                    LEFT JOIN ld_servicecontractscf ON ld_servicecontractscf.servicecontractsid = ld_servicecontracts.servicecontractsid
                    LEFT JOIN ld_account ON ld_servicecontracts.accountid = ld_account.accountid
                    LEFT JOIN (
                    SELECT
                    ld_invoice.invoice_no,
                    ld_invoice.invoiceid,
                    ld_invoice.total,
                    CASE
                    WHEN cf_1538 <> '' THEN
                    cf_1538
                    WHEN cf_1538 IS NULL THEN
                    date_add(cf_1519, INTERVAL cf_1539 DAY)
                    WHEN cf_1538 = '' THEN
                    date_add(cf_1519, INTERVAL cf_1539 DAY)
                    END AS cf_1538,
                    entitytypeid
                    FROM
                    ld_invoice
                    LEFT JOIN ld_invoicecf ON ld_invoice.invoiceid = ld_invoicecf.invoiceid
                    LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                    LEFT JOIN ld_servicecontracts ON ld_invoicedetail.entitytypeid = ld_servicecontracts.servicecontractsid
                    LEFT JOIN ld_servicecontractscf ON ld_servicecontractscf.servicecontractsid = ld_servicecontracts.servicecontractsid
                    WHERE
                    ld_invoicedetail.entitytype = 'ServiceContracts'
                    ) AS ld_invoice_date ON ld_invoice_date.entitytypeid = ld_servicecontracts.servicecontractsid
                    LEFT JOIN (
					SELECT  cf_1532,
                    SUM(Total) AS total FROM (
                    SELECT
                    cf_1532,
                    Total AS total,ld_cashbill.cashbillid
                    FROM
                    ld_cashbill
                    LEFT JOIN ld_cashbillscf ON ld_cashbill.cashbillid = ld_cashbillscf.cashbillid
										GROUP BY ld_cashbill.cashbillid 
									) AS sdf3
                    GROUP BY
                    cf_1532
                    ) AS cashbill ON ld_invoice_date.invoice_no = cashbill.cf_1532
                    WHERE
                    ld_servicecontracts.deleted = 0
                    AND ld_servicecontractscf.cf_1538 IS NULL $query2);";
 // echo $SQL."<br>";   
            $adb->pquery($SQL,array());
           if($ordertype==1){
            $SQL="select * from (SELECT * FROM temptable UNION SELECT * FROM temptable2) as F1 
           where cf_1518 BETWEEN '$begin_date' AND '$end_date'
           $where";
            //echo $SQL."<br>";
            }elseif($ordertype==2){
            $SQL="select * from (SELECT * FROM temptable3 UNION SELECT * FROM temptable4) as F1 
           where cf_1518 BETWEEN '$begin_date' AND '$end_date'
           $where";
            //echo $SQL."<br>";  
            }else{
            $SQL="select * from (SELECT * FROM temptable UNION SELECT * FROM temptable2 UNION 
            SELECT * FROM temptable3 UNION SELECT * FROM temptable4) as F1 
            where cf_1518 BETWEEN '$begin_date' AND '$end_date'
            $where";
               
            }
  //echo $SQL."<br>"; 
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);

    for ($i = 0; $i < $rowCount; $i++) {  
        $List[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $List[$i]['cf_1476'] = $adb->query_result($result, $i, 'cf_1476');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['cf_1459'] = $adb->query_result($result, $i, 'cf_1459');
        $List[$i]['cf_1469'] = $adb->query_result($result, $i, 'cf_1469');
        $List[$i]['cf_1461'] = $adb->query_result($result, $i, 'cf_1461');
        $List[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $List[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $List[$i]['cf_1518'] = $adb->query_result($result, $i, 'cf_1518');
        $List[$i]['total'] = number_format($adb->query_result($result, $i, 'total'),2);     
		$List[$i]['total2'] = number_format($adb->query_result($result, $i, 'total'),2);
        $List[$i]['yishou'] = number_format($adb->query_result($result, $i, 'yishou'),2);  
        $List[$i]['weishou'] = number_format($adb->query_result($result, $i, 'weishou'),2);  
		$List[$i]['shangji'] = $adb->query_result($result, $i, 'shangji');
    }
        $sSQL5="drop TEMPORARY  table if exists temptable4;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists temptable;"; 
        $result1 = $adb->query($sSQL5);  
      /*  echo '<pre>';
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
    $smarty->display('Comprehensivereport/ReceivablesReportcontent.tpl');
else
    $smarty->display('Comprehensivereport/ReceivablesReport.tpl');

exit();
?>