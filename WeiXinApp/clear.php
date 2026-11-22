<?php
/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/9/29 0021
 * Time: 下午 5:36
 * 清除微信版本号缓存
 */
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(__FILE__));

include($root_dir.'/includefile.php');
include($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
include($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
// require_once($root_dir.'/include/Zend/Json.php');

file_put_contents(globalStatic::$root_directory.'dataCache/weixin/version.txt','');






