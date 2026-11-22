<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");

$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
include($root_dir.'/includefile.php');
include_once ($root_dir.'/WeiXinApp/cloudpro/CloudUsers.php');
// require_once($root_dir.'/include/Zend/Json.php');
//include (globalStatic::$root_directory.'./appCommon/appCommon.php');

$model = new CloudUsers();
if(isset($_REQUEST['action'])){
    $action  = $_REQUEST['action'];
    $res = $model->$action();
    $_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1,$res,'success');
}
