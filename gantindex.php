<?php
$root_dir=(dirname(__FILE__));//获取根目录
define("ROOT_DIR",$root_dir);
require_once($root_dir.'/includefile.php');
require_once($root_dir.'/Register/MySessionHandler.php');

globalStatic::$root_directory=$root_directory;
global $global_crmredisobj;
global $adb,$root_directory,$current_user;
$global_crmredisobj=CRMRedis::getInstance();

if($global_crmredisobj!='error')
{
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


// 下面这行代码可以防止使用对象作为会话保存管理器时可能引发的非预期行为


session_start();

if(empty($current_user)){
    $current_user = new Users();
}
$current_user->id=$_SESSION['authenticated_user_id'];
if(empty($current_user->id))
 exit('请登录');
require_once('modules/Project/ganttView.php');
exit();



?>
