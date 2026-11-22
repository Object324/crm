<?php
global $adb, $default_charset;
if(!$adb){
    
    exit();
}
//海格5.订单的产品品种和数量不能超出报价单的相关数据
$quantityarr=explode(',',$_REQUEST['quantitys']);
$productids=$_REQUEST['productids'];
$productidarr=explode(",",$productids);
$query = "select productid,productname,usageunit from ld_products where productid in ($productids)";
$result = $adb->pquery($query);
$rows = $adb->num_rows($result);
if($rows >= 1){
	for($i=0;$i<$rows;$i++){
		$productid=$adb->query_result($result,$i,'productid');
		$producname=$adb->query_result($result,$i,'productname');	//产品型号
		$usageunit=$adb->query_result($result,$i,'usageunit');	//基本单位
		$sales_productsname[$productid]= array(
			'productname' => $producname,
			'usageunit' => $usageunit,
		);
	}
}
$quoteid=$_REQUEST['quoteid'];
$sql='select (ifnull(ld_quotesdetail.quantity,0)-ifnull(ld_quotesdetail.haveordercount,0)) as balanceordercount ,ld_quotesdetail.productid,
ld_products.productname,ld_products.usageunit from ld_quotesdetail 
inner join ld_products on ld_products.productid=ld_quotesdetail.productid where id=?';
$result=$adb->pquery($sql,array($quoteid));
$rows=$adb->num_rows($result);
$db_info=array();
for($i=0;$i<$rows;$i++)
{
    $productid=$adb->query_result($result,$i,'productid');
    $balanceordercount=$adb->query_result($result,$i,'balanceordercount');
    $producname=$adb->query_result($result,$i,'productname');	//产品型号
	$usageunit=$adb->query_result($result,$i,'usageunit');	//基本单位
    $db_info[$productid]=$balanceordercount;
    $dbproductnames[$productid]= array(
		'productname' => $producname,
		'usageunit' => $usageunit,
	);
}
foreach($productidarr as $index=>$productid)
{
    if(array_key_exists($productid,$db_info)){
        if($quantityarr[$index]>$db_info[$productid])
        {
			$data[] = array(2,$dbproductnames[$productid]['productname'],$dbproductnames[$productid]['usageunit'],$quantityarr[$index],'下单数量超过报价单数量',$db_info[$productid]);
        }else{
			$data[] = array(1,$dbproductnames[$productid]['productname'],$dbproductnames[$productid]['usageunit'],$quantityarr[$index],'',$db_info[$productid]);
            $db_info[$productid] -= $quantityarr[$index];
		}
    }
    else
    {
        //zkt 20230629 BUG0068879  海格：以下内容实际错误应该——是报价单不存在该型号，能否修改描述 
        $data[] = array(3,$sales_productsname[$productid]['productname'],$sales_productsname[$productid]['usageunit'],$quantityarr[$index],'报价单不存在该型号',0);
    }
}
$title = array('产品型号','基本单位','数量','备注','剩余下单数量');
	//echo globalStatic::$root_directory;die;
	require_once(globalStatic::$root_directory."PHPExcel/PHPExcel.php");
	$obj = new PHPExcel();  
	//横向单元格标识  
	$cellName = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO', 'AP', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ');  
	$obj->getActiveSheet(0)->setTitle('错误日志');   //设置sheet名称 
	$_row = 0;   //设置纵向单元格标识  
	if($title){  
		$_cnt = count($title);  
		$_row++;  
		$i = 0;  
		foreach($title AS $v){   //设置列标题  
			$obj->setActiveSheetIndex(0)->setCellValue($cellName[$i].$_row, $v);  
			$i++;  
		}  
		$_row++;  
	}
	//填写数据  
	if($data){  
		$i = 0;  
		foreach($data AS $_v){  
			$j = 0;
			$_rows = $i+$_row;
			$prd_type = 0;
			
			foreach($_v AS $key => $_cell){
				if($key >= 1){
					if($prd_type == 2 && $key == 3){
						$obj->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($j).$_rows)->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
						$obj->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($j).$_rows,$_cell);
						$obj->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($j))->setWidth(20);
					}else if($prd_type == 3 && $key == 1){
						$obj->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($j).$_rows)->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
						$obj->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($j).$_rows,$_cell);
						$obj->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($j))->setWidth(20);
					}else{
						$obj->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($j).$_rows,$_cell);
						$obj->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($j))->setWidth(20);
					}
					//$obj->getActiveSheet(0)->setCellValue($cellName[$j] . ($i+$_row), $_cell);  
					$j++;
				}else{
					$prd_type = $_cell;
				}
			}  
			$i++;  
		}  
	}
	//文件名处理  
	$fileName = "销售合同产品错误日志";
	$objWrite = PHPExcel_IOFactory::createWriter($obj, 'Excel2007');  //Excel2007
  
	//$_fileName = iconv("utf-8", "gb2312", $fileName);   //转码  
	$savePath = './storage/SalesOrder/';
	if (!file_exists($savePath)){
		mkdir ($savePath,0777,true);
	}
	$_savePath = $savePath.$_fileName.'.xlsx';
	
	$objWrite->save($_savePath);
	$disk_file_size = filesize($_savePath);
	$diskfilesize = $disk_file_size + ($disk_file_size % 1024);
	$fileContent = fread(fopen($_savePath, "r"), $diskfilesize);
	$name = html_entity_decode($fileName.'.xlsx', ENT_QUOTES, $default_charset);
	header("Content-type: $fileType");
	header("Pragma: public");
	header("Cache-Control: private");
	if(stripos($_SERVER['HTTP_USER_AGENT'],'edge')!==false)//edge浏览器(win10自带)
		 header("Content-Disposition: attachment; filename=".urlencode($name));
	else{
		 if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'||strtolower(PHP_OS)=='macos'){
			header("Content-Disposition: attachment; filename=".$name);
		}else{
			header("Content-Disposition: attachment; filename=".mb_convert_encoding($name,'GB2312','UTF-8'));
		}
	}
	//header("Content-Disposition: attachment; filename=\"".$name."\"");
	header("Content-Description: PHP Generated Data");
	header('Content-Encoding: none');       
	header("Content-Transfer-Encoding: binary" );
	//**********************************        
	/*
	edit:can
	date:20130424
	reason:0003461: "知识管理"上传word作为附件后，再下载，下载完成后，无法打开，希望修改。
	*/
	ob_clean();   
	flush(); 
	@unlink($_savePath);
	//********************************* 
	echo $fileContent;
	
?>