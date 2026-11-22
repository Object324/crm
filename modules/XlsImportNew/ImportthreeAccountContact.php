<?php

global $currentModule;
global $current_user;
global $adb;
global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony']='yes';
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
    
     $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['content']=$smarty->fetch('ImportXlsNew/ThreeImport.tpl');
    $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
    //$tmp['oktext']=getFixedLabel("ASTEP");
    
    ConvertTojsonString(1,$tmp,'success');
    
}

include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
  require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
crm_load_class_file('cls_Bangwoba', 'modules/Users');
$cls_Bangwoba = new cls_Bangwoba();
$focus=CRMEntity::getInstance($currentModule);
$module_tablename=$focus->table_name;
$module_tablename_scf=$focus->customFieldTable[0];
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$cls_contact_advance = new cls_module_advance('Contacts');
$detail_focus=CRMEntity::getInstance("Contacts");
$detail_tablename = 'ld_contactdetails';// 联系人主表
$detail_tablename_scf = 'ld_contactscf';// 联系人自定义表
$detail_modules='Contacts';
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];

    $error='';//错误信息
    
    
    $mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
 
    $totalcolumns=sizeof($mapfields);
   	$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
    
    //主表字段
    $result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id];//数组
    
    //明细表字段
    $detail_result=  $_SESSION['detailfieldContacts'];//明细数组
    $import_module = $_REQUEST['importmodel'];
    $smarty->assign("IMPORTMODULE",$import_module);
   $importcolumn=array();
   //$field_tables=array();//主表导入字段
   $field_tables[$module_tablename]=array();//主表导入字段
   $contactfield_tables[$detail_tablename]=array();//联系人导入字段
   $contacttables=array('ld_contactdetails','ld_contactaddress','ld_contactscf');
   $contactlastname='lastname-field';//联系人姓名
   //$module_NO=$Importoop->get_moduleNo($import_module);
   
   $contactlastindex=0;//联系人姓名列索引
   $field_columns_only=array();//唯一字段
   $codeIndex=0;//编号在xls文件中列索引
   $quantitIndex=0;
   $listpriceIndex=0;
   $findcodenum=false;
   $nohaveerror=true;
   $fieldcolIndex=0;
   $userarr=array();//用户集合
   //smcreatorid,createdtime,modifiedtime,modifiedby
   $noeditField=array('smcreatorid'=>'-1','createdtime'=>'-1','modifiedtime'=>'-1','modifiedby'=>'-1');
   $smownerfield=array('smownerid'=>'-1');
   $importcolumnname_index=array('code_num'=>-1,'bill_city'=>-1,'bill_state'=>-1);
   $salutationfield=array('salutation'=>'-1');//联系人称谓
   $moduleImport['choose'] = $_REQUEST['choose'];
   $moduleImport['select'] = $_REQUEST['select1'];
   $module_detail_Import['select2'] = $_REQUEST['select2'];
 
  
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
        if($i==sizeof($is_checkimportfield)-1)
        {
                $conditionlabel='';
        }
        $main_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
        
     }
     $contact_checkimportfield=implode(',',json_decode($_REQUEST['product_importdupcheckfields'],true));//查重字段
  
    $contact_is_checkimportfield = explode(',',$contact_checkimportfield);//将选中的联系人明细查重字段转为数组
    $contact_importdupfields_condition=json_decode($_REQUEST['product_importdupfields_condition'],true);//查重字段条件

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

    for($i=0;$i<sizeof($result);$i++){
         $uitype=$result[$i]['uitype'];
         $columnname=$result[$i]['columnname'];

         $tablename=$result[$i]['tablename'];
         $typeofdata=$result[$i]['typeofdata'];
         $fieldonly=$result[$i]['fieldonly'];//字段值是否唯一，1：唯一
         $fieldLabel=$result[$i]['fieldlabel'];
         $typedata=explode('~',$typeofdata);
      
         if($typedata[1]=='M'&&$uitype!=4){    
            if(!in_array($columnname.'-field',$mapfields)){
                 $error.='导入文件中缺少\''.$fieldLabel.'\'列<br>';
                 //break;
            }
         }
         
         if(in_array($columnname.'-field',$mapfields)){         
             if(!in_array($tablename,$contacttables)){
                 $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
             }
             $fieldcolIndex++;
             if($uitype==4){
               $codeIndex=array_search($columnname.'-field',$mapfields);
               $importcolumnname_index['code_num']=$codeIndex;
               $code_num_columnname=$columnname;
             }
             
             if($columnname=='bill_city'&&$tablename=='ld_account')
             {
                $importcolumnname_index['bill_city']=array_search($columnname.'-field',$mapfields);;
             }
             if($columnname=='bill_state'&&$tablename=='ld_account')
             {
                $importcolumnname_index['bill_state']=array_search($columnname.'-field',$mapfields);;
             }
             if('lastname-field'==$columnname.'-field'){
                $contactlastindex=array_search($columnname.'-field',$mapfields);
             }
         }  
    }
     if(trim($contact_checkimportfield)!='')
     {
            for($i=0;$i<sizeof($detail_result);$i++){
              
             $uitype=$detail_result[$i]['uitype'];
             $columnname=$detail_result[$i]['columnname'];
            
             $tablename=$detail_result[$i]['tablename'];
             $typeofdata=$detail_result[$i]['typeofdata'];
             $fieldonly=$detail_result[$i]['fieldonly'];//字段值是否唯一，1：唯一
             $fieldLabel=$detail_result[$i]['fieldlabel'];
             $typedata=explode('~',$typeofdata);
            //027268: 页面设置联系人模块编号设置为必填，导入客户时同时导入联系人信息，导入表格里没有联系人编号，导入客户时候会提示导入表格里面缺少编号。
             if($typedata[1]=='M'&&$uitype!='4'){ //必填项去掉联系人编号
       
                if(!in_array($columnname.'-detailfield',$mapfields)){
                     $error.='导入文件中缺少\''.$fieldLabel.'\'列<br>';
                     //break;
                }
             }
             
             if(in_array($columnname.'-detailfield',$mapfields)){
                
                 if(in_array($tablename,$contacttables)){
                    $contactfield_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-detailfield',$mapfields),$fieldLabel);
                 }
                 $fieldcolIndex++;
                 if($uitype==4){
                   $codeIndex=array_search($columnname.'-detailfield',$mapfields);
                 }
                 if('lastname-detailfield'==$columnname.'-detailfield'){
                    $contactlastindex=array_search($columnname.'-detailfield',$mapfields);
                 }
             }  
        }
     }
  
        

    if($error!='')
    {

  
       $successRows =0;
       $updateRows=0;
       $addimportrows=0;
       $importdatainfo=$error;
       $false=true;
       $smarty->assign('FALSE',$false);
       $smarty->assign("IMPORTINFO",$importdatainfo);
        $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
        fwrite($filehandler,str_replace('<br>',"\r\n",$error));
        fclose($filehandler);
       ConvertTojsonString("-1",array(),$error);
    }
    else
    {
        
        require_once('PHPExcel/PHPExcel/IOFactory.php') ;
       
        $_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
        $_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
        $Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);
        $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
        $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
        $highestColumnIndex = $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex'];//总列数
        
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
    
       
        if(sizeof($highestRow)<2){
            $error .='模板文件中没有数据，导入失败！'.'<br>'; 
            $successRows =0;
            $updateRows=0;
            $importdatainfo=$error;
            $false=true;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
           ConvertTojsonString("-1",array(),$error);
        }
      
        $xlsRowData=array();
       
        $nohaveerror=true;

        //先拼接ld_crmentity插入语句
        $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
        //将所有的字段拼接到一个数组里面
        $detail_Active = $detail_Active??'';
        if($detail_Active == 1){ //当联系人模块关闭或者首要联系人没有开启，则客户模块不应该显示导入联系人
            $contactfield_tables =array();
        }
        $allinsertfield = array_merge($field_tables,$contactfield_tables);
        $insert_columname = array();
        $insert_values = array();

        //再分别拼接客户和联系人插入sql
        foreach($allinsertfield as $tablename=>$colinfo)
        {
             if($tablename=='ld_crmentity'){
                continue;
             }
            if(!is_array($insert_columname[$tablename])){
                $insert_columname[$tablename] = [];
            }
             foreach($colinfo as $ky=>$colnames)
             {
                 $insert_columname[$tablename][] = $colnames[0];
                 if(!empty($checkPicklistColumn) && $colnames[1]==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
                     $tmpcolumn= $colnames[0];
                     $selcol=$tablename.':'.$tmpcolumn;
                     if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                         if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$tmpcolumn])) {
                             $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $tmpcolumn) ?? $detail_focus->fieldobj->getFieldInfoobjBykey("columnname", $tmpcolumn);
                             if ($fieldinfo) {
                                 $fieldname = $fieldinfo->getFieldName();
                                 crm_load_class_file('cls_PickList', 'modules/PickList');
                                 $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                                 $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                                 $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$tmpcolumn] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                             }
                         }
                     }
                 }
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
                if(!in_array('modifiedby',$insert_columname[$tablename])){//
                    $insert_columname[$tablename][] = 'modifiedby'; 
                }
                if(!in_array('servicecasher',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'servicecasher';
                }
                 if(!in_array('smownerid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][]='smownerid';
                 }
                $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename]; 
             }
             if($tablename==$module_tablename_scf){
                $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename];
            }
            if(strtolower($tablename)==$detail_tablename){
                if(!in_array($detail_focus->table_code,$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = $detail_focus->table_code;
                }
                if(!in_array($focus->tab_name_index[$module_tablename],$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename];
                }
                if(!in_array('smcreatorid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smcreatorid';
                }
                if(!in_array('createdtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'createdtime';
                }
                if(!in_array('modifiedtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'modifiedtime';
                }
                if(!in_array('modifiedby',$insert_columname[$tablename])){//
                    $insert_columname[$tablename][] = 'modifiedby';
                }
                $insert_columname['ld_contactdetails'][]='smownerid';
                
                if(!in_array('reference',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'reference';
                }
                $insert_columname[$tablename][] = $detail_focus->tab_name_index[$tablename]; 
            }
            if(strtolower($tablename)==$detail_tablename_scf){
                $insert_columname[$tablename][] = $detail_focus->tab_name_index[$tablename]; 
            }
             foreach($insert_columname as $tablename => $column_fields){
                 if($importcolumnname_index['code_num']<0&&$tablename==$focus->table_name)
                  {
                
                    $account_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ',account_no) values (' . generateQuestionMarks($column_fields).',?)' ;
                  }
                  else
                    $account_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;  
                      
                
             }
         }


        $contact_detail_fields = array_merge($field_tables,$contactfield_tables);
      
        /*导入定义*/
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
         
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $createdtime=date("Y-m-d H:i:s");
        $modifiedtime=$createdtime;
        $successRows=0;//成功导入单据数
        $updateRows=0;//覆盖单据数
  
        $tmp_cur_row_end_line='no';
        $tmp_prouctDetail_row=0;  
        $contact_same_salesorder='no';
        $shijidaoruRows=0;//实际导入行数(如客户存在多条联系人明细，这样算一条)
        $hangshu=0;
        $totalcolumns=sizeof($mapfields);
         $startrow=$_REQUEST['startrow'];
      
        $endrow=$_REQUEST['endrow'];
        $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
        $main_module_rows=0;//跨越的主表的行数
        $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
        
        $row=$startrow;
        $codeprefixtype=$focus->Library('SystemCode')->getModentityfield('prefixtype','Accounts');
        $joinmodule=getUsersettingByLabel($currentModule,'1','JointCheckDuplicate');
        while(true)
        {
            $test=0;
           
            $nohaveerror=true;
            $yijingtishi=true;
            if($row>=$maxrows){
             
                break;
            }
             if($main_module_rows>$between_rows)
            {
               
                $endrow=$row;//返回到前端，用于判断下次开始导入行数的标识
               
                break;
            }
            $excelrow=$row+2;
            
            $codenum=trim((string)$importdatas[$row][$codeIndex]);
            $col=0;
            if($row+1>=$maxrows){
                $tmp_cur_row_end_line='yes' ;             
            }
            
            foreach($contact_detail_fields as $tablename => $colinfo){
                foreach($colinfo as $ky=>$colnames){
                    $test++;
                    $columnname=$colnames[0];

                    $typedata=explode('~',$colnames[2]);
                    $fieldcolIndex=$colnames[3];
                    $fieldLabel=$colnames[4];
                    $str=trim((string)$importdatas[$row][$fieldcolIndex]);
                    $next_row_str='';
                    if($importcolumnname_index['code_num']==$fieldcolIndex)
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
                        //zkt 20230802 BUG0070417 Excel导入时编辑的默认值不生效，导入后的数据对应字段仍是空值。附件内容为excel导入时的操作和所用文件 
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
                                            $str= date('Y-m-d H:i:s',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
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
                  
                    if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)){
					
						if(!is_numeric($str))
						{
							$error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
							$nohaveerror=false;
						}
                    }
                    if($typedata[1]=='M'&&$str=='' && importXlsProductTable($tablename)){
                        //提示注释原因：bug0025604: 客户：导入单据，首要联系人信息中的姓名和编号为空时，提示信息显示了2次
                       
                        $nohaveerror=false;
                        //continue;
                    }

                    if($typedata[0]=='N'&&$str==''){
                        $str=NULL;
                    }  
                    if($typedata[0]=='NN'&&$str==''){
                        $str=NULL;
                    }
                    if($typedata[1]=='M'&&$str==''&&$importcolumnname_index['code_num']!=$fieldcolIndex){
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                       // $row++;
                        $nohaveerror=false;
                    }
                    if($colnames[1]==15 && array_key_exists($columnname,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                        if(!empty($str) && !in_array($str,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])){ //检查导入值是否是下拉框选项
                            $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                            $nohaveerror=false;
                        }
                    }
                    
                    if(array_key_exists($tablename,$focus->tab_name_index) && $str !=''){
                        if($colnames[1]==117){
                            $checkvalue = is_array($app_currency_strings) ? array_keys($app_currency_strings,$str) : array();
                            if($checkvalue[0]==''){
                                $checkvalue[0]=$str;
                            }
                                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';                   
                                $fieldResult=$adb->pquery($sqlfield,array());
                            if($adb->num_rows($fieldResult)>0){
                                $arraycurrency[0]['currency_symbol']=$adb->query_result($fieldResult,0,'currency_symbol');   
                                $arraycurrency[0]['conversion_rate']=$adb->query_result($fieldResult,0,'conversion_rate');                                   
                            }
                        }else{
                             
                             if($colnames[0]=='publicaccount')
                            {
                               
                                if(strpos($str,getFixedLabel('LBL_NOALLOCATE'))!==false)
                                {
                                     
                                    $str=1;
                                }
                                else if (strpos($str,getFixedLabel('LBL_PUBLICALLOCATE'))!==false)
                                {
                                    //公海已分配
                                    //户档案：客户信息导入时公海状态填写为公海已分配，导入进去后客户为普通客户
                                    //edit:can 户档案：客户信息导入时公海状态填写为公海已分配，导入进去后客户为普通客户
                                    $str=2;
                                }
                                else{
                                    $str=0;
                                }
                                //
                            }
                            else {
                                $HelpDeskstr = $HelpDeskstr ?? '0';
                                $str = $Importoop->setImprtNameToId($colnames[1],$str,$HelpDeskstr);//获取相关信息id
                            }
                            
                              
                            if( $typedata[1]=='M')
                                if(empty($str)&&$Importoop->import_nouitype=='no' ){
                                    if($Importoop->haveerrormsg()){
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                                    }
                                    else{
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                                    }
                                     $nohaveerror=false;
                                }
                                else if(trim($str)==''){
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                                     $nohaveerror=false;
                                }
                        }   
                    }
                    if($colnames[1]==1600){  //通过用户字段值获取成员所属部门
                        $colnames['tablename'] = $tablename;
                        $str = $Importoop->getvaluebyfields($colnames,$str,$contact_detail_fields,$importdatas[$row]);
                    }
                   
                    if(importXlsProductTable($tablename)){//判断是否是产品明细
                        $contact_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]]=vtlib_purify($adb->sql_escape_string($str));
                    }
                    else if($contact_same_salesorder=='no'){
                        //edit:can 2021-03-05 44846: （本地837.4）客户与联系人导入问题；客户导入时，名称含有“<”的话，导入后“<”会消失;导入联系人,客户名称含有“>”符号时,客户新增了一条单据
                        $xlsRowData['main'][$tablename][$colnames[0]]=vtlib_purify($adb->sql_escape_string($str)); 
                    }
                }
            }
          
            $contact_same_salesorder='yes';//判断明细是否为同一单据，yes:是,no:不是
            $conditionindex=0;
            if(trim($contact_checkimportfield)=='')
            {
                $contact_same_salesorder='no';//27196: 客户导入：如果联系人查重字段设置为无，则不导入联系人
            }
            else
            {
                if((is_array($is_checkimportfield)&&empty($is_checkimportfield[0]))||empty($is_checkimportfield))
                {
                    $contact_same_salesorder='no';
                    
                }
                
                foreach($_checkValues as $check_column =>$cur_value)
                {
                    //比较当前行和下一行数据查重字段的值是否相同，或下一行主表查重字段是否为空
                    if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='and' || empty($importdupfields_condition[$conditionindex])))
                    {
                        $contact_same_salesorder='no';
                        break;
                    }
                    else if(($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex]))&&$cur_value==$next_checkValues[$check_column]&&$next_checkValues[$check_column]!='')
                    {
                        $contact_same_salesorder='yes';
                        break;
                    }
                    else  if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex])))
                    {
                        $contact_same_salesorder='no';
                       
                    }
                    $conditionindex++;
                }
            }
            

           
            //客户模块若设置了没有工商信息不允许导入，则查询工商信息是否存在
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
            if($businessinformationobj->IsEnableBusiness()){
                if($businessinformationobj->IsNoBusinessnoimport()&&!empty($xlsRowData['main']))
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
                    $businesimport = getSaveBusiness('Accounts',$requestvalues_arr,'import');
                    if($businesimport == 'no')
                    {
                        $keywords_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                        $error .="第".$excelrow."行".$requestvalues_arr[$keywords_columnname]."工商信息不存在！"."<br>";
                        $nohaveerror=false;//工商信息不存在时，本行记录不进行导入
                    }
                }
            }


            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（导入判断客户数量上限）
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
            $public_account = $cls_PublicAccounts->getPublicAccount();
            foreach($xlsRowData['main'] as $maintable=>$infos){
                if($maintable=='ld_account'){
                    $tmp_smownerid = !empty($infos['smownerid'])?$infos['smownerid']:$current_user->id;
                    if($public_account['status'] != 'yes' || ($public_account['status'] == 'yes' && ($infos['pool_id'] === '' || $infos['pool_id'] === 0))){//普通客户  如果所属公海为空，则设置公海状态为普通客户
                        $limit_count = $focus->getCommonAccountLimitCount($tmp_smownerid);//普通客户数量上限
                        if($limit_count<9999999999)
                        {
                            $haved_count = $focus->getSmowerNumForCommonAccount($tmp_smownerid);//已有客户数量
                            if ($limit_count <= $haved_count) {
                                $error .="第".$excelrow."行销售负责人拥有的普通".getTranstab($currentModule)."数量已达上限！"."<br>";
                                $nohaveerror=false;
                            }
                        }
                    } elseif ($public_account['status'] == 'yes' && $infos['pool_id'] > 0 && $infos['publicaccount'] == 2) {//公海已分配   如果所属公海不为空，并且公海状态为公海已分配时，判断上限，其它情况属于公海未分配
                        $limit_count = $focus->getPublicAccountLimitCount($tmp_smownerid,$infos['pool_id']);//公海已分配客户数量上限
                        if($limit_count<9999999999)
                        {
                            $haved_count = $focus->getSmowerNumForPublicAccount($tmp_smownerid,$infos['pool_id']);//已有公海已分配客户数量
                            if ($limit_count <= $haved_count) {
                                $error .="第".$excelrow."行销售负责人拥有的公海已分配".getTranstab($currentModule)."数量已达上限！"."<br>";
                                $nohaveerror=false;
                            }
                        }
                    }
                }
            }



            if($contact_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){
                if($nohaveerror==false){
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]+1;
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                }
            }

           if($nohaveerror==false){
                //$row++;
                
               $xlsRowData=array();
               $contact_xlsRowData=array();
               $nohaveerror=true;
                //continue;
           } 
           
           
            
            
            if(($contact_same_salesorder=='no'||$tmp_cur_row_end_line=='yes') && !empty($xlsRowData['main'])){//如果当前行数据和下一行数据不相同或当前行为excel最后一行
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]+1;
                $flag = true; //主表重复，为false时，不插入明细表
                $detail_temp=array();
                $kk=0;
                $contactids=array();
                $main_column_is_not_exit=array();
                $main_module_rows++;
               
                if($import_type!="Insert"){ //查重判断
                    $tmp_uniqueid="";
                   
                    $_checkdupColumn= array();////不要等于array,如果等于arra()且查重字段的值为空会有bug
                   $_checkdupValues=array();
                   $_checkCondition=array();
                  
                    foreach($xlsRowData['main'] as $maintable=>$infos){
                        
                         $temp[$maintable] =$infos;
                        
                    }
                    foreach($is_checkimportfield as $index=> $checkField)
                    {
                        
                              $tmp_tablename=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$checkField,'tablename');
                           
                           $infos=$xlsRowData['main'][$tmp_tablename];
                            if($infos[$checkField]!='')
                            {
                                  $_checkdupColumn[]=$checkField;
                                  $_checkdupValues[$checkField] = $infos[$checkField];
                                    
                                  if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
                                  {
                                    //edit:can 20210511 45817: （http://123.60.10.239:85/crm [^]）客户问题（邹晓钰），客户导入，一直显示在导入数据界面
                                    $importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('fieldname',$is_checkimportfield[$index+1]);
                                    $importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
                                    if($xlsRowData['main'][$importcolumntablename][$is_checkimportfield[$index+1]]!='')
                                    {
                                    
                                        $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                    }
                                        
                                    else
                                        break;
                                  }
                                  else
                                  {
                                   
                                     $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                  }
                               
                            }
                              
                        }
                        //主表进行查重
                    $joincheckdup=false;
                    if(sizeof($_checkdupColumn)>0&&is_array($_checkdupColumn))
                    {
                        $main_table_sql = 'SELECT '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].' as '.$focus->tab_name_index[$module_tablename].' from '.$module_tablename.'  LEFT JOIN
                        '.$module_tablename_scf.' on '.$module_tablename_scf.'.'.$focus->tab_name_index[$module_tablename] .' = '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].'';
                        $main_table_sql .=" where ( ";
                        $dupcheckfield_len=sizeof($is_checkimportfield);

                        foreach($_checkdupColumn as $index=>$tmp_columnname)
                        {
                            $main_table_sql.= "  $tmp_columnname= ?  ";

                            if($_checkCondition[$tmp_columnname]!=""&&$index!=$dupcheckfield_len-1)
                            {

                                $main_table_sql.=$_checkCondition[$tmp_columnname];


                            }
                            $joincheckdup=false;
                            //wym 240417 1000195 销售线索和客户增加一起查重功能，包括新增、导入（邹晓宇）
                            if($tmp_columnname=='accountname' && $_checkCondition[$tmp_columnname]=='or'){
                                if(!empty($joinmodule) && $joinmodule!='no'){
                                    $fieldvalue=$_checkdupValues[$tmp_columnname];
                                    crm_load_class_file('cls_rule_validata','include/utils');
                                    $joincheckdup=cls_rule_validata::checkDuplicate($fieldvalue,$joinmodule,'');
                                }
                            }
                        }
                        $main_table_sql.=" ) ";
                        $main_table_sql.=" and deleted=0";
                        $check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
                        $num_rows = $adb->num_rows($check_result);
                    }else {
                        $num_rows=0;
                    }
                }
                if($import_type=='Update' || $import_type=='UpdateAll'){
                    if($num_rows>0){
                        $updateColumn=array();
                        $updateValues=array();
                        foreach($temp as $infoTablename =>$info_values){ //
                            foreach($info_values as $infoKey =>$new_info_values){
                                if (in_array($infoKey,array('approvestatus','createdtime'))) {//覆盖及覆盖(全部)时， 审批状态、创建时间不允许覆盖。
                                    continue;
                                }
                                if($new_info_values!='' && $infoKey !=$focus->tab_name_index[$module_tablename]){//排除导入文件中为空的数据
                                    $updateColumns[$infoTablename][$infoKey] = $infoKey;
                                    $updateValues[$infoTablename][$infoKey] = $new_info_values;
                                }
                            }
                        }
                        $focus->getModuleStatic('ModTracker');
                        for($i=0;$i<$num_rows;$i++){
                            $tmp_uniqueid= $adb->query_result($check_result,$i,$focus->tab_name_index[$module_tablename]);
                            $focus->id=$tmp_uniqueid;
                            $focus->modstatic->init($focus,$focus->module_name);//记录覆盖导入日志
                            $all_update_value=[];
                            foreach($updateColumns as $updateTablename => $updatecolumnnames){
                                foreach($updatecolumnnames as $updatecolumn)
                                {
                                    if(!empty($updateValues[$updateTablename]))//等于零不考虑了
                                    {
                                        //要判断日期字段类型,1600-01-01
                                        if(in_array($updateTablename,$focus->tab_name))
                                        {
                                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                        }
                                        else
                                        {
                                            $fieldinfo=$detail_focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                        }
                                        if(!$fieldinfo)
                                        {
                                            continue;
                                        }
                                        $query = 'update ' . $updateTablename . ' set ' . $updatecolumn . '=? where ' . $focus->tab_name_index[$updateTablename] . ' ='.$tmp_uniqueid;
                                        //$query .= ' and ( '.$updatecolumn.' is  null or  DATE_FORMAT('.$updatecolumn.',\'%Y-%m-%d\' )<\'1970-01-01\')';
                                        $adb->pquery($query,array($updateValues[$updateTablename][$updatecolumn]));
                                        $all_update_value=array_merge($all_update_value,$updateValues[$updateTablename]);
                                        if($currentModule == 'Accounts'&&$updateTablename=='ld_accountscf'){
                                            $focus->SyncAccountToBangwoba($tmp_uniqueid,'edit');//	$cls_Bangwoba->setAccountToBangwoba($tmp_uniqueid,'edit');
                                        }
                                    }
                                }
                                //edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
                                $cls_module_advance->createModuleAdvanceStage($tmp_uniqueid);
                            }
                            //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                            if($trigger_workflow=='yes'){
                                $workflowreverseobj->setRecord($tmp_uniqueid);
                                $focus->retrieve_entity_info($tmp_uniqueid,$currentModule);
                                $beforefieldvalue_arr=$focus->column_fields;
                                $afterfieldvalue_arr=$all_update_value;
                                $pagemode='updated';
                                if(!empty($afterfieldvalue_arr)){
                                    $workflowreverseobj->setPageMode($pagemode);
                                    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                }
                            }
                            $focus->modstatic->saveOperationLog($focus->module_name,$focus->id,'IMPORT',$import_type);
                            $focus->modstatic->triggerEvent($focus->module_name);
                            $_SESSION['import_'.$currentModule.'_'.$current_user->id."_updaterows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_updaterows"]+1;
                        }
                        if($num_rows>0)
                        {
                            //$_SESSION['import_'.$currentModule.'_'.$current_user->id."_successrows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_successrows"]+1;
                        }
                    } elseif($joincheckdup==true){ //$num_rows=0在当前模块不重复，但在查重模块重复，无法覆盖
                        $xlsRowData=array();
                        $contact_xlsRowData=array();
                        $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($joinmodule)."模块重复，覆盖失败!<br>";
                        $flag = false;
                    }
                }

                if( ( (empty($num_rows) && $joincheckdup==false ) || $import_type=='Insert') && $flag!=false ){ //目前flag为false仅针对：联合查重模块重复，当前模块不重复的情况，此时不插入
                    $tmp_uniqueid = $adb->getUniqueID('ld_crmentity');
                    $uniqueid[]=$tmp_uniqueid;
                    $adb->pquery($sqlcrmentity,array($tmp_uniqueid,'Accounts'));
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id."_successrows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_successrows"]+1;
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id."_addimportrows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_addimportrows"]+1;
                    $all_insert_value=[];
                    foreach($xlsRowData['main'] as $maintable=>$infos){
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
                            if(!in_array('modifiedby',$main_column_is_not_exit) || $infos['modifiedby']==''){
                                $infos['modifiedby']=$smcreatorid;
                            }
                            if(!in_array('servicecasher',$main_column_is_not_exit) || $infos['servicecasher']==''){//
                                 $infos['servicecasher']=$smcreatorid;
                            }
                             if(!in_array('smownerid',$main_column_is_not_exit) || $infos['smownerid']==''){
                                $infos['smownerid']=$smcreatorid;
                            }
                            if(array_key_exists('approvestatus',$infos) && (!in_array('approvestatus',$main_column_is_not_exit) || $infos['approvestatus']=='')){
                            $infos['approvestatus']='未提交';
                        }
                        }
                        $infos[$currentModule.'id']=$tmp_uniqueid;
                        if($checkcodenum==''&&$maintable==$focus->table_name)
                        {
                            if($importcolumnname_index['bill_city']>=0&&$codeprefixtype==2)
                            {
                                $tmpaccountno=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                $bill_cityvalue=trim((string)$importdatas[$row][$importcolumnname_index['bill_city']]);
                                $infos['account_no']= $focus->Library('SystemCode')->getModuleSeqNumRecordd('Accounts','bill_city',$bill_cityvalue,$tmpaccountno);
                                $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);

                            }
                            else if($importcolumnname_index['bill_state']>=0&&$codeprefixtype==1)
                            {
                                $tmpaccountno=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                $bill_statevalue=trim((string)$importdatas[$row][$importcolumnname_index['bill_state']]);
                                $infos['account_no']= $focus->Library('SystemCode')->getModuleSeqNumRecordd('Accounts','bill_state',$bill_statevalue,$tmpaccountno);
                                  $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);

                            }
                            else
                            {
                                $infos['account_no']=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                 $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                            }
                        }
                        else if($maintable==$focus->table_name&&$importcolumnname_index['code_num']<0)
                        {        
                            //如果该模块有编号字段，但是导入的excel中没有编号，则编号应该取当前单据的ID
                            if($importcolumnname_index['bill_city']>=0&&$codeprefixtype==2)
                          {
                                $tmpaccountno=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                $bill_cityvalue=trim((string)$importdatas[$row][$importcolumnname_index['bill_city']]);
                                $infos=array($infos,array($focus->Library('SystemCode')->getModuleSeqNumRecordd('Accounts','bill_city',$bill_statevalue,$tmpaccountno)));
                            
                                $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                          }
                          else if($importcolumnname_index['bill_state']>=0&&$codeprefixtype==1)
                          {
                                $tmpaccountno=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                $bill_statevalue=trim((string)$importdatas[$row][$importcolumnname_index['bill_city']]);
                                
                                 $infos=array($infos,array($focus->Library('SystemCode')->getModuleSeqNumRecordd('Accounts','bill_state',$bill_statevalue,$tmpaccountno)));
                                 $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                          }
                           else
                           {
                                $infos=array($infos,array($focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name)));
                                 $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                           }
                        }
                        else if($maintable==$focus->table_name)
                        {
                            //edit:can 20200820 新增行，要修改系统编号添加1
                            
                            $focus->Library('SystemCode')->setModuleSeqNumber('increment',$focus->module_name);
                        }
                        $all_insert_value = array_merge($all_insert_value, $infos);

                        $adb->pquery($account_sql[$maintable],$infos);

                        if($currentModule == 'Accounts'&&$maintable=='ld_accountscf'){
                            $focus->SyncAccountToBangwoba($tmp_uniqueid,'create');//	$cls_Bangwoba->setAccountToBangwoba($tmp_uniqueid,'create');
						}
                        //客户模块所属公海导入规则   chj 2022/6/24 先去除
                        if($currentModule == 'Accounts'&&$maintable=='ld_account'){
                            //$focus->updateImportPublicAccount($tmp_uniqueid);

                            //导入客户时重算保护结束日期
                            $focus->updateAccountInfo($currentModule,$tmp_uniqueid);
						}
						$cls_module_advance->createModuleAdvanceStage($tmp_uniqueid);
                        $infos=array();
                    }
                    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                    if($trigger_workflow=='yes'){
                        $workflowreverseobj->setRecord($tmp_uniqueid);
                        $beforefieldvalue_arr=[];
                        $afterfieldvalue_arr=$all_insert_value;
                        $pagemode='creation';
                        if(!empty($afterfieldvalue_arr)){
                            $workflowreverseobj->setPageMode($pagemode);
                            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                        }
                    }
                }
                
                if(($num_rows>0 || $joincheckdup==true) && $import_type=='Abort'){
                    $xlsRowData=array();
                    $contact_xlsRowData=array();
                    if($num_rows>0){
                        $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($currentModule)."模块重复，已做跳过处理!"."<br>";
                    }elseif($joincheckdup==true){
                        $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($joinmodule)."模块重复，已做跳过处理!"."<br>";
                    }
                    if($num_rows>0 && $joincheckdup==true){ //wym 240424 BUG20240423-29 两模块都重复时应该都提示
                        $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($currentModule)."和".getTranstab($joinmodule)."模块重复，已做跳过处理!"."<br>";
                    }
                    $flag = false;
                }

                if($flag==true && $detail_Active != 1 && trim($contact_checkimportfield)!=''){//27196: 客户导入：如果联系人查重字段设置为无，则不导入联系人
                    $smownerid_result=$xlsRowData['main']['ld_account']['smownerid'];
                    $_checkcontacts =$contact_is_checkimportfield; //获取联系人明细表查重字段
                   
                    if(is_array($contactid) && sizeOf($contactid) <=0 )$contactid = '';
                        //开始导入联系人明细
                        $detail_updateValues=array();
                        foreach($contact_xlsRowData as $contactData =>$contactColumn){
                           $detail_updateColumn=array();
                            foreach($contactColumn as $contactTablename =>$contact_Values){
                                if(!empty($_checkcontacts)){
                                  
                                    foreach($_checkcontacts as $index=>$contact_key_column )
                                    {
                                            $_checkimportfieldColumn[$contact_key_column] = $contact_key_column;
                                            $_checkimportfieldValues[$contact_key_column] = $contact_Values[$contact_key_column];
                                            $contact_checkCondition[$contact_key_column]=$contact_importdupfields_condition[array_search($contact_key_column,$contact_is_checkimportfield)];
                                    }
                                    
                                    foreach($contact_Values as $contact_key_column =>$contact_column_values){
                                        if(!empty($contact_column_values) && $contact_key_column !=$focus->tab_name_index[$detail_tablename]){//排除导入文件中为空的数据
                                            $detail_updateColumn[$contactData][$contactTablename][$contact_key_column] = $contact_key_column;
                                            $detail_updateValues[$contactData][$contactTablename][$contact_key_column] = $contact_column_values;
                                        }
                                    }

                                      if(!is_array($uniqueid)||$uniqueid[0]<=0)
                                      {
                                    
                                        $uniqueid[]=$tmp_uniqueid;
                                      }
                                     $contact_dupcheckfield_len=sizeof($_checkcontacts);
                                 
                                    for($i=0;$i<sizeof($uniqueid);$i++){
                                        //开始查重
                                        //ld_contactdetails.accountid=? and 
                                        //客户导入时， 判断联系人手机不允许重复， 应该在所有客户的联系人中进行重复与否判断， 而不是只在当前联系人所对应的客户名下判断。
                                        $contact_sql='SELECT '.$detail_tablename.'.'.'contactid as contactid from '. $detail_tablename. 
                                        ' LEFT JOIN '.$detail_tablename_scf.' on ld_contactdetails.contactid=ld_contactscf.contactid ';
                                        $contact_sql .=' where    ( ';
                                        foreach($_checkcontacts as $index=>$tmp_columnname)
                                        {
                                            $contact_tablename=$detail_focus->fieldobj->getFieldInfoBykeyValue('columnname',$tmp_columnname,'tablename');
                                            if($contact_tablename!='ld_contactdetails')
                                            {
                                                $leftjoin_contacttablename=$contact_tablename;

                                            }
                                            $contact_sql.= "  $tmp_columnname= ?  ";

                                            if($_checkimportfieldValues[$tmp_columnname]!=""&&$index!=$contact_dupcheckfield_len-1)
                                            {

                                                $contact_sql.=$contact_checkCondition[$tmp_columnname];
                                            }
                                        }
                                        if($leftjoin_contacttablename!='')
                                        {
                                            $contact_sql.=' left join '.$leftjoin_contacttablename.' on '.$leftjoin_contacttablename.'.contactid=ld_contactdetails.contactid';
                                                
                                        }
                                        
                                        $contact_sql.=" ) ";
                                        $contact_sql.=" and deleted=0  ";

                                        if(is_array($uniqueid))
											$contact_result=$adb->pquery($contact_sql,array($_checkimportfieldValues));
										else
											$contact_result=$adb->pquery($contact_sql,array($_checkimportfieldValues));
                                        $contact_num=$adb->num_rows($contact_result);
                                         
                                        if($contact_num>0 && $import_type=="Update"){//大于0，表示存在明细，直接获取明细id即可
                                        $tmpcontactid=array();
                                            for($p=0;$p<$contact_num;$p++){
                                                $tmpcontactid[$p][]=$adb->query_result($contact_result,$p,0);
                                            }
                                            foreach($tmpcontactid as $key => $key_contactid){
                                                $contactids=$key_contactid;
                                            }
                                            foreach($detail_updateColumn as $detail_No_one =>$new_detail){
                                                foreach($new_detail as $detail_updateTablename =>$new_detail_dateValues){

                                                   $detail_column = implode('=?,',$new_detail_dateValues) . '=?';
                                                   $query = 'update ' . $detail_updateTablename . ' set ' . $detail_column . ' where ' . $detail_focus->tab_name_index[$detail_updateTablename]. ' in ('.implode(',',$contactids).')';
                                                                                                   
                                                }
                                            }

                                            $adb->pquery($query,array($detail_updateValues[$detail_No_one][$detail_updateTablename]));
                                            $contactid = array();
                                           
                                        }
                                        
                                        if(empty($contact_num) || $contact_num<1){//追加
                                            if($contactTablename==$detail_tablename)
                                                    $contact_id=$adb->getUniqueID('ld_crmentity');
                                            $column_is_not_exit=array();//原来获取所有的columnname，后面原来判断部分字段在导入文件中是否存在
                                           

                                            foreach($contact_Values as $column_key => $column_values){
                                                $contacts_fieldValuess[$contactTablename][$column_key]=$column_values;
                                                $column_is_not_exit[$contactTablename][$column_key]=$column_key;
                                            }       
                                            
                                         
                                            if($contactTablename == $detail_tablename){
                                               // $sql='update ld_modentity_num set cur_id=cur_id+1 where semodule=?';
//                                                $adb->pquery($sql,array('Contacts'));             
                                                if($contacts_fieldValuess[$detail_tablename][$detail_focus->table_code] =='' || empty($contacts_fieldValuess[$detail_tablename][$detail_focus->table_code])){
                                                    $No = $detail_focus->Library('SystemCode')->setModuleSeqNumber("increment", $detail_modules);
                                                    //027268: 页面设置联系人模块编号设置为必填，导入客户时同时导入联系人信息，导入表格里没有联系人编号，导入客户时候会提示导入表格里面缺少编号。
                                                    $contacts_fieldValuess[$detail_tablename][$detail_focus->table_code]=SystemCode::getPrevStr("Contacts",$contact_id).$contact_id;
                                                }
                                                else{
                                                    //edit:can 20210925 46180: （本地部署）客户问题（邹晓钰），客户导入，同时导入联系人，联系人新建时，联系人编号显示重复（需要补丁）
                                                    $focus->Library('SystemCode')->setModuleSeqNumber('increment','Contacts');
                                                }
                                                if(!in_array($focus->tab_name_index[$module_tablename],$column_is_not_exit)){
													if(is_array($uniqueid))
														$contacts_fieldValuess[$detail_tablename]['accountid']=$uniqueid[$i];
													else
														$contacts_fieldValuess[$detail_tablename]['accountid']=$uniqueid;
                                                }
                                                if(!in_array('smcreatorid',$column_is_not_exit)){//取客户负责人
                                                    if(empty($smownerid_result)){
                                                        $contacts_fieldValuess[$detail_tablename]['smcreatorid']=$smcreatorid;
                                                    }else{
                                                        $contacts_fieldValuess[$detail_tablename]['smcreatorid']=$smownerid_result;
                                                    }
                                                }
                                                if(!in_array('createdtime',$column_is_not_exit)){
                                                    $contacts_fieldValuess[$detail_tablename]['createdtime']=date("Y-m-d H:i:s");
                                                }
                                                if(!in_array('modifiedtime',$column_is_not_exit)){
                                                    $contacts_fieldValuess[$detail_tablename]['modifiedtime']=date("Y-m-d H:i:s");
                                                }
                                                if(!in_array('modifiedby',$column_is_not_exit)){
                                                    $contacts_fieldValuess[$detail_tablename]['modifiedby']=$smcreatorid;
                                                }
                                                //if(!in_array('smownerid',$column_is_not_exit)){ 
                                                    if(empty($smownerid_result)){
                                                        $contacts_fieldValuess[$detail_tablename]['smownerid']=$smcreatorid;
                                                    }else{
                                                        $contacts_fieldValuess[$detail_tablename]['smownerid']=$smownerid_result;
                                                    }
                                               // }
                                                if(!in_array('reference',$column_is_not_exit)){     
                                                    $sql = 'SELECT 1 from ld_contactdetails where reference=1 AND accountid=? ';
                                                    $sql_result=$adb->pquery($sql,array($uniqueid[$i]));
                                                    $nums_sql = $adb->num_rows($sql_result);
                                                    if($nums_sql>0){
                                                        $contacts_fieldValuess[$detail_tablename]['reference']=0;
                                                    }else{
                                                        $contacts_fieldValuess[$detail_tablename]['reference']=1;
                                                    }   
                                                }else{
                                                    $sql = 'SELECT 1 from ld_contactdetails where reference=1 AND accountid=? ';
                                                    $sql_result=$adb->pquery($sql,array($uniqueid[$i]));
                                                    if($nums_sql>0){
                                                        $contacts_fieldValuess[$detail_tablename]['reference']=0;
                                                    }else{
                                                        $contacts_fieldValuess[$detail_tablename]['reference']=1;
                                                    }  
                                                }
                                                $contacts_fieldValuess[$contactTablename][$detail_focus->tab_name_index[$contactTablename]]=$contact_id; 
                                                $adb->pquery($sqlcrmentity,array($contact_id,$detail_modules));
                                               
                                            }
                                            else if($contactTablename==$detail_tablename_scf)
                                            {
                                                $contacts_fieldValuess[$contactTablename]['contactid']=$contact_id;
                                            }
                                         
                                         
                                           
                                            if(!empty($contacts_fieldValuess[$contactTablename]) && !empty($contact_id)){
                                                $adb->pquery($account_sql[$contactTablename],$contacts_fieldValuess[$contactTablename]);
                                                $cls_contact_advance->createModuleAdvanceStage($contact_id);
                                            }
                                            $contacts_fieldValuess=array();   
                                        }     
                                    }
                                }
                                else{
                                    $column_is_not_exit=array();//原来获取所有的columnname，后面原来判断部分字段在导入文件中是否存在
                                    $contact_id=$adb->getUniqueID('ld_crmentity');

                                    foreach($contact_Values as $column_key => $column_values){
                                        $contacts_fieldValuess[$contactTablename][$column_key]=$column_values;
                                        $column_is_not_exit[$contactTablename][$column_key]=$column_key;
                                    }
                                    if($contactTablename == $detail_tablename){
                                       // $sql='update ld_modentity_num set cur_id=cur_id+1 where semodule=?';
//                                            $adb->pquery($sql,array('Contacts'));
                                        if($contacts_fieldValuess[$detail_tablename][$detail_focus->table_code] =='' || empty($contacts_fieldValuess[$detail_tablename][$detail_focus->table_code])){
                                            $No = $detail_focus->Library('SystemCode')->setModuleSeqNumber("increment", $detail_modules);
                                            //027268: 页面设置联系人模块编号设置为必填，导入客户时同时导入联系人信息，导入表格里没有联系人编号，导入客户时候会提示导入表格里面缺少编号。
                                            $contacts_fieldValuess[$detail_tablename][$detail_focus->table_code]=$contact_id;
                                        }
                                        if(!in_array($focus->tab_name_index[$module_tablename],$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['accountid']=$uniqueid[0];
                                        }
                                        if(!in_array('smcreatorid',$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['smcreatorid']=$smcreatorid;
                                        }
                                        if(!in_array('createdtime',$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['createdtime']=date("Y-m-d H:i:s");
                                        }
                                        if(!in_array('modifiedtime',$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['modifiedtime']=date("Y-m-d H:i:s");
                                        }
                                        if(!in_array('modifiedby',$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['modifiedby']=$smcreatorid;
                                        }
                                        if(!in_array('smownerid',$column_is_not_exit)){
                                            $contacts_fieldValuess[$detail_tablename]['smownerid']=$smcreatorid;
                                        }
                                        if(!in_array('reference',$column_is_not_exit)){
                                            $sql = 'SELECT 1 from ld_contactdetails where reference=1 AND accountid=? ';
                                             if(is_array($uniqueid))
                                                $sql_result=$adb->pquery($sql,array($uniqueid[$i]));
                                             else
                                                 $sql_result=$adb->pquery($sql,array($uniqueid));
                                            $nums_sql = $adb->num_rows($sql_result);
                                            if($nums_sql>0){
                                                $contacts_fieldValuess[$detail_tablename]['reference']=0;
                                            }else{
                                                $contacts_fieldValuess[$detail_tablename]['reference']=1;
                                            }
                                            $contacts_fieldValuess[$contactTablename][$detail_focus->tab_name_index[$contactTablename]]=$contact_id;
                                            $adb->pquery($sqlcrmentity,array($contact_id,$detail_modules));
                                        }else{
                                            $sql = 'SELECT 1 from ld_contactdetails where reference=1 AND accountid=? ';
                                            if(is_array($uniqueid))
                                               $sql_result=$adb->pquery($sql,array($uniqueid[$i]));
                                            else
                                               $sql_result=$adb->pquery($sql,array($uniqueid));
                                            $nums_sql = $adb->num_rows($sql_result);
                                            if($nums_sql>0){
                                               $contacts_fieldValuess[$detail_tablename]['reference']=0;
                                            }else{
                                                $contacts_fieldValuess[$detail_tablename]['reference']=1;
                                            }
                                        }
                                    }
                                    $adb->pquery($account_sql[$contactTablename],array($contacts_fieldValuess[$contactTablename]));
                                    $cls_contact_advance->createModuleAdvanceStage($contact_id);
                                    $contacts_fieldValuess=array();

                                    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                                    if($trigger_workflow=='yes'){
                                        $workflowreverseobj_contact = cls_savereverse::getInstance('Contacts');
                                        if(is_array($uniqueid))
                                            $workflowreverseobj_contact->setRecord($uniqueid[$i]);
                                        else
                                            $workflowreverseobj_contact->setRecord($uniqueid);
                                        $beforefieldvalue_arr=[];
                                        $afterfieldvalue_arr=$contacts_fieldValuess[$contactTablename];
                                        $pagemode='creation';
                                        if(!empty($afterfieldvalue_arr)){
                                            $workflowreverseobj_contact->setPageMode($pagemode);
                                            $workflowreverseobj_contact->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                        }
                                    }
                                }
                            }   
                        }
                         
                } 
				
                $tmp_prouctDetail_row=0;
                $uniqueid=array();
                $xlsRowData=array();
                $contact_xlsRowData=array();   
            }
            $tmp_prouctDetail_row++;
            $row++;
        }
      
        $endrow=$row;//明细的行数不是固定的。
        include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $insertIdArr=array();//导入的id
      // echo substr($arr.$CiliangInsert[$key],0,-1);die;
        if (is_array($insertIdArr) && sizeof($insertIdArr)>0) {
            $focus->setFieldDefaultValue($insertIdArr, $currentModule);
        }
       $importdatainfo=$error;
       $smarty->assign("IMPORTINFO",$importdatainfo);
       $smarty->assign('SUCCESSROWS',$successRows);
       $smarty->assign('UPDATEROWS',$updateRows);
       $smarty->assign('TOTALROWS',($shijidaoruRows));
       $smarty->assign('ERRORROWS',($shijidaoruRows-$successRows));
       $smarty->assign('ADDIMPORTROWS',$addimportrows);//成功插入的数据数量
       $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
       $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
      
       if($endrow>=$maxrows&&($addimportrows>0))
       {
                
                //edit:can 20210419 45520: （61mis.com/WX/kh43259）客户管理-客户，操作导入客户之后，新建客户单据编号应是ACC10，但新建显示ACC18
                /*$sql='update ld_modentity_num set cur_id=LPAD((cur_id+?),LENGTH(cur_id),"0") where semodule=? and active=1;';
                if(strtolower($import_type)=='insert'||strtolower($import_type)=='abort')
                {
                    $adb->pquery($sql,array($addimportrows,'Accounts'));
                }
              
                else
                    $adb->pquery($sql,array($updateRows,'Accounts'));*/
                $sql="  insert into ld_accountscf(accountid)   
                 select accountid from ld_account where accountid not in(select accountid from ld_accountscf);";
                 $result=$adb->pquery($sql,array());
                
                
       }
     
       
       if($endrow>=$maxrows)
       {
        
            //edit:can 2021-01-04 044086: （http://akjykj.vicp.cc:85/crm/ [^]）客户问题（安康金源），客户->导入公海未分配客户，公海未分配客户页签中搜索不到导入的客户（中国水电三局安康市岭南液化气有限公司大同中心供气点）
            $sql='select  * from ld_account_public where status="yes" ';
            $tmpresult=$adb->pquery($sql,array());
              
            if($adb->num_rows($tmpresult)>0)
            {
                $sql='update ld_account set pool_id=1 where (publicaccount>=1) and pool_id=0  ';
                $adb->pquery($sql,array());
            }
            //edit:can 20210830 047732: （http://51mis.com.cn/XS/ZKEA [^] [^] [^] [^]）（客户问题-智家）客户-客户名称—黄东方，已34天未联系，客户并未被回收，公海回收规则无效
            $sql='update ld_account set allocatedate=createdtime where allocatedate is null or allocatedate="" ';
            $adb->pquery($sql,array());
       }
     
        $_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"].=$error;
 
       $tmp['timedescription']=$time_description;
       $tmp['cur_progress_step']=$cur_progress_step;
       $tmp['endimporttime']=$endimporttime;
       $tmp['endrow']=$endrow-1;
       ConvertTojsonString(1,$tmp,'success');
}


?>