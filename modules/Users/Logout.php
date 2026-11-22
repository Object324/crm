<?php

global $LOGIN_SECURITY_CODE;

require_once('modules/Users/LoginHistory.php');
global $root_directory;
require_once('config.inc.php');

global $adb,$current_user;

$login_method = $_SESSION['login_method'];
// Recording Logout Info
	$usip=LoginHistory::getIp();
        $outtime=date("Y/m/d H:i:s");
        $loghistory=new LoginHistory();
        $loghistory->user_logout($current_user->user_name,$usip,$outtime);

//$local_log =& LoggerManager::getLogger('Logout');

   // if($redisobj!='error')
  //  {
     //  $redisobj->flushSession();
        
    //}
    
//session_unset(); 
session_destroy();
/*
$_SESSION[$root_directory]="";
$_SESSION["app_unique_key"]="";
$_SESSION[globalStatic::$root_directory."Loginout"]="loginout";
*/
define("IN_LOGIN", true);
$direct_file=globalStatic::$root_directory;
$prev_dirname=pathinfo($direct_file,PATHINFO_DIRNAME);
$http_host=$_SERVER['HTTP_HOST'];
$serverself=$_SERVER['PHP_SELF'];

if(substr($prev_dirname,-1)=="/")
{
    
}
else
{
    $prev_dirname.="/";
}
if( (strtolower($http_host)=='kehu001.com'&&stripos($serverself,'ldcrm')!==false)||file_exists($prev_dirname."login/cls_aliyInfo.php"))
{
    header("Location: http://kehu001.com/ldcrm/login"); 
    exit();
}

/**
 *@ 演示平台跳转更新
 *@ by andy 20140307
 * 
 */ 
// go to the login screen.
if($LOGIN_SECURITY_CODE == '0' ){
    header("Location: index.php?action=Login&module=Users&login_method=true"); 
}else{
    if($login_method == 1)
    {
        header("Location: index.php?action=Login&module=Users&login_method=true");
    }else{
        header("Location: index.php?action=LoginCheck&module=Users");
    }
}    
?>