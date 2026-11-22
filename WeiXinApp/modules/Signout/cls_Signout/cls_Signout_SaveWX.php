<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Signout_SaveWX extends cls_SaveWX
{
    private $signid;
    public function common_save()
    {
        global $adb,$current_user;
        
        $focus = $this->focus;
        //签退保存前判断
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
        
        //签退保存后操作
        $this->signid=$focus->id;
        $this->after_save( );
    }
    
    public function before_save(){
        global $current_user,$adb,$PlatformMC,$currentModule;
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
        $distance=$signdata['distance'];
        $address=$signdata['address'];
        $select_sql = "SELECT tabid,record from ld_singin where signid = ?";
        $select_result = $adb->pquery($select_sql, array($_REQUEST['signoutfromid']));
        $tabid = $adb->query_result($select_result, 0, 'tabid');
        $record = $adb->query_result($select_result, 0, 'record');
        $module = getTabModuleName($tabid);
        if($record=='-1')
        {
            $msg = sprintf(getFixedLabel('TMPNAMECANNOTBEEMPTY'),getTranstab($module));
            ConvertTojsonString('-1','',$msg);
        }
        //签退方式翻译转换
        // $translatedbvalue_arr = getTranslateDbValue($currentModule,'signout_type');
        // $translatedbvalue_arr = $translatedbvalue_arr[$currentModule]['signout_type'];
        // foreach($translatedbvalue_arr as $column_dbvalue=>$db_label)
        // {
        //     if(getFixedLabel($db_label) == $_REQUEST['signout_type']){
        //         $_REQUEST['signout_type'] = $column_dbvalue;
        //         break;
        //     }
        // }
        if($_REQUEST['signouttype']==''){
            $_REQUEST['signouttype'] = 'signout';
        }else if($_REQUEST['signouttype']=='supsignout'){
            $_REQUEST['signouttype'] = 'supsign';
        }
        $_REQUEST['signout_type'] = $_REQUEST['signouttype'];
        $modulelist = getSinginOptionModule();
        if(!empty($modulelist[$tabid])){
            if($_REQUEST['signouttype'] != 'supsign'){
                if($modulelist[$tabid]['no_signin'] == 'yes' && $distance > $modulelist[$tabid]['allowable_distance']){
                    $jsonArray['list'] = array('distance'=>$distance,'address'=>$address);
                    $msg = str_replace('{metre}',$modulelist[$tabid]['allowable_distance'],getFixedLabel('Theadministratorhassetthatitisnotallowedtosignout'));
                    ConvertTojsonString(-1,$jsonArray,$msg);
                }
            }
        }
        
    }
    
    public function after_save( ){
        global $current_user;
        $signdata = $_REQUEST['signData'];
        $record = trim($_REQUEST['selectlistval']);
        $module = $_REQUEST['selectsourcename'];
        $address = $signdata['address'];
        $tabid = getTabid($module);
        // 签退图片添加水印
        $this->setWatermark($this->signid, $tabid, $address);
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
        global $current_user;
        // 判断签退中图片字段是否开启水印
        // $uploadwatermark = $this->isUploadWaterMark(getTabid('Signout'),$tabid);//Singin 142
        $fileFieldArr = $this->focus->fieldobj->getFieldInfoobjBykey_arr("bigtype", 'fileattachment');
        if (is_array($fileFieldArr) && count($fileFieldArr) > 0) {
            foreach ($fileFieldArr as $fieldinfo) {
                // $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname', 'signout_imagename');
                if ($fieldinfo) {
                    if ($fieldinfo->getUIType() == 69 && $fieldinfo->getUploadwatermark() == 'yes') {
                        crm_load_class_file('cls_ImageText', 'include');
                        $line_arr = array();
                        // $line_arr[] = $current_user->last_name;
                        $line_arr[] = getUserFullName($current_user->id);
                        $line_arr[] = DateOperation::getDateChinese(date("Y-m-d")) . ' ' . DateOperation::getWeekName(date("Y-m-d")) . " " . date("H:i");
                        $line_arr[] = $address;

                        $filejsondata = $this->getimageinfobycolumn($signid, 'Signout', $fieldinfo->getColumnName());
                        // dump($filejsondata);

                        foreach ($filejsondata as $imageInfo) {
                            $imageInfo['path'] = $imageInfo['file_path'];
                            $imageInfo['filename'] = $imageInfo['newfile_name'];
                            if ($imageInfo['storage_location'] == 'local') {
                                $imagetextobj = new cls_ImageText($imageInfo['path'] . $imageInfo['filename'], $imageInfo['filename'], $line_arr);
                                $imagetextobj->saveImage();
                            } else {
                                //edit:can 54682:客户问题（立凯电子），小程序，拜访签到，图片字段没有显示签到水印（苹果手机） 
                                if (is_array($imageInfo['cloud_path'])) {
                                    $cloud_path = $imageInfo['cloud_path'][0];
                                } else {
                                    $cloud_path = $imageInfo['cloud_path'];
                                }
                                $this->saveCosWaterMark($cloud_path, $imageInfo['path'], $imageInfo['filename'], $line_arr);//cos图片添加文字水印方法
                            }
                        }
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
            $adb->pquery($sql_crmentity,array($attachmentsid,'Signout Image'));
            //增加附件和单据字段的关联
            $sql_seattachmentsrel = "INSERT into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)";
            $adb->pquery($sql_seattachmentsrel,array($signid,$attachmentsid,'signout_imagename'));
            
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

}