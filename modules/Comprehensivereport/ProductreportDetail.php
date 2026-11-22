<?php
/**
 * 更新操作
 * Edit:andrew
 * date:20140115
 * reason:内销报表-产品（龙威）
 * */
global $adb,$mod_strings;

$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
     if(is_int(intval($_REQUEST['year']))==false)
    {
        
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
	$year_list = getSalesKit($year,$month,'all');
	$month_list = getSalesKit($year,$month,'month');
	$year_sun_quantity = 0;
	$year_sum_tax_amount = 0;
	$month_sun_quantity = 0;
	$month_sum_tax_amount = 0;
	$k = 1;
	foreach($year_list as $productid => $arr){
		if(!empty($month_list[$productid])){
			$year_list[$productid]['month_quantity'] = $month_list[$productid]['quantity'];
			$year_list[$productid]['month_tax_amount'] = $month_list[$productid]['tax_amount'];
		}else{
			$year_list[$productid]['month_quantity'] = 0;
			$year_list[$productid]['month_tax_amount'] = 0;
		}
		$year_sun_quantity += $year_list[$productid]['quantity'];
		$year_sum_tax_amount += $year_list[$productid]['tax_amount'];
		$month_sun_quantity += $year_list[$productid]['month_quantity'];
		$month_sum_tax_amount += $year_list[$productid]['month_tax_amount'];
		$year_list[$productid]['no'] = $k;
		$year_list[$productid]['qty_zhanbi'] =  round(($year_list[$productid]['month_quantity']/$year_list[$productid]['quantity']*100),2)."%";
		$year_list[$productid]['amount_zhanbi'] =  round(($year_list[$productid]['month_tax_amount']/$year_list[$productid]['tax_amount']*100),2)."%";
		$year_list[$productid]['descimal_quantity'] = getDecimalTwoVal($year_list[$productid]['quantity']);
		$year_list[$productid]['descimal_month_quantity'] = getDecimalTwoVal($year_list[$productid]['month_quantity']);
		$year_list[$productid]['descimal_tax_amount'] = getDecimalTwoVal($year_list[$productid]['tax_amount']);
		$year_list[$productid]['descimal_month_tax_amount'] = getDecimalTwoVal($year_list[$productid]['month_tax_amount']);
		$year_list[$productid]['year_junjia'] = getDecimalTwoVal($year_list[$productid]['tax_amount']/$year_list[$productid]['quantity']);
		$year_list[$productid]['junjia'] = getDecimalTwoVal($year_list[$productid]['month_tax_amount']/$year_list[$productid]['month_quantity']);
		$k++;
	}
	if(!empty($_REQUEST['Export']) && $_REQUEST['Export']=='true'){
		 include('PHPExcel/PHPExcel.php');
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->setActiveSheetIndex(0);
		$activesheet=$objPHPExcel->getActiveSheet();
		$exportheader = array('货号','类型','年累计销售数量','年累计销售金额','本月销售数量','本月销售金额','数量累计占比','金额累计占比','产品年均价','月均价');
		foreach($exportheader as $key=>$arr){
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
		}
		$j = 2;
		foreach($year_list as $productid => $arr){
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$j,decode_html($arr['productname']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(1).$j,decode_html($arr['productcategory']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(2).$j,decode_html($arr['quantity']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(3).$j,decode_html($arr['tax_amount']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(4).$j,decode_html($arr['month_quantity']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(5).$j,decode_html($arr['month_tax_amount']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(6).$j,decode_html($arr['qty_zhanbi']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(7).$j,decode_html($arr['amount_zhanbi']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(8).$j,decode_html($arr['year_junjia']));
			$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(9).$j,decode_html($arr['junjia']));
			++ $j;
		}
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$j,decode_html(''));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(1).$j,decode_html('合计'));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(2).$j,decode_html($year_sun_quantity));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(3).$j,decode_html($year_sum_tax_amount));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(4).$j,decode_html($month_sun_quantity));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(5).$j,decode_html($month_sum_tax_amount));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(6).$j,decode_html(''));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(7).$j,decode_html(''));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(8).$j,decode_html(''));
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(9).$j,decode_html(''));
		$file_name = 'Comprehensivereport.xls';
		$file_dir = './storage/';
		$label = $year."年".$month."月销售统计表-按产品";
		
		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'||strtolower(PHP_OS)=='macos'){
			$label=iconv('utf-8','gb2312',$label);
        }else{
			$label = mb_convert_encoding($label,'GB2312','UTF-8');
		}
		$objPHPExcel->getActiveSheet()->setTitle('Comprehensivereport');
		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
		$objWriter->save($file_dir.$file_name);

		//下载文件
		$file = fopen($file_dir.$file_name,"r"); 
		Header("Content-type: application/octet-stream");
		Header("Accept-Ranges: bytes");
		Header("Accept-Length: ".filesize($file_dir.$file_name));
		Header("Content-Disposition: attachment; filename=".$label.".xls" );
		Header("pragma: no-cache");
		ob_clean();
		flush(); 
		echo fread($file, filesize($file_dir.$file_name));
		fclose($file);
		exit();
	}
               
	//页面赋值
	$smarty->assign("YEAR",$year);//年
	$smarty->assign("MONTH",$month);//月
	$smarty->assign('formodule',$_REQUEST['formodule']);
	$smarty->assign('name',$_REQUEST['name']);
	$smarty->assign('parenttab',$_REQUEST['parenttab']);
	$smarty->assign("PRODUCT_LIST",$year_list);
	$smarty->assign('year_sun_quantity',$year_sun_quantity);
	$smarty->assign('year_sum_tax_amount',$year_sum_tax_amount);
	$smarty->assign('month_sun_quantity',$month_sun_quantity);
	$smarty->assign('month_sum_tax_amount',$month_sum_tax_amount);
	$smarty->assign('product_no',$_REQUEST['product_no']);
	$smarty->display('Comprehensivereport/ProductreportDetail.tpl');
	exit();
}

function getSalesKit($year,$month,$type){
	global $adb;
	$query = 'select ld_outboundorderdetail.id,ld_products.productid,ld_products.productname,ld_products.productcategory,
	sum(ld_outboundorderdetail.quantity) as qty,ld_outboundorderdetail.taxprice,
	sum(ld_outboundorderdetail.tax_amount) as amount,ld_outboundorder.adjustment  as ad
	from ld_outboundorderdetail 
	INNER JOIN ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id 
	LEFT JOIN ld_products on ld_products.productid = ld_outboundorderdetail.productid 
	where ld_outboundorder.deleted <> 1 and ld_outboundorderdetail.productid > 0 and ld_products.deleted <> 1 and presence = "已出库"  
	and year(ld_outboundorder.outdate) = ? ';
	if($type == 'month'){
		$query .= ' and month(ld_outboundorder.outdate) = "'.$month.'"';
	}else{
		$query .= ' and month(ld_outboundorder.outdate) <= "'.$month.'"';
	}
	if(!empty($_REQUEST['Report_form_query']) && $_REQUEST['Report_form_query'] == 'true' && !empty($_REQUEST['product_no'])){
		$query .= ' and ld_products.productname like "%'.$_REQUEST['product_no'].'%"';
	}
	$query .= ' GROUP BY ld_outboundorderdetail.productid ORDER BY qty desc';
	$result = $adb->pquery($query,array($year));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$productid = $adb->query_result($result,$i,'productid');
			$quantity = $adb->query_result($result,$i,'qty');
			$tax_amount = $adb->query_result($result,$i,'amount');
			if(!empty($data[$productid])){
				$data[$productid]['quantity'] += $quantity;
				$data[$productid]['tax_amount'] += $tax_amount;
			}else{
				$data[$productid] = array(
					'productname' => $adb->query_result($result,$i,'productname'),
					'productcategory' => $adb->query_result($result,$i,'productcategory'),
					'quantity' => $adb->query_result($result,$i,'qty'),
					'tax_amount' => $adb->query_result($result,$i,'amount'),
				);
			}
			
		}
	}
	return $data;
}
exit();
if($month==1){
    $lastyear = $year-1;
    $lastmonth = 12;
}else{
    $lastyear = $year;
    $lastmonth = $month;
}
$product_list = get_product();
$product_mun_list = loop_product($month,$year);
//echo '<pre>';
//print_r($product_list);
foreach($product_list as $key1=>$arr1){
    foreach($product_mun_list as $key2=>$arr2){
        if($key1==$key2){
            //echo $key1.'<br>';
            $product_list[$key1][3] = $arr2[0];
            $product_list[$key1][4] = $arr2[1];
            $product_list[$key1][5] = $arr2[2];
            $product_list[$key1][6] = $arr2[3];
            $product_list[$key1][7] = $arr2[7];
            $product_list[$key1][8] = $arr2[8];
            $product_list[$key1][9] = round($arr2[7]/$arr2[0]*100,2).'%';//年退货率
            $product_list[$key1][10] = $product_list[$key1][5]-$product_list[$key1][8];
            $product_list[$key1][11] =get_outnum($product_list[$key1][productid],$month,$year);
            unset($product_list[$key1][productid]);
        }
    }
}
/**
 *@edit:andy
 *@reason: LW产品报表增加查询字段，当月出库量
 *@data:20140430
 *@other:none
 */ 
function get_outnum($prodductid,$month,$year)
{  
    global $adb;
    $sql="select t3.productname,t3.productid,sum(t2.quantity) as outqty
         from ld_outboundorder as t1 inner join 
		 ld_inventoryproductrel as t2 on t1.out_id=t2.id inner join 
		 ld_products as t3 on t3.productid=t2.productid
         where YEAR(t1.outdate)=".$year." and MONTH(t1.outdate)=".$month." and t2.productid=".$prodductid.
         " group by t2.productid";
   $result=$adb->pquery($sql,array());
   $total=$adb->query_result($result,0,'outqty');
  //echo $total.'<br>';
   if($total=='')
        $total=0;
   return $total;
}
foreach($product_list as $key=>$row){
    $vals[$key] = $row[10];
}
array_multisort($vals,SORT_DESC,$product_list);

foreach($product_list as $key=>$arr){
    foreach($arr as $key2=>$arr2){
        if($key2!=1 && $key2!=2 && $key2!=3 && $key2!=4 && $key2!=6 && $key2!=7 && $key2!=9){
            $product_list[$key][$key2] = getDecimalTwoVal($arr2);
        }
    }
}



/*
*edit:andrew
*20140115
*循环产品获取列表
*/
function loop_product($month,$year){
    $product_list = get_product();
    //echo "<pre>";
    //var_dump($product_list);
    foreach($product_list as $key=>$arr){
        $aca[$key] = get_sale_list($arr[productid],$month,$year,'');
        $acas[$key] = get_sale_list($arr[productid],$month,$year,'monthdetail');
        $netspricelist[$key] = get_netspcie($arr[productid],$month,$year,'');
        $netspricelistyear[$key] = get_netspcie($arr[productid],$month,$year,'monthdetail');
        $salesbacknum[$key] = get_salesback($arr[productid],$month,$year);//退货单信息
    }
    //print_r($salesbacknum);
    foreach($netspricelist as $key=>$arr){
        //print_r($arr);echo "|<br>";
        if($arr==''){
            $netspricelist[$key][0][netprices] = 0;
        }
    }
    foreach($netspricelistyear as $key2=>$arr2){
        if($arr2==''){
            $netspricelistyear[$key2][0] = 0;
        } 
    }
    foreach($netspricelist as $key=>$arr){
        foreach($arr as $key2=>$arr2){
           $netspricelists[$key][netprices] += $arr2[netprices];
        }
    }
    foreach($netspricelistyear as $key=>$arr){
        foreach($arr as $key2=>$arr2){
           $netspricelistyears[$key][netprices] += $arr2[netprices];
        }
    }
    foreach($netspricelistyears as $key=>$arr){
        foreach($netspricelists as $key2=>$arr2){
            if($key==$key2){
               $netspricelists[$key2][1] = round(($arr[netprices]/$arr2[netprices]*100),2)."%";
            }
        }
    }
    foreach($aca as $key=>$arr){
        if($arr[0]==''){
            $aca[$key][0] = 0;
        }
    }
    foreach($acas as $key2=>$arr2){
        if($arr2[0]==''){
            $acas[$key2][0] = 0;
        } 
    }
    foreach($acas as $key=>$arr){
        foreach($aca as $key2=>$arr2){
            if($key==$key2){
               $aca[$key2][1] = round(($arr[0]/$arr2[0]*100),2)."%";
            }
        }
    }
    foreach($aca as $key1=>$arr1){
        foreach($netspricelists as $key2=>$arr2){
            if($key1==$key2){
                $aca[$key1][2] = $arr2[netprices];
                $aca[$key1][3] = $arr2[1];
            }
        }
    }
    //退货单信息
    foreach($aca as $key1=>$arr1){
        foreach($salesbacknum as $key2=>$arr2){
            if($key1==$key2){
                $aca[$key1][7] = $arr2[0][quantity]?$arr2[0][quantity]:0;
                $aca[$key1][8] = $arr2[0][listprice]?$arr2[0][listprice]:0;
            }
        }
    }
    //print_r($aca);
    return $aca;
    
}

/*
*edit:andrew
*20140115
*获取产品列表
*/
function get_product(){
    global $adb;
    $sql = "SELECT productid,productsheet as productname,productcategory FROM ld_products WHERE productcategory in ('经济型','专业级','工业级')";
    //echo $sql;
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $product_list[$i][productid] = $adb->query_result($result, $i, 'productid');
        $product_list[$i][1] = $adb->query_result($result, $i, 'productname');
        $product_list[$i][2] = $adb->query_result($result, $i, 'productcategory');
    }
    return $product_list;
}

/*
*edit:andrew
*20140115
*获取年累计销售数量
*/
function get_sale_list($pid,$month,$year,$type=''){
    global $adb;
    $ssql = "SELECT salesorderid FROM ld_salesorder  ";
    $ssql .= "WHERE ";
    if($type=='monthdetail'){
        $ssql .= "MONTH(signed_data)=".$month." and YEAR(signed_data)=".$year; 
    }else{
        $ssql .= "MONTH(signed_data)<=".$month." and YEAR(signed_data)=".$year; 
    }
    
    $ssql .= " and stockpresence='全部出库' and sostatus<>'已作废' and ld_salesorder.deleted=0";
    $sql = "SELECT sum(ifnull(quantity,0)) as s_quantity FROM ld_inventoryproductrel where productid=".$pid." and id in (".$ssql.")";

    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $productcount_list[$i] = $adb->query_result($result, $i, 's_quantity');
    }
    return $productcount_list;
}
/*
*edit:andrew
*20140115
*获取产品净价
*/
function get_netspcie($pid,$month,$year,$type=''){
    global $adb;
    $sql = "SELECT s.discount_percent,s.discount_amount,i.quantity,i.listprice,s.taxtype FROM ld_salesorder as s ";
    $sql .= "left join ld_inventoryproductrel as i on i.id=s.salesorderid  
    ";
    $sql .= "WHERE  ";
    if($type=='monthdetail'){
        $sql .= "MONTH(s.signed_data)=".$month." and YEAR(s.signed_data)=".$year; 
    }else{
        $sql .= "MONTH(s.signed_data)<=".$month." and YEAR(s.signed_data)=".$year; 
    }
    
    $sql .= " and stockpresence='全部出库' and s.sostatus<>'已作废' and s.deleted=0 and i.productid=".$pid;
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $discount_percent = $adb->query_result($result, $i, 'discount_percent');
        $discount_amount = $adb->query_result($result, $i, 'discount_amount');
        $quantity = $adb->query_result($result, $i, 'quantity');
        $listprice = $adb->query_result($result, $i, 'listprice');
        $taxtype = $adb->query_result($result, $i, 'taxtype');
        $productid = $pid;
        
        $total=$listprice*$quantity;//净价

        $RealDiscount=0;
        $totalMoney=$total;
        if(!empty($discount_percent)&&isset($discount_percent))
        {
            $RealDiscount=$total*$discount_percent/100;//折扣额       
            $total=$total-$total*$discount_percent/100;        
        }
        if(!empty($discount_amount)&&isset($discount_amount))
        {
            $total-=$discount_amount;
            $RealDiscount=$discount_amount;//折扣额
                                    
        }          
        $netprices[$i][netprices] = $total;
    }
    return $netprices;
}
/**
 * @ 获取产品退货数量
 * @ by andy 
 * @ 20140121
*/
function get_salesback($pid,$month,$year)
{    
    global $adb;
    
    $sql="SELECT i.quantity,i.listprice 
            FROM ld_inventoryproductrel as i 
            in (SELECT salesbackid from ld_salesback) 
            and i.productid= ".$pid." and MONTH(createdtime)<=".$month." and YEAR(createdtime)=".$year;
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $salesbacklist[$i][quantity] = $adb->query_result($result, $i, 'quantity');
        $salesbacklist[$i][listprice] = $adb->query_result($result, $i, 'listprice');
    }
    foreach($salesbacklist as $key=>$arr){
        $salesbacklists[0][quantity] += $arr[quantity];
        $salesbacklists[0][listprice] += $arr[listprice]*$arr[quantity];
    }
    return $salesbacklists;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);//月
$smarty->assign("PRODUCT_LIST",$product_list);
$smarty->display('Comprehensivereport/ProductreportDetail.tpl');
exit();
?>