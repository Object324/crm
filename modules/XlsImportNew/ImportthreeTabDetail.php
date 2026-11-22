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
   //$tmp['canceltext']=getFixedLabel("ASTEP");
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$tmp,'success');
    
}
$_REQUEST['diony']='yes';
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
  require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
$focus=CRMEntity::getInstance($currentModule);
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$module_tablename=$focus->table_name;//单据主表
$module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
import('data.Logic','class');
import('data.BaseLogic','class');
BaseLogic::$module=$currentModule;
 if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php'))
 {
    $btnlogic=new BaseLogic();
 }
 else
 {
    require_once(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php');
    $cls=$currentModule.'Logic';
   	$btnlogic=new $cls();
 }
//导入数据
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
     $code_num_columnname='';//编号字段名称
     $code_num_columnname=$focus->fieldobj->getFieldInfoBykeyValue("uitype",4,'columnname');
   $importcolumn=array();
   //$field_tables=array();//主表导入字段
   $field_tables[$module_tablename]=array();//主表导入字段
   $field_columns_only=array();//唯一字段
   $fieldonlyXlsIndex=0;//唯一字段在xls文件中列索引
   $codeIndex=0;//编号在xls文件中列索引
    crm_load_class_file('TabDetailFields','include/TabDetailFields');
    $detailfieldobj=TabDetailFields::getInstance($currentModule);
    //由于判断该模块是否有源单字段
    $entitytypefieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname','entitytypeid');
    if(!empty($entitytypefieldinfo) && $entitytypefieldinfo->getPresence()==1){
        $entitytypefieldinfo = '';
    }

    $subtotalfieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','subtotal');
  
    $totalfieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname','total');
    $total_detail_columnname='amount';//合计需要用到明细表字段
    if($totalfieldinfo)
    {
        $columnstring=$totalfieldinfo->getColumnString();
        //zkt 20240726 BUG20240725-12 费用报销单导入成功后没有合计显示（lkfbcrm也有这个问题，合计没有录入时，应该自动计算）
        $columnstring=str_replace('\'','"',$columnstring);
        $columnstring=str_replace('&#039;','"',$columnstring);
        $columnstring=str_replace('formulavar','"formulavar"',$columnstring);
        
        $total_arr=json_decode($columnstring,true);//获取合计的字段公式
        if(sizeof($total_arr)>0)
            $total_detail_columnname=$total_arr['formulavar'][0]['column'];
    }
  
   $findcodenum=false;
    //38128: 收款单和付款单，如果导入的时候审批状态为“已批准”，则导入的时候 checkoutstatus 赋值应该为“已审核”
   $importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1,'approvestatus'=>'-1');//导入字段在excel中的列位置
   $inventory_tables[$focus->Detail_table]=array();//明细表导入字段
  
   $nohaveerror=true;
   $fieldcolIndex=0;
   $moduleImport['choose'] = $_REQUEST['choose'];
   $moduleImport['select'] = $_REQUEST['select1'];
   $module_detail_Import['select2'] = $_REQUEST['select2'];
   
    $checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
    
    $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
   
    $tmps=array();
    foreach($is_checkimportfield as $tmpindex=>$checkimportfieldname)
    {
       $tmps[]= $focus->fieldobj->getFieldInfoBykeyValue("fieldname",$checkimportfieldname,'columnname');
    }
    $is_checkimportfield=$tmps;
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
    
      
         
         if(in_array($columnname.'-field',$mapfields))
         {
        
             $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
               if($columnname=='smownerid')
                $importcolumnname_index['smownerid']=array_search($columnname.'-field',$mapfields);
             else if($uitype==4)
             {
                $importcolumnname_index['code_num']=array_search($columnname.'-field',$mapfields);
             }
             else if($uitype==73)
             {
                 $importcolumnname_index['accountid']=array_search($columnname.'-field',$mapfields);
             }
             else if($columnname==$focus->getCreateColumnName())
             {
                $importcolumnname_index['smcreatorid']=array_search($columnname.'-field',$mapfields);
             }
             else if($columnname=='approvestatus')
             {
                 $importcolumnname_index['approvestatus']=array_search($columnname.'-field',$mapfields);
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
        $columnname=$producttoolresult[$i]['columnname'];
        $fieldlabel=$producttoolresult[$i]['fieldlabel'];
        $typeofdata=$producttoolresult[$i]['typeofdata'];
        $input_type=$producttoolresult[$i]['input_type'];
        $table_name=$producttoolresult[$i]['tablename'];
       $fieldtype=$producttoolresult[$i]['fieldtype'];

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
                     if($focus->detailfieldobj){
                         if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
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

  
    require_once('PHPExcel/PHPExcel/IOFactory.php') ;

    
    $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
    
    $highestColumnIndex = $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestcolumnindex'];//总列数
    
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
       
        $xlsRowData=array();
       
        $nohaveerror=true;
        
        $hangshu=0;
        $shijidaoruRows=0; //实际导入的单据数量，按主表计算

         //拼接主表的导入sql脚本       
        $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
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
                if(!in_array('checkoutstatus',$insert_columname[$tablename])&&($currentModule=='CashBill'||$currentModule=='SendCashBill')){
                    $insert_columname[$tablename][] = 'checkoutstatus';
                }
                if($focus->fieldobj->getFieldInfoBykeyValue('columnname','currency_id','uitype')!='')
                {
                     if(!in_array('currency_id',$insert_columname[$tablename])){
                        $insert_columname[$tablename][] = 'currency_id';
                    }
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
            $insert_columname[$tablename]=array_unique($insert_columname[$tablename]);
            
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
      
        $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $createdtime=date("Y-m-d H:i:s");
        $modifiedtime=$createdtime;
        
        $successRows=0;//成功导入的合同订单数
        $updateRows=0;//成功覆盖单据数
        $detail_error=0;//明细导入失败数
        $sql_split=explode(',',$field_sql[$module_tablename]);
        $detailtemp=0;
        

      
        $tmp_cur_row_end_line='no';
        $tmp_prouctDetail_row=0; 
        $product_same_salesorder='no';    
        $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
            
        $startrow=$_REQUEST['startrow'];
      
        $endrow=$_REQUEST['endrow'];
        $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
        $main_module_rows=0;//跨越的主表的行数
        $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
        $row=$startrow;
        $Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
        while(true){
           
            
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
            $col=0;
            if($row+1>=$maxrows)
            {
             
                $tmp_cur_row_end_line='yes' ;
            }
            $excelrow=$row+2;
            
            if($product_same_salesorder=='no')
            {
                $xlsRowData=array();
                $product_xlsRowData=array();
                $productid=array();
                $nohaveerror=true;
            }
            
           $approvestatus='';
            foreach($product_detail_fields as $tablename => $colinfo){
                foreach($colinfo as $ky=>$colnames){
                    $columnname=$colnames[0];

                    $typedata=explode('~',$colnames[2]);
                    $fieldcolIndex=$colnames[3];
                   
                  
               
                    $fieldLabel=$colnames[4];
                    $str=trim((string)$importdatas[$row][$fieldcolIndex]);
                 
                    if($fieldcolIndex==$importcolumnname_index['approvestatus'])
                    {
                        //edit:can 20210520 45983: （61mis.com/kfbcrm）OA表单-费用报销单-导入；导入单据后，银行账户有余额扣款变动，现金流水账没有数据
                        $approvestatus=$str;
                      
                    }
                    $next_row_str='';
                    if($fieldcolIndex==$importcolumnname_index['code_num'])
                    {
                        $checkcodenum=$str;
                    }
                    if(in_array($columnname,$is_checkimportfield)){
                          $_checkColumn[$columnname] = $columnname;
                          $_checkValues[$columnname] = $str;
                           if($tmp_cur_row_end_line=='no'){//如果不是最后一行则获取下一行数据，
                                $addrow=1;
                                while(true)
                                {
                                       if(!array_key_exists($row+$addrow,$highestRow)){
                                        //28106: 创彩账套（192.168.3.5:85/crm,6.6.5SP3）客户>导入：当导入文件中第一行有数据，第二行没有数据，第三行有数据时，导入后变成了一对多的数据了
                                        $addrow++;
                                     }
                                     else
                                     {
                                        break;
                                     }
                                }
                             $next_checkValues[$columnname]=trim((string)$importdatas[$row+$addrow][$fieldcolIndex]);
                           }
                    }
  
                    //$str=addslashes($str);
                    //获取用户的lastname
                    $uname = getUserFullName($current_user->id);
                    //为空时获取默认值
                    if($str==''){
                        if(in_array($colnames[0].'-field',$mapfields)&&in_array($tablename,$focus->tab_name)){
                            $tmpcolumnindex = array_search($colnames[0].'-field',$mapfields);
                            $str=trim($defaultvalue[$tmpcolumnindex]);
                        }
                    }
                    //日期类型
                    if($typedata[0]=='D'){
                        
                        if($str ==''){
                            $str=NULL;
                        }else{
                             if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2)
                             {
                                            if(sizeof(explode('.',$str))==3)
                                            {
                                                $datastrs=explode('.',$str);
                                                if(strlen($datastrs[0])<4)
                                                {
                                                    $datastrs[0]="20".$datastrs[0];
                                                }
                                                $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                
                                            }
                                            else
                                            $str= date('Y-m-d',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
                             }
                             else if(sizeof(explode('/',$str))==3)
                             {
                                    $datastrs=explode('/',$str);
                                    if(strlen($datastrs[2])==4)
                                    {
                                    $str=$datastrs[2].'-'.$datastrs[1].'-'.$datastrs[0];
                                                    
                                    }
                             }
                        }             
                    
                    }  
                    
                    if($typedata[0]=='T'){
                      $tmpstrs= explode(":",$str);
						if(sizeof($tmpstrs)<2)
                        {
							if($str==''){
                            $str=NULL;
								}else{
									$str=date('H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));   
								}  
						}
                    }
                    //日期时间类型
                    if($typedata[0]=='DT'){
                        if($str ==''){
                            $str=NULL;
                        }else{
                            if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2 &&sizeof(explode(':',$str))<2){
                                if(sizeof(explode('.',$str))==3)
                                   {
                                        $datastrs=explode('.',$str);
                                        $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                   
                                   }
                                   else
                                    $str= date('Y-m-d H:i:s',(PHPExcel_Shared_Date::ExcelToPHP($str))); 
                            }              
                        }    
                    }
                    if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)){
						//$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
						if(!is_numeric($str)){
						      //zkt 20220613 Bug0052653导入付款单报错，
							$error.='第'.$excelrow.'行“'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'”列内容为非法数字!<br>';
							$nohaveerror=false;
						}
                    }
                    if($typedata[0]=='N'&&$str==''){
                        $str=NULL;
                    }  
                    if($typedata[0]=='NN'&&$str==''){
                        $str=NULL;
                    }
                    $uitype=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'uitype');
                    $bigtype=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
                    
                    if($typedata[1]=='M'&&$str==''&&$uitype!=4&&$columnname!='currency_id'){
                      
                        $error.='第'.$excelrow.'行“'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'”列值为空或在数据库中不存在!<br>';
                       
                        $nohaveerror=false;
                    }
               
                   if($colnames[1]==117){
                           
                                $checkvalue=array_keys($app_currency_strings,$str);
                              
                            if($checkvalue[0]==''){
                                $checkvalue[0]=$str;
                            }
                           
                           
                            if($checkvalue[0]!='')
                            {
                               $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';                                                  
                                $fieldResult=$adb->pquery($sqlfield,array());
                            }
                            else
                            {
                                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where id=? order by id desc limit 0,1';                                                  
                                $fieldResult=$adb->pquery($sqlfield,array(1));
                            }
                               
                             
                            if($adb->num_rows($fieldResult)>0){
                                $arraycurrency[0]['currency_id']=$adb->query_result($fieldResult,0,'id'); 
								$str = $adb->query_result($fieldResult,0,'id');
                                $arraycurrency[0]['currency_symbol']=$adb->query_result($fieldResult,0,'currency_symbol');   
                                $arraycurrency[0]['conversion_rate']=$adb->query_result($fieldResult,0,'conversion_rate');                                   
                            }else{
                                $error.='第'.$excelrow.'行'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'”列值为空或在数据库中不存在!<br>';
                                $str=''; 
                            }
                           
                           
                        }
                      
                    if(array_key_exists($tablename,$focus->tab_name_index)  && $str !=''&&$colnames[1]!=117){
                        
                        
                       $tmpcolumnname=$colnames[0];
						$bigtype=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,'bigtype');
						
                        if($bigtype=='translatefield')
                        {
                           
                          $translatedbvalue_arr=  getTranslateDbValueNew($currentModule,$tmpcolumnname);
                          foreach($translatedbvalue_arr as $column_dbvalue=>$tmp_arr)
                          {
                              $db_label = $tmp_arr['labelbol'];
                             if(getFixedLabel($db_label)==($str))
                             {
                                $str=$column_dbvalue;
                                break;
                             }
                          }
                          if($str=='')
                          {
                            $str='cashbill';
                            
                          }
                         
                        }
                        
                        
                        
                        //获取相关信息
                           $str = $Importoop->setImprtNameToId($colnames[1],$str,$row);//获取相关信息id
						   if($bigtype=='reference'||$uitype==52||$uitype==53||$uitype==251)
                               if(empty($str) && $typedata[1]=='M'){
                                   if($Importoop->haveerrormsg()){
                                       $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                                   }
                                   else {
                                       $error .= '第' . $excelrow . '行“' . $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_excelfieldlabel'][$fieldcolIndex] . '”列值为空或在数据库中不存在!<br>';
                                   }
                                     $nohaveerror=false;
                                }
							else	
								if($str=='' && $typedata[1]=='M'){
                                    $error.='第'.$excelrow.'行“'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'”列值为空或在数据库中不存在!<br>';
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
                    if($tablename==$focus->Detail_table || $tablename==$focus->Detail_table_scf){//判断是否是明细
						if($tablename==$focus->Detail_table){
							$fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$colnames[0]);
							if(!empty($fieldinfo)){
								$str = $Importoop->setImprtNameToId_details($fieldinfo,$str,$row);//获取相关信息id
							}
						}
						
                        $product_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]]=vtlib_purify($str);
                        if($entitytypefieldinfo)//如果有源单字段
                           {
                          
                          
                                 $entitytype = $product_xlsRowData[$detailtemp][$tablename]['entitytype'];//取当前数据第一行明细的源单类型
                                if(($currentModule=='CashBill'||$currentModule=='SendCashBill')&&empty($entitytype))
                                 {
                                    //如果源单类型为空，则不导入明细
                                     unset($product_xlsRowData[$tmp_prouctDetail_row]);
                                     break;
                                 }
                                //若主表数据一样，源单类型不同，则不导入该条源单
                             /*  if($tmp_prouctDetail_row>0 &&($product_xlsRowData[$tmp_prouctDetail_row][$tablename]['entitytype'] != $entitytype)){
                                    $error.='第'.$excelrow.'行'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'列值“'.$str.'”与单据源单类型“'.$entitytype.'”不一致,明细导入失败！<br>';
                                    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']+1;
                                    unset($product_xlsRowData[$tmp_prouctDetail_row]);
                                    break;
                                }   */  
                           }
                    }
                    elseif($product_same_salesorder=='no'){//&& strtolower($typedata[0]) !='i'
                         $xlsRowData[0][$tablename][$colnames[0]]=vtlib_purify($str);
                    }
                }
            }
       
            
           $conditionindex=0;
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
                    $break;
                }
                else if(($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex]))&&$cur_value==$next_checkValues[$check_column]&&$next_checkValues[$check_column]!='')
                {
                    $product_same_salesorder='yes';
                    break;
                }
                else  if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex])))
                {
                    $product_same_salesorder='no';
                       
                }
                $conditionindex++;
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

            if($tmp_cur_row_end_line=='no'||$tmp_cur_row_end_line=='yes'){
                  
            
                //判断币种和账户字段在导入文件中是否存在，存在则比较币种和账户是否一致
                if(in_array('currency_id',$import_columname[$module_tablename]) && in_array('bankaccountsetid',$import_columname[$module_tablename])){
                    $importcurrencyid=$xlsRowData[0][$module_tablename]['currency_id'];
                    $importbankaccountid=$xlsRowData[0][$module_tablename]['bankaccountsetid'];
                    if(empty($xlsRowData[0][$module_tablename]['currency_id'])) $importcurrencyid=1;
                    if(empty($xlsRowData[0][$module_tablename]['bankaccountsetid'])) $importbankaccountid=0;
                    $importcurrencyid= $arraycurrency[0]['currency_id'];
                    
                    $bool_importcurrency=$Importoop->get_importcurrencyAccount($importcurrencyid,$importbankaccountid);
                    if(!$bool_importcurrency){//如果账户和币种不对应，则不导入该条数据
                        $error .='第'.$excelrow.'行“币种”和“账户”不一致！';
                        $product_xlsRowData=array();
                        $nohaveerror=false;
                    }
                }
               
                if($nohaveerror==false){
                   $row++;
                  $main_module_rows++;
                  $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                  $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']+1;
                    $xlsRowData=array();
                   $nohaveerror=true;
                    continue;
                }

            }
            
     
            if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){//如果当前行数据和下一行数据不相同或当前行为excel最后一行
                //查询币种和账户是否对应
                $main_module_rows++;
               $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                 $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']+1;
                $detailtemp=$tmp_prouctDetail_row+1;

                $k=0;
                $flag = true; //主表重复，为false时，不插入明细表
                $service_base_contractstotal=0; //合同的合计(不包含调整金额、整单折扣金额)

                

                $temp=array();
                $uniqueid=array();
                $invenValues=array();
                $main_column_is_not_exit=array();
                $_checkdupColumn=array();
                $_checkdupValues=array();
                $_checkCondition=array();
                $total=$xlsRowData[0][$module_tablename]['total'];//取合计
                if(empty($total)) $total=0;
                
                if($import_type!="Insert"){ //查重判断
                    foreach($xlsRowData[0] as $maintable=>$infos){
                            $temp[$maintable] =$infos;
                            foreach($is_checkimportfield as $checkField)
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
                                 foreach($_checkdupColumn as $tmp_dupcheckfield=>$tmp_columnname)
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
                      
                        $updateColumns=array();
                        $updateValues=array();
                        foreach($temp as $infoTablename =>$info_values){ //
                            foreach($info_values as $infoKey =>$new_info_values){
                                if(!empty($info_values) && $infoKey !=$focus->tab_name_index[$module_tablename]){//排除导入文件中为空的数据
                                    $updateColumns[$infoTablename][$infoKey] = $infoKey;
                                    $updateValues[$infoTablename][$infoKey] = $new_info_values;
                                }
                            }
                        }
                  
                        $focus->getModuleStatic('ModTracker');
                       
                        for($i=0;$i<$num_rows;$i++){
                            $_uniqueid=$adb->query_result($check_result,$i,'id');
                            $focus->id=$_uniqueid;
                            $focus->retrieve_entity_info($focus->id,$currentModule);
                            if ($import_type=='Update') {
                                $btnlogic->controller=$focus;
                                $editbutton=$btnlogic->getEditViewBtn($currentModule,$_uniqueid);
                                if($editbutton['permit']!='yes')
                                {
                                    //是否有该单据的编辑权限
                                    if($btnlogic->edit_errorreason['reason']=='approve')
                                    {
                                        $error.='第'.$excelrow.'行单据'.$btnlogic->edit_errorreason['description'].'，不允许覆盖！<br>';

                                    }
                                    else
                                    {
                                        $error.='第'.$excelrow.'行无编辑权限，不允许覆盖！<br>';
                                    }
                                    continue;

                                }
                            }
                             $focus->modstatic->init($focus,$focus->module_name);//记录覆盖导入日志
                             $uniqueid[]=$_uniqueid;//后面循环插入需要用到
                             //按照表循环
                             global $before_approveinfo;
                            $before_approveinfo=[];
                            if($currentModule == 'CashBill'){
                                //已收金额计算时是否统计未审核的收款单  0 是 1 否
                                $setsystem_check = getSys_deploy(83);
                                if($setsystem_check['deploy_value']==0){
                                    $focus->minusBankMoney($_uniqueid);
                                }
                            } else if($currentModule == 'SendCashBill'){
                                $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
                                if($setsystem_check['deploy_value']==0) {
                                    $focus->addBankMoney($_uniqueid);
                                }
                            }
                            foreach( $focus->before_field_info as $before_field_info)
                            {

                                 if($before_field_info->getColumnName()=='approvestatus')
                                 {

                                     $before_approveinfo['approvestatus']=$before_field_info->getColumn_Value();
                                     if($before_approveinfo['approvestatus']==constant('D_A_S_APPROVED'))
                                     {

                                         if($currentModule=='Commission'||$currentModule=='Expense')
                                         {
                                            //edit:can 45983: （61mis.com/kfbcrm）OA表单-费用报销单-导入；导入单据后，银行账户有余额扣款变动，现金流水账没有数据
                                            $focus->addBankMoney($_uniqueid);
                                         }
                                         if($currentModule == 'CashBill'){
                                                //已收金额计算时是否统计未审核的收款单  0 是 1 否
                                                 $setsystem_check = getSys_deploy(83);
                                                 if($setsystem_check['deploy_value']==1){
                                                    $focus->minusBankMoney($_uniqueid);
                                                 }
                                            }
                                            else if($currentModule == 'SendCashBill'){
                                                $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
                                                if($setsystem_check['deploy_value']==1)
                                                {
                                                    $focus->addBankMoney($_uniqueid);
                                                }
                                            }
                                         break;
                                     }
                                 }
                            }
                            foreach($updateColumns as $updateTablename => $updatecolumnnames){
                                //按照字段循环
                                foreach($updatecolumnnames as $updatecolumn)
                                {
                                    //edit:can 20200824 42491: (http://171.221.206.240:88/crm [^])客户问题（易冲半导体），销售管理>S4量产项目：“覆盖导入”成功后，没有覆盖更新“销售预测”区块“Sep”字段数据
                                   if($updateValues[$updateTablename][$updatecolumn]!=''){//等于零不考虑了
                                        //要判断日期字段类型,1600-01-01
                                        if(in_array($updateTablename,$focus->tab_name))
                                        {
                                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                        }
                                        else
                                        {
                                             $fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                        }
                                        if(!$fieldinfo)
                                        {
                                            continue;
                                        }


                                            $query = 'update ' . $updateTablename . ' set ' . $updatecolumn . '=? where ' . $focus->tab_name_index[$updateTablename] . ' ='.$_uniqueid;


                                         $adb->pquery($query,array($updateValues[$updateTablename][$updatecolumn]));

                                      }
                                }
                                //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                                if($trigger_workflow=='yes'){
                                    $workflowreverseobj->setRecord($_uniqueid);
                                    $beforefieldvalue_arr=$focus->column_fields;
                                    $afterfieldvalue_arr=$updateValues[$updateTablename];
                                    $pagemode='updated';
                                    if(!empty($afterfieldvalue_arr)){
                                        $workflowreverseobj->setPageMode($pagemode);
                                        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                    }
                                }
                                //edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
                                $cls_module_advance->createModuleAdvanceStage($_uniqueid);
                            }
                            $focus->modstatic->saveOperationLog($focus->module_name,$focus->id,'IMPORT',$import_type);
                            $focus->modstatic->triggerEvent($focus->module_name);
                            $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
                        }
                        
                        //若存在重复数据，需要先删除收款单/付款单的明细
                        $deletesql='delete from '.$focus->Detail_table.' where '.$focus->Detail_table_index.' in(?)';
                        $adb->pquery($deletesql,array(implode(',',$uniqueid)));
                         
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
                                 if(!in_array('smownerid',$main_column_is_not_exit) || $infos['smownerid']==''){
                                    $infos['smownerid']=$current_user->id;
                                }
                                if(!in_array('createdtime',$main_column_is_not_exit) || $infos['createdtime']==''){
                                    $infos['createdtime']=date("Y-m-d H:i:s");
                                }
                                if(!in_array('modifiedtime',$main_column_is_not_exit) || $infos['modifiedtime']==''){
                                    $infos['modifiedtime']=date("Y-m-d H:i:s");
                                }
                                if((!in_array('checkoutstatus',$main_column_is_not_exit) || $infos['checkoutstatus']=='')
                                    &&$focus->fieldobj->getFieldInfoBykeyValue('columnname','checkoutstatus','fieldid')!=''){
                                    $infos['checkoutstatus']='未审核';
                                }
                                if(array_key_exists('approvestatus',$infos) && (!in_array('approvestatus',$main_column_is_not_exit) || $infos['approvestatus']=='')){
                                    $infos['approvestatus']='未提交';
                                }
								if(!empty($infos['approvestatus'])){
									 $approvestatus = $infos['approvestatus'];
								}
                                if($currentModule == 'CashBill'){
                                    //已收金额计算时是否统计未审核的收款单  0 是 1 否
     		                         $setsystem_check = getSys_deploy(83);
                                     if($setsystem_check['deploy_value']==0){
                                         $focus->minusBankMoney($_uniqueid);
                                     }
                                }
                                else if($currentModule == 'SendCashBill'){
                                    $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
                                    if($setsystem_check['deploy_value']==0)
                                    {
                                        $focus->addBankMoney($_uniqueid);
                                    }
                                }
                              
                                if($currentModule=='CashBill'||$currentModule=='SendCashBill')
                                {
                                    if($approvestatus==D_A_S_APPROVED)//38128: 收款单和付款单，如果导入的时候审批状态为“已批准”，则导入的时候 checkoutstatus 赋值应该为“已审核”
                                         $infos['checkoutstatus']='已审核';
                                    else
                                        $infos['checkoutstatus']='未审核';
                                }
                                if($focus->fieldobj->getFieldInfoBykeyValue('columnname','currency_id','fieldid')!='')
                                {
                                     if(!in_array('currency_symbol',$main_column_is_not_exit) || $infos['currency_symbol']==''){
                                        if(empty($infos['currency_id']))$infos['currency_id']=1;
                                        $currencyobj=Currency::getInstance($adb,$infos['currency_id']);
                                        $infos['currency_symbol']=decode_html($currencyobj->getCurrencySymbol());
                                    }
                                    if(!in_array('conversion_rate',$main_column_is_not_exit) || $infos['conversion_rate']==''){
                                        if(empty($infos['currency_id']))$infos['currency_id']=1;
                                        $currencyobj=Currency::getInstance($adb,$infos['currency_id']);
                                        $infos['conversion_rate']=$currencyobj->getCurrencyRate();
                                    }
                                }
                                if($infos[$code_num_columnname]=='')
                                {
                                    $infos[$code_num_columnname]=$_uniqueid;
                                }
                            }
                           
                           $infos[$currentModule.'id']=$_uniqueid;
                           
                            if($maintable==$focus->table_name&&$code_num_columnname!=''&&$importcolumnname_index['code_num']<0)
                            {
                                //如果该模块有编号字段，但是导入的excel中没有编号，则编号应该取当前单据的ID
                                
                               //对应关系没有单据编号字段时sql出错 BUG0057601产品价格模块，数据导入后显示导入成功，没有报错，但是列表上没有数据，客户不提供导入文件，如需要导入的文件，需要远程到客户的电脑上操作
                               $infos[$code_num_columnname]=$_uniqueid;
                               $adb->pquery($field_sql[$maintable],array($infos));
                            }
                            else if($importcolumnname_index['code_num']>=0&&$checkcodenum==''&&$maintable==$focus->table_name)
                            {
                               
                                if(array_key_exists($code_num_columnname,$infos))
                                {
                                    $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                }
                                else
                                {
                                    $infos=array_merge($infos,array($focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name)));
                                }
                                $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                                
                                $adb->pquery($field_sql[$maintable],array($infos));
                               
                            }
                            else
                              {
                                    if($import_type=='Insert'&&$importcolumnname_index['code_num']>=0&&$checkcodenum!='')
                                   {
                                        $sql=" select 1 from $maintable where $code_num_columnname=? and deleted=0 limit 1 ";
                                        $result=$adb->pquery($sql,array($checkcodenum));
                                        if($adb->num_rows($result)>0)
                                        {
                                            
                                            //edit:can 2020-10-30 43071: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），数据模板中录入的合同编号重复，合同订单单据导入时，设置合同订单重复时导入方式为“追加”，导入成功后，单据编号应该为最大编号+1（需要补丁）
                                            $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                           
                                        }
                                   }
                                $adb->pquery($field_sql[$maintable],array($infos));
								$cls_module_advance->createModuleAdvanceStage($_uniqueid);
                                if($maintable==$focus->table_name)//edit:can 20200820 新增行，要修改系统编号添加1
                                    $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                              }
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
                        $error .="第".$excelrow."行$main_fieldlabel_dup_tip 重复，已做跳过处理！"."<br>";
                        $flag = false;
                    }
                   
                    $product_value=array_values($product_xlsRowData);//获取产品明细的值，用来判断导入的产品明细是否为空

                    if($flag==true){
                        //wym 240515  BUG20240514-24 更新单据来源为导入
                        $sourcefrominfo=$focus->fieldobj->getFieldInfoobjBykey('uitype',118);
                        if(!empty($sourcefrominfo)) {
                            $sourcefrom_columnname = $sourcefrominfo->getColumnName();
                            $sourcefrom_table = $sourcefrominfo->getTableName();
                            $updatesourcefromsql = 'update ' . $sourcefrom_table . ' set ' . $sourcefrom_columnname . '="import" where ' . $focus->table_index . ' in(?) and '.$sourcefrom_columnname.' is null ;';
                            $adb->pquery($updatesourcefromsql,array(implode(',',$uniqueid)));
                        }
                        //wym 240515 BUG20240513-73 更新收款认领单-认领状态
                        if($currentModule=='CollectionSlip'){
                            $statusinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','collectionslip_status');
                            if(!empty($statusinfo)) {
                                $updatestatussql = 'update ' . $focus->table_name . ' set collectionslip_status="uncollected" , collectionslip_time=null where ' . $focus->table_index . ' in(?) and collectionslip_status is null ;';
                                $update = $adb->pquery($updatestatussql,array(implode(',',$uniqueid)));
                            }
                        }
                    }
                    if($flag==true && !empty($product_value)){    
                        //更新小计的sql
                        $updatesubtotalsql='update '.$focus->table_name.' set subtotal=? where '.$focus->table_index.' in(?);';
                        //开始导入明细
                        $sutotal_sum=0;
                        $source_listids=array();
                        $source_entitytype='';
                        $detailtables=array($focus->Detail_table,$focus->Detail_table_scf);
                      
                        foreach($product_xlsRowData as $productData =>$productColumn){ 
                            foreach($detailtables as $tmpdetailtable)
                            {

                                    // foreach($productColumn[$tmpdetailtable] as $product_Values){//收款单、付款单明细没有自定义表，这里就不判断了
                                   $productTablename=$tmpdetailtable;
                                    for($i=0;$i<sizeof($uniqueid);$i++){
                                        if($entitytypefieldinfo && $productTablename == $focus->Detail_table)//如果该模块有源单字段
                                        {
                                            
                                             $entitytype=$productColumn[$productTablename]['entitytype'];
                                            //$error .="第".$row."行源单不存在或源单与源单类型不一致!"."<br />";
                                            //获取源单信息(源单id，源单name)
                                            $sourInformation=getProducts_entitytypeid($productColumn[$productTablename]['entitytypeid'],$entitytype,$currentModule);
                                        }
                                        if(empty($sourInformation['id'])&&empty($sourInformation['fieldname'])&&!empty($entitytype)){
                                            //excel中源单类型不为空，但是匹配失败，这种情况不导入
                                        }else{
											if(!empty($sourInformation)&&$entitytypefieldinfo && $productTablename == $focus->Detail_table)
											{
											     //收款单原单导入
											//	$entitytypeidInfos[$sourInformation['fieldname']][]=$productColumn[$productTablename]['entitytypeid'];
												$productColumn[$productTablename]['entitytypeid']=$sourInformation['id'];
												$source_listids[]=$sourInformation['id'];
												$source_entitytype=$sourInformation['fieldname'];
												$productColumn[$productTablename]['entitytype']=$sourInformation['fieldname'];
												$entitytypeidInfos[$sourInformation['fieldname']][]=$sourInformation['id'];
											//	$entitytypeidInfos[$sourInformation['fieldname']][] = $sourInformation['fieldname'];
											}
											if(!array_key_exists($focus->Detail_table,$productColumn))
											{
												$adb->pquery("insert into ".$focus->Detail_table.' ( '.$focus->Detail_table_index.',sequence ) value(?,?)',array($uniqueid[$i],$i+1));
												$detailid_value=$adb->getLastInsertID();
                                                  
											}

                                            
											if($productTablename==$focus->Detail_table)
												$productColumn[$productTablename][$focus->Detail_table_index]=$uniqueid[$i];
											else
												$productColumn[$productTablename][$focus->Detail_table_id]=$detailid_value;
											//表体明细表写入
                                            
                                            $adb->pquery($field_sql[$productTablename], ($productColumn[$productTablename]));
                                       
                                            if($productTablename==$focus->Detail_table )
                                            {
                                                if(empty($detailid_value))
                                                        $detailid_value=$adb->getLastInsertID();
                                              
                                            }
                                            else 
                                            {
                                              
                                              $detailid_value=0;
                                            }
                                            
                                            if(empty($productColumn[$productTablename][$total_detail_columnname])&&array_key_exists($total_detail_columnname,$productColumn[$productTablename]))
                                                {
                                                    $productColumn[$productTablename][$total_detail_columnname]=0;
                                                }
                                                $sutotal_sum += $productColumn[$productTablename][$total_detail_columnname];//为空情况下，需要计算
        
                                        } 
                                    }
                                //}
                            }
                           
						
							
                        }
                        
                        if($subtotalfieldinfo)//如果有小计字段
                             $adb->pquery($updatesubtotalsql,array($sutotal_sum,implode(',',$uniqueid)));

                        //有明细的情况下，合计取本次收/付款小计的合计
                        if(!empty($sutotal_sum))
                        {
                            $totals=$sutotal_sum;
                            $updatetotalsql='update '.$focus->table_name.' set total=? where '.$focus->table_index.' in(?);';
                            $adb->pquery($updatetotalsql,array($totals,implode(',',$uniqueid)));
                        }
                        
                      if($approvestatus == '已批准' && ($currentModule == 'Commission' || $currentModule == 'Expense')){
								/*edit: chj,date: 2020/7/24 reason:42085: （https://61mis.com/kfbtest [^]）费用报销单->导入：导入数据成功后，没有更新现金银行流水账记录*/
					           //edit:can 20210520 042249: （https://61mis.com/kfbtest [^]）佣金单->导入：导入一张单据多条明细成功后，银行账户当前余额计算错误
                                $focus->minusBankMoney($uniqueid);
                                
						}
                        //zkt 20220921 BUG0056792导入的与银行账户相关单据（收款单、付款单），导致银行流水帐盈亏与银行账户余额不一致（分配给灿哥）
                        //反写银行账户,收付款单若统计未审核单据，则需在前面有对收付款单银行账户做删除操作
                        //若不统计未审核单据，需保证导入前单据审批状态为已批准时先做反审对应的审批操作，且导入后审批状态为已批准
                        if($currentModule == 'CashBill'){
                            //已收金额计算时是否统计未审核的收款单  0 是 1 否
                    		 $setsystem_check = getSys_deploy(83);
                             if($setsystem_check['deploy_value']==0){
                                $focus->addBankMoney($uniqueid);
                             }
                             else if($setsystem_check['deploy_value']==1&&$approvestatus == '已批准'){
                                $focus->addBankMoney($uniqueid);
                             }
                        }else if($currentModule == 'SendCashBill'){
                            $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
                            if($setsystem_check['deploy_value']==0){
                                $focus->minusBankMoney($uniqueid);
                             }
                             else if($setsystem_check['deploy_value']==1&&$approvestatus == '已批准'){
                                $focus->minusBankMoney($uniqueid);
                             }
                        }
                        
                      if(!empty($source_entitytype))
                      {
                         //原单不为空ongoing
                         $sourceupdatesql='update '.$focus->table_name.' set entitytype=?,source_list=? where '.$focus->table_index.' in(?);';
                         $adb->pquery($sourceupdatesql,array($source_entitytype,implode(',',$source_listids), implode(',',$uniqueid)));
                  
                      }
					foreach($entitytypeidInfos as $entitytype=>$entityids)
					{
						if(in_array($currentModule,array('CashBill','SendCashBill'))){
							if(!empty($entitytype)&&!empty($entityids[0])){//源单或源单类型为空的情况下，更新源单会报错
								$focus->updateSourceInfo(array_unique($entityids),$entitytype);
                                //收款单（付款单）导入后更新相关的收款计划（付款计划）的已收金额，最近收款日期
                                if($currentModule == 'CashBill'){
                                    $focus->update_PaymentActualamount(implode(',',array_unique($entityids)));
                                }else if($currentModule == 'SendCashBill'){
                                    $focus->update_SendPaymentActualamount(implode(',',array_unique($entityids)));
                                }
							}
						}
						//chj 2021/1/20 42265: （https://61mis.com/kfbtest/ [^]）自定义表单26->导入：导入数据成功后，（ZDYBD26-21）源单信息中的“合同金额”字段值在单据列表界面显示为0
						if(!empty($entityids[2]) && (get_file_address($entityids[2],'ProductDetails')|| get_file_address($entityids[2],'DetailFieldsHtml'))){
							 $sourcemodule_focus=CRMEntity::getInstance($entityids[2]);
							 $updatesql='update '.$focus->Detail_table.' inner join '.$sourcemodule_focus->table_name.' on '.$sourcemodule_focus->table_name.'.'.$sourcemodule_focus->table_index.' = '.$focus->Detail_table.'.entitytypeid set source_total='.$sourcemodule_focus->table_name.'.total where id in(?);';
							 $adb->pquery($updatesql,array(implode(',',$uniqueid)));
						}
					}
                        $sutotal_sum=0;
                        $totals=0;  
                }
            }
        
            $tmp_prouctDetail_row++;
           
            $row++;
        }
      
        //die;
        $endrow=$row;//明细的行数不是固定的。
        include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');
        $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
        $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];


        $_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"].$error;


        $tmp['timedescription']=$time_description;
        $tmp['cur_progress_step']=$cur_progress_step;
        $tmp['endimporttime']=$endimporttime;
        $tmp['endrow']=$endrow-1;
        ConvertTojsonString(1,$tmp,'success');
    }

?>