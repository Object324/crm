<?php
require_once(globalStatic::$root_directory.'/WeiXinApp/detail/cls_SaveWX.php');
require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class cls_FormCode_Save extends cls_SaveWX
{
    public function setFieldInfoFromPost(){
        
        global $weixin_user,$adb;
        $_REQUEST['cur_module_step']='1';
        //editor:gyq_150 reason:客户/联系人保存字段重复提示自定义  2019/10/15 14:19
        include globalStatic::$root_directory.'modules/lingdang/staticlingdang.class.php';
        $this->check_before_field_duplicate();
        if(!empty($_REQUEST['wx_fieldInfo'])) {
            $fieldobj=Field::getInstance($this->module,$adb);
            $moduleFields=$fieldobj->getModuleFields();
           // PC端+微信端：模块单据提交审批后，系统应该做实时判断
            $ldcls = new staticlingdang();
            $input['record']=$_REQUEST['record'];
            $input['fld_module']=$this->module;
          
            foreach ($_REQUEST['wx_fieldInfo'] as $key=>$val) {
                $field = $moduleFields[$key];
                if ($field->uitype == 69||$field->uitype==1109||$field->uitype==1108||$field->uitype==28) {
                    foreach($val as $k=>$v){
                        $_REQUEST[$k] = $v;
                    }
                    unset($_REQUEST[$key]);
                }else{
                    $_REQUEST[$key] = $val;
                    
                }
            }


        }
    }
    
    public function Formcode_save(){
        global $adb;
        $focus = $this->focus;
        $module = $this->module;        
        //单据旧数据
        $focus->retrieve_entity_info($focus->id,$module);
        
        //判断模块是否启用审批
        crm_load_function_file('getSys_Approvedeploy','include/utils','CacheInfo');
        $sys_approve= getSys_Approvedeploy($module);
        if(is_array($sys_approve)&&$sys_approve['deploy_value']==0){
            //审批状态:未提交、已驳回、已拒绝
            $approve_arr = array(constant('D_A_S_UNAPPROVED'),constant('D_A_S_REJECTED'),constant('D_A_S_DISMISSED'));
            //获取单据审批状态
            if(empty($focus->column_fields['approvestatus']))
            {
                $sql="select approvestatus from ".$focus->table_name.' where '.$focus->table_index."=?";
                $result=$adb->pquery($sql,array($focus->id));
                if($adb->num_rows($result)>0)
                    $focus->column_fields['approvestatus']=$adb->query_result($result,0,'approvestatus');
            }
            if(in_array($focus->column_fields['approvestatus'],$approve_arr) || empty($focus->column_fields['approvestatus'])){
                $approve = 'no';
            }else{
                $approve = 'yes';
            }
        }else{
            $approve = 'no';
        }
        //获取二维码字段设置
        $qrcode_field_arr = $this->getQrcode_FieldsDetail();
        
        $module_fields = $focus->fieldobj->getModuleFields();
        $update_column_arr = array();
        $update_value_arr = array();
        $_REQUEST['formcode_saveattachment'] = 'yes';
        foreach($module_fields as $fieldinfo){
            $columnname = $fieldinfo->getColumnName();
            $uitype = $fieldinfo->getUIType();
            $fieldname = $fieldinfo->getFieldName();
            $tablename = $fieldinfo->getTableName();
            $prevalue = $focus->column_fields[$fieldname];
            
            $tmp_field = $qrcode_field_arr[$columnname];
            if($approve == 'yes' && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                continue;
            }else if(!empty($prevalue) && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                continue;
            }else if($tmp_field['input']=='no'){//是否允许编辑
                continue;
            }else{
            }
            
            if(isset($_REQUEST[$fieldname])){
                $postvalue = $_REQUEST[$fieldname];
                //多选框处理
                if($uitype==33)
                {
                    $prevalue = str_replace('|##|',',',$prevalue);
                    $postvalue = str_replace('|##|',',',$postvalue);
                }                
                //新旧信息对比
                if($prevalue != $postvalue){
                    $update_column_arr[$tablename][$columnname] = $columnname.'=?';
                    $update_value_arr[$tablename][$columnname] = $postvalue;
                    $this->save_fieldlog($module,$fieldname,$focus->id,$prevalue,$postvalue);
                }
            }else{
                if($uitype==1109||$uitype==28){
                    //删除旧附件
                    $this->insertinto_fieldattament($columnname,$focus,$fieldname);   
                }
            }
        }
        //更新所有的字段值
        foreach($update_value_arr as $tablename=>$column_value){
            $tmp_value_arr = array();
            $tmp_value_arr = array_values($column_value);
            $tmp_value_arr[] = $focus->id;
            $sql = 'update '.$tablename.' set '.implode(',',$update_column_arr[$tablename]).' where '.$focus->table_index.'=? ';
            $adb->pquery($sql,$tmp_value_arr);   
        }
        //保存成功
        return array(1, array(), '保存成功');
	}
    //保存修改日志
    public function save_fieldlog($module,$fieldname,$crmid,$prevalue,$postvalue){
        global $adb;
        $qrcodeid = $_REQUEST['qrcodeid'];
        $wechatuserid = $_REQUEST['wechatuserid'];
        //单据修改日志
        $time = date('Y-m-d H:i:s',time());$status = 0;
		$trackid = $adb->getUniqueID('ld_modtracker_basic');
        $userid_qrcode = -1503;//表单码修改特殊取值
		$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
						values(?,?,?,?,?,?);';
		$adb->pquery($query,array($trackid,$crmid,$module,$userid_qrcode,$time,$status));
		$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
		$adb->pquery($query,array($trackid,$fieldname,$prevalue,$postvalue));
        //表单码修改日志
        $query = 'insert into ld_qrcode_operatelog(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
        $adb->pquery($query,array($qrcodeid,$wechatuserid,$time,'submit',$trackid,$crmid));
    }
    
    public function getQrcode_FieldsDetail(){
        global $adb;
        $qrcodeid = $_REQUEST['qrcodeid'];
        $qrcode_field_arr = array();
        $qrcode_viewfield_arr = array();
        $sql = 'select ld_qrcode_fieldsdetail.*,ld_field.columnname from ld_qrcode_fieldsdetail 
                INNER JOIN ld_field on ld_qrcode_fieldsdetail.fieldid = ld_field.fieldid
                INNER JOIN ld_qrcode_creation on ld_qrcode_creation.qrcodetemplateid = ld_qrcode_fieldsdetail.qrcodetemplateid
                where qrcodebasicid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype = "normal"';
        $result = $adb->pquery($sql,array($qrcodeid,'yes'));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $tmp_columnname = $adb->query_result($result,$i,'columnname');
                $view = $adb->query_result($result,$i,'viewpermit');
                $qrcode_viewfield_arr[] = $tmp_columnname;
                $qrcode_field_arr[$tmp_columnname] = array('label'=>$adb->query_result($result,$i,'qrcode_fieldlabel'),
                                                        'view'=>$adb->query_result($result,$i,'viewpermit'),
                                                        'input'=>$adb->query_result($result,$i,'editpermit'),
                                                        'edit'=>$adb->query_result($result,$i,'editcontentpermit'),
                                                        'approve'=>$adb->query_result($result,$i,'approvepermit'),
                                                        'require'=>$adb->query_result($result,$i,'requirecontent')
                                                        );
            }
        }
        return $qrcode_field_arr;
    }
    
    //删除某一字段关联的附件
    public function insertinto_fieldattament($columnname,$focus,$fieldname){
        global $adb;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        //先删除原文件记录
        $deletedetailsql='select ld_attachments.attachmentsid,newfile_name,path,
              ld_attachments.storage_location,ld_attachments.cloud_path,attachmentcolumnname  from ld_attachments 
                inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
           WHERE  ld_attachments.attachmentsid not in(
            select ld_seattachmentsrel.attachmentsid from ld_seattachmentsrel inner join ld_crmentity on ld_crmentity.crmid=ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.crmid=? and ld_crmentity.setype=? ) and ld_seattachmentsrel.crmid=? and ld_seattachmentsrel.attachmentcolumnname=?;';
               
        $tmp_result=$adb->pquery($deletedetailsql,array($focus->id,$focus->module_name.' Image',$focus->id,$columnname));
        $delfileids=explode(",",$_REQUEST['delfileid']);
        //关联过其他单据的附件只删除记录，不删除文件
        $related_fileids = $focus->attachment_related_record($focus->id);
        if(sizeof($related_fileids)>0&&sizeof($delfileids)>0){
            foreach($delfileids as $key => $value){
                if(in_array($value,$related_fileids)){
                    unset($delfileids[$key]);
                }
            }
        }
        
        if ($adb->num_rows($tmp_result) > 0) {
            $delfileList = array();
            for ($i = 0; $i < $adb->num_rows($tmp_result); $i++) {
                $attachmentcolumnname=$adb->query_result($tmp_result,$i,'attachmentcolumnname');
               
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$attachmentcolumnname);
                if(!$fieldinfo||$fieldinfo->getReadOnly()==1)
                {
                    continue;
                }
                $attachmentsid = $adb->query_result($tmp_result, $i, 'attachmentsid');
                $delattachmentsid[] = $adb->query_result($tmp_result, $i, 'attachmentsid');
                $filepath = $adb->query_result($tmp_result, $i, 'path');
                $newfile_name = $adb->query_result($tmp_result, $i, 'newfile_name');
                $storage_location = $adb->query_result($tmp_result, $i, 'storage_location');
                $cloud_path = $adb->query_result($tmp_result, $i, 'cloud_path');
                if (is_array($delfileids) && in_array($attachmentsid, $delfileids)) {
                    $delfileList[$i]['storage_location'] = $storage_location;
                    $delfileList[$i]['path'] = $filepath;
                    $delfileList[$i]['cloud_path'] = $cloud_path;
                    $delfileList[$i]['newfile_name'] = $newfile_name;
                }
            }
            //从腾讯云存储桶中删除表中存储的文件
            $this->deleteFileFromTable($delfileList);
            if ($adb->num_rows($tmp_result) > 0&&is_array($delattachmentsid)&&$delattachmentsid[0]>0) {
                $delattachmentsid = implode(',', $delattachmentsid);
                $sql = 'delete from  ld_attachments  where attachmentsid  in ( ' . $delattachmentsid . ' )';
                $adb->pquery($sql, array());
                $deletesql = 'delete  from ld_seattachmentsrel  where  attachmentsid in( ' . $delattachmentsid . ' )';
                $adb->pquery($deletesql, array());
            }
        }
        //从request获取新的文件路径
        if($_REQUEST[$fieldname.'-file_num']>0){
            for($i=0;$i<=220;$i++)
            {
                $filename = $_REQUEST[$fieldname.'-file_name_'.$i];	//附件名称
                $filename = from_html(preg_replace('/\s+/', '_', $filename));
                $filename= FileFileterString($filename);//上传文件的特殊字符过滤和安全性检测
                $filetype = $_REQUEST[$fieldname.'-file_type_'.$i];	//附件类型
                $filepath = $_REQUEST[$fieldname.'-file_path_'.$i];	//附件路径
                $filesize = $_REQUEST[$fieldname.'-file_size_'.$i];	//附件大小
                $newfile_name = $_REQUEST[$fieldname.'-newfile_name_'.$i];	//附件大小
                
                //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                $isEncrypt = $_REQUEST[$fieldname.'-isEncrypt_'.$i];	//是否加密
                $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($filepath) : $filepath;
                $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($newfile_name) : $newfile_name;
                
                $newfile_name= FileFileterString($newfile_name);// 上传文件的特殊字符过滤和安全性检测
                $cloud_path=$_REQUEST[$fieldname.'-cloud_path_'.$i];
                $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;
                //editor:gyq_20190326 reason:小程序附件记录上传方式
                $imagefromtype = $_REQUEST[$fieldname.'-imagefromtype_'.$i];	//附件上传的方式
				if(empty($imagefromtype))$imagefromtype = 'Computer';
                if($filename==''&&$filesize<=0.0001)
                {
                    //附件删除会有错误
                    continue;
                }
                //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                $upload_from = $_REQUEST[$fieldname.'-upload_from_'.$i];
                if(empty($upload_from) || $upload_from=='undefined'){
                    $upload_from = '';
                }
                //文件存储位置:腾讯云存储桶/本地 （cos/local）
                $storage_location = $_REQUEST[$fieldname.'-storage_location_'.$i];
                if(empty($storage_location) || $storage_location=='undefined'){
                    $storage_location = 'local';
                    $cloud_path = '';
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
                    $this->deleteQcloudTempFile($newfile_name);
                }
                $binFile = sanitizeUploadFileName($filename, $upload_badext);
                $filename=str_replace(" ","_",$filename); 
                $filename = ltrim(basename(" ".$binFile)); //allowed filename like UTF-8 characters
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
                    $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                    $adb->pquery($sql1,array($current_id,'Attachment'));
                    
                    //插入知识管理与附件明细关联表ld_seattachmentsrel
                    $sqlInsertRel='insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
                    $adb->pquery($sqlInsertRel,array($focus->id,$current_id,$columnname));

                    //插入附件明细表ld_attachments
                    $sqlInsertAttachments='insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?, ?, ?, ?,?,?,?,?,?)';//description不知道什么，暂时去掉
                    $adb->pquery($sqlInsertAttachments,array($current_id,$filename,$newfile_name,'-无-',$filetype,$filepath,$size,$imagefromtype,$cloud_path,$storage_location,$upload_from));
                }
            }
        }
    }
    //调用删除文件方法
    public function deleteFileFromTable($rDelfileList){
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $cosFileList = array();
        foreach ($rDelfileList as $i=>$value){
            $storage_location = $value['storage_location'] ;
            $filepath = $value['path'];
            $cloud_path = $value['cloud_path'];
            $newfile_name = $value['newfile_name'];
            if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {

            } else {
                $newfile_name = iconv('utf-8', 'gbk', $newfile_name);
            }
            if($storage_location == 'cos'){
                $cosFileList[] = $cloud_path;
            }else{
                $tmpfile = $filepath . $newfile_name;
                @unlink(globalStatic::$root_directory . $tmpfile);
            }
        }
        if(!empty($cosFileList)){
            deleteQcloudFile($cosFileList);
        }
    }
    //删除文件缓存
    protected function deleteQcloudTempFile($rNewfileName){
        global $adb;
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        //删除临时缓存,但不需删除云端文件
        $sql = 'delete from ld_attachments_tempsave where newfile_name=?';
        $adb->pquery($sql,array($rNewfileName));
        //删除超过24小时的临时表中云端文件
        $sqlTwo = 'select newfile_name,path from ld_attachments_tempsave where create_time<DATE_SUB(NOW(),INTERVAL 1 DAY) limit 5';
        $result = $adb->pquery($sqlTwo,array());
        $num = $adb->num_rows($result);
        if($num > 0){
            $fileArr = array();
            for($i=0;$i<$num;$i++){
                $fileArr[$i]['newfile_name'] = $adb->query_result($result,$i,'newfile_name');
                $fileArr[$i]['path'] = $adb->query_result($result,$i,'path');
            }
            deleteQcloudFile($fileArr);
        }
    }
    
    
}
?>