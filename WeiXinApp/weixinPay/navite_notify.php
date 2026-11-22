<?php
//native支付的回调文件
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir = dirname(dirname(dirname(__FILE__)));//获取根目录
include($root_dir . '/includefile.php');
require_once(globalStatic::$root_directory . './appCommon/appCommon.php');
require_once globalStatic::$root_directory . 'WeiXinApp/weixinPay/cls_getConfig.php';
require_once globalStatic::$root_directory . 'WeiXinApp/weixinPay/cls_notify.php';
$getConfigObj = new cls_getConfig();
$configArr = $getConfigObj->getNativePaySetting();//商户号配置 获取的方法
$configPath = $getConfigObj->getNativePayKeyPath();//证书路径 获取的方法
$_REQUEST['diony'] = 'yes';
global $adb,$current_user;

try {
    $cls_notify = new cls_notify($configArr,$configPath);
    $inBodyResourceArray = $cls_notify->getNativeNotifyArr();

    $attach = $inBodyResourceArray['attach'];//附加数据  传输模块名称 用以判断是订单支付还是充值
    $attach = json_decode($attach, true);
    $moduleName = $attach['moduleName'];//模块名称
    $record = $attach['record'];//单据ID

    //更改订单的状态
    $current_user->id =1;//先写1 后面再改
    $current_user->is_admin ="on";

    $transaction_id = $inBodyResourceArray['transaction_id'];//微信交易编号
    $trade_state = $inBodyResourceArray['trade_state'];
    $total = $inBodyResourceArray['amount']['payer_total'];

    $insert_sql = " insert into ld_weixinpay_notify (
        out_trade_no,
        transaction_id,
        trade_type,
        trade_state,
        trade_state_desc,
        bank_type,
        attach,
        success_time,
        payer_openid,
        payer_total                     
         )values(?,?,?,?,?,?,?,?,?,?)";
    $insert_res = $adb->pquery($insert_sql,array(
        $inBodyResourceArray['out_trade_no'],
        $transaction_id,
        $inBodyResourceArray['trade_type'],
        $trade_state,
        $inBodyResourceArray['trade_state_desc'],
        $inBodyResourceArray['bank_type'],
        $inBodyResourceArray['attach'],
        date('Y-m-d H:i:s',strtotime($inBodyResourceArray['success_time'])),
        $inBodyResourceArray['payer']['openid'],
        $total/100
    ));
    //更改模块单据的状态
    $focus = CRMEntity::getInstance($moduleName);
    $tablename=$focus->table_name;
    $update_sql = "update ".$tablename." set payment_status='HavePaid' where ".$focus->table_index."=?";
    $insert_res = $adb->pquery($update_sql,array(
        $record
    ));
} catch (Exception $e) {
    file_put_contents('ldmall_error.txt', '</br>' . date('Y-m-d H:i:s') . '报错信息:' . $e->getMessage(), FILE_APPEND);
}




