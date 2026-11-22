<?php
ob_get_clean();
global $adb,$current_user,$currentModule;
//$module='Accounts';
require('user_privileges/user_language_'.$current_user->id.'.php');

$modulelabel=getTranstab($currentModule);
$tabid = getTabid($currentModule);



$modulelabel=getTranstab($currentModule);

if(file_exists('storage/'.$currentModule.'.xls'))
{
    @unlink('storage/'.$currentModule.'.xls');
}
/*
if(isset($_REQUEST['exports']) && !empty($_REQUEST['exports'])){
	$text=$_REQUEST['exports'];
}else{
	echo '<script type="text/javascript">alert("请选择模板。");history.go(-1);</script>';exit();
}
*/

$sql = 'SELECT fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,tablename 
        FROM ld_field
        INNER JOIN ld_blocks ON ld_blocks.blockid = ld_field.block
        INNER JOIN ld_tranlabel AS fieldtran ON ld_field.fieldid = fieldtran.relateid
        INNER JOIN ld_tranlabel AS blocktran ON blocktran.relateid = ld_blocks.blockid 
      where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
        and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
         and presence in(0,2) and ld_field.uitype not in(64,65,1109,28,69) and ld_field.tablename not in("ld_contactdetails","ld_contactscf")
        order by ld_blocks.sequence, ld_field.sequence asc ';
        $result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));

$exportarr=array();
$exportTemplateValue=array('main'=>array('accountname'=>'上海信息科技有限公司','account_no'=>'ACC1',
    'smownerid'=>'系统管理员'),'Contacts'=>array(array('lastname'=>'刘总','contact_no'=>'CON1'),
        array('lastname'=>'李总','contact_no'=>'CON2'))
   
        
    
    );
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$modulelabel = getTranstab($currentModule);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);
$dupfield_count=0;
$addsheet=new PHPExcel_Worksheet($objPHPExcel,'导入示例');
$objPHPExcel->addSheet($addsheet,1);
$objPHPExcel->setActiveSheetIndex(1);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'1',getTranstab('Accounts').'有一个'.getTranstab('Contacts').'的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'7',getTranstab('Accounts').'有多个'.getTranstab('Contacts').'的导入示例');


$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'14')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'14','说明：多选框字段，录入格式为：张三 |##| 李四');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'15')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'15','*注意：|##|两边都要有空格');
$objPHPExcel->getActiveSheet()->getTabColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);

$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setWidth(40);  
$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setWidth(15); 
$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setWidth(15); 
$objPHPExcel->getActiveSheet()->getColumnDimension('E')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('F')->setWidth(15); 
$objPHPExcel->getActiveSheet()->getColumnDimension('G')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);
$objPHPExcel->getActiveSheet()->SetTitle("导入示例");

$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$kk=0;

for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
   // $blockLabel=($adb->query_result($result,$i,'blocklabel'));
    $columnname=$adb->query_result($result,$i,'columnname');
    $tablename=$adb->query_result($result,$i,'tablename');
    $uitype=$adb->query_result($result,$i,'uitype');
    $typedata=explode('~',$typeofdata);
     $columnname_tablename =$columnname.'_'.$tablename; 

   // if(in_array($columnname_tablename.'-field',$text))
    //{
      
        if($typedata[1]=='M'||$uitype==4)
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
$objPHPExcel->setActiveSheetIndex(0);
for($k=2;$k<100;$k++)
{
    $kk=0;
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        
        $columnname=$adb->query_result($result,$i,'columnname');
        $tablename=$adb->query_result($result,$i,'tablename');
        
         $columnname_tablename =$columnname.'_'.$tablename; 
    
        //if(in_array($columnname_tablename.'-field',$text))
        //{
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).$k," ");
           
            $kk++;
       // }
       
        
    }
}
$objPHPExcel->setActiveSheetIndex(1);
$dupfield_count=0;
foreach($exporttemplatecolumn as $columntype=>$columnnames)
{
    foreach($columnnames as $index=>$columnname)
    {
        if($columntype=='Contacts')
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['Contacts'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['Contacts'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['Contacts'][1][$columnname]);
        }
        
        else
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['main'][$columnname]);
           $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['main'][$columnname]);
        
        }
        $dupfield_count++;
    }
    
    
}
//exit();
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'1')->setWidth(100);
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'7')->setWidth(100);

$objPHPExcel->setActiveSheetIndex(0);
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($adb);

$modulelabel=getFixedLabel('My').getTranstab($currentModule).getFixedLabel('exporttemplate');
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));

$objWriter->save('storage/'.$currentModule.'.xls');   
//下载文件
$file_name = "$currentModule.xls";
$file_dir = "storage/";
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_get_clean();
 
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);

?>