<?php
//*************************次页功能已被index_login替换，待删**************************
global $adb,$current_user;
$focus = CRMEntity::getInstance('Users');;
$focus->column_fields["user_name"] = to_html($_REQUEST['user_name']);
$user_password = vtlib_purify($_REQUEST['user_password']);
$focus->load_user($user_password);
if($_SESSION['useraccountnotexists'] == 1){
    //0026212: （微信端）关联界面，没有判断登录的用户在CRM系统中是否存在
    ConvertTojsonString(-1,null,'该CRM用户不存在！');
}
//editor:gyq_114 reason:小程序绑定优化  2019/5/23 20:20
if(empty($_REQUEST['userid']))
    ConvertTojsonString(-1,null,'ERROR:USERID MISSING');
$get_userid = $_REQUEST['userid'];
if($focus->is_authenticated()){
    $SQL = 'SELECT wx_userid FROM ld_users WHERE id=?';
    $result = $adb->pquery($SQL,array($focus->id));
    $wx_userid = $adb->query_result($result,0,'wx_userid');
    //允许自己重复绑定自己，故增加判断$wx_userid!=$get_userid
    if(!empty($wx_userid) && $wx_userid!=$get_userid){
        ConvertTojsonString(-1,null,'Tip:此账号已被其他用户绑定,请绑定其他账号');
    }else{
        //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
        $SQL = 'UPDATE ld_users set wx_userid=? WHERE wx_userid=?';
        $adb->pquery($SQL,array('',$get_userid));
        $SQL = 'UPDATE ld_users set wx_userid=? WHERE id=?';
        $adb->pquery($SQL,array($get_userid,$focus->id));
        ConvertTojsonString(1, '', 'success');
    }
}else{
    $status='Active';
    $sql="select status from ld_users where user_name=? and status='Inactive'";
    $result=$adb->pquery($sql,array($focus->column_fields["user_name"]));
    if($adb->num_rows($result)>0)
    $status=$adb->query_result($result,0,0);
    if($status=='Inactive'){
        ConvertTojsonString(-1,null,'您绑定的CRM用户已离职或停用');
    }else{
        //您的账户或密码有误，请重新输入
        ConvertTojsonString(-1,null,'您的账户或密码有误，请重新输入');
    }
}

?>