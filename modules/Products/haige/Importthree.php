<?php
 set_time_limit(0);
global $current_user;
global $currentModule;
$filename=$_REQUEST['filename'];
if(empty($filename))
{
    $frommodule=$_REQUEST['frommodule'];
    $focus=CRMEntity::getInstance($frommodule);
    $arr['modulelabel']=gettranstab($frommodule);
    $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty=new lingdangCRM_Smarty();
     $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['content']=$smarty->fetch('ImportXlsNew/haige/ThreeImport.tpl');
    $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
	$tmp['cur_progress_step'] = 0;
    //$tmp['oktext']=getFixedLabel("ASTEP");
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$tmp,'success');
    
}

if($currentModule=='Users')
{
    include(globalStatic::$root_directory."modules/XlsImportNew/ImportThreeUsers.php");
    exit();
}
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
$filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名
if($filetype=='xlsx'){
	$inputFileType = 'Excel2007';      
}else{
	$inputFileType = 'Excel5';
}
$inputFileName = 'storage/'.$filename;
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objReader->setReadDataOnly(true);        
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();
$highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
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
$startrow = $_REQUEST['startrow'];
$endrow=$_REQUEST['endrow'];
if(!empty($xlsRowData) && !empty($_REQUEST['record'])){
	$pricebookid = $_REQUEST['record'];	//价格表ID
	foreach($xlsRowData as $key => $data){
		if($key >= $startrow && $key <= $endrow){
			if(!empty($data[0]) && !empty($data[1])){
				$productname = $data[0];
				$price = $data[1];
				$query = "select productid from ld_products where productname = ? and deleted = 0 limit 1";
				$result = $adb->pquery($query,array($productname));
				if($adb->num_rows($result) >= 1){
					$productid = $adb->query_result($result,0,0);
					$query_rel = "select 1 from ld_pricebookproductrel where pricebookid = ? and productid = ?";
					$result_rel = $adb->pquery($query_rel,array($pricebookid,$productid));
					if($adb->num_rows($result_rel) >= 1){
						$update = "update ld_pricebookproductrel set listprice = ? where pricebookid = ? and productid = ?";
						$adb->pquery($update,array($price,$pricebookid,$productid));
						$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
					}else{
						$query= "insert into ld_pricebookproductrel (pricebookid,productid,listprice,usedcurrency) values(?,?,?,?)";
						$adb->pquery($query, array($pricebookid,$productid,$price,1));
						$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
					}
					$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
				}else{
					$error = "物料编号【".$productname."】在CRM系统不存在，导入失败！".'<br>';
					$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error'].=$error;
				}
			}
			//$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error'].=$error;
			
		}
	}
}

$_REQUEST['diony']='yes';
include(globalStatic::$root_directory.'modules/Products/haige/ImportProgress.php');//进度条
$tmp['timedescription']=$time_description;
$tmp['cur_progress_step']=$cur_progress_step;
$tmp['endimporttime']=$endimporttime;
$tmp['endrow']=$endrow;
ConvertTojsonString(1,$tmp,'success');

?>