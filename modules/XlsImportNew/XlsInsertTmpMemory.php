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
    $error .=getFixedLabel('IMPORTNODATAERROR').'<br>';
    
    ConvertTojsonString("-1",array(),$error);
                    
}
 $highestColumn = $objWorksheet->getHighestColumn();
 $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
 $result=$_SESSION['mainfield_'.$currentModule.'_'.$current_user->id.'_fields'];//数组
 $mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
 $totalcolumns=sizeof($mapfields);
 
if($totalcolumns<=0)
{
    ConvertTojsonString("-1",array(),'导入字段不能为空');
    
}
for($i=0;$i<sizeof($result);$i++)
{
              
    $uitype=$result[$i]['uitype'];
    $columnname=$result[$i]['columnname'];
    $tablename=$result[$i]['tablename'];
    $typeofdata=$result[$i]['typeofdata'];
    $fieldLabel=$result[$i]['fieldlabel'];
    $typedata=explode('~',$typeofdata);
    $smcreatorid=$current_user->id;
     if($currentModule=="ServiceCharge"&&($tablename=='ld_contactdetails'||$tablename=='ld_contactscf'))
        continue;
    //37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
    if($typedata[1]=='M'&&$uitype!=4&&$columnname!='currency_id')//修改系统编号为非必填
    {
        if(!in_array($columnname.'-field',$mapfields))
        {
            $error.='导入文件中缺少'.$fieldLabel.'列<br>';
            
        }
    }            
}
if(!empty($error)){
    
    ConvertTojsonString("-1",array(),$error);
    
}
$totalcolumns=sizeof($mapfields);
$maxrows=$objWorksheet->getHighestRow();
while(true)
{
                        //获取excel中数据行数，防止有删除的空行也算入导入行数了
    for($tmppk=0;$tmppk<$totalcolumns;$tmppk++)
    {
                $tmp_str=trim((string)$objWorksheet->getCellByColumnAndRow($tmppk, $maxrows)->getValue());
                if($tmp_str!=='')
                {
                    break;
                }
    }
    if($tmp_str!='')
    {
            break;
    }
    if($maxrows<=0)
    {
        break;
    }
    $maxrows--;
                       
                        
                        
}
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
$importdupfields_condition=json_decode($_REQUEST['importdupfields_condition'],true);//查重字段条件
$checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
$is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
 $sql='delete from  ld_importcheckdupfields where entitytype=? ';
 $adb->pquery($sql,array($currentModule));
 $sql='insert into ld_importcheckdupfields(columns,entitytype,sequence,conditions)value(?,?,?,?)';
 $conditionorlabel=getFixedLabel('OR');
 $conditionandlabel=getFixedLabel('SEARCHAND');

 for($i=0;$i<sizeof($is_checkimportfield);$i++)
 {
            
            $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$is_checkimportfield[$i],'fieldlabel');
            if($importdupfields_condition[$i]=='or')
                $conditionlabel=$conditionorlabel;
            else
                $conditionlabel=$conditionandlabel;
            
            $adb->pquery($sql,array($is_checkimportfield[$i],$currentModule,$i,$importdupfields_condition[$i]));
            
            
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