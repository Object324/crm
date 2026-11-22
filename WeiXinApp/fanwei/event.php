<?php
//editor:gyq_144 reason:登陆绑定
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
require_once($root_dir . '/includefile.php');
require_once($root_dir . '/appCommon/appCommon.php');
require_once $root_dir . '/WeiXinApp/fanwei/model/event_model.php';
include_once($root_dir . '/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
// define('NONCESTR','ldcrm_abcdefg');
// define('H5HTML','WeiXinApp/fanwei/websaas/ldcrm/index.html');
$model_obj = new event_model();
switch ($_REQUEST['action']) {
    //根据泛微工号获取用户表id
    case 'get_userid':
        $result = $model_obj->get_userid($_REQUEST['fanwei_userid_encode']);
        ConvertToJsonString(1,array('userid'=>$result) ,'success');
        break;
}

?>
