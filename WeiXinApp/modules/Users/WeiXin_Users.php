<?php
//gyq_117 reason:企业微信增加个人资料及修改密码  2019/5/31 15:03
crm_load_class_file('Users','modules/Users');
class WeiXin_Users extends Users
{
    public function insertIntoAttachment($id,$module)
    {
        //reason:头像的UITYPE跟图片不一样  2019/6/3 16:35
        global  $weixin_user;
        //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:32
        //editor:gyq_97 reason:小程序附件上传  2019/1/11 16:04
        if($weixin_user->environment=='weixinh5' && !empty($_REQUEST['image_save_weixin'] ) && $this->fieldobj->getFieldInfoobjBykey("uitype",105) ){
            crm_load_class_file("cls_SaveWX",'WeiXinApp/detail');
            $saveObj = new cls_SaveWX(null);
            $saveObj->saveFileFromWeiXinApi_CommonModule($id,$module,$_REQUEST['image_save_weixin']);
        }else{
            parent::insertIntoAttachment($id,$module);
        }
        /*if($PlatformMC['type_mini']){
            parent::insertIntoAttachment($id,$module);
        }else{
            $fieldinfo=$this->fieldobj->getFieldInfoobjBykey("uitype",105);
            if(!$fieldinfo)//如果没有图片字段
            {
                return ;
            }
            if(!empty($_REQUEST['image_save_weixin'] )) {

            }
        }*/
    }
    //gyq_117 reason:企业微信增加个人资料及修改密码  2019/6/3 16:05
    public function getUserImage($userid)
    {
        global $adb;
        //edit:can 20210629 46284: （企业微信移动端-kfbcrm）在电子名片中修改头像后，PC端查看成员信息头像，显示图片加载失败；PC端更换头像后，移动端只在修改头像界面加载失败
        // require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$this->id.'.php');
        $sql='select ld_attachments.path, ld_attachments.attachmentsid, ld_attachments.name ,
              ld_attachments.newfile_name,ld_attachments.size,ld_attachments.type,
              ld_attachments.storage_location,ld_attachments.cloud_path from
                        ld_salesmanattachmentsrel INNER JOIN ld_attachments  
                        on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                        where smid=? ';

        $user_result=$adb->pquery($sql,array($userid));
        $newImageArr = array();
        if($adb->num_rows($user_result)>0)
        {
            $new_name = $adb->query_result($user_result,$i,'newfile_name');
            $path = $adb->query_result($user_result,$i,'path');
            $file_path_arr = explode($path,$new_name);
            $newImageArr[0]['fileid_image']=$adb->query_result($user_result,$i,'attachmentsid');
            $newImageArr[0]['imgid']=$adb->query_result($user_result,$i,'attachmentsid');
            $newImageArr[0]['name']=$file_path_arr[1];
            $newImageArr[0]['newfile_name']=$file_path_arr[1];
            $newImageArr[0]['orgname']=$adb->query_result($user_result,$i,'name');
            $newImageArr[0]['path']=$adb->query_result($user_result,$i,'path');
            $newImageArr[0]['size']=$adb->query_result($user_result,$i,'size');
            $newImageArr[0]['value']=$new_name;
            $newImageArr[0]['storage_location']=$adb->query_result($user_result,$i,'storage_location');
            $newImageArr[0]['cloud_path']=$adb->query_result($user_result,$i,'cloud_path');
        }
        return $newImageArr;
    }
}
?>