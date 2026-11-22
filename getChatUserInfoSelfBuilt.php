<?php
//自建应用
//该文件位于账套上，当身份认证后（oauth2），携带code参数访问
//根据code获取登录用户的userid
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Access-Control-Allow-Origin: *');
$root_dir = dirname(__FILE__);
if (substr(PHP_OS, 0, 3) == 'WIN') {
    $root_dir = str_replace('\\', '/', $root_dir);
}
include($root_dir . '/includefile.php');

global $adb;
crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
$wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
$corp_link = $wxselfbuilt_obj->corp_link;

//根据code获取用员工信息，比如UserId（返回值明文，需要转密文）。https://developer.work.weixin.qq.com/document/path/91023
$userInfo_obj = $wxselfbuilt_obj->corpApiObj->GetUserInfoByCode($_REQUEST["code"]);
$wx_userid = $userInfo_obj->UserId;

if (!empty($userInfo_obj->deviceId)) {
    $wxselfbuilt_obj->deviceId = $userInfo_obj->DeviceId;
}

$location= $corp_link.'webapi/wechatSidebar.html?userid='.$wx_userid.'&corp_link='.$corp_link.'&a='.rand(1,9999);
 
header("Location:".$location);
exit;



?>
