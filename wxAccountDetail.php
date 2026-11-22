<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');
$root_dir = dirname(__FILE__);
if (substr(PHP_OS, 0, 3) == 'WIN') {
    $root_dir = str_replace('\\','/', $root_dir);
}
include($root_dir.'/includefile.php');

if (isset($_REQUEST['selfbuilt']) && $_REQUEST['selfbuilt'] == 'yes') {
    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Accounts/cls_wxAccountDetailSelfBuilt.php");
}else{
    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Accounts/cls_wxAccountDetail.php");
}
