<?php
//导出模块
global $adb,$current_user,$currentModule;
$module=$currentModule;

require('user_privileges/user_language_'.$current_user->id.'.php');
$tabid=getTabid($module);
$modulelabel=getTranstab($module);

if(file_exists('storage/'.$module.'.xls'))
{
    @unlink('storage/'.$module.'.xls');
}
					

$exportTemplateValue=array('main'=>array('smownerid'=>'系统管理员','timesheet_no'=>'TS001'),
        'Products'=>array(array('timetype'=>'direct','entitytype'=>'项目','entitytypeid'=>'PROJ2','costtime'=>'4'),
        array('timetype'=>'direct','entitytype'=>'项目','entitytypeid'=>'PROJ3','costtime'=>'8')
    ));


/*
if(isset($_REQUEST['exports']) && !empty($_REQUEST['exports'])){
	$text=$_REQUEST['exports'];
}else{
	echo '<script type="text/javascript">alert("请选择模板。");history.go(-1);</script>';exit();
}
*/


$sql='select fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
 and presence in(0,2)  and ld_field.columnname not in("entitytypeid","subtotal","total") AND ld_field.uitype not in(1109,202,69,222)
order by ld_blocks.sequence, ld_field.sequence asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));


$_sql='select ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname ,input_type
    from ld_tabdetailfield tf
    inner join ld_tranlabel on ld_tranlabel.relateid=tf.tabdetailfieldid
    where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2) 
    and tf.tabid=? and (tf.tablename=? or tf.tablename=?) and tf.savedatabase = "yes"
     ORDER BY sequence  asc;';
$_result=$adb->pquery($_sql,array($languageType,'ld_tabdetailfield',$tabid,'ld_timesheetdetail','ld_timesheetdetailscf'));

   

$exportarr=array();

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->getActiveSheet()->SetTitle($modulelabel);
$objPHPExcel->setActiveSheetIndex(0);
$modulelabel = getTranstab($module);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);
$kk=0;

$dupfield_count=0;
$addsheet=new PHPExcel_Worksheet($objPHPExcel,'导入示例');
$objPHPExcel->addSheet($addsheet,1);
$objPHPExcel->setActiveSheetIndex(1);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'1',getTranstab($currentModule).'有一个明细的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'7')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'7',getTranstab($currentModule).'有多个明细的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'14')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'14','说明：多选框字段，录入格式为：张三 |##| 李四');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'15')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'15','*注意：|##|两边都要有空格');
$objPHPExcel->getActiveSheet()->SetTitle("导入示例");

$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$dupfield_count=0;
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
   // $blockLabel=($adb->query_result($result,$i,'blocklabel'));
    $columnname=$adb->query_result($result,$i,'columnname');
    $uitype=$adb->query_result($result,$i,'uitype');
    $typedata=explode('~',$typeofdata);
    $mainfield[]=$fieldLabel;

    //if(in_array($columnname.'-field',$text))
    //{
      
        if($typedata[1]=='M' ||$uitype==4)
        {
          $fieldLabel= $fieldLabel.'*';
           $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
          
          
            $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $exporttemplatecolumn['main'][]=$columnname;
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $dupfield_count++;
          
           
        }
        $objPHPExcel->setActiveSheetIndex(0);
        
        
        $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $activesheet->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($kk))->setWidth(20);  
        if($typedata[0]=='D')
        {
            $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
       
        
        $kk++;
    //} 
}

for($i=0;$i<$adb->num_rows($_result);$i++)
{
    $typeofdata=$adb->query_result($_result,$i,'typeofdata');
    $columnname=$adb->query_result($_result,$i,'columnname');
    $fieldLabel=$adb->query_result($_result,$i,'fieldlabel');
    $input_type=$adb->query_result($_result,$i,'input_type');
    $typedata=explode('~',$typeofdata);
    
 
    //if(in_array($columnname.'-tabdetailfield',$text))
   // {
        if(in_array($fieldLabel,$mainfield)){
            $fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL'). '_'.$fieldLabel;
        }
        $objPHPExcel->setActiveSheetIndex(0);
         if($typedata[1]=='M'||$input_type==2)
        {
          $fieldLabel.='*';
           $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
        }
        //导入明细模板
       
	
       // $activesheet->getColumnDimension($headers[$kk%26].$forheaders[$kk/26])->setWidth(20);
        if($typedata[0]=='D')
        {
            $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
       
        if($typedata[1]=='M')
        {
               
                  $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
        
        }
       
             //导入明细示例
            $exporttemplatecolumn['Products'][]=$columnname;
             $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $dupfield_count++;
         
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $kk++;
    //}
     if($columnname=='entitytypeid'||$columnname=='costtime')
    {
         $exporttemplatecolumn['Products'][]=$columnname;
          $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
         $dupfield_count++;
    }
   
}


$objPHPExcel->setActiveSheetIndex(1);
$dupfield_count=0;

//导入示例模板
foreach($exporttemplatecolumn as $columntype=>$columnnames)
{
    foreach($columnnames as $index=>$columnname)
    {
        if($columntype=='main')
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['main'][$columnname]);
        }
        else
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['Products'][1][$columnname]);
        }
        $dupfield_count++;
    }
    
    
}



$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'1')->setWidth(100);
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'7')->setWidth(100);

$objPHPExcel->getActiveSheet()->getTabColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->setActiveSheetIndex(0);

$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($adb);

//$modulelabel = getTranstab($currentModule);
$modulelabel=getFixedLabel('My').getTranstab($module).getFixedLabel('exporttemplate');
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));

$objWriter->save('storage/'.$module.'.xls');   
//下载文件
$file_name = "$module.xls";
$file_dir = "storage/";
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);

?>