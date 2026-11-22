<?php
/*******************************************************
**更新操作
**edit:chj
**date:2013-11-26
**reason:导出
*******************************************************/

require_once('ListView.php');
ob_clean();
$ex_heard= array(
    getFixedLabel('COMPANYACCOUNT'),
    getFixedLabel('DATE'),
    getFixedLabel('BIll'),
    getFixedLabel('DocumentNumber'),
    getFixedLabel('ACCOUNTSVENDORS'),
    getFixedLabel('STATUS'),
    getFixedLabel('RELATEDPERSONNEL'),
    getFixedLabel('AMOUNTRECEIVED'),
    getFixedLabel('AMOUNTSPENDING'),
    getFixedLabel('BALANCE')
);

$listview_entriess = $bankcashalllist;

$amount = 0;

//$amount = $after_importtotal - $after_outtotal;
$importtotal=0;
$outtotal=0;
$currencyinfo_arr=[];
$sql='select * from ld_currency_info ';
$result=$adb->pquery($sql,array());
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $currencyinfo_arr[$adb->query_result($result,$i,'id')]=array('rate'=>$adb->query_result($result,$i,'conversion_rate')
    ,'symbol'=>$adb->query_result($result,$i,'currency_symbol'));
    
}


foreach($listview_entriess as $key => $val)
{
   
    if($val['bankaccountsetid'] != $bankaccountsetid )
    {
       
        $amount =$aftertotal[$val['bankaccountsetid']];// $after_importtotal[$listview_entriess[$key]['bankaccountsetid']]-$after_outtotal[$listview_entriess[$key]['bankaccountsetid']];
		
	}
    if(empty($listview_entriess[$key]['conversion_rate']))
    {
       $listview_entriess[$key]['conversion_rate']= $currencyinfo_arr[$listview_entriess[$key]['currency_id']]['rate'];
       $listview_entriess[$key]['currency_symbol']=$currencyinfo_arr[$listview_entriess[$key]['currency_id']]['symbol'];
    }
     $bankaccountsetid=$val['bankaccountsetid'];
   // if($listview_entriess[$key]['importtotal'] > 0)
  //  {
        
        if($listview_entriess[$key]['currency_id'] > 0)
            $amount += $listview_entriess[$key]['importtotal'] / $listview_entriess[$key]['conversion_rate'];
        else
            $amount += $listview_entriess[$key]['importtotal'];
        //echo$listview_entriess[$key]['currency_rate'];
       
  //  }
   // if($listview_entriess[$key]['outtotal'] > 0)
   // {
        if($listview_entriess[$key]['currency_id'] > 0)
            $amount -= $listview_entriess[$key]['outtotal'] / $listview_entriess[$key]['conversion_rate'];
        else
            $amount -= $listview_entriess[$key]['outtotal'];
  //  }
	//dump($amount);
    $listview_entries[$key][0] = $listview_entriess[$key]['cashname'];
    $listview_entries[$key][1] = $listview_entriess[$key]['date'];
    $listview_entries[$key][2] = $listview_entriess[$key]['bill'];
    $listview_entries[$key][3] = $listview_entriess[$key]['billno'];
    $listview_entries[$key][4] = $listview_entriess[$key]['accountid'];
    $listview_entries[$key][5] = $listview_entriess[$key]['status'];
    $listview_entries[$key][6] = $listview_entriess[$key]['person'];
    $listview_entries[$key][7] = htmlspecialchars_decode($listview_entriess[$key]['currency_symbol']).number_format(strip_tags($listview_entriess[$key]['importtotal']),2);
    $listview_entries[$key][8] = htmlspecialchars_decode($listview_entriess[$key]['currency_symbol']).number_format(strip_tags($listview_entriess[$key]['outtotal']),2);
    //$listview_entries[$key][9] = $listview_entriess[$key]['currency_symbol'].strip_tags($amount);
	
	if($basic_currency_id>1)
		
    $listview_entries[$key][9]=$basic_currency_symbol.number_format($amount*$currencyinfo_arr[$basic_currency_id]['rate'],2);
	else
		$listview_entries[$key][9]=$basic_currency_symbol.number_format($amount,2);
    $listview_entries[$key][10] = htmlspecialchars_decode($listview_entriess[$key]['currency_symbol']).$amount;
    $bankname = $listview_entriess[$key]['cashname'];
}
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$headerlang = count($ex_heard);
for($i=0;$i<$headerlang;$i++) {
	$header = $ex_heard[$i];
	$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($i).'1',$header);
}
$j = 2;$list = 0;
foreach($listview_entries as $arr){
	array_pop($arr);$for_i = 0;
	$list = 0;$arrcount = count($arr);
	foreach($arr as $value){
		if($value == '&&'){
			$value = '';
			++ $list;
		}else if($value == '&nbsp;'){
			$value = '';
		}else{
			$value = str_replace('&yen;','¥',strip_tags($value));
            $value = str_replace('&pound;','£',strip_tags($value));
            $value = str_replace('&euro;','€',strip_tags($value));
		}

        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i).$j, trim($value),PHPExcel_Cell_DataType::TYPE_STRING);
		++ $for_i;
		if($arrcount == $list){
			-- $j;
		}
	}
	++ $j;
}

$moduleName = $currentModule;
$modulelabel = getTranstab($moduleName);
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
$objPHPExcel->getActiveSheet()->setTitle($moduleName);
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('storage/'.$moduleName.'.xls');
//下载文件
$file_name = ''.$moduleName.'.xls';
$file_dir = 'storage/';
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir.$file_name));
Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
Header("pragma: no-cache");
ob_clean();
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();

?>