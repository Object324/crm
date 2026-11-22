<?php
/**
 * 微信支付通知的接收
 */
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
include($root_dir.'/includefile.php');
require_once (globalStatic::$root_directory.'./appCommon/appCommon.php');
require_once globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_getConfig.php';
require_once globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_notify.php';
$getConfigObj = new cls_getConfig();
$configArr = $getConfigObj->getShopSetting();//商户号配置 获取的方法
$configPath = $getConfigObj->getShopSettingKeyPath();//证书路径 获取的方法

$_REQUEST['diony'] = 'yes';
global  $adb;
try{
    $cls_notify = new cls_notify($configArr,$configPath);
    $inBodyResourceArray = $cls_notify->getNotifyArr();
    $attach = $inBodyResourceArray['attach'];//附加数据  传输模块名称 用以判断是订单支付还是充值
    $attach = json_decode($attach,true);
    $moduleName = $attach['moduleName'];
    require_once(globalStatic::$root_directory.'WeiXinApp/ldmall/modules/LdMallNotify.php');
    $LdMallNotifyObj = new LdMallNotify();
    switch ($moduleName){
        case 'SalesOrder'://合同订单付款
            $LdMallNotifyObj->salesorderWeixinPay($inBodyResourceArray);
            break;
        case 'CashBill'://充值 创建收款单
            $LdMallNotifyObj->recharge($inBodyResourceArray);
            break;
    }

}catch (Exception $e){
    file_put_contents('ldmall_error.txt','</br>'.date('Y-m-d H:i:s').'报错信息:'.$e->getMessage(),FILE_APPEND);
}




