<?php
require_once('config.inc.php');
include('include/database/PearDatabase.php');
include('include/DatabaseUtil.php');
include('modules/Users/Users.php');
//include('include/language/zh_cn_version.lang.php');
include('include/utils/CacheInfo.php');
if(file_exists("dataCache/Login/zh_cn_version_new.lang.php")){
    include("dataCache/Login/zh_cn_version_new.lang.php");
}else{
    include("include/language/zh_cn_version.lang.php");
}
session_start();
global $adb,$current_user;
if(!isset($adb))
{
    $adb=PearDatabase::getInstance();
    
}
global $default_timezone;
if(isset($default_timezone) && function_exists('date_default_timezone_set')) {
	@date_default_timezone_set($default_timezone);
} 
$current_user = new Users();

$sql='select id from ld_users  where user_name=?';
$result=$adb->pquery($sql,array('admin'));

$_SESSION['authenticated_user_id']=$adb->query_result($result,0,0);
$_SESSION[$root_directory]='lingdang';

$result = $current_user->retrieveCurrentUserInfoFromFile($_SESSION['authenticated_user_id']);
$_SESSION["app_unique_key"] =$application_unique_key;
$_REQUEST['auto']='yes';
include('modules/SalesOrder/KDeeOrder.php');
include('modules/SalesOrder/KDeeIncreatment.php');
?>
<html>
<head>

</head>
<body>




</body>


</html>