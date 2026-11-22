<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Singin_SaveWX extends cls_SaveWX
{
    private $signid;
    public function common_save()
    {
        global $adb,$current_user;
        
        $focus = $this->focus;
        //签到保存前判断
        $this->before_save();
        
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        setObjectValuesFromRequest($focus);
        $focus->save($this->module);
        
        //签到保存后操作
        $this->signid=$focus->id;
        $this->after_save();
    }
    
    public function before_save(){
        global $current_user,$adb,$PlatformMC;
        //duan 20231016 如果用签到地址覆盖客户地址,将误差视为0
        if(isset($_REQUEST['saveaddress'])&&$_REQUEST['saveaddress'] == 'yes'){
            $_REQUEST['signData']['distance'] = 0;
        }
        $signdata=$_REQUEST['signData'];
        
        $longtitude=$signdata['longtitude'];//+$littlelong;
        $longtitude=is_numeric($longtitude)?$longtitude:null;
        $latitude=$signdata['latitude'];//+$littlelati;
        $latitude=is_numeric($latitude)?$latitude:null;
        $uuid=$signdata['uuid'];
        $signway=$signdata['signway'];
        $record=trim($_REQUEST['selectlistval']);
        $module = $_REQUEST['selectsourcename'];
        $distance=$signdata['distance'];
        $address=$signdata['address'];
        $tabid = getTabid($module);
        if($record=='-1')
        {
            $msg = sprintf(getFixedLabel('TMPNAMECANNOTBEEMPTY'),getTranstab($module));
            ConvertTojsonString('-1','',$msg);
        }
        
        $modulelist = getSinginOptionModule();
        if(!empty($modulelist[$tabid])){
            if($modulelist[$tabid]['no_signin'] == 'yes' && $distance > $modulelist[$tabid]['allowable_distance']){
                 $jsonArray['list'] = array('distance'=>$distance,'address'=>$address);
                $msg = str_replace('{metre}',$modulelist[$tabid]['allowable_distance'],getFixedLabel('Theadministratorhassetthatitisnotallowedtosign'));
                ConvertTojsonString(-1,$jsonArray,$msg);
            }
        }
        if($this->isAllowSigninWhenNotSignout($module) == 'yes'){
            if($this->isExistsNotSignedoutToday($module) == 'yes'){//判断当天是否有未签退的外勤
                $msg = getFixedLabel('NotAllowSigninPleaseSignout');
                ConvertTojsonString('goto_signout_list','',$msg);
            }
        }
    }
    public function setSignid($signid )
    {
        $this->signid=$signid;

    }
    public function after_save(){

        global $current_user;
        $signdata=$_REQUEST['signData'];
        $record=trim($_REQUEST['selectlistval']);
        $module = $_REQUEST['selectsourcename'];
        $address=$signdata['address'];
        $tabid = getTabid($module);
        $signid=$this->signid;

        //签到图片添加水印
        $this->setWatermark($signid,$tabid,$address);
        //如果客户地址为空，签到后将地址信息反写到单据字段中
        if(isset($_REQUEST['saveaddress'])&&$_REQUEST['saveaddress'] == 'yes'){
            $bill_country = $_REQUEST['current_nation'];//国家
            $bill_state = $_REQUEST['current_province'];//省份
            $bill_city = $_REQUEST['current_city'];//城市
            $bill_area = $_REQUEST['current_district'];//区域
            $bill_street = $address;//详细地址
            $tmp_focus = CRMEntity::getInstance($module);
            $_REQUEST['mode'] = 'edit';
            $tmp_focus->mode = 'edit';
            $tmp_focus->id = $record;
            $tmp_focus->retrieve_entity_info($record,$module);
            $fieldname_arr = array('bill_country'=>$bill_country,
                                    'bill_state'=>$bill_state,
                                    'bill_city'=>$bill_city,
                                    'bill_area'=>$bill_area,
                                    'bill_street'=>$bill_street);
            //联系人模块详细地址字段不同
            if($module == 'Contacts'){
                unset($fieldname_arr['bill_street']);
                $fieldname_arr['mailingstreet'] = $bill_street;
            }
            foreach($fieldname_arr as $fieldname=>$fieldvalue){
                if(isset($tmp_focus->column_fields[$fieldname])&&!empty($fieldvalue)){
                    $tmp_focus->column_fields[$fieldname] = $fieldvalue;
                }
            }
            $tmp_focus->is_check_business = 'no';
            $tmp_focus->save($module);
        }
        //判断拜访签到模块是否启用审批以及是否启用快速提交
        crm_load_class_file("ApproveCommon","modules/Approve");
        $approvecommonobj = ApproveCommon::getInstance($this->module);
        $approvecommonobj->quick_submit($signid);

    }
    
    public function getimageinfobycolumn($record,$module,$columnname)
    {
        global $adb;
        
        $file_info=array();
        $attachmentsinfo=array();
        $sql='select ld_attachments.*,ld_seattachmentsrel.attachmentcolumnname  from ld_attachments 
                        inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                   WHERE   ld_seattachmentsrel.crmid=? and ld_seattachmentsrel.attachmentcolumnname = ?
                     ';
        
        $result=$adb->pquery($sql,array($record,$columnname));
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $id=$adb->query_result($result,$i,'attachmentsid');
            $recordid = $record;
            $attname = $adb->query_result($result,$i,'name');

            $size = $adb->query_result($result,$i,'size');
            $path = $adb->query_result($result,$i,'path');
            $cloud_path = $adb->query_result($result,$i,'cloud_path');
            $file_type = $adb->query_result($result,$i,'type');
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $attachmentcolumnname=$adb->query_result($result,$i,'attachmentcolumnname');
            $storage_location = $adb->query_result($result,$i,'storage_location');
            $upload_from = $adb->query_result($result,$i,'upload_from');
            $imagefromtype = $adb->query_result($result,$i,'imagefromtype');
            
            //表头编辑
            if(is_numeric($size)){
                if ($size < 1024)
                    $size = $size . ' B';
                elseif ($size > 1024 && $size < 1048576)
                    $size = round($size / 1024, 2) . ' KB';
                else if ($size > 1048576)
                    $size = round($size / (1024 * 1024), 2) . ' MB';
            }
            $file_info[] = array('file_name'=>$attname,'file_size'=>$size
            ,'file_type'=>$file_type,'file_path'=>$path,'newfile_name'=>$newfile_name
            ,'cloud_path'=>($cloud_path)
            ,'fileid'=>$id,'storage_location'=>$storage_location,'upload_from'=>$upload_from ,'imagefromtype'=>$imagefromtype);
        }
        
        return $file_info;
    }

    public function setWatermark($signid,$tabid,$address){
        global $current_user,$adb;
        crm_load_class_file('cls_ImageText','include');
        $line_arr=array();
        $line_arr[]=$current_user->last_name;
        $line_arr[]=DateOperation::getDateChinese(date("Y-m-d")).' '.DateOperation::getWeekName(date("Y-m-d"))." ".date("H:i");
        $line_arr[]=$address;

        //判断拜访签到模块是否开启水印
        $sign_tabid = getTabid('Singin');
        $uploadwatermark = $this->isUploadWaterMark($sign_tabid,$tabid);//Singin 142
        if ($uploadwatermark == 'yes') {

            $filejsondata = $this->getimageinfobycolumn($signid,'Singin','imagename');

            //file_put_contents(globalStatic::$root_directory.'WeiXinApp/modules/Singin/a.txt',json_encode($savefileinfo_arr));
            foreach($filejsondata as $imageInfo)
            {
                $imageInfo['path'] = $imageInfo['file_path'];
                $imageInfo['filename'] = $imageInfo['newfile_name'];
                if($imageInfo['storage_location']=='local')
                {
                    $imagetextobj=new cls_ImageText($imageInfo['path'].$imageInfo['filename'],$imageInfo['filename'],$line_arr);
                    $imagetextobj->saveImage();
                }else{
                    //edit:can 54682:客户问题（立凯电子），小程序，拜访签到，图片字段没有显示签到水印（苹果手机）
                    if(is_array($imageInfo['cloud_path']))
                    {
                        $cloud_path=$imageInfo['cloud_path'][0];
                    }
                    else{
                        $cloud_path=$imageInfo['cloud_path'];
                    }
                    $this->saveCosWaterMark($cloud_path,$imageInfo['path'],$imageInfo['filename'],$line_arr);//cos图片添加文字水印方法
                }
            }
        }
        //duan 20241008 自定义图片字段添加水印
        $SQL='select attachmentcolumnname,ld_attachments.* from ld_seattachmentsrel
			inner join ld_attachments   on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
			where ld_seattachmentsrel.crmid=? and attachmentcolumnname <> "imagename" ';
        $result=$adb->pquery($SQL,array($signid));
        $rows=$adb->num_rows($result);

        for($i=0;$i<$rows;$i++)
        {
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $storage_location=$adb->query_result($result,$i,'storage_location');

            $attachmentcolumnname = $adb->query_result($result,$i,'attachmentcolumnname');
            $uploadwatermark = $this->isUploadWaterMarkWhenCreate($sign_tabid,$attachmentcolumnname);
            if ($uploadwatermark == 'yes') {
                $path=$adb->query_result($result,$i,'path');
                $extension_arr=pathinfo($newfile_name);
                $extension=strtolower($extension_arr['extension']);
                if($extension=='png'||$extension=='jpg'||$extension=='jpeg')
                {
                    if($storage_location=='cos'){
                        $cloud_path = $adb->query_result($result,$i,'cloud_path');
                        $this->saveCosWaterMark($cloud_path,$path,$newfile_name,$line_arr);//cos图片添加文字水印方法
                    }else{
                        $imagetextobj=new cls_ImageText($path.$newfile_name,$newfile_name,$line_arr);
                        $imagetextobj->saveImage();
                    }
                }

            }
        }

    }
    
    //考勤签到图片保存
    public function saveFileasCommonFile($signid, $module, $imageArr){
        $T1 = array('album'=>'Computer','camera'=>'Takephoto');
        global  $adb,$PlatformMC,$current_user,$weixin_user;
        $retinfo_arr=[];
        
        foreach($imageArr as $imageval) {
            //在ld_crmentity 中添加附件的关联关系
            $attachmentsid = $adb->getUniqueID('ld_crmentity');
            $sql_crmentity = "INSERT INTO ld_crmentity(crmid,setype) values(?,?)";
            $adb->pquery($sql_crmentity,array($attachmentsid,'Singin Image'));
            //增加附件和单据字段的关联
            $sql_seattachmentsrel = "INSERT into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)";
            $adb->pquery($sql_seattachmentsrel,array($signid,$attachmentsid,'imagename'));
            
            $sql_attachments = "INSERT into ld_attachments(attachmentsid,`name`,description,type,path,`subject`,size,newfile_name,
                imagefromtype,storage_location,upload_from,cloud_path) values(?,?,?,?,?,?,?,?,?,?,?,?)";
            if($imageval['storage_location']=='')
            {
                $imageval['storage_location']='local';
                
            }
            if($imageval['storage_location']=='cos')
            {
                if(stripos($imageval['cloud_path'],'https://')!==false||stripos($imageval['cloud_path'],'http://')!==false)
                {
                   
                }
                else{
                     $imageval['cloud_path']='https://'.$imageval['cloud_path'];
                }
            }
            
            $params2 = array($attachmentsid,$imageval['filename'],'',$imageval['filetype'],$imageval['filepath'],'',$imageval['filesize'] .' B',
                $imageval['filename'],$T1[$imageval['type']],$imageval['storage_location'],'',$imageval['cloud_path']);
            $result = $adb->pquery($sql_attachments, $params2);
            
            $retinfo_arr[]=array("filename"=>$imageval['filename'],'path'=>$imageval['filepath'],'type'=>"new",'storage_location'=>$imageval['storage_location'],'cloud_path'=>$imageval['cloud_path']);
        }
         return $retinfo_arr;
    }
    //参数: 当天有未签退的外勤时，不允许继续签到
    public function isAllowSigninWhenNotSignout($module){
        crm_load_class_file('cls_OptionModule', 'include/OptionModule');
        $cls_OptionModule = cls_OptionModule::getInstance('Singin','');
        $tabid = getTabid($module);
        $frommodule_alldata = $cls_OptionModule->getSourceModule_AllData('Singin')[$tabid];
        return $frommodule_alldata['nosignout_cantsignin'];
    }
    //判断当天是否有未签退的外勤
    public function isExistsNotSignedoutToday($module){
        global $adb,$PlatformMC,$current_user,$weixin_user;

        $tabid = getTabid($module);
        $select_sql = "SELECT DISTINCT ld_singin.signid FROM ld_singin LEFT JOIN ld_signout ON ld_signout.signin_id = ld_singin.signid
                        WHERE ld_singin.deleted = 0 AND ld_singin.tabid = ? AND ld_signout.signin_id IS NULL AND ld_singin.smownerid = ? AND DATE(ld_singin.createdtime) = CURDATE()";
        $select_result = $adb->pquery($select_sql,array($tabid,$current_user->id));
        $num_rows = $adb->num_rows($select_result);
        if ($num_rows > 0) {
            return 'yes';
        }else{
            return 'no';
        }
    }
}