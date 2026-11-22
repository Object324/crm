<?php
global $current_user,$adb;
$newpwd=$_REQUEST['newpwd'];

$userid=$_REQUEST['userid'];
$oldpwd=$_REQUEST['oldpwd'];
$confirmpwd=$_REQUEST['confirmpwd'];
 $crypt_type='MD5';
 require_once(globalStatic::$root_directory.'modules/Users/CheckPwd.php');

 $userObj=new Users();

 $userObj->retrieve_entity_info($userid,'Users');
$encrypted_old_password = $userObj->column_fields['user_password'];
 if(!is_admin($current_user))
 {
    if($current_user->id!=$userid)
    {
        //普通用户模拟管理员密码
        exit('$$error$$'.getFixedLabel('NOPERMISSIONTOMODIFYTHEPASSWORDS'));
    }

    $encrypted_old_password = $userObj->encrypt_password($oldpwd, $crypt_type);
    
    if($userObj->column_fields['user_password']!=$encrypted_old_password)
       {
         echo '$$error$$'.getFixedLabel('NEWPWDNOTSAMEOLD').'$$error$$';
        exit();
       }
 }
 
 $encrypted_new_password = $userObj->encrypt_password($newpwd, $crypt_type);

   $checkpwdobj = new cls_CheckPwd($current_user);
  $_REQUEST['save_checkstrictpwd']='yes';
        
 $_REQUEST['passwordinfo']=$newpwd;
 if($checkpwdobj->PasswordManage())
 {
    $sql='update  ld_users set user_password=?,pwd_checkcondition=?  where id=?';
    $pwd_checkcondition='yes';
 }
else
{
    $sql='update  ld_users set user_password=?,pwd_checkcondition=?  where id=?';
    
    $pwd_checkcondition='no';
}
$adb->pquery($sql,array($encrypted_new_password, $pwd_checkcondition,$userid));

//zkt 20240718 XUQIU20240626-12 修改密码，需要强制登录移动端
//用户密码修改后 记录密码做了修改
if($encrypted_old_password!=$encrypted_new_password)
{
    crm_load_class_file('LoginHistory','modules/Users');
    LoginHistory::Changepassword($userid);
}
else{
    echo 'REPEAT';
    exit();
}
 require_once(globalStatic::$root_directory."modules/Users/CreateUserPrivilegeFile.php");
 
 createUserPrivilegesfile($userid);
//zxm 2021-0122【修改密码增加操作日志】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001248
$userObj->insertUserLog('Users',$userid,$current_user->id,'******','******','user_password');
echo 'SUCCESS';
 exit();
 
?>