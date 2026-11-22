<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:59
if(isset($_REQUEST['second_file_index']) && $_REQUEST['second_file_index']=='documentEntry'){
    include(globalStatic::$root_directory."modules/XlsImportNew/documentEntryIndex.php");
    exit;
}
ob_get_clean();
global $adb,$current_user;
$module='Users';
require('user_privileges/user_language_'.$current_user->id.'.php');

$focus=CRMEntity::getInstance($module);

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
$modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
                        ,'start_hour','title','reports_to_id','phone_other'
                        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
                        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
                        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
                        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
                        ,'viewothers','editothers','imagename'
                        ,'delothers','viewselfbills','edit_other_mobile','edit_me_mobile','is_mobile_style'
                        ,'select_servicedetail','select_due_date','trackpostion','login_sms','telephone_view'
                        ,'push_work_reminds','push_news_reminds','push_wx_reminds','scopeauthority'
                        ,'accountallview','profileid','approvestatus','approveby');
if($currentModule=='Users')
{
    $deployarray=getSys_deploy(55);//呼叫中心类型
    $deploy_value=$deployarray['deploy_value']??'';
    if($deploy_value=='汉天EC2')
    {
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
        $modulenoshowfields['Users'][]='jw_user';
                    
    }
    else  if($deploy_value=='苏州思孚')
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='jw_user';
    }
    else if($deploy_value=='苏州九维')
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
    }
    else 
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
        $modulenoshowfields['Users'][]='jw_user';
    }
}
$sql='select fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,ld_field.fieldname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=29) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=29) 
  and presence in(0,2)  and ld_blocks.visible=0  and  ld_field.uitype <> 1109
  and savedatabase="yes"
order by ld_blocks.sequence, ld_field.sequence asc ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$languageType,'ld_blocks'));
   
$exportarr=array();
$exportTemplateValue=array('user_name'=>'ly','last_name'=>'留影','user_password'=>'123','confirm_password'=>'123'
        ,'status'=>'启用','phone_mobile'=>'15152563652','email1'=>'45621222@qq.com','level'=>'普通用户','hire_date'=>'2017-11-9');
include(globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
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
    $fieldname=$adb->query_result($result,$i,'fieldname');
    if(in_array($fieldname,$modulenoshowfields[$currentModule]))
    {
        continue;
    }
   // if(in_array($columnname.'-field',$text))
   // {
      
        if($typedata[1]=='M')
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
            $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk)); 
            $objStyle->getNumberFormat()   
             ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);   
        }
        $kk++;
    //}
   
    
}

$objPHPExcel->setActiveSheetIndex(1);
$activesheet=$objPHPExcel->getActiveSheet();
$dupfield_count=0;
foreach($exporttemplatecolumn as $index=>$columnname)
{
    $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$exportTemplateValue[$columnname]);
    $dupfield_count++;
}

$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'5')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'5','说明：多选框字段，录入格式为：张三 |##| 李四');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0).'6')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED); 
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'6','*注意：|##|两边都要有空格');

$objPHPExcel->getActiveSheet()->getTabColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$activesheet->SetTitle("导入示例");
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