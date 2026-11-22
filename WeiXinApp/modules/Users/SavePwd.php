<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb;
$newpwd=$_REQUEST['newpwd'];
$userid=$current_user->id;
$oldpwd=$_REQUEST['oldpwd'];
$confirmpwd=$_REQUEST['confirmpwd'];
 $crypt_type='MD5';
 $userObj=new Users();

 $userObj->retrieve_entity_info($userid,'Users');
$encrypted_old_password = $userObj->column_fields['user_password'];
 if(!is_admin($current_user))
 {
    $encrypted_old_password = $userObj->encrypt_password($oldpwd, $crypt_type);
    
    if($userObj->column_fields['user_password']!=$encrypted_old_password)
       {
           ConvertTojsonString(-1,array(),getFixedLabel('NEWPWDNOTSAMEOLD'));
       }
 }
 
 $encrypted_new_password = $userObj->encrypt_password($newpwd, $crypt_type);
 $sql='update  ld_users set user_password=?  where id=?';
 $adb->pquery($sql,array($encrypted_new_password,$userid));
//zkt 20240718 XUQIU20240626-12 修改密码，需要强制登录移动端
//用户密码修改后 记录密码做了修改
if($encrypted_old_password!=$encrypted_new_password)
{
    crm_load_class_file('LoginHistory','modules/Users');
    LoginHistory::Changepassword($userid);
}
 require_once(globalStatic::$root_directory."modules/Users/CreateUserPrivilegeFile.php");
 
 createUserPrivilegesfile($userid);
//zxm 2021-0122【修改密码增加操作日志】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001248
$userObj->insertUserLog('Users',$userid,$userid,'******','******','user_password');
if($encrypted_old_password!=$encrypted_new_password)
{
    crm_load_class_file('LoginHistory','modules/Users');
    $loginhistoryobj=new LoginHistory();
    $loginhistoryobj->yidong_checkLogin($_REQUEST,'ajax');
}
ConvertTojsonString(1,array(),getFixedLabel('SUCCESS'));
 
?>