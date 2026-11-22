<?php
require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class User_Special
{
    
      

static function getUserEmail($userid)
{
	
        global $adb;
        if($userid != '')
        {
                $sql = "select email1 from ld_users where id=?";
                $result = $adb->pquery($sql, array($userid));
                $email = $adb->query_result($result,0,"email1");
        }
        return $email;
}
//根据用户ID，获取到用户的手机号码
static function getUserPhonebyID($id)
{
	/**
	 * 在createRemind文件中会无数次循环调用该方法
	 * 添加静态变量，防止重复调用时反复读取数据库
	 * @author Tujt 2015-04-17
	 */
	static $staticuserPhonebyid;
	$statickey = 'staticuserphoneid';
	if(!empty($staticuserPhonebyid) && isset($staticuserPhonebyid[$id])){
		return $staticuserPhonebyid[$id];
	}
	global $adb;
	$sql = "select phone_mobile from ld_users where id=?";
	$result = $adb->pquery($sql, array($id));
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0)
	{
		$user_phone = $adb->query_result($result,0,"phone_mobile");
 	}
	else
	{
		$user_phone = '';
	}
	return $staticuserPhonebyid[$id] = $user_phone;
}
   static  function change_password($user_password, $new_password,$userobj, $dieOnError = true) {

        $usr_name = $userobj->column_fields["user_name"];
        global $mod_strings;
        global $current_user;
        //$userobj->log->debug("Starting password change for $usr_name");

        if( !isset($new_password)/* || $new_password == ""*/) {
            $userobj->error_string = $mod_strings['ERR_PASSWORD_CHANGE_FAILED_1'].$user_name.$mod_strings['ERR_PASSWORD_CHANGE_FAILED_2'];
            return false;
        }

        if (!is_admin($current_user)) {

            $userobj->db->startTransaction();

            if($userobj->db->hasFailedTransaction()) {
                if($dieOnError) {
                    die("error verifying old transaction[".$userobj->db->database->ErrorNo()."] ".
                            $userobj->db->database->ErrorMsg());
                }
                return false;
            }
        }


        $user_hash = strtolower(md5($new_password));

        //set new password
        $crypt_type = $userobj->DEFAULT_PASSWORD_CRYPT_TYPE;
        $encrypted_new_password = $userobj->encrypt_password($new_password, $crypt_type);

        /*
         * editor : gyq_01
         * reason : 新增用户密码严格管理,新增更新date_modified
         * date   : 2016.1.15
         * */

        $query = "UPDATE $userobj->table_name SET user_password=?, confirm_password=?, user_hash=?, ".
                "crypt_type=?,date_modified=? where id=?";
        $userobj->db->startTransaction();
        $userobj->db->pquery($query, array($encrypted_new_password, $encrypted_new_password,
                $user_hash, $crypt_type,date("Y-m-d H:i:s",time()), $userobj->id));
                
       
        if($userobj->db->hasFailedTransaction()) {
            if($dieOnError) {
                die("error setting new password: [".$userobj->db->database->ErrorNo()."] ".
                        $userobj->db->database->ErrorMsg());
            }
            return false;
        }
         require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
        createUserPrivilegesfile($userobj->id);
        return true;
    }
  static   function insertIntoEntityTable($table_name, $module,$userobj,$fileid = '') {
        
        global $adb, $current_user;
        $insertion_mode = $userobj->mode;
        //Checkin whether an entry is already is present in the lingdang_table to update
        if($insertion_mode == 'edit') {
            $check_query = "select * from ".$table_name." where ".$userobj->tab_name_index[$table_name]."=?";
            $check_result=$userobj->db->pquery($check_query, array($userobj->id));

            $num_rows = $userobj->db->num_rows($check_result);

            if($num_rows <= 0) {
                $insertion_mode = '';
            }
        }

        // We will set the crypt_type based on the insertion_mode
        $crypt_type = '';

        if($insertion_mode == 'edit') {
            $update = '';
            $update_params = array();
            $tabid= getTabid($module);
            $sql = "select * from ld_field where tabid=? and tablename=? and displaytype in (1,3) and ld_field.presence in (0,2)";
            $params = array($tabid, $table_name);
        }
        else {
            $column = $userobj->tab_name_index[$table_name];
            if($column == 'id' && $table_name == 'ld_users') {
                //$currentuser_id = $userobj->db->getUniqueID("ld_users");
                //$userobj->id = $currentuser_id;
                if(empty($userobj->id))
                {
                    $currentuser_id = $userobj->db->getUniqueID("ld_users");
                    $userobj->id = $currentuser_id;
                }
            }
            $qparams = array($userobj->id);
            $tabid= getTabid($module);
            $sql = "select * from ld_field where tabid=? and tablename=? and displaytype in (1,3,4) and ld_field.presence in (0,2)";
            $params = array($tabid, $table_name);

            $crypt_type = $userobj->DEFAULT_PASSWORD_CRYPT_TYPE;
        }

        $result = $adb->pquery($sql, $params);
        $noofrows = $adb->num_rows($result);
        for($i=0; $i<$noofrows; $i++) {
            $fieldname=$adb->query_result($result,$i,"fieldname");
            $columname=$adb->query_result($result,$i,"columnname");
            $uitype=$adb->query_result($result,$i,"uitype");
            $typeofdata=$adb->query_result($result,$i,"typeofdata");

            $typeofdata_array = explode("~",$typeofdata);
            $datatype = $typeofdata_array[0];

            if(isset($userobj->column_fields[$fieldname])) {
                if($uitype == 56) {
					if('scopeauthority' != $fieldname){
					
                      
						if($userobj->column_fields[$fieldname] === 'on' || $userobj->column_fields[$fieldname] == 1) {
							$fldvalue = 1;
						}else{
							$fldvalue = 0;
						}
                         
					}else{
						$fldvalue = $_REQUEST['scopeauthority'];
                        if(empty($fldvalue))
                        {
                            $fldvalue=1;
                        }
					}
                }elseif($uitype == 15) {
                
                        $fldvalue = $userobj->column_fields[$fieldname];
                    
                }
                elseif($uitype == 601) {                
                       
                        $trackpostion_query="SELECT trackpostion_id from ld_trackpostion where trackpostion=? ";
                        $trackpostion_result=$adb->pquery($trackpostion_query,array($userobj->column_fields[$fieldname]));                      
                        $trackpostion_nums=$adb->num_rows($trackpostion_result);                        
                        if($trackpostion_nums>0)
                        {                             
                            $fldvalue = $adb->query_result($trackpostion_result,0,'trackpostion_id');                                               
                        }                                                                              
                }
                elseif($uitype == 33) {
                    if(is_array($userobj->column_fields[$fieldname])) {
                        $field_list = implode(' |##| ',$userobj->column_fields[$fieldname]);
                    }else {
                        $field_list = $userobj->column_fields[$fieldname];
                        //@edit:liushuai,2020-8-7,reason:(61mis.com/kfbcrm)成员管理>新建单据界面：新增自定义“多选框”字段，保存单据后“多选框”显示异常1########2
                        if(strpos($field_list,'########') !== false)
                            $field_list = implode(' |##| ', explode("########",$field_list));

                    }
                    $fldvalue = $field_list;
                }
                elseif($uitype == 99) {
                    $fldvalue = $userobj->encrypt_password($userobj->column_fields[$fieldname], $crypt_type);
                }
                else {
                    $fldvalue = $userobj->column_fields[$fieldname];
                    $fldvalue = stripslashes($fldvalue);
                }
                $fldvalue = from_html($fldvalue,($insertion_mode == 'edit')?true:false);



            }
            else {
                $fldvalue = '';
            }
            if($uitype == 31) {
                
                $fldvalue='softed';
                if($current_user->id == $userobj->id) {
                    $_SESSION['lingdang_authenticated_user_theme'] = $fldvalue;
                }
            } elseif($uitype == 32) {
                $fldvalue = $default_language;
               
                if($current_user->id == $userobj->id) {
                    $_SESSION['authenticated_user_language'] = $fldvalue;
                }
            }
            if($fldvalue=='') {
                $fldvalue = $userobj->get_column_value($columname, $fldvalue, $fieldname, $uitype, $datatype);
                //$fldvalue =null;
            }
            if($insertion_mode == 'edit') {
                if($i == 0) {
                    $update = $columname."=?";
                }
                else {
                    $update .= ', '.$columname."=?";
                }
                array_push($update_params, $fldvalue);
            }
            else {
                $column .= ", ".$columname;
                array_push($qparams, $fldvalue);
            }
        }
      if($insertion_mode == 'edit') {
            //Check done by Don. If update is empty the the query fails
            if(trim($update) != '') {
                  if($table_name=="ld_users")
                {
                
                    $sql1 = "update $table_name set $update,modifiedby=?,modifiedtime=? where ".$userobj->tab_name_index[$table_name]."=?";
                    
                    $update_params[]=$current_user->id;
                    $update_params[]=date("Y-m-d H:i:s");
                    
                }
                else
                {
                     $sql1 = "update $table_name set $update where ".$userobj->tab_name_index[$table_name]."=?";
                }
                array_push($update_params, $userobj->id);

                $adb->pquery($sql1, $update_params);
            }

        }
        else {
            // Set the crypt_type being used, to override the DB default constraint as it is not in ld_field
            if($table_name == 'ld_users' && strpos('crypt_type', $column) === false) {
                $column .= ', crypt_type';
                $qparams[]= $crypt_type;
            }
              if(empty($_REQUEST['weixin_mark'])){
                  if(isPermitted("Users","AllowSetRoleDataProfile")=='no')  //1114
                {
                    $_REQUEST["profileid"]="";
                    $_REQUEST["scopeauthority"]=0;;
                    $_REQUEST['viewothers']=0;
                    $_REQUEST['editothers']=0;
                    $_REQUEST['delothers']=0;
                    $_REQUEST['viewselfbills']=0;
                    $_REQUEST['edit_other_mobile']=0;
                    $_REQUEST['is_mobile_style']=0;
                    $_REQUEST['select_servicedetail']=0;
                    $_REQUEST['select_due_date']=0;
                    $_REQUEST['accountallview']=0;
                    $_REQUEST['trackgroupid']='2';
                    $_REQUEST['edit_me_mobile']=0;
                }
              }
                if($table_name=="ld_users")
                {
                       $sql1 = "insert into $table_name ($column,createdtime,smcreatorid,modifiedby,modifiedtime) values(". generateQuestionMarks($qparams) .",?,?,?,?)";  
            
                        $qparams[]=date("Y-m-d H:i:s");
                        $qparams[]=$current_user->id;
                        $qparams[]=$current_user->id;
                        $qparams[]=date("Y-m-d H:i:s");
                }
                else
                {
                       $sql1 = "insert into $table_name ($column) values(". generateQuestionMarks($qparams) .")";  
            
                }
           
            
                $adb->pquery($sql1, $qparams);
        }
    }
      static  function uploadAndSaveFile($id,$module,$file_details,$userobj) {
      
        global $current_user;
        global $upload_badext;
        global $adb;
        $date_var = date('Y-m-d H:i:s');
        //to get the owner id
        $ownerid = $userobj->column_fields['assigned_user_id'];
        if(!isset($ownerid) || $ownerid=='')
            $ownerid = $current_user->id;
        $current_id = $userobj->db->getUniqueID("ld_crmentity");
        //get the file path inwhich folder we want to upload the file
        $upload_file_path = decideFilePath();
        //@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片（如果是用户模块的头像上传，需要删除原来的头像。）
        if($module == 'Users'){
            $sql='select concat(path,newfile_name) as file_path from ld_attachments where attachmentsid in( select attachmentsid from ld_salesmanattachmentsrel where smid = ?)';
            $result = $adb->pquery($sql, array($id));
            $file_path=$adb->query_result($result,0,'file_path');
            if(file_exists(globalStatic::$root_directory.$file_path)){
                @unlink(globalStatic::$root_directory.$file_path);
            }
        }

        $delquery='delete from ld_attachments where attachmentsid in( select attachmentsid from ld_salesmanattachmentsrel where smid = ?)';
        $adb->pquery($delquery, array($id));
        $delquery = 'delete from ld_salesmanattachmentsrel where smid = ?';
        $adb->pquery($delquery, array($id));
        //upload the file in server
        /****************************/
        /* editor:gyq date:20180703 reason:微信接口已不再提供头像信息
         * editor:gyq date:20171229 reason:同步微信头像
         * if($module == 'Users' && !empty($_REQUEST['sync_wx_headerimage_url'])){
            $binFile = 'jpg';
            $localurl = globalStatic::$root_directory.$upload_file_path.$current_id."_1.".$binFile;
            $filename = time().mt_rand(1, 100000).'.'.$binFile;
            $filetype = 'image/jpeg';
            $response = curlDownLoadUrl($_REQUEST['sync_wx_headerimage_url'],$localurl);
            $save_file = 'true';
        }else{
            $file = $file_details['name'];
            $binFile = sanitizeUploadFileName($file, $upload_badext);

            $filename = ltrim(basename(" ".$binFile)); //allowed filename like UTF-8 characters
            $filetype= $file_details['type'];
            $filesize = $file_details['size'];
            $filetmp_name = $file_details['tmp_name'];

            /*
            *更新操作
            *edit:diony
            *time:2013-11-29
            *reson:个人设置，上传图片，中文名称报错问题，将上传后的附件名称做更改
            
            $lastfixs=explode(".",$binFile);
            $lastfix=$lastfixs[count($lastfixs)-1];
            $binFile=$lastfix;
            $newfile_name=$upload_file_path.$current_id."_1.".$binFile;
            $upload_status = move_uploaded_file($filetmp_name,$upload_file_path.$current_id."_1.".$binFile);

            $save_file = 'true';*/
            //only images are allowed for these modules
          //  if($module == 'Users') {
//                $save_file = validateImageFile($file_details);
//            }
       // }d
     //  dump('www');
      global $adb;
      $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $fieldname='imagename';
       
          for($i=0;$i<=60;$i++)
            {
                            $filename = $_REQUEST[$fieldname.'-file_name_'.$i];	//附件名称
                            $filename = from_html(preg_replace('/\s+/', '_', $filename??''));
                            $filetype = $_REQUEST[$fieldname.'-file_type_'.$i];	//附件类型
                            $filepath = $_REQUEST[$fieldname.'-file_path_'.$i];	//附件路径
                            $filesize = $_REQUEST[$fieldname.'-file_size_'.$i];	//附件大小
                            $newfile_name = $_REQUEST[$fieldname.'-newfile_name_'.$i];	//附件大小
                            $cloud_path=$_REQUEST[$fieldname.'-cloud_path_'.$i];
                            
                            //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                            $isEncrypt = $_REQUEST[$fieldname.'-isEncrypt_'.$i];	//是否加密
                            $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($filepath) : $filepath;
                            $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($newfile_name) : $newfile_name;
                            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;
                          
                            $newfile_name=str_replace("&","_",$newfile_name??'');
                            //editor:gyq_20190326 reason:小程序附件记录上传方式
                            $imagefromtype = $_REQUEST['filename-imagefromtype_'.$i];	//附件上传的方式
        					if(empty($imagefromtype))$imagefromtype = 'Computer';
                            if($filename==''&&$filesize<=0.0001)
                            {
                                //附件删除会有错误
                                continue;
                            }
        					//editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 17:09
                            //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                            $upload_from = $_REQUEST[$fieldname.'-upload_from_'.$i];
                            if(empty($upload_from) || $upload_from=='undefined'){
                                $upload_from = '';
                            }
                            //文件存储位置:腾讯云存储桶/本地 （cos/local）
                            $storage_location = $_REQUEST[$fieldname.'-storage_location_'.$i];
                            if(empty($storage_location) || $storage_location=='undefined' || $storage_location=='local'){
                                $storage_location = 'local';
                                $cloud_path = '';
                                $upload_file_path = $filepath;
                            }elseif($storage_location=='cos'){
                                //给存储桶链接增加头，以便界面显示
                               $cloud_path = str_replace("http://",'https://',$cloud_path);
                               if(stripos($cloud_path,'https://') === false){
                                    $cloud_path = 'https://'.$cloud_path;
                                }else{
                                    //$cloud_path = $filepath;
                                }
                                //$filepath = '';
                                //删除文件临时表数据
                               // $current_user->deleteQcloudTempFile($newfile_name);
                            }
                            $binFile = sanitizeUploadFileName($filename, $upload_badext);
                            $filename=str_replace(" ","_",$filename??''); 
                            $filename = ltrim(basename(" ".$binFile??"")); //allowed filename like UTF-8 characters
                            $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id 
                            
                            if(!strpos($filesize,'B')){//Liver 只有新增的附件，才需要计算附件大小并加上單位
                                if ($filesize < 1024)
                                    $filesize = $filesize . ' B';
                                elseif ($filesize > 1024 && $filesize < 1048576)
                                    $filesize = round($filesize / 1024, 2) . ' KB';
                                else if ($filesize > 1048576)
                                    $filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                            }
                            $size = $filesize;
                            
                            if($filename !=''){
                                $sql1 = "insert into ld_crmentity (crmid,setype) values(?,?)";
                                $params1 = array($current_id, $module." Attachment");
                                $userobj->db->pquery($sql1, $params1);
                    
                                $sql2="insert into ld_attachments(attachmentsid, name,newfile_name, description, type, path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?,?,?,?,?,?,?,?,?,?)";
                                $params2 = array($current_id, $filename, $newfile_name,$userobj->column_fields['description'], $filetype, $upload_file_path,$filesize,$imagefromtype,$cloud_path,$storage_location,$upload_from);
                                $result=$userobj->db->pquery($sql2, $params2);
                    
                                if($id != '') {
                                    $delquery = 'delete from ld_salesmanattachmentsrel where smid = ?';
                                    $userobj->db->pquery($delquery, array($id));
                                }
                    
                                $sql3='insert into ld_salesmanattachmentsrel values(?,?)';
                                $userobj->db->pquery($sql3, array($id, $current_id));
                    
                                //we should update the imagename in the users table
                                $userobj->db->pquery("update ld_users set imagename=? where id=?", array($filename, $id));
                    			return $newfile_name;
                                /*$sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                                $adb->pquery($sql1,array($current_id,'Attachment'));
                                
                                //插入知识管理与附件明细关联表ld_seattachmentsrel
                                $sqlInsertRel='insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
                                $adb->pquery($sqlInsertRel,array($this->id,$current_id,$columnname));
            
                                //插入附件明细表ld_attachments
                                $sqlInsertAttachments='insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?, ?, ?, ?,?,?,?,?,?)';//description不知道什么，暂时去掉
                                $adb->pquery($sqlInsertAttachments,array($current_id,$filename,$newfile_name,'-无-',$filetype,$filepath,$size,$imagefromtype,$cloud_path,$storage_location,$upload_from));
                                */
                                
                            }
        
                          
                        }
                        
        /*if($save_file == 'true') {

            $sql1 = "insert into ld_crmentity (crmid,setype) values(?,?)";
            $params1 = array($current_id, $module." Attachment");
            $userobj->db->pquery($sql1, $params1);

            $sql2="insert into ld_attachments(attachmentsid, name,newfile_name, description, type, path) values(?,?,?,?,?,?)";
            $params2 = array($current_id, $filename, $newfile_name,$userobj->column_fields['description'], $filetype, $upload_file_path);
            $result=$userobj->db->pquery($sql2, $params2);

            if($id != '') {
                $delquery = 'delete from ld_salesmanattachmentsrel where smid = ?';
                $userobj->db->pquery($delquery, array($id));
            }

            $sql3='insert into ld_salesmanattachmentsrel values(?,?)';
            $userobj->db->pquery($sql3, array($id, $current_id));

            //we should update the imagename in the users table
            $userobj->db->pquery("update ld_users set imagename=? where id=?", array($filename, $id));
			return $newfile_name;
        }
        else {
           
        }*/
        
        return;
    }
    static 	function getList($result,$userobj){
		global $current_user,$adb,$default_charset;
		require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.'.php');
		$blockidsetting = $_REQUEST['blockidsetting'];
		$fieldidsetting = $_REQUEST['fieldidsetting'];
		$parenttab = $_REQUEST['parenttab'];
		$reg=RegOp::getInstance();
    
		$testFile=$reg->isExistFile();
		$moduleFields=$userobj->fieldobj->getModuleFields();
		$list_fields = $userobj->list_fields;//列表显示字段
		$table = '<table class="listEntries fir-center" width="100%" border="0" cellspacing="1" cellpadding="0">';
		$table .='<tr>';
		$table .='<th>#</th>';
       
		foreach($list_fields as $listvalues){
			foreach($listvalues as $fieldname){
				$field = $moduleFields[$fieldname];
				if(!empty($field)){
					$listViewFields[] = $fieldname;
					$fieldlabel = $field->getfieldLabel();
					$table .='<th align="left" title="'.$fieldlabel.'">'.$fieldlabel.'</th>';				}
			}
		}
		if($languageType == 'en')
			$table .='<th width="432">'.getFixedLabel('OPERATING').'</th>';
		else
			$table .='<th width="306">'.getFixedLabel('OPERATING').'</th>';
		$table .='</tr>';
		$showfieldvalueobj=new ShowFieldValue($userobj->fieldobj,'Users',SHOW_LISTVIEW);
        $showfieldvalueobj->setownerNameList($userobj->list_fields);
        $showfieldvalueobj->setadbResult($result);
		$rowCount = $adb->num_rows($result);
       
		if($rowCount > 0){
			for ($i = 0; $i < $rowCount; ++$i) {
				$showfieldvalueobj->setLine_index($i);
				$recordId = $adb->query_result($result,$i,"id");
                $profileid=$adb->query_result($result,$i,"roleid");
				$showfieldvalueobj->setRecorId($recordId);
				foreach ($listViewFields as $key=> $columnname){
					$field = $moduleFields[$columnname];
					if(empty($field)){
						continue;
					}
					$uitype = $field->getUIType();
					$fieldid = $field->getFieldid();
                   
					//echo $uitype;echo '<br><br>';
					if($columnname == 'profileid'){//角色权限
						$columnname = 'rolename';
					}
					$rawValue = $userobj->db->query_result($result, $i, $columnname);
					//echo $columnname . '--' . $uitype;echo '<br><br>';
					if($uitype != 8){
						$value = html_entity_decode($rawValue,ENT_QUOTES,$default_charset);
					} else {
						$value = $rawValue;
					}
					$showvalue=$showfieldvalueobj->getFieldValueByField($field,$rawValue,$value);
					if($uitype == 106){
					  
						$ListViewEntries[$recordId][] = '<a  referencemodule="Users" referencerecord="'.$recordId.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"><span title="'.$showvalue['value'].'">'.$showvalue['value'].'</span><span style="display:none;" vtmodule="Users" vtfieldname="'.$columnname.'" vtrecordid="'.$recordId.'" type="vtlib_metainfo"></span></a>';
						
					}else if($uitype == 13 && !empty($showvalue['value'])){
						$ListViewEntries[$recordId][] = '<a href="javascript:InternalMailer(' . $recordId . ',' . $fieldid . ',\'' . $columnname . '\',\'Users\',\'record_id\');" title="'.$showvalue['value'].'">' . textlength_check($showvalue['value']) . '</a><span style="display:none;" vtmodule="Users" vtfieldname="'.$columnname.'" vtrecordid="'.$recordId.'" type="vtlib_metainfo"></span>';
					}else if($uitype == 115){
						if($showvalue['value'] == 'Active'){
							$ListViewEntries[$recordId][] = getFixedLabel('ACTIVATE');
							$user_status_label = getFixedLabel('INACTIVATE');
						}else{
							$ListViewEntries[$recordId][] = getFixedLabel('INACTIVATE');
							$user_status_label = getFixedLabel('ACTIVATE');
						}
					}else{
					   if($uitype==98){
					       $ListViewEntries[$recordId][] = '<a target="_blank" href="index.php?module=Settings&action=profilePrivileges&parenttab=Settings&mode=view&return_module=Settings&return_action=listroles&profileid='.$profileid.'&blockidsetting=2&fieldidsetting=1"><span title="'.$showvalue['value'].'">'.$showvalue['value'].'</span><span style="display:none;" vtmodule="Users" vtfieldname="'.$columnname.'" vtrecordid="'.$recordId.'" type="vtlib_metainfo"></span></a>';

					   }else
						$ListViewEntries[$recordId][] = '<span title='.$showvalue['value'].'>'.$showvalue['value'].'</span><span style="display:none;" vtmodule="Users" vtfieldname="'.$columnname.'" vtrecordid="'.$recordId.'" type="vtlib_metainfo"></span>';
					}
					
					//用户状态 启用、禁用
					if($uitype == 115){
						$user_status = $showvalue['rawvalue'];
					}
				}
				//操纵列按钮
				$button = '';
				$button .= '<a class="Anu3_a" href="index.php?action=EditView&return_action=ListView&return_module=Users&module=Users&parenttab='.$parenttab.'&record='.$recordId.'&blockidsetting='.$blockidsetting.'&fieldidsetting='.$fieldidsetting.'">'.getFixedLabel('EDIT').'</a>';
				$button .='<a class="Anu3_a" onclick="setProfile(this,'.$recordId.')">'.getFixedLabel('SETTHEPERMISSIONS').'</a>';
				$button .='<a class="Anu3_a" onclick="ShowSetUeryScop('.$recordId.')">'.getFixedLabel('DATARANGE').'</a>';
				if($recordId != 1){
					if(!empty($user_status_label)){
						$button .='<a class="Anu3_a" onclick="setStatus(this,'.$recordId.',\''.$user_status.'\')">'.$user_status_label.'</a>';
					}
					$blockidsettings = $blockidsetting > 0 ? $blockidsetting : 0;
					$fieldidsettings = $fieldidsetting > 0 ? $fieldidsetting : 0;
					$button .='<a class="Anu3_a" href="#" onclick="deleteUser(this,'.$recordId.','.$blockidsettings.','.$fieldidsettings.',\''.$parenttab.'\')">'.getFixedLabel('DELETE').'</a>';
				}
				if($testFile == 1){
					$button .='<a class="Anu3_a" href="index.php?action=EditView&return_action=ListView&return_module=Users&module=Users&parenttab='.$parenttab.'&record='.$recordId.'&isDuplicate=true&blockidsetting='.$blockidsetting.'&fieldidsetting='.$fieldidsetting.'">'.getFixedLabel('COPY').'</a>';
				}
				 
			
				$ListViewEntries[$recordId][] = $button;
			}
			$row = 0;
			foreach($ListViewEntries as $recordid => $list){
				if($row%2 == 0){
					$table .='<tr id="setting_'.$row.'" class="lvtColData" onmouseout="listOnMouseOut(ld(this),\'on\');" onmouseover="listOnMouseOver(ld(this));">';
				}else{
					$table .='<tr id="setting_'.$row.'" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),\'On\');" onmouseover="listOnMouseOver(ld(this));">';
				}
				$no = $row+1;
				$table .='<td>'.$no.'<input type="hidden" id="userlistview'.$recordid.'" name="userlistview'.$recordid.'"></td>';
				foreach($list as $value){
				    switch($value){//Liver bug0026982: 控制面板>用户管理：当用户停用时，建议状态栏，停用显示为红色字体
				        case '在职':
                        case 'Activate':
                            $table .='<td align="left" >'.$value . '</td>';
                            break;
                        case '离职':
                        case 'Inactivate':
                            $table .='<td align="left" >'.'<font color=\'red\'>'.$value .'</font>'. '</td>';
                            break;
                        default:
                            $table .='<td align="left" >'.$value .'</td>';
				    }
				}
				$row++;
			}
		}else{
			$table .='<tr>';
			$table .='<td  style="background-color:#efefef;height:194px" colspan="10" align="center">';
			$table .='<div class=\'noResultBG\' >';
			$table .='<div class=\'noResultContent\'> ';
			$table .='<div  class="divNoRecord">'.getFixedLabel('NOTFINDUSERS').'</div>';
			$table .='</div>';
			$table .='</div>';
			$table .='</td>';
			$table .='</tr>';
		}
		$table .='</table>';
		//echo $table;echo '<br><br>';
		return $table;
	}
    
   	static function vtws_transferOwnership($ownerId, $newOwnerId,$userobj, $delete=true) 
        {
	       require_once globalStatic::$root_directory.'vtlib/lingdang/Utils.php';
		$db = PearDatabase::getInstance();
		//用户跟踪记录表
		if ($delete) {
			$sql = "delete from LD_tracker where user_id=?";
			$db->pquery($sql, array($ownerId));
		}
		//提醒
		$sql ="update ld_reminds set recieverid=? where recieverid=?";
		$db->pquery($sql, array($newOwnerId,$ownerId));
        //呼叫中心
	    $sql ="update ld_callbutler set userid=? where userid=?";
		$db->pquery($sql, array($newOwnerId,$ownerId));
        
		if(lingdang_Utils::CheckTable('ld_customerportal_prefs')) {
			$query = 'UPDATE ld_customerportal_prefs SET prefvalue = ? WHERE prefkey = ? AND prefvalue = ?';
			$params = array($newOwnerId, 'defaultassignee', $ownerId);
			$db->pquery($query, $params);

			$query = 'UPDATE ld_customerportal_prefs SET prefvalue = ? WHERE prefkey = ? AND prefvalue = ?';
			$params = array($newOwnerId, 'userid', $ownerId);
			$db->pquery($query, $params);
		}

		//delete from ld_homestuff
		if ($delete) {
			$sql = "delete from ld_homestuff where userid=?";
			$db->pquery($sql, array($ownerId));
		}

		//delete from lingdang_users to ld_role lingdang_table
		if ($delete) {
			$sql = "delete from ld_users2group where userid=?";
			$db->pquery($sql, array($ownerId));
		}
		/**
		 * edit:chj
		 * date:2014-9-5
		 * reason:删除用户时，更改审批人 uitype 131
		 * desc:0010859: 控制面板->用户管理：【删除】用户后，会导致控制面板->审批流程管理中【审批步骤】的审批人显示为空。
		 * */
		$sql = "select ld_field.tabid,fieldname,tablename,columnname,name from ld_field 
        LEFT JOIN ld_tab ON ld_tab.tabid=ld_field.tabid AND ld_tab.presence=0
        left join ".
		"ld_fieldmodulerel on ld_field.fieldid=ld_fieldmodulerel.fieldid where uitype ".
		"in (52,53,77,101,131) or (uitype=10 and relmodule='Users')";
       
		$result = $db->pquery($sql, array());
		$it = new SqlResultIterator($db, $result);
		$columnList = array();
		foreach ($it as $row) {
			$column = $row->tablename.'.'.$row->columnname;
			if(!in_array($column, $columnList)) {
				$columnList[] = $column;
                //echo $row->name.'|'.$row->tablename.'|'.$row->columnname.'|'.$row->fieldname.'|'.$ownerId;die;
                if($row->fieldname=='ServiceCharge'||$row->fieldname=='servicecasher'){
                    $userobj->update_user_Smownerid($row->name,$row->tablename,$row->columnname,$row->fieldname,$ownerId);
                }

				$sql = "update $row->tablename set $row->columnname=? where $row->columnname=?";
				$db->pquery($sql, array($newOwnerId, $ownerId));
			}
		}
		 /**
		 * date:2014-9-9
		 * reason:删除用户时，更改审批步骤的用户
		 * desc:0010859: 控制面板->用户管理：【删除】用户后，会导致控制面板->审批流程管理中【审批步骤】的审批人显示为空。
		 * */
		$sqlapprove = "select id,approvevalue from ld_approvestep where FIND_IN_SET($ownerId,approvevalue) and approvetype in (0,5,6)";
		$query = $db->pquery($sqlapprove,array());
		$num_rows = $db->num_rows($query);
		for($i = 0; $i<$num_rows; $i++)
		{
			$approveid = $db->query_result($query,$i,'id');
			$approvevalue = $db->query_result($query,$i,'approvevalue');
			$approve_userid = explode(',', $approvevalue);
			foreach($approve_userid as $key => $val)
			{
				if($val == $ownerId)
				{
					unset($approve_userid[$key]);
					if(!in_array($newOwnerId,$approve_userid))
					{
						$approve_userid[$key] = $newOwnerId;
					}
				}
			}
			$approve_new_userid = implode(',',$approve_userid);
			$db->pquery('update ld_approvestep set approvevalue = ? where id = ?',array($approve_new_userid,$approveid));
		}
        
        //27321: 自用系统71mis/ldcrm，用户管理A账户被删除了，名下数据转移到B账户名下，审批流程下一步处理人也变成b了，但是之前审批中的单据，下一步处理人还是A
       $sql=" select * from (select id,crmid,nextstepapproveby from ld_approvelog  where  FIND_IN_SET($ownerId,nextstepapproveby)  ORDER BY crmid desc, id  desc ) as tmp_approve 
        where   FIND_IN_SET($ownerId,nextstepapproveby)  GROUP BY crmid  ";
        
        $result=$db->pquery($sql,array());
        $num_rows=$db->num_rows($result);
        for($i=0;$i<$num_rows;$i++)
        {
            $nextstepapproveby=$db->query_result($result,$i,'nextstepapproveby');
            $id=$db->query_result($result,$i,'id');
            $crmid = $db->query_result($result,$i,'crmid');
            $approve_userid = explode(',', $nextstepapproveby);
			foreach($approve_userid as $key => $val)
			{
				if($val == $ownerId)
				{
					unset($approve_userid[$key]);
					if(!in_array($newOwnerId,$approve_userid))
					{
						$approve_userid[$key] = $newOwnerId;
					}
				}
			}
            
            $approve_new_userid = implode(',',$approve_userid);
			$db->pquery('update ld_approvelog set nextstepapproveby = ? where id = ?',array($approve_new_userid,$id));
            //zkt BUG0056109在维保计划模块进行高级查找时显示有49条数据要吴泽棠审批，但是在审批中心只有46条。
            $tmpmodulename  =  getSalesEntityType($crmid);
            $tmpfocus = CRMEntity::getInstance($tmpmodulename);
            $tmptabname = $tmpfocus->table_name;
            $tmptabindex = $tmpfocus->table_index;
            //duan 20221114 删除用户转交审批人时，只更新审批中的单据信息 approvestatus = '审批中'
            //获取原有的审批人
            $tmp_sql = " select currentapprover from $tmptabname where $tmptabindex = ? and approvestatus = ? ";
            $tmp_result = $db->pquery($tmp_sql,[$crmid,constant('D_A_S_APPROVALOF')]);
            if($db->num_fields($tmp_result)>0){
                $tmp_currentapprover = $db->query_result($tmp_result,0,'currentapprover');
                if(!empty($tmp_currentapprover)){
                    $tmp_approver_arr = explode(',',$tmp_currentapprover);
                    foreach ($tmp_approver_arr as $tmp_key => $tmp_id){
                        if($ownerId == $tmp_id){
                            unset($tmp_approver_arr[$tmp_key]);
                            if(!in_array($newOwnerId,$tmp_approver_arr))
                            {
                                $tmp_approver_arr[$tmp_key] = $newOwnerId;
                            }
                        }
                    }
                    $tmp_approver_str = implode(',',$tmp_approver_arr);
                    //duan 20221114 删除用户转交审批人时，只更新审批中的单据信息 approvestatus = '审批中'
                    $db->pquery("update $tmptabname set currentapprover = ? where $tmptabindex = ? and approvestatus = ? ",array($tmp_approver_str,$crmid,constant('D_A_S_APPROVALOF')));
                }
            }

        }

	}
     /**
    *@author:andy
    *@data:
    *@reason:获取用户登陆信息
    *@version:true:该用户在24小时内已经登陆
    * @mobile:yes:表示手机登陆
    */
    static  function SmsLoginCheck24Hours($mobile='no',$userobj=null){
        global $adb;
        $sql='select login_id  from ld_loginhistory 
            where user_ip=? and machinename=? and user_name=?
            and login_time>=DATE_ADD(now(),INTERVAL -24 Hour)  
            and whethercodelogin=1 limit 1';
        if($mobile=='yes')
        {
            $user_ip='手机app登陆';
            $machinename='localhost';
        }
        else
        {
            $user_ip=LoginHistory::getIp();
            //$user_ip=$_SERVER['REMOTE_ADDR'];
            $computername=exec ('nbtstat -A'.' '.$user_ip.' | find /i "20"');
            $UserName=(preg_split("/\s+/", trim($computername)));
            $machinename=$UserName[0];
            if(empty($machinename))
            {
                $machinename=gethostbyaddr($user_ip);    //获取主机名 
            }
        }
        $params=array($user_ip,$machinename,$userobj->user_name);
        $result=$adb->pquery($sql,$params);
        if($adb->num_rows($result)>0){
            return true;
        }
        else{
            $params=array($_SERVER['REMOTE_ADDR'],$machinename,$userobj->user_name);
            $result=$adb->pquery($sql,$params);
            if($adb->num_rows($result)>0){
                return true;
            }else{
                return false;	
            }
        }
    }
}

?>