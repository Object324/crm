<?php
//ls 20241225 XUQIU20241202-01 亿海蓝--AD域控对接集成
if ($version_account == 'yihailan') {
    $ldap_userid = $_REQUEST['user_name'];
    $login_user_info = $focus->getUserinfoByColumnname("ldap_userid",$ldap_userid);
    if(empty($login_user_info) || !isset($login_user_info[0]['user_name']) || empty($login_user_info[0]['user_name'])){
        //查无此用户
        $tmplogin_error = "请管理员前去CRM维护用户";
        $_SESSION['login_error'] = $tmplogin_error;
        if($_REQUEST['loginajax'] == 'yes'){
            unset($_SESSION['login_error']);
            AuthenticateLoginUnSuccessful(-1,array(),$tmplogin_error);
        }
    }
    try {
        crm_load_class_file("LDAP", 'include/LDAP');
        $ldapobj = LDAP::getInstance();
        $ldapobj->connect();//测试发现ip没有设置白名单，也会返回资源值,并不会抛出错误，因此无法通过连接返回值判断是否能连接到AD服务。。
        if ($ldapobj->authenticate($ldap_userid,$_REQUEST['user_password']??"",true)) {
            //认证通过之后，做单点登录
//            $fields = array("cn","Nickname","Phone","Email");
//            $ldapobj->search("OU=上海XX有限公司,".$ldapobj->getBaseDn(), "(uid=".$ldap_userid.")",$fields);

            global $global_dandianlogin;
            $global_dandianlogin='yes';
            $_REQUEST['user_name'] = $login_user_info[0]['user_name'];
        } else {
            //锁定CRM中账号
            $_REQUEST['user_name'] = $login_user_info[0]['user_name']??'';
            $_REQUEST['user_password'] = uniqid();//使用原有逻辑进行锁定
        }

    } catch (Exception $e) {
        $tmplogin_error = "登录异常，请检查LDAP扩展";//$e->getMessage();
        $_SESSION['login_error'] = $tmplogin_error;
    } finally {
        unset($ldapobj);//自动调用析构函数关闭资源
    }

    if($_REQUEST['loginajax'] == 'yes'&&!empty($tmplogin_error)){
        unset($_SESSION['login_error']);
        AuthenticateLoginUnSuccessful(-1,array(),$tmplogin_error);
    }
}