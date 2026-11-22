<?php

/**
 * 更新操作
 * edit:can
 * date:20140115
 * reason:导出模板文件
 * */
global $adb,$current_user,$currentModule;
require('user_privileges/user_language_'.$current_user->id.'.php');

$modulelabel=getTranstab($currentModule);
$moduleid = getTabid($currentModule);
if(file_exists('storage/'.$currentModule.'.xls'))
{
    @unlink('storage/'.$currentModule.'.xls');
}

    $exportTemplateValue=array('main'=>array('purchaseinvoice_no'=>'PINV42','purchaseinvoicestatus'=>'已创建',  'purchaseinvoicedate'=>'2018-3-28',
    'smownerid'=>'系统管理员','currency_id'=>'人民币'),'Products'=>array(array('product_no'=>'PRO1', 'productname'=>'灵当迷你版'),
        array('product_no'=>'PRO2','productname'=>'灵当标准版)'),array('product_no'=>'PRO2','productname'=>'灵当标准版)')),
    'inventorydetail'=>array( array('entitytype'=>'采购订单','entitytypeid'=>'PO1','quantity'=>1,'taxprice'=>12000,'listprice'=>12000,'list_amount'=>12000,'tax_amount'=>12000,'tax_total'=>0)
    ,array('entitytype'=>'采购订单','entitytypeid'=>'PO1','quantity'=>1,'taxprice'=>30000,'listprice'=>30000,'list_amount'=>30000,'tax_amount'=>30000,'tax_total'=>0)
    ,array('entitytype'=>'采购订单','entitytypeid'=>'PO2','quantity'=>1,'taxprice'=>30000,'listprice'=>30000,'list_amount'=>30000,'tax_amount'=>30000,'tax_total'=>0)
        )
    
    );

$details=array('products','inventoryproductrel','producttoolfield');//明细字段信息
$headers=array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
$forheaders=array('','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
$i=0;
/*
if(isset($_REQUEST['exports']) && !empty($_REQUEST['exports'])){
	$text=$_REQUEST['exports'];
}else{
	echo '<script type="text/javascript">alert("请选择模板。");history.go(-1);</script>';exit();
}*/


if(in_array('entitytypeid_ld_inventoryproductrel-producttoolfield',$text) && ($currentModule=='PurchaseInvoice')){//Liver 2016-12-06源单列被选中的情况下，源单类型一同导出
    array_push($text,"entitytype_ld_inventoryproductrel-producttoolfield");
   
}

$sql='select fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,ld_field.tablename from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
 and presence in(0,2) and ld_field.savedatabase="yes" and ld_field.uitype not in(69,1109,202,222,301) and ld_field.columnname not in("discount_percent","discount_amount","adjustment","currency_id","total","subtotal")
order by ld_blocks.sequence, ld_field.sequence asc ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));//主表字段

//产品名称字段
$sql='select ld_tranlabel.fieldlabel from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid
where languagetype=? and trantable=? and ld_tranlabel.tabid=14 and ( columnname=?)';
$proresult=$adb->pquery($sql,array($languageType,'ld_field','product_no'));

//产品工具自定义字段
$sql="SELECT ld_tranlabel.fieldlabel,typeofdata,uitype,columnname,input_type,tablename FROM ld_producttoolfield
      LEFT JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_producttoolfield.producttoolfieldid
      WHERE
	  ld_producttoolfield.tabid = ? AND ld_tranlabel.trantable = ? AND columnname NOT in('adjustment','contractid') and 
      ld_tranlabel.languagetype=? AND ld_producttoolfield.presence IN (0, 2) AND ld_producttoolfield.savedatabase = 'yes'
      GROUP BY ld_producttoolfield.producttoolfieldid
      ORDER BY ld_producttoolfield.sequence ASC;";
$producttoolresult=$adb->pquery($sql,array(getTabid($currentModule),'ld_producttoolfield',$languageType));

//0027800 合同订单导处模板勾选“产品名称”（导出后产品名称也不是必录项）
for($i=0;$i<$adb->num_rows($producttoolresult);$i++)
{
    $typeofdata=$adb->query_result($producttoolresult,$i,'typeofdata');
    $columnname=$adb->query_result($producttoolresult,$i,'columnname');
	if('productname' == $columnname){
		$typedata=explode('~',$typeofdata);
		$productname_typeofdata = $typedata[1];
	}
}
$Salescolumname=array('discount_percent-'.$currentModule,'discount_amount-'.$currentModule,'adjustment-'.$currentModule,'currency_id-'.$currentModule,'subtotal-'.$currentModule,'total-'.$currentModule);
$Salesdetails=array(getFixedLabel('WHOLEDISCOUNTPERCENT')=>'O',getFixedLabel('WHOLEDIRECTPRICE')=>'O',getFixedLabel('Adjustment')=>'O',getFixedLabel('Currency')=>'M',getFixedLabel('SUBTOTAL')=>'O',getFixedLabel('TOTAL')=>'O');

$productcolumname=array('product_no-products','productid-products');
if($productname_typeofdata == 'M'){
	$productdetail=array($adb->query_result($proresult,0,0).'*'=>'M');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
}else{
	$productdetail=array($adb->query_result($proresult,0,0)=>'DEFAULT');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
}
$exportarr=array();

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
$kk=0;
$dupfield_count=0;
$addsheet=new PHPExcel_Worksheet($objPHPExcel,'导入示例');
$objPHPExcel->addSheet($addsheet,1);
$objPHPExcel->setActiveSheetIndex(1);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'1',getTranstab($currentModule).'有一个产品明细的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'7')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'7',getTranstab($currentModule).'关联一张源单多个产品明细的导入示例');

$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'12')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'12',getTranstab($currentModule).'入库单关联多张源单的导入示例');



$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'17')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'17','说明：多选框字段，录入格式为：张三 |##| 李四');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'18')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'18','*注意：|##|两边都要有空格');
$objPHPExcel->getActiveSheet()->SetTitle("导入示例");
//$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'1')->setWidth(100);  
//$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'7')->setWidth(100);  
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$dupfield_count=0;
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
    $mainfield[]=$fieldLabel;
    
   // if(in_array($columnname_tablename.'-field',$text))
    //{
      
        $columnindex=PHPExcel_Cell::stringFromColumnIndex($kk).'1';
         if($typedata[1]=='M' )
        {
    
            $fieldLabel.='*';
            $objPHPExcel->getActiveSheet()->getStyle($columnindex)->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $exporttemplatecolumn['main'][]=$columnname;
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13',$fieldLabel);
            $dupfield_count++;
        }
       $objPHPExcel->setActiveSheetIndex(0);
        $activesheet->setCellValue($columnindex,$fieldLabel);
        $activesheet->getColumnDimension($columnindex)->setWidth(20);  
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
       // {
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).$k," ");
           
            $kk++;
       // }
       
        
    }
}

$j=0;
foreach($Salesdetails as $fieldLabel=>$typedata)
{
    $columnname_tablename=$Salescolumname[$j];
   
     //if(in_array($columnname_tablename,$text))
   // {
//XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
    if(in_array($fieldLabel,$mainfield)){
        $fieldLabel= getTranstab('Products').'_'.$fieldLabel;
    }
        if($typedata=='M')
        {
            
    		$fieldLabel.='*';
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            
        }
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $kk++;
    //}
    
    
    $j++;
}



$j=0;



foreach($productdetail as $fieldLabel=>$typedata)
{
    $columnname_tablename=$productcolumname[$j];
    //if($columnname_tablename=='productid-products'&&!in_array('productid-products',$text))
    //{
       //26494: 采购订单>导出模版：导出模版时不勾选产品名称，导出的模版还是有产品名称
       // $j++;
        //continue;
    //}
    $export_product_columns=explode('-',$columnname_tablename);
   
        $columnname=$export_product_columns[0];
    
    //if(in_array($columnname_tablename,$text))
  //  {
    if(in_array($fieldLabel,$mainfield)){
        $fieldLabel= getTranstab('Products').'_'.$fieldLabel;
    }
        if($typedata=='M')
        {
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
             $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
             $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
            $exporttemplatecolumn['Products'][]=$columnname;
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13',$fieldLabel);
            $dupfield_count++;
        }
        $objPHPExcel->setActiveSheetIndex(0);
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $kk++;
   // }
   
    
    $j++;
}
for($i=0;$i<$adb->num_rows($producttoolresult);$i++)
{
    $typeofdata=$adb->query_result($producttoolresult,$i,'typeofdata');
    $columnname=$adb->query_result($producttoolresult,$i,'columnname');
    $tablename=$adb->query_result($producttoolresult,$i,'tablename');
    $fieldLabel=$adb->query_result($producttoolresult,$i,'fieldlabel');
    $input_type=$adb->query_result($producttoolresult,$i,'input_type');
    $typedata=explode('~',$typeofdata);
    $columnname_tablename =$columnname.'_'.$tablename; 
  
    
   // if(in_array($columnname_tablename.'-producttoolfield',$text))
   // {
    if(in_array($fieldLabel,$mainfield)){
        $fieldLabel= getTranstab('Products').'_'.$fieldLabel;
    }
         if($typedata[1]=='M'||$input_type==2 ||$columnname_tablename=='entitytype_ld_inventoryproductrel')
         {
            $fieldLabel.='*';
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $exporttemplatecolumn['inventorydetail'][]=$columnname;
         
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13',$fieldLabel);
            $dupfield_count++;
            $productdetail[$fieldLabel]=$typedata[1];
         }
         if($columnname_tablename=='entitytypeid_ld_inventoryproductrel')
         {
            $objPHPExcel->setActiveSheetIndex(1);
             $exporttemplatecolumn['inventorydetail'][]=$columnname;
             $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'13',$fieldLabel);
            $dupfield_count++;
         }
         $objPHPExcel->setActiveSheetIndex(0);
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
       // $activesheet->getColumnDimension($headers[$kk%26].$forheaders[$kk/26])->setWidth(20);
        if($typedata[0]=='D')
        {
            $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
        $kk++;
    //}
  
    
}

$objPHPExcel->setActiveSheetIndex(1);
$dupfield_count=0;


foreach($exporttemplatecolumn as $columntype=>$columnnames)
{
    foreach($columnnames as $index=>$columnname)
    {
        if($columntype=='Products')
        {
           
            if($columnname=='productid')
                $columnname='productname';
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['Products'][1][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'14',$exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'15',$exportTemplateValue['Products'][2][$columnname]);
        }
        else if($columntype=='inventorydetail')
        {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['inventorydetail'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['inventorydetail'][0][$columnname]);
           $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['inventorydetail'][1][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'14',$exportTemplateValue['inventorydetail'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'15',$exportTemplateValue['inventorydetail'][2][$columnname]);
            
        }
        else
        {
          
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'3',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'9',$exportTemplateValue['main'][$columnname]);
           $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'10',$exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'14',$exportTemplateValue['main'][$columnname]);
             $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'15',$exportTemplateValue['main'][$columnname]);
        
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
$modulelabel=getFixedLabel('My').getTranstab($currentModule).getFixedLabel('exporttemplate');
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));

$objWriter->save('storage/'.$currentModule.'.xls');   
//下载文件
$file_name = $currentModule.".xls";
$file_dir = "storage/";
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

//$modulelabel=iconv('UTF-8','gb2312',$modulelabel);
Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);


?>
