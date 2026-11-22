<?php
//导出模块
ob_get_clean();
global $adb,$current_user,$currentModule;
$module=$currentModule;
require('user_privileges/user_language_'.$current_user->id.'.php');
$tabid=getTabid($module);
$modulelabel=getTranstab($module);

if(file_exists('storage/'.$module.'.xls'))
{
    @unlink('storage/'.$module.'.xls');
}
					

$exportTemplateValue=array('main'=>array('cashbill_no'=>'GR1','accountid'=>'上海信息科技有限公司','cashbilldate'=>'2017-04-06','paymentmethod'=>'现金',
    'checkoutstatus'=>'未审核','smownerid'=>'系统管理员','bankaccountsetid'=>'现金（财务部）','total'=>'10000','currency_id'=>'人民币',
    'cashtype'=>'收款'),'Products'=>array(array('entitytype'=>'合同订单','entitytypeid'=>'SO1','source_total'=>'26000','amount'=>'10000'),
        array('entitytype'=>'合同订单','entitytypeid'=>'SO2','source_total'=>'30000','amount'=>'15000'))
    );


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
 and presence in(0,2)  and ld_field.columnname not in("subtotal")  
 and ld_field.uitype not in(69,1109,222,301)
order by ld_blocks.sequence, ld_field.sequence asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));


$_sql1='select ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname ,input_type
    from ld_tabdetailfield tf
    inner join ld_tranlabel on ld_tranlabel.relateid=tf.tabdetailfieldid
    where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2) 
    and  ( columnname != "total" ) AND tf.savedatabase = "yes" and (sourcemodule !="" or sourcemodule is not null)
    and tf.tabid=?  ORDER BY sequence  asc';
$params1 = array($languageType,'ld_tabdetailfield',$tabid);
$_sql2 = "SELECT ld_tranlabel.fieldlabel,typeofdata,uitype,columnname,input_type FROM ld_producttoolfield
      LEFT JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_producttoolfield.producttoolfieldid
      WHERE
	  ld_producttoolfield.tabid = ? AND ld_tranlabel.trantable = ? AND columnname NOT in('adjustment','contractid','total','subtotal','product_no') and 
      ld_tranlabel.languagetype=? AND ld_producttoolfield.presence IN (0, 2) AND (ld_producttoolfield.savedatabase = 'yes' or  ld_producttoolfield.tablename='ld_products' or ld_producttoolfield.tablename='ld_productcf')
      and (sourcemodule !='' or sourcemodule is not null)
      GROUP BY ld_producttoolfield.producttoolfieldid
      ORDER BY ld_producttoolfield.sequence ASC";
$params2 = array($tabid,'ld_producttoolfield',$languageType);
//zkt 获取源单类型，用于收付款单判断源单类型。
$sourcemodule_arr = getSourceModule($module);
$productdetailcount = 0;
foreach($sourcemodule_arr as $sourcemoduleinfo)
{
    if($sourcemoduleinfo['withdetail'] == 'yes')
    {
        $productdetailcount++;
    }
}
if(empty($productdetailcount)){
    $_sql="select * from (".$_sql1.") as tmptab group by tmptab.columnname;";
    $params = $params1;
}
else if($productdetailcount>0 &&$productdetailcount == sizeof($sourcemodule_arr)){
    $_sql="select * from (".$_sql2.") as tmptab group by tmptab.columnname;";
    $params = $params2;
}
else{
    $_sql="select * from ((".$_sql1.") union all (".$_sql2.")) as tmptab group by tmptab.columnname;";
    $params = array($languageType,'ld_tabdetailfield',$tabid,$tabid,'ld_producttoolfield',$languageType);
}
$_result=$adb->pquery($_sql,$params);

//0027800 合同订单导处模板勾选“产品名称”（导出后产品名称也不是必录项）
for($i=0;$i<$adb->num_rows($_result);$i++)
{
    $typeofdata=$adb->query_result($_result,$i,'typeofdata');
    $columnname=$adb->query_result($_result,$i,'columnname');
	if('productname' == $columnname){
		$typedata=explode('~',$typeofdata);
		$productname_typeofdata = $typedata[1];
	}
}

$sql='select ld_tranlabel.fieldlabel from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid
where languagetype=? and trantable=? and ld_tranlabel.tabid=14 and ( columnname=?)';
$proresult=$adb->pquery($sql,array($languageType,'ld_field','product_no'));
//产品编号
$productcolumname=array('product_no-products','productid-products');
if($productname_typeofdata == 'M'){
	$productdetail=array($adb->query_result($proresult,0,0).'*'=>'M');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
}else{
	$productdetail=array($adb->query_result($proresult,0,0)=>'DEFAULT');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
}


$detailcolumname=array('entitytype-tabdetailfield');



$exportarr=array();

include('PHPExcel/PHPExcel.php');
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

        
        if($columnname=='source_list')
        {
            $columnindex=PHPExcel_Cell::stringFromColumnIndex($kk).'1';
            //收付款单源单导入
            $tmplabel=getFixedLabel('CHOOSEENTITYTYPE');//源单类型
            //新增的源单类型字段要增加进表头字段数组中
            $mainfield[]=$tmplabel;
            if($typedata[1]=='M')
            {
                $tmplabel.='*';
                  $objPHPExcel->getActiveSheet()->getStyle($columnindex)->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
                 $objPHPExcel->setActiveSheetIndex(1);
               
                  $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
                  $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
                  $exporttemplatecolumn['main'][]='entitytype';
                  $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$tmplabel);
                  $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$tmplabel);
                  $dupfield_count++;
                
            }
            
             $objPHPExcel->setActiveSheetIndex(0);
            $activesheet->setCellValue($columnindex,$tmplabel);
            $activesheet->getColumnDimension($columnindex)->setWidth(20); 
            $kk++;
        }
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
}

$j=0;
foreach($productdetail as $fieldLabel=>$typedata)
{
    $columnname_tablename=$productcolumname[$j];
//XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段，判断分录字段是否与表头重复，重复增加标识
    if(in_array($fieldLabel,$mainfield)){
        $fieldLabel = $modulelabel.getFixedLabel('DETAIL').'_'.$fieldLabel;
    }
    if($columnname_tablename=='productid-products'&&!in_array('productid-products',$text))
    {
        $j++;
        continue;
    }
    $export_product_columns=explode('-',$columnname_tablename);
   
        $columnname=$export_product_columns[0];
        if($typedata=='M')
        {
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk).'1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
             $objPHPExcel->setActiveSheetIndex(1);
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
            $exporttemplatecolumn['Products'][]=$columnname;
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
            $dupfield_count++;
        }
        $objPHPExcel->setActiveSheetIndex(0);
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk).'1',$fieldLabel);
        $kk++;
    $j++;
}

for($i=0;$i<$adb->num_rows($_result);$i++)
{
    $typeofdata=$adb->query_result($_result,$i,'typeofdata');
    $columnname=$adb->query_result($_result,$i,'columnname');
    $fieldLabel=$adb->query_result($_result,$i,'fieldlabel');
    $input_type=$adb->query_result($_result,$i,'input_type');
    $typedata=explode('~',$typeofdata);
    if(in_array($fieldLabel,$mainfield)){
        $fieldLabel = $modulelabel.getFixedLabel('DETAIL').'_'.$fieldLabel;
    }
    
    //if(in_array($columnname.'-tabdetailfield',$text))
   // {
        
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