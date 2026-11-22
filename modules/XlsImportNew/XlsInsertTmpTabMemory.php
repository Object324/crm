<?php

global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony']='yes';
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_startdate']=date("Y-m-d H:i:s");
$_REQUEST['startrow']=0;
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
$focus=CRMEntity::getInstance($currentModule);
$error='';//错误信息
   

$mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
    
$totalcolumns=sizeof($mapfields);
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
$result=  $_SESSION['mainfieldServiceContracts'];//数组
     
//产品工具自定义字段
$import_module = $_REQUEST['importmodel'];

$producttoolresult=$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id];//数组
$code_num_columnname='';//编号字段名称
$code_num_columnname=$focus->fieldobj->getFieldInfoBykeyValue("uitype",4,'columnname');
$importcolumn=array();
   //$field_tables=array();//主表导入字段
$field_tables[$module_tablename]=array();//主表导入字段
$field_columns_only=array();//唯一字段
   
   $codeIndex=0;//编号在xls文件中列索引
    crm_load_class_file('TabDetailFields','include/TabDetailFields');
    $detailfieldobj=TabDetailFields::getInstance($currentModule);
    //由于判断该模块是否有源单字段
    $entitytypefieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname','entitytypeid');
    
    $subtotalfieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','subtotal');
  
    $totalfieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname','total');
    $total_detail_columnname='amount';//合计需要用到明细表字段
    if($totalfieldinfo)
    {
        $columnstring=$totalfieldinfo->getColumnString();
        $columnstring=str_replace('&#039;','"',$columnstring);
        $columnstring=str_replace('formulavar','"formulavar"',$columnstring);
        
        $total_arr=json_decode($columnstring,true);//获取合计的字段公式
        if(sizeof($total_arr)>0)
            $total_detail_columnname=$total_arr['formulavar'][0]['column'];
    }
  
   $findcodenum=false;

   $importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1);//导入字段在excel中的列位置
   $inventory_tables[$focus->Detail_table]=array();//明细表导入字段
  
   $nohaveerror=true;
   $fieldcolIndex=0;
   $moduleImport['choose'] = $_REQUEST['choose'];
  
    $checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
  
    $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
    $importdupfields_condition=json_decode($_REQUEST['importdupfields_condition'],true);//查重字段条件
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
        $main_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
        $adb->pquery($sql,array($is_checkimportfield[$i],$currentModule,$i,$importdupfields_condition[$i]));
     }
     $main_fieldlabel_dup_tip=trim($main_fieldlabel_dup_tip,$conditionlabel);
     
     
     if($frommodule == 'CashBill' || $frommodule == 'SendCashBill'){
        //zkt 获取源单类型，用于收付款单判断源单类型，若含有源单类型使用产品分录即withdetail=yes，则显示设置产品管理不存在时导入方式
        $sourcemodule_arr = getSourceModule($frommodule);
        $billhave_productdetail = 'no';
        foreach($sourcemodule_arr as $sourcemoduleinfo)
        {
            if($sourcemoduleinfo['withdetail'] == 'yes'){
                $billhave_productdetail = 'yes';
            }
        }
        if($billhave_productdetail == 'yes'){
            $product_checkimportfield=implode(',',json_decode($_REQUEST['product_importdupcheckfields'],true));//查重字段
            $product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
            $product_importdupfields_condition=json_decode($_REQUEST['product_importdupfields_condition'],true);//查重字段条件
            $profocus=CRMEntity::getInstance('Products');
             for($i=0;$i<sizeof($product_is_checkimportfield);$i++)
             {
                $tmpcolumnname=$product_is_checkimportfield[$i];
                
                 $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,'fieldlabel');
                 
                 if(!in_array($tmpcolumnname.'-products',$mapfields))
                {
                    //$error.='导入文件中缺少查重\''.$fieldlabel.'\'列<br>';
                }
                if($product_importdupfields_condition[$i]=='or')
                    $conditionlabel=$conditionorlabel;
                else
                    $conditionlabel=$conditionandlabel;
                $product_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
                $adb->pquery($sql,array('ld_products:'.$product_is_checkimportfield[$i],$currentModule,$i,$product_importdupfields_condition[$i]));
             }
         }
     }

    for($i=0;$i<sizeof($result);$i++)
    {
          
         $uitype=$result[$i]['uitype'];
         $columnname=$result[$i]['columnname'];
        
         $tablename=$result[$i]['tablename'];
         $typeofdata=$result[$i]['typeofdata'];
         $fieldonly=$result[$i]['fieldonly'];//字段值是否唯一，1：唯一
         $fieldLabel=$result[$i]['fieldlabel'];
         $typedata=explode('~',$typeofdata);
    
      
         if($typedata[1]=='M' && $uitype!=4&&$columnname!='currency_id')
         {
             
            if(!in_array($columnname.'-field',$mapfields))
            {
               
                 $error.='导入文件中缺少\''.$fieldLabel.'\'列<br>';
                 //break;
            }
         }
         
         if(in_array($columnname.'-field',$mapfields))
         {
        
             $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
             
             
         }
        
    }

 
   for($i=0;$i<sizeof($producttoolresult);$i++)
    {
        
        $uitype=$producttoolresult[$i]['uitype'];
        $columnname=$producttoolresult[$i]['columnname'];
        $fieldlabel=$producttoolresult[$i]['fieldlabel'];
        $typeofdata=$producttoolresult[$i]['typeofdata'];
        $input_type=$producttoolresult[$i]['input_type'];
        $table_name=$producttoolresult[$i]['tablename'];
       
        $typedata=explode('~',$typeofdata);
         
         if($typedata[1]=='M')
         {
          
            if(!in_array($columnname.'-producttoolfield',$mapfields))
            {
                 $error.='导入文件中缺少详细信息\''.$fieldlabel.'\'列<br>';
                // break;
            }
            
            $fieldlabel.='*';
         }
         if(in_array($columnname.'-producttoolfield',$mapfields))
         {
              
                $producttoolfield_tables[$table_name][]=array($columnname,$uitype,$typeofdata, array_search($columnname.'-producttoolfield',$mapfields));
          
         }
        
    }
    $filename=$_REQUEST['filename'];
    $filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名

  
    if($filetype=='xlsx'){$inputFileType = 'Excel2007';} else{$inputFileType = 'Excel5';}           
    $inputFileName = "storage/".$filename;
    require_once('PHPExcel/PHPExcel/IOFactory.php') ;

    $objReader = PHPExcel_IOFactory::createReader($inputFileType);
    $objPHPExcel = $objReader->load($inputFileName);
    $objPHPExcel->setActiveSheetIndex(0);
    $objWorksheet = $objPHPExcel->getActiveSheet();//
  
    $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
    $highestColumn = $objWorksheet->getHighestColumn();
    $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
    
    if($error!='')
    {
        $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组;
      
            $false = true;
            $importdatainfo=$error;
            
             $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
             fwrite($filehandler,str_replace('<br>',"\r\n",$error));
            fclose($filehandler);
            ConvertTojsonString('-1',array(),$error);
    }
    else
    {
       

        if(sizeof($highestRow)<2){
            $error .=getFixedLabel('IMPORTNODATAERROR').'<br>';
            $successRows =0;
            $addimportrows=0;
            $updateRows=0;
            $importdatainfo=$error;
            $false=true;
            $smarty = new lingdangCRM_Smarty;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
            ConvertTojsonString('-1',array(),$error);
        }
        $row=2;
        $xlsRowData=array();
        $nohaveerror=true;
        
        $hangshu=0;
        $shijidaoruRows=0; //实际导入的单据数量，按主表计算

        
        $insert_columname = array();
        $insert_values = array();

         //将所有的字段拼接到一个数组里面
         $insertfield=$field_tables;
         if(is_array($inventory_tables)&&$inventory_tables[0]!='')
            $insertfield = array_merge($field_tables,$inventory_tables);
         $allinsertfield =$insertfield;
         $tmpkeys=array_keys($producttoolfield_tables);
         if(is_array($producttoolfield_tables)&&$producttoolfield_tables[$tmpkeys[0]]!='')
              $allinsertfield  = array_merge($insertfield,$producttoolfield_tables);
              
   
        //拼接sql插入语句      
        foreach($allinsertfield as $tablename=>$colinfo)
        {
             if($tablename=='ld_crmentity'){
                continue;
             }
             foreach($colinfo as $ky=>$colnames)
             {
                $insert_columname[$tablename][] = $colnames[0];
                $import_columname[$tablename][] = $colnames[0];//这个是为了后面判断是否存在币种、币种账户字段
             }
            if(strtolower($tablename)==$module_tablename){
                if(!in_array('smcreatorid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smcreatorid';
                }
                 if(!in_array('smownerid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smownerid';
                }
                if(!in_array('createdtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'createdtime';
                }
                if(!in_array('modifiedtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'modifiedtime';
                }
                if(!in_array('checkoutstatus',$insert_columname[$tablename])&&array_key_exists('checkoutstatus',$focus->column_fields)){
                    $insert_columname[$tablename][] = 'checkoutstatus';
                }
                if($focus->fieldobj->getFieldInfoBykeyValue('columnname','currency_id','uitype')!='')
                {
                     if(!in_array('currency_symbol',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'currency_symbol';
                    }
                    if(!in_array('conversion_rate',$insert_columname[$tablename])){
                        $insert_columname[$tablename][] = 'conversion_rate';
                    }
                }
               
                            
                $insert_columname[$tablename][] = $focus->tab_name_index[$tablename];
             }
            if($tablename==$module_tablename_scf){
                $insert_columname[$tablename][] =  $focus->tab_name_index[$module_tablename];
            }
            if($tablename==$focus->Detail_table_scf){
                $insert_columname[$tablename][] = $focus->Detail_table_id;
            }
            if($tablename==$focus->Detail_table){
                $insert_columname[$tablename][] = $focus->Detail_table_index;
            }
            if($tablename==$focus->Detail_table&&in_array('entitytypeid',$insert_columname[$tablename])&&!in_array('entitytype',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'entitytype';
            }
            if($tablename==$focus->Detail_table&&in_array('entitytype',$insert_columname[$tablename])&&!in_array('entitytypeid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'entitytypeid';
            }      
          
             foreach($insert_columname as $tablename => $column_fields){
                     if($code_num_columnname!=''&&$importcolumnname_index['code_num']<0&&$tablename==$focus->table_name)
                      {
                        $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ','.$code_num_columnname.') values (' . generateQuestionMarks($column_fields).',?)' ;
                      }
                      else
                      $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;   
             }
         }
        
         $product_detail_fields=$field_tables;
       $tmpkeys=array_keys($producttoolfield_tables);
     
        if(is_array($producttoolfield_tables)&&$producttoolfield_tables[$tmpkeys[0]]!='')     
            $product_detail_fields = array_merge($field_tables,$producttoolfield_tables);
        
  

        /*导入定义*/
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
        $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $createdtime=date("Y-m-d H:i:s");
        $modifiedtime=$createdtime;
        $sostatus='已创建';
        
        $sql_split=explode(',',$field_sql[$module_tablename]);
        $detailtemp=0;
        
      

        $_checkproductsfield = explode(',',$_checkproducts);//将明细查重字段转换为数组
        
        $tmp_cur_row_end_line='no';
        $tmp_prouctDetail_row=0; 
        $product_same_salesorder='no';        
        $startimporttime=date("Y-m-d H:i:s");
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
}
?>