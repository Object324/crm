<?php
ob_get_clean();
global $adb, $current_user, $currentModule;
require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
if(isset($_REQUEST['frommodule'])){
    $currentModule = $_REQUEST['frommodule'];
}

$modulelabel = getTranstab($currentModule);
$moduleid = getTabid($currentModule);
$file_name = $currentModule . "_product.xls";
if (file_exists('storage/' .$file_name)) {
    @unlink('storage/' . $file_name);
}

// 创建一个新的Excel对象
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();

// 选择活动工作表
$objPHPExcel->setActiveSheetIndex(0);
$sheet = $objPHPExcel->getActiveSheet();
$tmpSheettitle = $modulelabel.'产品';
$tmpSheettitle = str_replace(' ','_',$tmpSheettitle);
$tmpSheettitle = str_replace('/','_',$tmpSheettitle);
$tmpSheettitle = str_replace('\\','_',$tmpSheettitle);
$tmpSheettitle = str_replace('?','_',$tmpSheettitle);
$tmpSheettitle = str_replace('[','(',$tmpSheettitle);
$tmpSheettitle = str_replace(']',')',$tmpSheettitle);
$tmpSheettitle = str_replace('*','',$tmpSheettitle);
$tmpSheettitle = str_replace(':','',$tmpSheettitle);
$objPHPExcel->getActiveSheet()->setTitle($tmpSheettitle);


//zkt 20230719 BUG0069508 基础资料--价格表--导入 1、导入的模板下面的页签应修改为价格表明细，应该有第二个页签做示例导入 
//导入示例
$addsheet=new PHPExcel_Worksheet($objPHPExcel,'导入示例');
$objPHPExcel->addSheet($addsheet,1);
$objPHPExcel->setActiveSheetIndex(1);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE);
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'1','产品查重字段为产品名称的价格表产品导入示例');
$addsheet->setCellValue('A2', '产品查重字段*');
$addsheet->setCellValue('B2', '单价*');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(1) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$addsheet->setCellValue('A3', '豆浆');
$addsheet->setCellValue('B3', '10');
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'6','*注意：产品查重字段的内容应与导入明细中设置的查重字段保持一致');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'6')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->getActiveSheet()->SetTitle("导入示例");


$objPHPExcel->setActiveSheetIndex(0);
// 在第一个单元格(A1)中设置数据
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0))->setWidth(20);
$sheet->setCellValue('A1', '产品查重字段*');
$sheet->setCellValue('B1', '单价*');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(1) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);

//zkt 20230717 BUG0069491 	kfbcrm-价格表-产品管理-导入-下载数据模板，模板名称应为“价格表产品清单导入模板” 
$importfilename = getTranstab($currentModule).getFixedLabel('PRODUCTS') . getFixedLabel('importtemplate');
$importfilename = str_replace(' ', '_', iconv('UTF-8', 'gbk', $importfilename));
// 保存Excel文件为xlsx格式
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
//$objWriter->save('example.xlsx');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($adb);


$objWriter->save('storage/' . $file_name);
//下载文件

$file_dir = "storage/";
$file = fopen($file_dir . $file_name, "r");
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: " . filesize($file_dir . $file_name));
Header("Content-Disposition: attachment; filename=" . $importfilename . ".xls");
ob_get_clean();
ob_clean();
flush();
echo fread($file, filesize($file_dir . $file_name));
fclose($file);

?>