<?php
global $currentModule,$adb,$current_user;
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
$regop=RegOp::getInstance();
$registercount= $regop->GetUserCount();
crm_load_function_file("createUserPrivilegesfile","modules/Users","CreateUserPrivilegeFile");
       
static $db_checkValues;	//查重信息
   $focus=new Users();   

        
        //这里开始处理数据并且导入
        //$_SESSION[$currentModule]['importXls']['count']
        $start_importxl_row_index=1;
      
        $mapfields=json_decode($_REQUEST['mapped_fields'],true);//导入字段
   	    $mapfieldsname = json_decode($_REQUEST['isfieldname']);//导入的字段名称
      	$mapfieldsnamevalue = json_decode($_REQUEST['isfieldnamevalue'],true);//导入的字段名称对应值
        $totalcolumns=sizeof($mapfields);
    	$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
        //主表字段
        $result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id.'_fields'];//数组;//数组
        $error='';//错误信息
       
        
     
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
    
         $importcolumnname_index=array("user_name"=>"-1","status"=>"-1"
                , "smcreatorid"=>"-1",'is_admin'=>'-1',"user_password"=>"-1","confirm_password"=>"-1"
                ,'groupid'=>'-1'
                );//导入字段在excel中的列位置
     
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
        $_REQUEST['diony']='yes';
        
        if($error!=''){
            
           // if($_REQUEST['getcount']=='getcount'){echo "##SUCCESS##".'1';exit();}
                $false = true;
              ConvertTojsonString("-1",array(),$error);
              
        }else{
               
                $filename=$_REQUEST['filename'];
               $filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名
                
                $inputFileName = 'storage/'.$current_user->id.'_'.$import_module.'.'.$filetype;
                require_once('PHPExcel/PHPExcel/IOFactory.php') ;
              
                 $AccountDeskstr=array();
               $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];
                $addimportrows=0;
                $successRows=0;//成功导入的数目
                $updateRows=0;//成功覆盖数据的数目
               
             
                if(sizeof($highestRow)<2){
                    $error .='模板文件中没有数据，导入失败！'.'<br>'; 
                    ConvertTojsonString("-1",array(),$error); 
                    exit(); 
                }
                 $highestColumnIndex=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex'];//总列数
                
             
              
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
                    
                  
                    $prevRowIndex=2;
                    $nohaveerror=true;
                    $totalRows=0;//总共导入数据
                    $codenum=0;
                    $hangshu=0;
                    $g=0;
                    $test =array();
                     $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
                    $startrow=$_REQUEST['startrow'];
                    $endrow=$_REQUEST['endrow'];
                    $module_tablename=$focus->table_name;//单据主表
                    $module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
                    $current_user_name = $current_user->last_name;
                  $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];//导入的总行数
                  $Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);
                   
                    for($row=$startrow;$row<=$endrow;$row++)
                    {
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']+1;
                          
                         $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                         
                         $nohaveerror=true;
                         $xlsRowData=array();
                         $st = array();
                         $flag = true;
                         $groupids="";
                        if($row>=$maxrows)//如果超过xls文件行数则退出循环
                         {
                            break;
                         }
                         $excelrow=$row+2;
                         if(!array_key_exists($excelrow,$highestRow))
                         {
                            
                            continue;
                         }
                         
                      
                       
                         
                          
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
                                $str=trim((string)$importdatas[$row][$fieldcolIndex]);
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
									//$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
									if(!is_numeric($str))
									{
										$error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
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
                                    if($importdatas[$row][$importcolumnname_index['user_password']]!=$importdatas[$row][$importcolumnname_index['confirm_password']])
                                    {
                                        
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['user_password']]."和".
                                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['confirm_password']]
                                        .'"的值不相等!'."<br>";
                                        $nohaveerror=false;
                                    }
                                }
                               
                               //获取导入列值
                                $str=$Importoop->setImprtNameToId($colnames[1],$str,$row);
                                if($fieldcolIndex==$importcolumnname_index['groupid'])
                                {
                                    $groupids=$str;
                                }
                                if($str == ''  && $typedata[1]=='M'&&$uitype!=4){

                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                                    $nohaveerror=false;
                                }else{
                                    if(strtolower($typedata[0]) == 'i'){
                                        if(empty($str)) $str = 0;
                                    }
                                    if($colname=='user_password')
                                    {
                                        $main_focus->column_fields["user_name"]=$importdatas[$row][$importcolumnname_index['user_name']];
                                        $str=$main_focus->encrypt_password($importdatas[$row][$fieldcolIndex],"MD5");


                                    }
                                    if($colname=='user_name')
                                    {
                                        //wym 240430 BUG20240429-22 成员管理--导入的时候没有控制账号不允许使用中文(只有字母,数字,下划线)，导致客户可以创建，创建后无法正常登录
                                        //zkt 20240911 BUG20240911-27 成员管理导入时不能用@和.但是直接在系统里新建是可以的
                                        if(preg_match('/^[a-zA-Z0-9_@.]+$/', $str)){
                                            $main_focus->column_fields['user_name']=$str;
                                        }else{
                                            $error.='第'.$excelrow.'行用户账号只能由字母、数字、下划线组成，不能输入其他特殊符号！';
                                            $nohaveerror=false;
                                        }
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
                             
                             continue;
                         }
                          if($g!=0){
                            //$codenum++;
                         }
						
                     
                  
                    //下面开始导入数据
					$temp=array();
					$_uniqueid=array();
					$_checkdupValues=array();
					$_checkColumn=array();////不要等于array,如果等于arra()且查重字段的值为空会有bug
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
						if($dupcheckfield_len>0&&is_array($_checkColumn)&&$_checkColumn[0]!='')
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
						$error .="第".$excelrow."行$fieldlabel_dup_tip 重复，已做跳过处理!"."<br>";
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
										     
                                             if(!empty($groupids))
                                             {
                                                $sql='delete from ld_users2group where userid=?';
                                                $adb->pquery($sql,array($_uniqueid));
                                                $arr_groupids=explode(",",$groupids);
                                                  foreach($arr_groupids as $tmpgroupid)
                                                  {
                                                    if(empty($tmpgroupid))
                                                    {
                                                        continue;
                                                    }
                                                    $sql='insert into ld_users2group (userid,groupid)value(?,?)';
                                                    $adb->pquery($sql,array($_uniqueid,$tmpgroupid));
                                                }
                                                
                                             }
                                             createUserPrivilegesfile($_uniqueid);
                                        }
                                    }
                                }
                                
                              $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
                            }
                            
                            $updateColumns=array();
                            $updateValues=array();
                        }
		
						if(empty($num_rows)  || $num_rows< 1 || $import_type =='Insert'){
							 $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
							foreach($xlsRowData as $main => $values_one){
								foreach($values_one as $inert_tablename => $insert_files_values){
									 $st =array(); 
									if(strtolower($inert_tablename)==strtolower($module_tablename)){
										$k =array();
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
									
									    $uniqueid=$adb->getUniqueID('ld_users');  
									}
                                      
									$st['id']=$uniqueid;//获取crmid
                                   
							          if($inert_tablename=='ld_users'&&$regop->compareCount($registerFileUserCount,$softuserCount)<=0)
                                        {
                                                $st["status"]='Inactive';
                                               
                                        }
                                        $st_keys=array_keys($st);
                                        if($st_keys[0]!='')
									       $insert_value = array_merge($insert_files_values, $st);//拼接数组
                                        else
                                            $insert_value = $insert_files_values;
								    
                                    
									$adb->pquery($field_sql[$inert_tablename],array($insert_value));
                                  
								    if(!empty($groupids))
                                    {
                                            $arr_groupids=explode(",",$groupids);
                                           
                                              foreach($arr_groupids as $tmpgroupid)
                                              {
                                                    if(empty($tmpgroupid))
                                                    {
                                                        continue;
                                                    }
                                                    $sql='insert into ld_users2group (userid,groupid)value(?,?)';
                                                    $adb->pquery($sql,array($uniqueid,$tmpgroupid));
                                              }

                                              $sql = 'INSERT into ld_user_group_set(`userid`,`groupid`,`type`,`content`)
                                                SELECT DISTINCT ld_users.id,ld_users2group.groupid,\'userlevel\',IFNULL(ld_users.userlevel,\'\') 
                                                from ld_users INNER JOIN ld_users2group on ld_users.id = ld_users2group.userid
                                                where ld_users.userlevel <> \'\' and ld_users.id = ? AND not EXISTS(SELECT 1 from ld_user_group_set where userid = ? ) ;';
                                              $adb->pquery($sql,array($uniqueid,$uniqueid));
                                                
                                    }
                                   
                                    createUserPrivilegesfile($uniqueid);
									$insert_value=array();  
								}
									$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
							}
							
						}
					}
                   
			}  
        
            $_REQUEST['diony']='yes';
            include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');//进度条
             $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
            $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
            $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error'].=$error;
             if($endrow>=($maxrows-1))
            {
                $sql="  insert into ld_usersscf(id)
						select id from ld_users where id not in(select id from ld_usersscf);";
               $result=$adb->pquery($sql,array());
			
              
            }
          $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$maxrows;
            $tmp['timedescription']=$time_description;
            $tmp['cur_progress_step']=$cur_progress_step;
            $tmp['endimporttime']=$endimporttime;
            $tmp['endrow']=$endrow;
            ConvertTojsonString(1,$tmp,'success');
          
            exit();
    }

?>