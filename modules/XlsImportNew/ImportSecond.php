<?php
global $currentModule;
crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
global $adb;
set_time_limit(0);
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist']=array();
$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);
$arr['modulelabel']=gettranstab($frommodule);
$arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
$smarty=new lingdangCRM_Smarty();
$smarty->assign("ARRLABEL",$arr);

$_REQUEST['diony']='yes';
$tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
$tmp['canceltext']=getFixedLabel("NEXT");
$tmp['oktext']=getFixedLabel("ASTEP");
$filename=$_REQUEST['filename'];
$filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名
if($filetype=='xlsx'){$inputFileType = 'Excel2007';} else{$inputFileType = 'Excel5';}
$sessionMainfield=array();
include 'PHPExcel/PHPExcel/IOFactory.php';
$importcolumn=array();   
$importcolumn[]=array(0,'none-field','--无--');
$i=0;
$modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
                        ,'start_hour','title','reports_to_id','phone_other'
                        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
                        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
                        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
                        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
                        ,'imagename','viewothers','editothers'
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
 foreach($focus->fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
        $uitype=$fieldinfo->getUIType();
        if($uitype==69 || $uitype==1109)
        {
            continue;
        }
        if(in_array($fieldname,$modulenoshowfields['Users'])&&$currentModule=='Users')
         {
            continue;
         }
         $columnname=$fieldinfo->getColumnName();
         $fieldLabel=$fieldinfo->getFieldLabel();
         $typeofdata=$fieldinfo->getTypeOfData();
         $tablename=$fieldinfo->getTableName();
         $savedatabase=$fieldinfo->getSaveDataBase();
         if($savedatabase=='no')
            continue;
         $sessionMainfield[$i]['uitype']=$uitype;
         $sessionMainfield[$i]['columnname']=$columnname;
         $sessionMainfield[$i]['fieldlabel']=$fieldLabel;
         $sessionMainfield[$i]['typeofdata']=$typeofdata;
         $sessionMainfield[$i]['tablename']=$tablename;
         
         $typedata=explode('~',$typeofdata);
         if($typedata[1]=='M'||$uitype==4)
         {
            $fieldLabel.='*';
         }
         if($uitype==15 ||$uitype==33)
         {
            $profileid=$current_user->profileid;
          
	        $picklistdrop = getAssignedPicklistValues($fieldname, $profileid, $adb,array(),"");
            $drophtml[$columnname.'-field']=$picklistdrop;
         }
         $importcolumn[]=array($uitype,$columnname.'-field',trim($fieldLabel));
         if($columnname == 'taxclass')
		{
		   crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
			$tax_details = getAllTaxes('available');
            
			foreach($tax_details as $key => $val)
			{
			     $i++;
                $sessionMainfield[$i]['uitype']=83;
                $sessionMainfield[$i]['columnname']=$val['taxname'];
                $sessionMainfield[$i]['fieldlabel']=$val['taxlabel'];
                $sessionMainfield[$i]['typeofdata']='N~O';
                $sessionMainfield[$i]['tablename']='ld_producttaxrel';
			    $importcolumn[]=array(83,$val['taxname'].'-field',trim($val['taxlabel']));
			}
		
		}
         $i++;
 }
 
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');

 $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id.'_fields']=$sessionMainfield;
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objReader->setReadDataOnly(true);

$objPHPExcel = $objReader->load('storage/'.$filename);

$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();//
        
$highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
            
$_totalRows=count($highestRow)-1; //导入的数据总行数
    
$highestColumn = $objWorksheet->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
 //取第一行标题和第二行数据
 for ($col = 0;$col < $highestColumnIndex;$col++)
 {
        $uitype=0;
        $columnname='';
        $objvalue0= trim($objWorksheet->getCellByColumnAndRow($col, $highestRow[1])->getValue());  
        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][]=$objvalue0;
        if($objvalue0=="")
        {
            break;
        }

        $objvalue1= trim($objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue());  
        foreach($importcolumn as $index=> $cols)
        { 
            if($cols[2]==$objvalue0|| $objvalue0.'*'==$cols[2])
            {
                $uitype=$cols[0];
                $columnname=$cols[1];
                $selcolumnName[$columnname]='';
            
                $typeofdatas=explode("~",$sessionMainfield[$index-1]['typeofdata']);
               
               break;
               
            }
        }
        if($typeofdatas[0]=='D')
         {
          
            $objvalue1=NewImportCommon::operationDate($objvalue1);
           
         }
         else if($typeofdatas[0]=='DT')
         {
            $objvalue1=NewImportCommon::operationDateTime($objvalue1);
            
         }
  
        $objstr[$col]=array($objvalue0,$objvalue1,$uitype,$columnname);  
} 

$smarty->assign('IMPORTDATA',$objstr);//Excel标题数组
$smarty->assign('IMPORTCOLUMN',$importcolumn);//所有字段数组
$smarty->assign('DROPHTML',$drophtml);//下拉框数组
$smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
$tmp['excelcolumncount']=$highestColumnIndex;
$tmp['content']=$smarty->fetch("ImportXlsNew/secondImport.tpl");
ConvertTojsonString(1,$tmp,"success");
?>