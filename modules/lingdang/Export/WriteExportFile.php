<?php
/**
 * 列表不带明细的测试
 * 
 * 
 * */

global  $adb;
global $current_user;
$languageType=getLanguageType($current_user);

global $currentModule, $theme;
global $list_max_entries_per_page_new;

require_once('include/ListView/ListViewSession.php');
include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';



if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
}

//$cacheMethod = PHPExcel_CachedObjectStorageFactory::cache_to_phpTemp;
//$cacheSettings = array('memoryCacheSize'=>'10MB');
//PHPExcel_Settings::setCacheStorageMethod($cacheMethod, $cacheSettings);
        
@unlink($pathname);
  
$objPHPExcel = new PHPExcel();

$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$modulelabel = getTranstab($currentModule);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);

$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($_REQUEST['search_field']);
unset($_REQUEST['search_text']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
unset($_REQUEST['type']);
unset($_REQUEST['advft_criteria']);
unset($_REQUEST['advft_criteria_groups']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);





$listview_header=$_SESSION[$currentModule][$current_user->id]['export']['listview_header'];
foreach($listview_header as $key=>$arr){
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim(strip_tags($arr)));
}




$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
 crm_load_class_file("cls_excelImage",'include');
 $excelimageobj=new cls_excelImage();
 if($listcounts<=0)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
    echo '<script>showExportResult();</script>';
 }
 $prev_totalrows=2;
 $headerlistfields=$_SESSION[$currentModule][$current_user->id]['export']['headerlistfields'];

 //$objWriter->save($pathname); 
//echo sizeof($_SESSION[$currentModule][$current_user->id]['export']['data']);
//exit();
//230530 wym 图片字段添加超链接
$sql="select crm_address from ld_organizationdetails";
$result = $adb->pquery($sql, array());
$organization_crm_address = $adb->query_result($result,0,'crm_address');
 foreach($_SESSION[$currentModule][$current_user->id]['export']['data'] as $index=>$listview_entries )
 {
             //if($index>)
                 
                    foreach($listview_entries as $key=>$arr)
                    {
                                 
                            foreach($arr as $key2=>$arr2){
                                   $fieldname=$headerlistfields[$key2];
                                  // $fieldinfo=$controller->getListViewFieldobj($key2,$fieldname);
                                  
                                   $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                               
                                
                                if($fieldinfo&&$fieldinfo->isImageField()=="yes")
                                {
                                    
                                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                                    
                                    
                                }
                                else  if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
                                 {
                                   
                                    
                                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).(($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_NUMERIC);
                
                                 }
                                 else
                                $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).(($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
                            }
                            
                            $prev_totalrows++;
                            file_put_contents(globalStatic::$root_directory.'modules/lingdang/2.txt',$prev_totalrows);
                            
                            //$_SESSION[$currentModule][$current_user->id]['export']['writecurrow']=$prev_totalrows-2;
                    }
                       
 }
              
 foreach($listview_header as $key=>$arr)//设置数字列和金额列的宽度
 {
                             $fieldname=$headerlistfields[$key];
                             $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                           // $fieldinfo=$controller->getListViewFieldobj($key,$fieldname);
                             if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
                                {
                                     $tmp= PHPExcel_Cell::stringFromColumnIndex($key);
                                     $objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(12);
                                }
 }
              
      
        
$totalfldhtml = $_SESSION[$currentModule][$current_user->id]['export']['totalhtml'];
if(!empty($totalfldhtml))
{
                 
    $_SESSION[$currentModule][$current_user->id]['export']['totalfldhtml']=$totalfldhtml;
    $maxkey=$prev_totalrows+1;
               
    if(is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
    foreach($totalfldhtml as $key=>$arr){
        $arr = str_replace('&yen;','¥',strip_tags($arr)); 
        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
    }
                  
}
        
       
$objWriter->save($pathname); 
//unset($_SESSION[$currentModule][$current_user->id]['export']); 
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
             
exit();
?>