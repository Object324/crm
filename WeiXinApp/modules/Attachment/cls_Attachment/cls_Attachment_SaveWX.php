<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Attachment_SaveWX extends cls_SaveWX
{
    public function common_save()
    {
        $this->before_save();

        $focus = $this->focus;
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
                
       // if(!empty($_REQUEST['attachment_save_weixin'])){
        // $this->saveAttachmentFromWeiXinApi_AttachmentModule($_REQUEST['attachment_save_weixin'],$focus->id);
        //}
        $this->after_save();
    }
    
    //普通模块附件保存，暂时只有图片
    public function saveAttachmentFromWeiXinApi_AttachmentModule($filestr,$curid){
        /*Albums  选择相册  Takephoto  拍照上传*/
        //editor:gyq_20190325 reason:区分拍照、相册、电脑上传
        return false;
        $T1 = array('album'=>'Albums','camera'=>'Takephoto');
        $fileArrNew = $filestr['new']; // 新增的图片
        $fileArrExist = $filestr['delete']; //待删除的图片
        $uuid = $filestr['uuid'];
        global $adb,$current_user;
        if(!empty($fileArrExist)){
            foreach($fileArrExist as $key=>$val){
				$adb->pquery("delete from ld_attachmentsforbillsdetails where id=?", array($val));
            }
        }
        if(!empty($fileArrNew)) {
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21

            $ACCESS_TOKEN = $port_obj->getCorpToken();

            if (!empty($ACCESS_TOKEN)) {
                $upload_file_path = decideFilePath();
                $ch = curl_init();
                foreach ($fileArrNew as $fileval) {

                    $fileurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $fileval['serverId'];

                    curl_setopt($ch, CURLOPT_URL, $fileurl);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                    $curlresult = curl_exec($ch);
                    $downloadcode= curl_getinfo($ch, CURLINFO_HTTP_CODE);
                    
                   if($downloadcode!=200)
                   {
                    //edit:can 2020-09-23 41792: （灵当开发产品，企业微信移动端）附件管理新建界面选择附件保存时，界面一直显示加载中
                    $this->checkCurlResult($curlresult);
                   }
                  
                    
                    $imagetypeEX = 'jpg'; //暂时将图片类型写死 gyqTE
                    $imagetype = 'image/jpeg';
                    $time = time();
                    $rand = mt_rand(1, 100000);
                    $filename = $time . $rand;
                    $current_id = $adb->getUniqueID("ld_crmentity");
                    $file_name_final = $filename . '.' . $imagetypeEX;//id加附件名称
                    $filename_sql = $filename . '.' . $imagetypeEX;
                    $save_path = globalStatic::$root_directory . $upload_file_path . $file_name_final;
                    mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                    $zijie = file_put_contents($save_path, $curlresult);//返回的是字节数
                    if ($zijie > 0) {
                        $filesize = filesize($save_path);
                        //确定文件大小
            			if ($filesize < 1024)
            				$filesize = $filesize . ' B';
            			elseif ($filesize > 1024 && $filesize < 1048576)
            				$filesize = round($filesize / 1024, 2) . ' KB';
            			else if ($filesize > 1048576)
            				$filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                        
                        $insertsql='INSERT INTO ld_attachmentsforbillsdetails(attachmentsid,filename,newfile_name,size,path,type,imagefromtype,uuid,storage_location) VALUES(?,?,?,?,?,?,?,?,?);';
                        $adb->pquery($insertsql,array($curid,$filename_sql,$filename_sql,$filesize,$upload_file_path,$imagetype,$T1[$fileval['type']],$uuid,'local'));
                    }
                }
                curl_close($ch);
                return true;
            }
        }
    }
}
?>