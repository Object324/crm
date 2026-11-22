<?php
ob_get_clean();
global $adb,$current_user;
$module='VendorContactRecords';
require('user_privileges/user_language_'.$current_user->id.'.php');
$exportTemplateValue=array('subject'=>'初次沟通','vendorid'=>'京东','smownerid'=>'系统管理员','contactid'=>'章总');
$modulelabel=getTranstab($module);

if(file_exists('storage/'.$module.'.xls'))
{
    @unlink('storage/'.$module.'.xls');
}
/*
if(isset($_REQUEST['exports']) && !empty($_REQUEST['exports'])){
	$text=$_REQUEST['exports'];
}else{
	echo '<script type="text/javascript">alert("请选择模板。");history.go(-1);</script>';exit();
}*/
$tabid=getTabid("VendorContactRecords");
$sql='select fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
 and presence in(0,2)  and savedatabase="yes"
order by ld_blocks.sequence, ld_field.sequence asc ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));
   
$exportarr=array();

include(globalStatic::$root_directory. 'PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$modulelabel = getTranstab($module);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);
$activesheet=$objPHPExcel->getActiveSheet();
$addsheet=new PHPExcel_Worksheet($objPHPExcel,'导入示例');
$objPHPExcel->addSheet($addsheet,1);
$objPHPExcel->setActiveSheetIndex(0);
$dupfield_count=0;
$kk=0;
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
   // $blockLabel=($adb->query_result($result,$i,'blocklabel'));
    $columnname=$adb->query_result($result,$i,'columnname');
    $uitype=$adb->query_result($result,$i,'uitype');
    $typedata=explode('~',$typeofdata);

    //if(in_array($columnname.'-field',$text))
    //{
      
        if($typedata[1]=='M' ||$uitype==4)
        {
          $fieldLabel= $fieldLabel.'*';
           $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
           $objPHPExcel->setActiveSheetIndex(1);
           $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
           $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'1',$fieldLabel);
           $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($dupfield_count))->setWidth(20);  
           $exporttemplatecolumn[]=$columnname;
           $dupfield_count++;
           
        }
        $objPHPExcel->setActiveSheetIndex(0);
        $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($kk))->setWidth(20);  
        if($typedata[0]=='D')
        {
            $objStyle = $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
        $kk++;
   // }
   
    
}
$objPHPExcel->setActiveSheetIndex(1);
$activesheet=$objPHPExcel->getActiveSheet();
$dupfield_count=0;
foreach($exporttemplatecolumn as $index=>$columnname)
{
    $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$exportTemplateValue[$columnname]);
    $dupfield_count++;
}
$activesheet->SetTitle("导入示例");
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