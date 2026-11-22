<?php
set_time_limit(0);
global $adb;
//require_once("modules/XlsImport/ImportCommon.php");
global $currentModule,$current_user;
 $focus=CRMEntity::getInstance($_REQUEST['frommodule']);
 $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=array();
$_REQUEST['diony']='yes';
$filename=$_REQUEST['filename'];
$filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名

 if($filetype=='xlsx'){
        $inputFileType = 'Excel2007';      
 }else{
        $inputFileType = 'Excel5';
 }
$startimporttime=date("Y-m-d H:i:s");
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_startdate']=$startimporttime;//导入开始时间         
$inputFileName = 'storage/'.$filename;
require_once('PHPExcel/PHPExcel/IOFactory.php') ;
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objReader->setReadDataOnly(true);        
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();
$highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
if(sizeof($highestRow)<2){
	 $error .='模板文件中没有数据，导入失败！'.'<br>'; 
	 ConvertTojsonString("-1",array(),$error);			
}
$highestColumn = $objWorksheet->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
$maxrows=$objWorksheet->getHighestRow();
$xlsRowData=array();
$tmprow=0;
$row=2;

while(true)
{
                   
    if($row>$maxrows)//如果超过xls文件行数则退出循环
    {
        break;
    }
    if(!array_key_exists($row,$highestRow))
    {
        $row++;
        continue;
    }
                             
    for($excel_col_index=0;$excel_col_index<$highestColumnIndex;$excel_col_index++)
    {
        $excel_value=$objWorksheet->getCellByColumnAndRow($excel_col_index, $row)->getValue();
        $excel_value=trim((string)$excel_value);
       
       $xlsRowData[$tmprow][]=$excel_value;
    }
                        
	$row++;
	$tmprow++;
}
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=$xlsRowData;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex']=$highestColumnIndex;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows']=sizeof($xlsRowData);
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow']=$highestRow;  
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']=0;    
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=0;  
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]='';
include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');//进度条

$tmp['maxrows']=$maxrows;
$tmp['timedescription']=$time_description;
$tmp['cur_progress_step']=$cur_progress_step;
ConvertTojsonString(1,$tmp,'success');
                  
?>