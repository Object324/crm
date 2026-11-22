<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
require_once('config.inc.php');

include($root_directory.'Smarty_setup.php');
include("includefile.php");
include_once($root_directory.'Register/RegOp.php');

//duan 20240228 增加redis读取$_SESSION,修复启用redis后,无法进入短信验证界面的问题
require_once($root_directory."Register/CRMRedis.php");
require_once($root_directory."Register/MySessionHandler.php");

global $global_crmredisobj;
$global_crmredisobj=CRMRedis::getInstance();
if($global_crmredisobj!='error')
{
    $handler = new MySessionHandler();
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
    
    //hjz 修改手机验证页面的背景图片为动态获取
    require($root_directory.'dataCache/Login/LoginSettingsInfo.php');
    $smarty->assign('backgroundbg',$global_logininfo['backgroundbg']['content']);
    
    $_SESSION['ACCOUNTSECURITYSMS']='yes';
    
    $smarty->display('AccountSecurityCenter.tpl');
}
else
{
    header("Location:index.php");
    
}

?>