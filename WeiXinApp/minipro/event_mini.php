<?php
/**
 * Created by PhpStorm.
 * User: gao
 * Date: 2018/9/12
 * Time: 13:53
 */
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");

$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
require_once($root_dir . '/includefile.php');
require_once($root_dir . '/appCommon/appCommon.php');

require_once $root_dir . '/WeiXinApp/minipro/EventMiniModel.php';
require_once $root_dir . '/WeiXinApp/minipro/const_mini.php';
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
//editor:gyq_125 reason:新增包含cls_MP_CommonFun  2019/6/19 15:10
require_once($root_dir.'/weixinmp/include/cls_MP_CommonFun.php');
$model_obj = new EventMiniModel();
if(isset($_REQUEST['action'])){
    $action  = $_REQUEST['action'];
    $model_obj->$action();
}
?>
