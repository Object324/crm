<?php

set_time_limit(0);
global $currentModule;
global $current_user;
global $adb;
$detail_modules='Contacts';
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=array();
$isModuleActive=vtlib_isModuleActive($detail_modules);//判断联系人模块是否开启
if(empty($isModuleActive) || $deValue==1){
    $detail_Active = 1;//表示关闭
}
$_REQUEST['diony']='yes';
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_startdate']=date("Y-m-d H:i:s");
$_REQUEST['startrow']=0;
$mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
$totalcolumns=sizeof($mapfields);
if($totalcolumns<=0)
{
    ConvertTojsonStringIndex("-1",array(),'导入字段不能为空');

}
//导入数据
$focus=CRMEntity::getInstance($currentModule);
$detailfocus=CRMEntity::getInstance('Contacts');


$module_tablename=$focus->table_name;
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
if($filetype=='xlsx')
{$inputFileType = 'Excel2007';}
 else{$inputFileType = 'Excel5';}

    //主表
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
            ld_field.columnname,tablename ,fieldonly,ld_field.fieldname,ld_field.displaytype
            from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
            inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
            inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
            where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=? 
            AND ld_field.tablename not in(\'ld_contactdetails\',\'ld_contactscf\')) 
            and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
            and presence in(0,2)   and ld_blocks.visible=0
            and ld_field.uitype not in(69,1109) 
            order by ld_blocks.sequence, ld_field.sequence ';


$result=$adb->pquery($sql,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));

$sessionMainfield=array();
        //28625: 客户>列表：导入地址字段时，默认匹配的是联系人的“地址”，应该是默认匹配客户的“地址”

for($i=0;$i<$adb->num_rows($result);$i++)
    {
         $uitype=$adb->query_result($result,$i,'uitype');
         $columnname=$adb->query_result($result,$i,'columnname');
         $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
         $typeofdata=$adb->query_result($result,$i,'typeofdata');
         $fieldonly=$adb->query_result($result,$i,'fieldonly');
         $tablename=$adb->query_result($result,$i,'tablename');
         $fieldname=$adb->query_result($result,$i,'fieldname');
         $displaytype=$adb->query_result($result,$i,'displaytype');
         $sessionMainfield[$i]['uitype']=$uitype;
         $sessionMainfield[$i]['columnname']=$columnname;
         $sessionMainfield[$i]['fieldlabel']=$fieldLabel;
         $sessionMainfield[$i]['typeofdata']=$typeofdata;
         $sessionMainfield[$i]['fieldonly']=$fieldonly;
         $sessionMainfield[$i]['tablename']=$tablename;
        $sessionMainfield[$i]['displaytype']=$$displaytype;
         $typedata=explode('~',$typeofdata);
         if($typedata[1]=='M'||$uitype==4)
         {
            $fieldLabel.='*';
         }

         $importcolumn[]=array($uitype,$columnname.'-field',trim($fieldLabel),$displaytype);
    }




  //明细表
  $detail_sql ='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
                ld_field.columnname,tablename ,fieldonly,ld_field.fieldname,ld_field.displaytype
                from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
                inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
                inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
                where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=4
                AND ld_field.columnname NOT in(\'smownerid\',\'accountid\',\'smcreatorid\',\'modifiedtime\',\'modifiedby\',\'createdtime\',\'imagename\',\'mailingcountry\',\'mailingstate\',\'mailingcity\',\'mailingzip\')) 
                and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=4) 
                and presence in(0,2)   and ld_blocks.visible=0 and ld_field.uitype not in(69,1109) 
                order by ld_blocks.sequence, ld_field.sequence ';

    if($detail_Active != 1) $detail_result=$adb->pquery($detail_sql,array($languageType,'ld_field',$languageType,'ld_blocks'));
    $session_Detailfield=array();
    for($i=0;$i<$adb->num_rows($detail_result);$i++)
    {
        $uitype=$adb->query_result($detail_result,$i,'uitype');
        $columnname=$adb->query_result($detail_result,$i,'columnname');
        $fieldLabel=($adb->query_result($detail_result,$i,'fieldlabel'));
        $typeofdata=$adb->query_result($detail_result,$i,'typeofdata');
        $fieldonly=$adb->query_result($detail_result,$i,'fieldonly');
        $tablename=$adb->query_result($detail_result,$i,'tablename');
        $fieldname=$adb->query_result($detail_result,$i,'fieldname');
        $displaytype=$adb->query_result($result,$i,'displaytype');
        $session_Detailfield[$i]['uitype']=$uitype;
        $session_Detailfield[$i]['columnname']=$columnname;
        $session_Detailfield[$i]['fieldlabel']=$fieldLabel;
        $session_Detailfield[$i]['typeofdata']=$typeofdata;
        $session_Detailfield[$i]['fieldonly']=$fieldonly;
        $session_Detailfield[$i]['tablename']=$tablename;
        $typedata=explode('~',$typeofdata);
        if($typedata[1]=='M')
        {
            $fieldLabel.='*';
        }


        if($detail_Active !=1) $importcolumn[]=array($uitype,$columnname.'-detailfield',trim($fieldLabel),$displaytype);
    }


    $checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
    $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
    $importdupfields_condition=json_decode($_REQUEST['importdupfields_condition'],true);//查重字段条

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
        if($i==sizeof($is_checkimportfield)-1)
        {
                $conditionlabel='';
        }

        $adb->pquery($sql,array($is_checkimportfield[$i],$currentModule,$i,$importdupfields_condition[$i]));
     }


     $product_checkimportfield=implode(',',json_decode($_REQUEST['product_importdupcheckfields'],true));//查重字段
    $product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
    $product_importdupfields_condition=json_decode($_REQUEST['product_importdupfields_condition'],true);//查重字段条件
     for($i=0;$i<sizeof($product_is_checkimportfield);$i++)
     {
         $fieldlabel=$detailfocus->fieldobj->getFieldInfoBykeyValue("columnname",$product_is_checkimportfield[$i],'fieldlabel');
        if($product_importdupfields_condition[$i]=='or')
            $conditionlabel=$conditionorlabel;
        else
            $conditionlabel=$conditionandlabel;
        $product_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
        $adb->pquery($sql,array('ld_contactdetails:'.$product_is_checkimportfield[$i],$currentModule,$i,$product_importdupfields_condition[$i]));
     }

    $selcolumnName=array();
   include 'PHPExcel/PHPExcel/IOFactory.php';
    $objReader = PHPExcel_IOFactory::createReader($inputFileType);

    $objPHPExcel = $objReader->load($inputFileName);
    $objPHPExcel->setActiveSheetIndex(0);
    $objWorksheet = $objPHPExcel->getActiveSheet();//

    $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
    if(sizeof($highestRow)<2){
         $error .=getFixedLabel('IMPORTNODATAERROR').'<br>';

         ConvertTojsonString("-1",array(),$error);

 }
    $highestColumn = $objWorksheet->getHighestColumn();
    $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
    $objvalue_name = array();



if(!empty($error)){

    ConvertTojsonString("-1",array(),$error);

}
 $highestColumn = $objWorksheet->getHighestColumn();

$maxrows=$objWorksheet->getHighestRow();
 $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数

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

$_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=$xlsRowData;

$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex']=$highestColumnIndex;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows']=sizeof($xlsRowData);
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow']=$highestRow;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=0;//实际导入的单据数量，按主表计算
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=0;//导入成功的明细条数
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=0;//失败导入的明细条数
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]='';


include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');//进度条

$tmp['maxrows']=$maxrows;
$tmp['timedescription']=$time_description;
$tmp['cur_progress_step']=$cur_progress_step;
ConvertTojsonString(1,$tmp,'success');

?>