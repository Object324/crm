<?php
 set_time_limit(0);

global $adb,$current_user,$app_currency_strings;
require('user_privileges/user_language_'.$current_user->id.'.php');
if(file_exists($root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
    include($root_directory."dataCache/Login/zh_cn_version_new.lang.php");
}else{
    include($root_directory."include/language/zh_cn_version.lang.php");
}
$currentModule=$_REQUEST['return_module'];

if(isPermitted("Users","Import")=='no')
{
    exit("无权限");
}
if(empty($currentModule)){
   $currentModule=$_REQUEST['module']; 
}

$smarty = new lingdangCRM_Smarty();
$modulelabe = getTranstab($currentModule);
$moduleid = getTabid($currentModule);
setGLobalURLSmarty($smarty);//js,css的加载url
$smarty->assign('CATEGORY',getParentTab($modulelabe));
$smarty->assign('MODULELABEL',$modulelabe);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$xlsStep=$_REQUEST['xlsStep']; //获取导入步骤



if($xlsStep=='First'){
    //选择导入文件
    $smarty->display("ImportXls/FirstStep.tpl");
}elseif($xlsStep=="Second"){
    //第二步,导入界面2字段映射
    foreach($_FILES['ImportXlsFile'] as $key1=>$value1){
        $filenamess=$_FILES['ImportXlsFile']['name'];//获取导入文件的名称
    }   
        $filetype =pathinfo($filenamess, PATHINFO_EXTENSION);//获取导入文件的后缀名
        $pathname="storage/".$current_user->id.'_'.$currentModule.".".$filetype;

         if(isset($_FILES['ImportXlsFile'])){
             if($_FILES['ImportXlsFile']['error'] != UPLOAD_ERR_OK){
                echo "alert('引入文件上传失败！')";
                exit();
             }else{
                if(file_exists("storage/".$current_user->id.'_'.$currentModule.".".$filetype)){
                    $result = @unlink ("storage/".$current_user->id.'_'.$currentModule.".".$filetype);
                        if($result==false){
                             echo "删除文件失败！";
                             exit();
                        }
                    }
                move_uploaded_file($_FILES['ImportXlsFile']['tmp_name'] , $pathname);  
              }  
         }
        $cachekey = 'importtabid_'.$moduleid;
        $moduleImport = CacheDirectory($cachekey,'Cache');
        
        if($filetype=='xlsx'){$inputFileType = 'Excel2007';} else{$inputFileType = 'Excel5';}
            
        $inputFileName = $pathname;
        crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
         //获取主表字段
        $sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
            ld_field.columnname,tablename ,ld_field.fieldname,ld_field.is_checkimportfield
            from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
            inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
            inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
            where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
            and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
            and presence in(0,2)   and ld_blocks.visible=0
            order by ld_blocks.sequence, ld_field.sequence asc ';
        
        $relsert = $adb->pquery($sql,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));
        $defaultvalueHtml='';
        $importcolumn=array();
        $drophtml=array();
        $sessionMainfield=array();
        $importcolumn[]=array(0,'none-field','--无--');
        
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
                        ,'accountallview','groupid','profileid','approvestatus','approveby');
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
    $tmpk=0;
    for($i=0;$i<$adb->num_rows($relsert);$i++)
    {
         $uitype=$adb->query_result($relsert,$i,'uitype');
         $columnname=$adb->query_result($relsert,$i,'columnname');
         $fieldname=$adb->query_result($relsert,$i,'fieldname');
         if(in_array($fieldname,$modulenoshowfields['Users']))
         {
            continue;
         }
         $fieldLabel=($adb->query_result($relsert,$i,'fieldlabel'));
         $typeofdata=$adb->query_result($relsert,$i,'typeofdata');
         $tablename=$adb->query_result($relsert,$i,'tablename');
         
         $is_checkimportfield = $adb->query_result($relsert,$i,'is_checkimportfield');
         $sessionMainfield[$tmpk]['uitype']=$uitype;
         $sessionMainfield[$tmpk]['columnname']=$columnname;
         $sessionMainfield[$tmpk]['fieldlabel']=$fieldLabel;
         $sessionMainfield[$tmpk]['typeofdata']=$typeofdata;
         $sessionMainfield[$tmpk]['tablename']=$tablename;
         $sessionMainfield[$tmpk]['is_checkimportfield']=$is_checkimportfield;
         $typedata=explode('~',$typeofdata);
         if($typedata[1]=='M'||$uitype==4)
         {
            $fieldLabel.='*';
         }
         if($uitype==15 ||$uitype==33)
         {
            $profileid=$current_user->profileid;
           //  crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
	        $picklistdrop = getAssignedPicklistValues($fieldname, $profileid, $adb);
            $drophtml[$columnname.'-field']=$picklistdrop;
         }
         $importcolumn[]=array($uitype,$columnname.'-field',trim($fieldLabel));
         $tmpk++;
    }
        $_SESSION['mainfieldUsers']=$sessionMainfield;
        $selcolumnName=array();
        include 'PHPExcel/PHPExcel/IOFactory.php';
    
        $objReader = PHPExcel_IOFactory::createReader($inputFileType);
    
        $objPHPExcel = PHPExcel_IOFactory::load($inputFileName);
    
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
        if($objvalue0=="")
        {
            break;
        }

        $objvalue1= trim($objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue());  
        
        
        
        foreach($importcolumn as $cols)
        {
            if(in_array($objvalue0,$cols)||in_array($objvalue0.'*',$cols))
            {
                $uitype=$cols[0];
                $columnname=$cols[1];
                $selcolumnName[$columnname]='';
               
            }
        }
  
        $objstr[$col]=array($objvalue0,$objvalue1,$uitype,$columnname);  
    } 
    
        $main_focus=CRMEntity::getInstance($currentModule);

        //获取明细文件缓存中的查重字段             
        $cache_columnname = explode(',',$moduleImport['select']);
        $defaultCheckField='';
     
        $defaultCheckField="user_name";
        
        $modulefieldblocks= $main_focus->fieldobj->getBlockVisibleInfos();
         foreach($modulefieldblocks as $blockid=>$blockinfo)
         {
            //删除没有字段的区块
            $blockfield='no';
            if($blockinfo['label']=='LBL_USERLOGIN_ROLE')
               {
                     foreach($main_focus->fieldobj->getModuleFields() as $index=>$fieldinfo)
                    {
                        if($fieldinfo->getColumnName()=="user_name")
                        {
                            $blockfield='yes';
                            $select[0]['blockid']=$blockid;
                            $select[0]['fieldlabel']=$fieldinfo->getFieldLabel();
                             $select[0]['columnname']=$fieldinfo->getColumnName();
                            break;
                        }
                    }
                 if($blockfield=='yes')
                {
                    $blocks[]=$blockinfo;
                }
            
            }
            
           
         }
        
         $smarty->assign("MODULEFIELDBLOCKS",$blocks);
         $smarty->assign("JSONMODULEFIELDBLOCKS",json_encode($blocks));
         $i=0;
        $smarty->assign('FILETYPE',$filetype);
    
        $smarty->assign('SELECTCOLUMNS',$select);//查重字段
        $smarty->assign('JSONSELECTCOLUMNS',json_encode($select));
        $checkselect_column[]=array('column'=>"user_name",'condition'=>'or');
        $smarty->assign('CHECKEDCOLUMNS',$checkselect_column);
        $smarty->assign('IMPORTCOLUMN',$importcolumn);//所有字段数组
        $smarty->assign('SELCOLUMN',$selcolumnName);//导入字段数组
        $smarty->assign('DROPHTML',$drophtml);//下拉框数组
        $smarty->assign('IMPORTDATA',$objstr);//Excel标题数组
        //29987: 单据>列表：选择重复时导入方式，不记住上次的选择，一直显示默认值“跳过”
        $smarty->assign('IMPORTCHOOSE','Abort');
        $smarty->display("ImportXls/SecondStep.tpl");   
         
}elseif($xlsStep=="Third"){
    $regop=RegOp::getInstance();
    $registercount= $regop->GetUserCount();
    crm_load_function_file("createUserPrivilegesfile","modules/Users","CreateUserPrivilegeFile");
        include(globalStatic::$root_directory.'modules/XlsImport/ImportSModule.php');
		static $db_checkValues;	//查重信息
        
        $page_width= $_SESSION['bodywidth'];
        $smarty->assign("PAGEWIDTH",$page_width);
       $smarty->display("ImportXls/importProgress.tpl");
        
        //这里开始处理数据并且导入
        //$_SESSION[$currentModule]['importXls']['count']
        $start_importxl_row_index=1;
      
        $mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
   	    $mapfieldsname = json_decode($_REQUEST['isfieldname']);//导入的字段名称
      	$mapfieldsnamevalue = json_decode($_REQUEST['isfieldnamevalue']);//导入的字段名称对应值
        $totalcolumns=sizeof($mapfields);
    	$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
        //主表字段
        $result=  $_SESSION['mainfieldUsers'];//数组
        $error='';//错误信息
        $currentModule=$import_module = $_REQUEST['importmodel'];
        
        $smarty->assign("IMPORTMODULE",$import_module);
        $importcolumn=array();
        $main_focus=CRMEntity::getInstance($currentModule);
        $field_tables[$main_focus->table_name]=array();//主表导入字段
        $field_columns_only=array();//唯一字段
        $codeIndex=0;//编号在xls文件中列索引
        $quantitIndex=0;
        $listpriceIndex=0;
        $findcodenum=false;
        $nohaveerror=true;
        $fieldcolIndex=0;
        $userarr=array();//用户集合

        $moduleid = getTabid($currentModule);
    
         $importcolumnname_index=array("user_name"=>"-1","status"=>"-1", "smcreatorid"=>"-1",'is_admin'=>'-1',"user_password"=>"-1","confirm_password"=>"-1");//导入字段在excel中的列位置
     
        $moduleImport['choose'] = $_REQUEST['choose'];

        $cachekey = 'importtabid_'.$moduleid;
        
        CacheDirectory($cachekey,'Cache',$moduleImport);
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
        $checkimportfield="user_name";//查重字段
        $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
       
        $importdupfields_condition="";//查重字段条件
        
            
        $fieldlabel_dup_tip=trim($fieldlabel_dup_tip,$conditionlabel);
   
        for($i=0;$i<sizeof($result);$i++)
        {
              
                 $uitype=$result[$i]['uitype'];
                 $columnname=$result[$i]['columnname'];
                
                 $tablename=$result[$i]['tablename'];
              
                 $typeofdata=$result[$i]['typeofdata'];
                 $fieldLabel=$result[$i]['fieldlabel'];
                 $typedata=explode('~',$typeofdata);
                // $is_checkimportfield=$result[$i]['is_checkimportfield']; //是否导入字段
                 $smcreatorid=$current_user->id;
    
                 if($typedata[1]=='M'&&$uitype!=4)//修改系统编号为非必填
                 {
                    if(!in_array($columnname.'-field',$mapfields))
                    {
                         $error.='导入文件中缺少'.$fieldLabel.'列<br>';
                         //break;
                    }
                 }
                 if($code_num_columnname!=''){
                     if(!in_array($code_num_columnname.'-field',$mapfields)){
                         $onlytablename = $tablename;
                     }
                 }
                 if(in_array($columnname.'-field',$mapfields))
                 {
                   
                    //$contactfield_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
                    $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
                    $fieldcolIndex++;
                      if(array_key_exists("$columnname",$importcolumnname_index))
                      {
                        $importcolumnname_index[$columnname]=array_search($columnname.'-field',$mapfields);
                      }
                     
                 }
        }
       
        if($importcolumnname_index['user_password']=="-1"&&$importcolumnname_index['confirm_password']>=0)
        {
            $fieldLabel=$main_focus->fieldobj->getFieldInfoBykeyValue("columnname",'user_password','fieldlabel');
            $error.='导入文件中缺少'.$fieldLabel.'列<br>';
        }
        if($error!=''){
            
           // if($_REQUEST['getcount']=='getcount'){echo "##SUCCESS##".'1';exit();}
                $false = true;
               $smarty->assign('FALSE',$false);
               $smarty->assign("IMPORTINFO",$error);
               $smarty->display("ImportXls/ThirdStep.tpl");
                $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
                 fwrite($filehandler,str_replace('<br>',"\r\n",$error));
                fclose($filehandler);
               exit();
        }else{
               
               $filetype = $_REQUEST['xlsfiletype'];
              
               $focus=$main_focus;
                if($filetype=='xlsx'){
                    $inputFileType = 'Excel2007';      
                }else{
                    $inputFileType = 'Excel5';
                }
                
                $inputFileName = 'storage/'.$current_user->id.'_'.$import_module.'.'.$filetype;
                require_once('PHPExcel/PHPExcel/IOFactory.php') ;
                $objReader = PHPExcel_IOFactory::createReader($inputFileType);
              
                $objPHPExcel = $objReader->load($inputFileName);
                $objPHPExcel->setActiveSheetIndex(0);
                $objWorksheet = $objPHPExcel->getActiveSheet();
                 $AccountDeskstr=array();
                $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
                $addimportrows=0;
                $successRows=0;//成功导入的数目
                $updateRows=0;//成功覆盖数据的数目
                $Importoop = new Import_Xls($importcolumnname_index,$objWorksheet);
                if($_REQUEST['getcount']=='getcount'){
                    echo "##SUCCESS##".count($highestRow);exit();
                }
                if(sizeof($highestRow)<2){
                    $error .='模板文件中没有数据，导入失败！'.'<br>'; 
                    $successRows =0;
                    $updateRows=0;
                    $importdatainfo=$error;
                    $false=true;
                    $smarty->assign('FALSE',$false);
                    $smarty->assign("IMPORTINFO",$importdatainfo);
                    $smarty->display("ImportXls/ThirdStep.tpl"); 
                    exit(); 
                }
                $highestColumn = $objWorksheet->getHighestColumn();
                $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
                $startimporttime=date("Y-m-d H:i:s");
                
                
              
                $insert_columname = array();
                $insert_values = array();
            
                foreach($field_tables as $tablename=>$colinfo)
                {
                    
                     foreach($colinfo as $ky=>$colnames)
                     {
                         if($colnames[0]=='confirm_password')//密码确认列不用导入
                         {
                            continue;
                         }
                        $insert_columname[$tablename][] = $colnames[0];
                     }
                    if(strtolower($tablename)==$focus->table_name){
                        if(!in_array('is_admin',$insert_columname[$tablename])){
                            $insert_columname[$tablename][] = 'is_admin'; 
                        }
                        if(!in_array('user_password',$insert_columname[$tablename])){
                            $insert_columname[$tablename][] = 'user_password'; 
                        }
                        if(!in_array('status',$insert_columname[$tablename])){
                            $insert_columname[$tablename][] = 'status'; 
                        }
                        if(!in_array('approvestatus',$insert_columname[$tablename])){
                            $insert_columname[$tablename][] = 'approvestatus'; 
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
                        if(!in_array('modifiedby',$insert_columname[$tablename])){
                            $insert_columname[$tablename][] = 'modifiedby'; 
                        }
                        
                        
                     }
                     $insert_columname[$tablename][] = $focus->tab_name_index[$tablename]; 
                     foreach($insert_columname as $tablename => $column_fields){
                          
                              $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;  
                             
                     }
                 }
                 
                 
                    $columnname = array();
                    $insertvalue = array();
                    
                    $row=2;
                    $prevRowIndex=2;
                    $nohaveerror=true;
                    $totalRows=0;//总共导入数据
                    $codenum=0;
                    $hangshu=0;
                    $g=0;
                    $test =array();
                    $module_tablename=$focus->table_name;//单据主表
                    $module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
                    $current_user_name = $current_user->last_name;
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
                    while(true)
                    {
                        $hangshu++;
                         $totalRows++;
                         $nohaveerror=true;
                         $xlsRowData=array();
                         $st = array();
                         $flag = true;

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
                            if($excel_value!='')
                            {
                              
                                break;
                            }
                        }
                        
                        if($excel_value=='')
                        {
                            $totalRows=$row-1;
                            $highestRow=$row-1;
                            break;
                        }
                        
                         if($code_num_columnname!='')
                         {
                         
                                $checkcodenum=trim((string)$objWorksheet->getCellByColumnAndRow($codeIndex, $row)->getValue());
                                if($checkcodenum!='')
                                    $checkcodenum=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$checkcodenum);
                                //$checkcodenum=addslashes($checkcodenum);
                            if($checkcodenum==''){
                                $g=1;
                            }else{
                                $codenum=$checkcodenum;
                            }
                         }
                         
                            $uniqueid=$adb->getUniqueID('ld_users');
                            $xlsRowData=array();
            
   
                         foreach($field_tables as $tablename=>$colinfo)
                         {     
                            foreach($colinfo as $ky=>$colnames)
                            {
                                $typedata=explode('~',$colnames[2]);
                                $fieldcolIndex=$colnames[3];
                                if($colnames[0]=='confirm_password')
                                {
                                    //密码确认
                                    continue;
                                }
                                $colname=$colnames[0];
                                $uitype=$main_focus->fieldobj->getFieldInfoBykeyValue('columnname',$colname,'uitype');

                                $fieldLabel=$colnames[4];
                                //$is_checkimportfield=$colnames[5];
                                $str=trim((string)$objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getValue());
                                // $str=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$str);
                                //$str=addslashes($str);
                                $uname = getUserFullName($current_user->id);
                                if($str=='')
                                {
                                    $str=trim($defaultvalue[$colnames[0].'-field-defaultvalue']);//获取默认值
                                    $test[]=$str;
                                
                                }
                                if($typedata[0]=='D'&&$typedata[1]=='M'){
                                    
                                    if($str ==''){
                                        $str=NULL;
                                    }else{
                                         if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                                            $str= date('Y-m-d',PHPExcel_Shared_Date::ExcelToPHP($str));  
                                         }             
                                    }  
                                }
                                if($typedata[0]=='D'&&$typedata[1]!='M'){
                                    if($str==''){
                                        $str=NULL;
                                    }else{
                                         if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                                            $str= date('Y-m-d',PHPExcel_Shared_Date::ExcelToPHP($str));  
                                         }               
                                    }  
                                }
                                
                                
                                if($typedata[0]=='DT'&&$typedata[1]=='M'){
                                    if($str ==''){
                                        $str=NULL;
                                    }else{
                                        if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                                            $str= date('Y-m-d H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));  
                                        }              
                                    }    
                                }
                                if($typedata[0]=='DT'&&$typedata[1]!='M'){
                                    if($str==''){
                                        $str=NULL;
                                    }else{
                                        if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                                            $str= date('Y-m-d H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));  
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

                                if($typedata[0]=='N'&&$str!=''&&!is_numeric($str))
                                {
									$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
									if(!is_numeric($str))
									{
										$error.='第'.$row.'行"'.$objWorksheet->getCellByColumnAndRow($fieldcolIndex, 1)->getValue().'"列内容为非法数字!<br>';
										$nohaveerror=false;
									}
                                }
                                if($typedata[0]=='N'&&$str=='')
                                {
                                    $str=NULL;
                                }

                               
                                if($typedata[0]=='NN'&&$str=='')
                                {
                                    $str=NULL;
                                } 
                              
                                if($importcolumnname_index['user_password']>0&&$fieldcolIndex==$importcolumnname_index['user_password']&&$importcolumnname_index['confirm_password']>0)
                                {   //密码和密码确认的值不相等
                                    if($objWorksheet->getCellByColumnAndRow($importcolumnname_index['user_password'], $row)->getValue()!=$objWorksheet->getCellByColumnAndRow($importcolumnname_index['confirm_password'], $row)->getValue())
                                    {
                                        $error.='第'.$row.'行"'.$objWorksheet->getCellByColumnAndRow($importcolumnname_index['user_password'], 1)->getValue()."和".
                                        $objWorksheet->getCellByColumnAndRow($importcolumnname_index['confirm_password'], 1)->getValue()
                                        .'"的值不相等!'."<br>";
                                        $nohaveerror=false;
                                    }
                                }
                                
                               //获取导入列值
                                $str=$Importoop->setImprtNameToId($colnames[1],$str,$row);
                                
                                if($str == ''  && $typedata[1]=='M'&&$uitype!=4){
                                   
                                    $error.='第'.$row.'行"'.$objWorksheet->getCellByColumnAndRow($fieldcolIndex, 1)->getValue().'"列值为空或在数据库中不存在!<br>';
                                    $nohaveerror=false;
                                }else{
                                    if(strtolower($typedata[0]) == 'i'){
                                        if(empty($str)) $str = 0;
                                    }
                                    if($colname=='user_password')
                                    {
                                        $main_focus->column_fields["user_name"]=$objWorksheet->getCellByColumnAndRow($importcolumnname_index['user_name'], $row)->getValue();
                                        $str=$main_focus->encrypt_password($objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getValue(),"MD5");
                                        
                                        
                                    }
                                    if($colname=='user_name')
                                    {
                                        $main_focus->column_fields['user_name']=$str;
                                    }
                                    if($colname=='is_admin')
                                    {
                                            if($str==getFixedLabel("YES"))
                                            {
                                                $str="on";
                                            }
                                            else
                                            {
                                                $str="off";
                                            }
                                    }
                                    if($colname=='status')
                                    {
                                            if($str==getFixedLabel("Job"))
                                            {
                                                $str="Active";
                                            }
                                            else
                                            {
                                                $str="Inactive";
                                            }
                                    }
                                  $values[] = $str;
                                  $xlsRowData['maintable'][$tablename][$colnames[0]]=$str;
                                }

                            }
                                
                         }    
                         if($nohaveerror==false)
                         {                          
                             $row++;
                             continue;
                         }
                          if($g!=0){
                            //$codenum++;
                         }
						$progress_step=$page_width/$maxrows;
                        $cur_progress_step=$row*$progress_step;
                        if($cur_progress_step>$page_width)
                        {
                            $cur_progress_step=$page_width;
                        }
                        if($row%5==0||$row==2)
                        {
                            $endimporttime=date("Y-m-d H:i:s");
                          
                            $between_seconds=DateOperation::sencods_between_time($endimporttime,$startimporttime);
                            
                            $Average_time=$between_seconds/$row;
                            $balance_import_rows=$maxrows-$row;
                            $balance_time=round($Average_time*$balance_import_rows);
                            $totalseconds=round($maxrows*$Average_time);
                            if($totalseconds<60)
                            {
                                $time_description="共耗时".$totalseconds.'秒,';
                            }
                            else if($totalseconds>=3600)
                            {
                                $time_description="共耗时".round($totalseconds/3600).'小时,';
                            }
                            else
                            {
                                 $time_description="共耗时".round($totalseconds/60).'分钟,';
                            }
                            if($balance_time<60)
                            {
                                $time_description.="大约还需要".$balance_time."秒完成数据导入";
                            }
                            else if($balance_time>=3600)
                            {
                                $time_description.="大约还需要".round($balance_time/3600)."小时完成数据导入";
                            }
                            else
                            {
                                $time_description.="大约还需要".round($balance_time/60)."分钟完成数据导入";
                            }
                        }
                        echo '<script> 
                        document.getElementById("dvctimedescription").innerHTML="'.$time_description.'"
                         document.getElementById("dv").innerHTML="'.$row.'/'.($maxrows-1).'";
                         document.getElementById("dvImportprogress").style.width = "'.$cur_progress_step.'px"</script>';
                         ob_flush(); 
                         flush(); 
                    
                     
                  
                    //下面开始导入数据
					$temp=array();
					$_uniqueid=array();
					$_checkdupValues=array();
					$_checkColumn='';////不要等于array,如果等于arra()且查重字段的值为空会有bug
					$_checkValues=array();
					$_checkCondition=array();
					if($import_type!="Insert"){ //查重判断
						 foreach($xlsRowData as $main => $values_one){
							 $temp =$values_one;
							 foreach($is_checkimportfield as $index=>$columnname)
							 {
								if($columnname != ''){
									 $tablename=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'tablename');
									 if($values_one[$tablename][$columnname]!='')
									 {
										 $_checkColumn[]=$columnname;
										 $_checkdupValues[] = $values_one[$tablename][$columnname];
										  if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
										  {
												$importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('columnname',$is_checkimportfield[$index+1]);
												$importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
												if($xlsRowData[$importcolumntablename][$is_checkimportfield[$index+1]]!='')
													$_checkCondition[$columnname]=$importdupfields_condition[array_search($columnname,$is_checkimportfield)];
												else
													break;
										  }
										  else
										  {
												$_checkCondition[$columnname]=$importdupfields_condition[array_search($columnname,$is_checkimportfield)];
										  }
										  //$_checkCondition[$columnname]=$importdupfields_condition[array_search($columnname,$is_checkimportfield)];
									 }
								}
								 
							 }
						 }
						  
						  
						//进行查重
						$main_table_sql = 'SELECT '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].' as id from '.$module_tablename.'  LEFT JOIN
						'.$module_tablename_scf.' on '.$module_tablename_scf.'.'.$focus->tab_name_index[$module_tablename] .' = '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].'';
						$main_table_sql .=" where (   "; 
						$dupcheckfield_len=sizeof($_checkColumn);
						$tmp_dupcheckfield=0;
						if($dupcheckfield_len>0&&is_array($_checkColumn))
						{
							foreach($_checkColumn as $index=>$tmp_columnname)
							{
								$main_table_sql.= "  $tmp_columnname= ?  ";
								if($_checkCondition[$tmp_columnname]!=""&&$tmp_dupcheckfield!=$dupcheckfield_len-1)
								{
									$main_table_sql.=$_checkCondition[$tmp_columnname];
								}
							}
							$main_table_sql.=" ) ";
							$check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
							$num_rows = $adb->num_rows($check_result);   
						}
						else
						{
							$num_rows=0;
						}
					}
                        $fieldlabel_dup_tip=$main_focus->fieldobj->getFieldInfoBykeyValue("columnname",$checkimportfield,'fieldlabel');
                        
					if($num_rows>0&&$import_type=='Abort'){
						$xlsRowData=array();
						$error .="第".$row."行$fieldlabel_dup_tip 重复，已做跳过处理!"."<br>";
						$flag = false;
					}   
                    $sql="select 1 from ld_users where status='active'  ";
                    $user_result_count=$adb->pquery($sql,array());
                    $softuserCount=$adb->num_rows($user_result_count)+1;
                    $registerFileUserCount=$regop->GetUserCount();
                   /* if($regop->compareCount($registerFileUserCount,$softuserCount)<=0)
                    {
                        $xlsRowData['maintable']["ld_users"]["status"]='Inactive';
                    }*/
                    if($flag == true){   
                        /*--Update begin--*/
                        if($num_rows > 0 && $import_type=='Update'){
							$updateValues=array();
							$updateColumns=array();
                       
                            foreach($temp as $t_table => $t_files_values){
                                foreach($t_files_values as $t_files =>$t_values){
                                    if($t_values!=''){//
                                        $updateColumns[$t_table][$t_files] = $t_files;
                                        $updateValues[$t_table][$t_files] = $t_values;
                                    }
                                }
                            }
                          
                           // $main_focus->getModuleStatic('ModTracker');
                          
                            //覆盖脚本
                            for($j=0;$j<$num_rows;$j++)
                            {
								$_uniqueid=$adb->query_result($check_result,$j,'id'); 

								$main_focus->id=$_uniqueid;
							//	$main_focus->modstatic->init($main_focus,$main_focus->module_name);//记录覆盖导入日志
                               
                                foreach($updateColumns as $tablename => $updatecolumnnames){
                                  
                                    foreach($updatecolumnnames as $updatecolumn)
                                    {
                                        if(!empty($updateValues[$tablename][$updatecolumn]))//等于零不考虑了
                                        {
                                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                            if(!$fieldinfo)
                                            {
                                                continue;
                                            }
                                            
                                             $query = 'update ' . $tablename . ' set ' . $updatecolumn . '=?' . ' where ' . $focus->tab_name_index[$tablename] . ' =?  '; 
                                             $adb->pquery($query,array($updateValues[$tablename][$updatecolumn],$_uniqueid));
										     createUserPrivilegesfile($_uniqueid);
                                        }
                                    }
                                }
                                
                              //  $main_focus->modstatic->triggerEvent($main_focus->module_name);
                                $updateRows++;
                            }
                            if($num_rows>0)
                            {
                                $successRows++;
                            }
                            
                            $updateColumns=array();
                            $updateValues=array();
                        }
		
						if(empty($num_rows)  || $num_rows< 1 || $import_type =='Insert'){
							$addimportrows++;
							foreach($xlsRowData as $main => $values_one){
								foreach($values_one as $inert_tablename => $insert_files_values){
									 $st = ''; 
									if(strtolower($inert_tablename)==strtolower($module_tablename)){
										$k ='';
										foreach($insert_files_values as $key => $value){
											if(!empty($value)){
												  $k[] = $key;
											}
										  
										} 
                                        if(!in_array('is_admin',$k))
                                        {
                                           
                                            $st['is_admin']='off';
                                        }  
                                        if(!in_array('user_password',$k))
                                        {
                                           
                                            $fldvalue = $main_focus->encrypt_password("", "MD5");
                                            $st['user_password']=$fldvalue;
                                        }
                                         if(!in_array('status',$k))
                                        {
                                           
                                            $st['status']="Active";
                                           
                                        }
                                         if(!in_array('approvestatus',$k))
                                        {
                                            $st['approvestatus']="1";
                                        }
										if(!in_array('smcreatorid',$k)){
											$st['smcreatorid']=$smcreatorid;
										}
										if(!in_array('createdtime',$k)){
											$st['createdtime']=date("Y-m-d H:i:s");
										}
										if(!in_array('modifiedtime',$k)){
											$st['modifiedtime']=date("Y-m-d H:i:s");
										}
										if(!in_array('modifiedby',$k)){
											$st['modifiedby']=$smcreatorid;
										}
									
									   
									}
                                       
									$st['id']=$uniqueid;//获取crmid
                                   
							          if($inert_tablename=='ld_users'&&$regop->compareCount($registerFileUserCount,$softuserCount)<=0)
                                        {
                                                $st["status"]='Inactive';
                                               
                                        }
									$insert_value = array_merge($insert_files_values, $st);//拼接数组
								      
									$adb->pquery($field_sql[$inert_tablename],array($insert_value));
								    
                                    createUserPrivilegesfile($uniqueid);
									$insert_value=array();  
								}
								$successRows++;
							}
							
						}
					}
                    $row++;
                    //exit();
			}  
            //exit();
            $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
            
            $accountfocus=new $import_module();           
            $accountfocus->setFieldDefaultValue($insertIdArr,$import_module);
            $importdatainfo=$error;
            if($error=="")
            {
                $error='<br>';
            }
            fwrite($filehandler,str_replace('<br>',"\r\n",$error));
            fclose($filehandler);
            $smarty->assign("HANGSHU",$hangshu-1);
            $smarty->assign("IMPORTINFO",$importdatainfo);                  
            $smarty->assign('SUCCESSROWS',$successRows);
            $smarty->assign('ADDIMPORTROWS',$addimportrows);
            $smarty->assign('UPDATEROWS',$updateRows);
            $smarty->assign('TOTALROWS',($totalRows-1));
            $smarty->assign('ERRORROWS',($totalRows-1-$successRows));
       
           $smarty->display("ImportXls/ThirdStep.tpl");
            exit();
    }
}
?>