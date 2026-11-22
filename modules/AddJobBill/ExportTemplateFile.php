<?php
//导出模块
ob_get_clean();
global $adb,$current_user,$currentModule;
$module=$currentModule;
$languageType= getLanguageType($current_user);
$tabid=getTabid($module);
$modulelabel=getTranstab($module);

if(file_exists('storage/'.$module.'.xls'))
{
    @unlink('storage/'.$module.'.xls');
}
					
$exportTemplateValue=array('main'=>array('addjobbill_no'=>'JB1', 'smownerid'=>'系统管理员'),
                'Products'=>array(array('starttime'=>'2017-5-8 18:00:00','endtime'=>'2017-5-8 19:00:00','costtime'=>1),
            
                    array('starttime'=>'2017-5-9 18:00:00','endtime'=>'2017-5-9 19:00:00','costtime'=>1),
                    array('starttime'=>'2017-5-10 18:00:00','endtime'=>'2017-5-10 19:00:00','costtime'=>1)
        )
    
    );

/*
if(isset($_REQUEST['exports']) && !empty($_REQUEST['exports'])){
	$text=$_REQUEST['exports'];
}else{
	echo '<script type="text/javascript">alert("请选择模板。");history.go(-1);</script>';exit();
}*/




$sql='select fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
 and presence in(0,2)  and ld_field.columnname not in("entitytypeid","subtotal") AND ld_field.uitype  not in(202,1109,69,222)
order by ld_blocks.sequence, ld_field.sequence asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));


$_sql='select ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname ,input_type
    from ld_tabdetailfield tf
    inner join ld_tranlabel on ld_tranlabel.relateid=tf.tabdetailfieldid
    where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2)  
    and  tf.edit_permission = 0 AND ( tf.newline = 0 or tf.input_type=2) AND tf.savedatabase = "yes"
    and tf.tabid=?  ORDER BY sequence  asc;';

$_result=$adb->pquery($_sql,array($languageType,'ld_tabdetailfield',$tabid));


$detailcolumname=array('entitytype-tabdetailfield');

   
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
   //XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段
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
    //{
    //XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
    if (in_array($fieldLabel,$mainfield)){
        $fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL'). '_'.$fieldLabel;
    }
        $objPHPExcel->setActiveSheetIndex(0);
         if($typedata[1]=='M'||$input_type==2)
        {
          $fieldLabel.='*';
           $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
        }
       
        if($typedata[0]=='D')
        {
            $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
         if($columnname=='entitytypeid'){
            
                
               // $fieldLabel=getFixedLabel('CHOOSEENTITYTYPE');
               if($typedata[1]=='M')
               {
                 $fieldLabel.="*" ;
                  $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
        
               }
            
                $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',getFixedLabel('CHOOSEENTITYTYPE'));
                $kk++;
            	$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        } 
        else
        {
            
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
             //导入明细示例
            $exporttemplatecolumn['Products'][]=$columnname;
             $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $dupfield_count++;
        } 
        $kk++;
    //}
   
}



$objPHPExcel->setActiveSheetIndex(1);
$dupfield_count=0;
//导入示例模板
crm_load_class_file('TabDetailFields','include/TabDetailFields');
$detailfieldobj=TabDetailFields::getInstance($currentModule);

foreach($exporttemplatecolumn as $columntype=>$columnnames)
{
    foreach($columnnames as $index=>$columnname)
    {
        if($columntype=='main')
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'11',$exportTemplateValue['main'][$columnname]);
        }
        else
        {
             $detailfieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
            $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($dupfield_count))->setWidth($detailfieldinfo->getWidth()/2);  
           
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['Products'][1][$columnname]);
             $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'11',$exportTemplateValue['Products'][2][$columnname]);
        }
        $dupfield_count++;
    }
    
    
}



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