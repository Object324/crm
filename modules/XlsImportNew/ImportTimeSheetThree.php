<?php

   global $currentModule;
global $adb;
global $current_user;
$filename=$_REQUEST['filename'];
$smarty=new lingdangCRM_Smarty();
if(empty($filename))
{
    $frommodule=$_REQUEST['frommodule'];
    $focus=CRMEntity::getInstance($frommodule);
    $arr['modulelabel']=gettranstab($frommodule);
    $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty=new lingdangCRM_Smarty();
     $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['content']=$smarty->fetch('ImportXlsNew/ThreeImport.tpl');
    $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
 //  $tmp['canceltext']=getFixedLabel("ASTEP");
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$tmp,'success');
    
}
$_REQUEST['diony']='yes';
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
    //导入数据
    $allFieldOnly=array();//所有唯一字段
    $error='';//错误信息
    //$mapfields=$_REQUEST['mapped_fields'];
    $mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
    
    $totalcolumns=sizeof($mapfields);
  	$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
    //主表字段

    $result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id];//数组
     
     
     //产品工具自定义字段
    $import_module = $_REQUEST['importmodel'];
    $smarty->assign("IMPORTMODULE",$import_module);
    $producttoolresult=$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id];//数组
    $module_NO='timesheet_no';
    
   $importcolumn=array();
   //$field_tables=array();//主表导入字段
   $field_tables[$module_tablename]=array();//主表导入字段
   $field_columns_only=array();//唯一字段
   $fieldonlyXlsIndex=0;//唯一字段在xls文件中列索引
   $codeIndex=0;//编号在xls文件中列索引

  
   $findcodenum=false;
  
  // $noeditField=array('smcreatorid'=>'-1','createdtime'=>'-1','modifiedtime'=>'-1','modifiedby'=>'-1','sostatus'=>'-1');
  // $smownerfield=array('smownerid'=>'-1');
   $importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1);//导入字段在excel中的列位置
   $inventory_tables['ld_timesheetdetail']=array();//产品明细表导入字段
   $producttoolfield_tables['ld_timesheetdetailscf']=array();//产品明细自定义表导入字段
   $nohaveerror=true;
   $fieldcolIndex=0;
   $moduleImport['choose'] = $_REQUEST['choose'];
   $moduleImport['select'] = $_REQUEST['select1'];
   $module_detail_Import['select2'] = $_REQUEST['select2'];
   $cachekey = 'importtabid_'.$moduleid;
   $cachekey_detail = 'importdetail_'.$moduleid;//用于明细
   unsetCache($moduleImport);//清除缓存
   CacheDirectory($cachekey,'Cache',$moduleImport);  
    $checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
  
    $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
    $importdupfields_condition=json_decode($_REQUEST['importdupfields_condition'],true);//查重字段条件
    
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
        
     }
     $main_fieldlabel_dup_tip=trim($main_fieldlabel_dup_tip,$conditionlabel);
     
    $code_num_columnname=$focus->fieldobj->getFieldInfoBykeyValue('uitype',4,'columnname');
    
     for($i=0;$i<sizeof($product_is_checkimportfield);$i++)
     {
         $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$product_is_checkimportfield[$i],'fieldlabel');
        if($product_importdupfields_condition[$i]=='or')
            $conditionlabel=$conditionorlabel;
        else
            $conditionlabel=$conditionandlabel;
        $product_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
     }
    // wym 240423 XUQIU20240402-03 检查下拉框字段
    $checkPicklist=getUsersettingByLabel($currentModule, $current_user->id,'ImportCheckPicklist');
    if(!empty($checkPicklist) && $checkPicklist!='no' && $checkPicklist!='yes'){//yes代表虽然开启了检查,但没有设置检查字段
        $checkPicklistColumn=explode('##',$checkPicklist);
    }
    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
    $trigger_workflow=getUsersettingByLabel($currentModule,$current_user->id,'ImportCheckWorkflow');
    if($trigger_workflow=='yes') {
        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($currentModule);
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
      
         if($typedata[1]=='M' || $uitype==4)
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
               if($columnname=='smownerid')
                $importcolumnname_index['smownerid']=array_search($columnname.'-field',$mapfields);
             else if($uitype==4)
             {
                $importcolumnname_index['code_num']=array_search($columnname.'-field',$mapfields);
             }
             else if($columnname==$focus->getCreateColumnName())
             {
                $importcolumnname_index['smcreatorid']=array_search($columnname.'-field',$mapfields);
             }
             if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
                 $selcol=$tablename.':'.$columnname;
                 if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                     if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                         $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $columnname);
                         if ($fieldinfo) {
                             $fieldname = $fieldinfo->getFieldName();
                             crm_load_class_file('cls_PickList', 'modules/PickList');
                             $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                             $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                             $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$columnname] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                         }
                     }
                 }
             }
         }
        
    }

   for($i=0;$i<sizeof($producttoolresult);$i++)
    {
        
        $uitype=$producttoolresult[$i]['uitype'];
        $fieldtype=$producttoolresult[$i]['fieldtype'];
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
             if(!empty($checkPicklistColumn) && ($fieldtype=='Select' || $fieldtype==60)){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
                 $selcol=$table_name.':'.$columnname;
                 if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                     if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                         if ($focus->detailfieldobj) {
                             $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $columnname);
                             if ($fieldinfo) {
                                 $fieldname = $fieldinfo->getFieldName();
                                 crm_load_class_file('cls_PickList', 'modules/PickList');
                                 $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                                 $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                                 $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$columnname] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                             }
                         }
                     }
                 }
             }
         }
        
    }

     $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
    
     $highestColumnIndex = $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestcolumnindex'];//总列数
    $Importoop = new NewImport_Xls($importcolumnname_index,$objWorksheet);
     $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
            
       $startrow=$_REQUEST['startrow'];
      
        $endrow=$_REQUEST['endrow'];
        $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
        $main_module_rows=0;//跨越的主表的行数
        $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
        $row=$startrow;
    if($error!='')
    {
        
            $false = true;
            $importdatainfo=$error;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
            $smarty->assign('TOTALROWS',(sizeof($highestRow)));
            $smarty->assign('SUCCESSROWS',0);
            $smarty->assign('ERRORROWS',sizeof($highestRow));
             $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
             fwrite($filehandler,str_replace('<br>',"\r\n",$error));
            fclose($filehandler);
             ConvertTojsonString("-1",array(),$error);
            exit();
    }
    else
    {
       
       
        if(sizeof($highestRow)<2){
            $error .='模板文件中没有数据，导入失败！'.'<br>'; 
            $successRows =0;
            $addimportrows=0;
            $updateRows=0;
            $importdatainfo=$error;
            $false=true;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
            ConvertTojsonString("-1",array(),$error);
        }
        $row=0;
        $xlsRowData=array();
       
        $nohaveerror=true;
        
        $hangshu=0;
        $shijidaoruRows=0; //实际导入的单据数量，按主表计算

         //拼接主表的导入sql脚本       
        $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
        $insert_columname = array();
        $insert_values = array();
        //将所有的字段拼接到一个数组里面
        $insertfield = array_merge($field_tables,$inventory_tables);
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
                 
             }
            if(strtolower($tablename)==$module_tablename){
                if(!in_array('smcreatorid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smcreatorid';
                }
                if(!in_array('createdtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'createdtime';
                }
                if(!in_array('modifiedtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'modifiedtime';
                }
                $insert_columname[$tablename][] = $focus->tab_name_index[$tablename];
             }
     
            if($tablename=='ld_timesheetdetail'){
               if(in_array('entitytypeid',$insert_columname[$tablename])){
                       $insert_columname[$tablename][]='entitytype';//关联源单类型 
                    }
                $insert_columname[$tablename][]='timesheet_id';
                $insert_columname[$tablename][]='timesheetdetail_id';
                
            }
            if($tablename==$module_tablename_scf){
                $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename];
            }
            if($tablename=='ld_timesheetdetailscf'){ $insert_columname[$tablename][]='timesheetdetail_id';}   
          
           
         }
       
           foreach($insert_columname as $tablename => $column_fields){
                     if($code_num_columnname!=''&&$importcolumnname_index['code_num']<0&&$tablename==$focus->table_name)
                      {
                        $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ','.$code_num_columnname.') values (' . generateQuestionMarks($column_fields).',?)' ;
                      }
                      else
                      $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;   
             }
        $product_detail_fields = array_merge($field_tables,$producttoolfield_tables);

        /*导入定义*/
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
        $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $createdtime=date("Y-m-d H:i:s");
        $modifiedtime=$createdtime;
        $sostatus='已创建';
        $successRows=0;//成功导入的合同订单数
        $updateRows=0;//成功覆盖单据数
        $sql_split=explode(',',$field_sql[$module_tablename]);
        //用于导入完成后，更新订单的合计等
        //$sqlupdate='update ld_servicecontracts set total=?,subtotal=?, discount_type=? where servicecontractsid=?';
        $sqlupdate='update '.$module_tablename.' set currency_symbol=?,total=?,subtotal=?,discount_type=? where '.$focus->tab_name_index[$module_tablename].'=?';
      
        $tmp_cur_row_end_line='no';
        $tmp_prouctDetail_row=0; 
        $product_same_salesorder='no';        
        $startimporttime=date("Y-m-d H:i:s");
       
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
      
        while(true){
           
            $hangshu++;
            $nohaveerror=true;
            $yijingtishi=true;
            //如果超过xls文件行数则退出循环
            if($row>=$maxrows){
                break;
            }
            if($main_module_rows>$between_rows)
            {
               
                $endrow=$row;//返回到前端，用于判断下次开始导入行数的标识
               
                break;
            }
            $excelrow=$row+2;
            $col=0;
            if($row+1>=$maxrows)
            {
                $tmp_cur_row_end_line='yes' ;
            }
            
            if($product_same_salesorder=='no')
            {
                $xlsRowData=array();
                $product_xlsRowData=array();
                $productid=array();
                $nohaveerror=true;
            }
            
            
           
            
            foreach($product_detail_fields as $tablename => $colinfo){
                foreach($colinfo as $ky=>$colnames){
                    $columnname=$colnames[0];

                    $typedata=explode('~',$colnames[2]);
                    $fieldcolIndex=$colnames[3];
                    $fieldLabel=$colnames[4];
                    $str=trim((string)$importdatas[$row][$fieldcolIndex]);
                    $next_row_str='';
                    
                    if(in_array($columnname,$is_checkimportfield)){
                          $_checkColumn[$columnname] = $columnname;
                          $_checkValues[$columnname] = $str;
                           if($tmp_cur_row_end_line=='no'){//如果不是最后一行则获取下一行数据，
                             $next_checkValues[$columnname]=trim((string)$importdatas[$row+1][$fieldcolIndex]);
                           }
                    }
  
                    //$str=addslashes($str);
                    //获取用户的lastname
                    $uname = getUserFullName($current_user->id);
                    //为空时获取默认值
                    if($str==''){
                        $str=trim($defaultvalue[$colnames[0].'-field-defaultvalue']);
                    }
                    //日期类型
                    if($typedata[0]=='D'){
                        
                        if($str ==''){
                            $str=NULL;
                        }else{
                             if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                                $str= date('Y-m-d',PHPExcel_Shared_Date::ExcelToPHP($str));  
                             }             
                        }  
                    }
                    if($typedata[0]=='T'){
                        if($str==''){
                            $str=NULL;
                        }else{
                            $str=date('H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));   
                        }  
                    }
                    //日期时间类型
                    if($typedata[0]=='DT'){
                        if($str ==''){
                            $str=NULL;
                        }else{
                            if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2 &&sizeof(explode(':',$str))<2){
                                $str= date('Y-m-d H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));  
                            }              
                        }    
                    }
                    if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)){
					//	$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
						if(!is_numeric($str)){
							$error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'].'"列内容为非法数字!<br>';
							$nohaveerror=false;
						}
                    }
                    if($typedata[0]=='N'&&$str==''){
                        $str=NULL;
                    }  
                    if($typedata[0]=='NN'&&$str==''){
                        $str=NULL;
                    }
                    if($typedata[1]=='M'&&$str==''&&$fieldcolIndex!=$importcolumnname_index['code_num']){
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'].'"列值为空或在数据库中不存在!<br>';
                       // $row++;
                        $nohaveerror=false;
                    }
                    
                    if(array_key_exists($tablename,$focus->tab_name_index)  && $str !=''){
                        if($colnames[1]==117 ){
                           
                                $checkvalue=array_keys($app_currency_strings,$str);
                                 
                            if($checkvalue[0]==''){
                                $checkvalue[0]=$str;
                            }
                                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';                                                  
                                $fieldResult=$adb->pquery($sqlfield,array());
                            if($adb->num_rows($fieldResult)>0){
                                $arraycurrency[0]['currency_id']=$adb->query_result($fieldResult,0,'id');   
                                $arraycurrency[0]['currency_symbol']=$adb->query_result($fieldResult,0,'currency_symbol');   
                                $arraycurrency[0]['conversion_rate']=$adb->query_result($fieldResult,0,'conversion_rate');                                   
                            }else{
                                $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'].'"列值为空或在数据库中不存在!<br>';
                                $str=''; 
                            }
                            
                        }
                        
                           $str = $Importoop->setImprtNameToId($colnames[1],$str,$HelpDeskstr);//获取相关信息id
                                if(empty($str) && $typedata[1]=='M'){
                                    if($Importoop->haveerrormsg()){
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                                    }
                                    else{
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'].'"列值为空或在数据库中不存在!<br>';
                                    }
                                     $nohaveerror=false;
                                }
                    }
                    if($colnames[1]==1600){ //通过用户字段值获取成员所属部门
                        $str = $Importoop->getvaluebyfields($colnames,$str,$product_detail_fields,$importdatas[$row]);
                    }
                    if(array_key_exists($colnames[0],$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                        if(!empty($str)  && !in_array($str,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$colnames[0]])){ //检查导入值是否是下拉框选项
                            $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                            $nohaveerror=false;
                        }
                    }
                    if($tablename==$focus->Detail_table || $tablename==$focus->Detail_table_scf){//判断是否是产品明细
                     
                        $product_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]]=vtlib_purify($str);            
                    }
                    elseif($product_same_salesorder=='no'){//&& strtolower($typedata[0]) !='i'
                         $xlsRowData[0][$tablename][$colnames[0]]=vtlib_purify($str);
                    }
                }
            }
            
                
            //模块若设置了没有工商信息不允许导入，则查询工商信息是否存在
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
            if($businessinformationobj->IsEnableBusiness()){
                if($businessinformationobj->IsNoBusinessnoimport()&&!empty($xlsRowData['maintable']))
                {
                    $requestvalues_arr = array();
                    foreach($xlsRowData as $reqtabtype=>$reqtabtypeinfo)
                    {
                        foreach($reqtabtypeinfo as $reqtabname=>$reqtabfields)
                        {
                            foreach($reqtabfields as $reqcolumnname=>$reqcolumnvalue)
                            {
                                $requestvalues_arr[$reqcolumnname]=$reqcolumnvalue;
                            }
                        }
                    }
                    crm_load_function_file('getSaveBusiness','modules/Users','GetTianYanSearchInfo');
                    $businesimport = getSaveBusiness($frommodule,$requestvalues_arr);
                    if($businesimport == 'no')
                    {
                        $company_name_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                        $company_name = $requestvalues_arr[$company_name_columnname];
                        $error .="第".$excelrow."行".$company_name."工商信息不存在！"."<br>";
                        $nohaveerror=false;
                    }
                }
            }
            
           
            $product_same_salesorder='yes';//判断明细是否为统一单据，yes:是,no:不是
            if((is_array($is_checkimportfield)&&empty($is_checkimportfield[0]))||empty($is_checkimportfield))
            {
                    $product_same_salesorder='no';
                    
            }
            foreach($_checkValues as $check_column =>$cur_value)
            {
                //比较当前行和下一行数据查重字段的值是否相同，或下一行主表查重字段是否为空
                if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!='')
                {
                    $product_same_salesorder='no';
                    break;
                }
            }           
           if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){
            $main_module_rows++;
                if($nohaveerror==false){
                   $row++;
                   $shijidaoruRows++;
                    $xlsRowData=array();
                   $nohaveerror=true;
                    continue;
                }
            }
            
            if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){//如果当前行数据和下一行数据不相同或当前行为excel最后一行
                 $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']+1;
                $main_module_rows++;
                $k=0;
                $flag = true; //主表重复，为false时，不插入明细表
                $service_base_contractstotal=0; //合同的合计(不包含调整金额、整单折扣金额)

                $sql='update ld_modentity_num set cur_id=cur_id+1 where semodule=?';
                $adb->pquery($sql,array($currentModule));

                $temp=array();
                $uniqueid=array();
                $invenValues=array();
                 $_checkCondition=array();
                $main_column_is_not_exit=array();
               $_checkdupValues=array();
                $_checkdupColumn=array();
                if($import_type!="Insert"){ //查重判断
                    foreach($xlsRowData[0] as $maintable=>$infos){
                            $temp[$maintable] =$infos;
                            foreach($is_checkimportfield as $index=>$checkField)
                            {
                                if(!empty($infos[$checkField]))
                                {
                                     $_checkdupColumn[]=$checkField;
                                     
                                     $_checkdupValues[$checkField] = $infos[$checkField];
                                      if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
                                      {
                                            $importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('columnname',$is_checkimportfield[$index+1]);
                                            $importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
                                            if($xlsRowData[$importcolumntablename][$is_checkimportfield[$index+1]]!='')
                                                $_checkCondition[$columnname]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                            else
                                                break;
                                      }
                                      else
                                      {
                                            $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                      }
                                     //$_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                }
                            }
                        }

                         if(sizeof($_checkdupColumn)>0)
                        {
                            //进行查重
                                $main_table_sql = 'SELECT ser.'.$focus->tab_name_index[$module_tablename].' as id from '.$module_tablename.' ser LEFT JOIN
                                '.$module_tablename_scf.' scf on ser.'.$focus->tab_name_index[$module_tablename] .' =scf.'.$focus->tab_name_index[$module_tablename].'';
                                $main_table_sql .=" where ("; 
                                $dupcheckfield_len=sizeof($_checkColumn);
                                 foreach($_checkdupColumn as $index=>$tmp_columnname)
                                {
                                    $main_table_sql.= "  $tmp_columnname= ?  ";
                                    if($_checkCondition[$tmp_columnname]!=""&&$tmp_dupcheckfield!=$dupcheckfield_len-1)
                                    {
                                        $main_table_sql.=$_checkCondition[$tmp_columnname];
                                    }
                                }
                                $main_table_sql.=" ) ";
                                $main_table_sql.=" and deleted=0";

                                $check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
                                $num_rows = $adb->num_rows($check_result);  
                        }
                        else
                        {
                            $num_rows=0;
                        }

                }

                    if($num_rows>0 && ($import_type=='Update' || $import_type=='UpdateAll')){ //获取重复的单据id
                      
                        
                        foreach($temp as $infoTablename =>$info_values){ //
                            foreach($info_values as $infoKey =>$new_info_values){
                                if (in_array($infoKey,array('approvestatus','createdtime'))) {
                                    continue;
                                }
                                if(!empty($new_info_values) && $infoKey !=$focus->tab_name_index[$module_tablename]){//排除导入文件中为空的数据
                                    $updateColumn[$infoTablename][$infoKey] = $infoKey;
                                    $updateValues[$infoTablename][$infoKey] = $new_info_values;
                                }
                            }

                        }
                        $focus->getModuleStatic('ModTracker');
                        for($i=0;$i<$num_rows;$i++){
                                $_uniqueid=$adb->query_result($check_result,$i,'id'); 
                                 $focus->id=$_uniqueid;
                                 $focus->modstatic->init($focus,$focus->module_name);//记录覆盖导入日志
                                 $uniqueid[]=$_uniqueid;//后面循环插入需要用到
                                foreach($updateColumn as $updateTablename => $new_pdateValues){
                                    if($updateValues[$updateTablename]!='')
                                    {
                                        $column = implode('=?,',$new_pdateValues) . '=?';
                                        $query = 'update ' . $updateTablename . ' set ' . $column . ' where ' . $focus->tab_name_index[$updateTablename] . ' ='.$_uniqueid;
                                        
                                        $adb->pquery($query,array($updateValues[$updateTablename]));
                                    }
                                    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                                    if($trigger_workflow=='yes'){
                                        $workflowreverseobj->setRecord($_uniqueid);
                                        $focus->retrieve_entity_info($focus->id,$currentModule);
                                        $beforefieldvalue_arr=$focus->column_fields;
                                        $afterfieldvalue_arr=$updateValues[$updateTablename];
                                        $pagemode='updated';
                                        if(!empty($afterfieldvalue_arr)){
                                            $workflowreverseobj->setPageMode($pagemode);
                                            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                        }
                                    }
                                    unset($updateColumn[$keyTablename]);
                                    unset($updateValues[$keyTablename]);                       
                                }
                            $focus->modstatic->saveOperationLog($focus->module_name,$focus->id,'IMPORT',$import_type);
                                 $focus->modstatic->triggerEvent($focus->module_name);        
                        }
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
                    }   
                    
                    if(empty($num_rows) || $import_type=='Insert'){
                        $_uniqueid = $adb->getUniqueID('ld_crmentity');
                        $uniqueid[] = $_uniqueid;
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
                        $adb->pquery($sqlcrmentity,array($_uniqueid,$currentModule));

                        foreach($xlsRowData[0] as $maintable=>$infos){
                            if($maintable==$module_tablename){
                                foreach($infos as $key =>$values){
                                    $main_column_is_not_exit[]=$key;
                                }
                                if(!in_array('smcreatorid',$main_column_is_not_exit) || $infos['smcreatorid']==''){
                                    $infos['smcreatorid']=$smcreatorid;
                                }
                                if(!in_array('createdtime',$main_column_is_not_exit) || $infos['createdtime']==''){
                                    $infos['createdtime']=date("Y-m-d H:i:s");
                                }
                                if(!in_array('modifiedtime',$main_column_is_not_exit) || $infos['modifiedtime']==''){
                                    $infos['modifiedtime']=date("Y-m-d H:i:s");
                                }
                                if(array_key_exists('approvestatus',$infos) && (!in_array('approvestatus',$main_column_is_not_exit) || $infos['approvestatus']=='')){
                                    $infos['approvestatus']='未提交';
                                }
                              
                            }
                            $infos[$currentModule.'id']=$_uniqueid;
                            if($maintable==$focus->table_name&&$code_num_columnname!=''&&$importcolumnname_index['code_num']<0)
                            {
                                //如果该模块有编号字段，但是导入的excel中没有编号，则编号应该取当前单据的ID
                                $adb->pquery($field_sql[$maintable],array($infos,$_uniqueid));
                            }
                            else if($importcolumnname_index['code_num']>=0&&$checkcodenum==''&&$maintable==$focus->table_name)
                            {
                               
                                $infos[$code_num_columnname]=$_uniqueid;
                                $adb->pquery($field_sql[$maintable],array($infos));
                            }
                            else
                                $adb->pquery($field_sql[$maintable],array($infos));
                            //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                            if($trigger_workflow=='yes'){
                                $workflowreverseobj->setRecord($_uniqueid);
                                $beforefieldvalue_arr=[];
                                $afterfieldvalue_arr=$infos;
                                $pagemode='creation';
                                if(!empty($afterfieldvalue_arr)){
                                    $workflowreverseobj->setPageMode($pagemode);
                                    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                }
                            }
                            $main_column_is_not_exit=array();
                            $xlsRowData=array();
                        }
                    }
                    if($num_rows>0 && $import_type=='Abort'){
                        $xlsRowData=array();
                        $product_xlsRowData=array();
                        $error .="第".$excelrow."行$main_fieldlabel_dup_tip 重复，已做跳过处理!"."<br />";
                        $flag = false;
                    }

                    if($flag==true){

                        //开始导入明细
                        $timesheetdetail_id=$adb->getLastInsertID();
                        
                        foreach($product_xlsRowData as $productData =>$productColumn){                            
                            foreach($productColumn as $productTablename =>$product_Values){
                                for($i=0;$i<sizeOf($uniqueid);$i++){
                                    if($productTablename=='ld_timesheetdetail'){
                                            $invenValues=$productColumn['ld_timesheetdetail'];
                                            $timesheetdetail_id++;
                                           if($invenValues['entitytypeid'])
                                           {

                                                //获取源单信息(源单id，源单name)

                                                $sourInformation=getProducts_entitytypeid($invenValues['entitytypeid'],getTransTab('Project'),$currentModule);
                                                if(empty($sourInformation['id'])&&empty($sourInformation['fieldname'])&&!empty($entitytype)){
                                                     //excel中源单类型不为空，但是匹配失败，这种情况不导入
                                                }else{
                                                    if(empty($sourInformation['fieldname']))$sourInformation['fieldname']=0;
                                                    $invenValues['entitytypeid']= $sourInformation['id'];
                                                    $invenValues['entitytype']=$sourInformation['fieldname'];
                                                    //$invenValues['parent_lineitem_id']=getProducts_lineitem_id($invenValues['entitytypeid'],$productid[$o]);
                                                    $invenValues['timesheet_id']=getProducts_lineitem_id($invenValues['entitytypeid'],$productid[$o]);
                                                }
                                           }
                                           else if(in_array('entitytypeid',$insert_columname['ld_timesheetdetail']))
                                           {

                                             $invenValues['entitytypeid']= 0;
                                             $invenValues['entitytype']='';
                                           }
                                   }
                                    $invenValues['timesheet_id']=$uniqueid[$i];
                                    $invenValues['timesheetdetail_id']=$timesheetdetail_id;

                                    $adb->pquery($field_sql['ld_timesheetdetail'],array($invenValues));
                                    $invenValuescf=$productColumn['ld_timesheetdetailscf'];

                                    if(is_array($invenValuescf)&&sizeof($invenValuescf)>0)
                                    {
                                         $adb->pquery($field_sql['ld_timesheetdetailscf'],array($invenValuescf,$invenValues['timesheetdetail_id']));
                                    }
                                    else
                                     $adb->pquery($field_sql['ld_timesheetdetailscf'],array($invenValues['timesheetdetail_id']));

                                   $invenValues=array();

                                }
                             
                        } 
                    }
                }
            }
            $tmp_prouctDetail_row++;
           
            $row++;
        }
        
           $endrow=$row;//明细的行数不是固定的。
           include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');
            $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
            $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
            if($endrow>=$maxrows&&($addimportrows>0||$updateRows>0))
            {
                
                $sql='update ld_modentity_num set cur_id=LPAD((cur_id+?),LENGTH(cur_id),"0") where semodule=? and active=1;';
                if(strtolower($import_type)=='insert'||strtolower($import_type)=='abort')
                    $adb->pquery($sql,array($addimportrows,$currentModule));
                else
                    $adb->pquery($sql,array($updateRows,$currentModule));
            }
       
            $_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"].$error;
            
           
            $tmp['timedescription']=$time_description;
            $tmp['cur_progress_step']=$cur_progress_step;
            $tmp['endimporttime']=$endimporttime;
            $tmp['endrow']=$endrow-1;
            ConvertTojsonString(1,$tmp,'success');
    }
?>