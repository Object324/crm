<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);


include("includefile.php");
include("Register/MySessionHandler.php");
include_once($root_directory.'Register/RegOp.php');

   global $global_crmredisobj;
    $global_crmredisobj=CRMRedis::getInstance();
    if($global_crmredisobj!='error')
    {
        //36059: （1.6）报表库>即时库存余额表：即时库存数量字段的值应该是蓝色可点击跳转的。（需要补丁）
        $handler = new MySessionHandler();
   
        //session_set_save_handler($handler,true);
        session_set_save_handler(
            array($handler, 'open'),
            array($handler, 'close'),
            array($handler, 'read'),
            array($handler, 'write'),
            array($handler, 'destroy'),
            array($handler, 'gc')
            );
            register_shutdown_function('session_write_close');
    }   
    session_start();
include globalStatic::$root_directory."modules/Users/CheckPwd.php";
include('Smarty_setup.php');

if(isset($_SESSION["authenticated_user_id"]) && (isset($_SESSION["app_unique_key"]) && $_SESSION["app_unique_key"] == $application_unique_key))
{
    global $current_user;
   
    $current_user = new Users();
    $result = $current_user->retrieveCurrentUserInfoFromFile($_SESSION['authenticated_user_id']);
    
    require("user_privileges/user_privileges_".$_SESSION["authenticated_user_id"].'.php');
 
    
    require("user_privileges/user_language_".$_SESSION["authenticated_user_id"].'.php');
    /*if($languageType='')//语言格式
    {
        include("user_privileges/user_language_".$_SESSION["authenticated_user_id"].'.php');
    }*/
    
    $id=$_SESSION["authenticated_user_id"];

    $smarty = new lingdangCRM_Smarty();
    $smarty->assign('user_name',$user_info['user_name']);
    $smarty->assign('phone_mobile',$user_info['phone_mobile']);
    $smarty->assign('languageType',$languageType);
    $smarty->assign('username',$user_info['last_name']);

    /*
     * editor : gyq_01
     * reason : 新增用户密码严格管理
     * date   : 2016.1.15
     * */

    $temp = new cls_CheckPwd($current_user);

    if($_GET['PasswordTimeout'] == 1){

        $smarty->assign('NOTICEPASSWORDSTANDARDFAILED',sprintf(getFixedLabel('PMPASSWORDTIMEOUT'),$temp->days));

    }else{

        $smarty->assign('NOTICEPASSWORDSTANDARDFAILED',sprintf(getFixedLabel('NOTICEPASSWORDSTANDARDFAILED'),$temp->role));

    }

    $str = getFixedLabel('PMWARMREMINDFORPASSWORD');
    $str2 = getFixedLabel('PMWARMREMINDFORPASSWORDADD');
    $temparray = explode('$=$',str_replace(PHP_EOL,'', $str));
    $temparray = array_merge($temparray, explode('$=$',$str2));

    $newstr = '';
    foreach($temparray as $key=>$val){

        $newstr .= '<li>'.$val.'</li>';

    }
    $_SESSION['USERPMLogin']='yes';
    $smarty->assign('WARMREMINDFORPASSWORD',$newstr);

    $smarty->display('AccountSecurityCenterForPassword.tpl');
}
else
{
    header("Location:index.php");
    
}

?>