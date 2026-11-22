<?php
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
include_once($root_dir.'/includefile.php');
include_once (globalStatic::$root_directory.'./appCommon/appCommon.php');
global $adb;
//查询公众号APPID 和SECRET
$sql = " select para_content from ld_wx_config where name='wechat_miniprogram_setting'";
$res = $adb->pquery($sql);
$para_content = $adb->query_result($res,0,'para_content');
$para_content = Zend_Json::decode($para_content);
$appid = $para_content['offiaccount_appid'];
$appsecret = $para_content['offiaccount_secret'];
if(empty($appid)||empty($appsecret)){
    ConvertTojsonString(-1,array(),getFixedLabel('Appletremindersettings').getFixedLabel('CANOTEMPTYGTH'));
}
//crm小程序 推送消息到公众号的 对应公众号的appid secret
//$appid = 'wx70bee1ea15cf5889';
//$appsecret = 'd6db480411ae09f25c9c80b5b61f6ad4';
$_REQUEST['diony']='yes';
include_once (globalStatic::$root_directory.'include/weixinMsg/cls_WeChatSubscription.php');
$WeChatSubscriptionObj = new cls_WeChatSubscription($appid,$appsecret,'CRMoffiaccount','CRM公众号','CRMoffiaccount');
$WeChatSubscriptionObj->getUserList();
$msg = $WeChatSubscriptionObj->getUsersInfo();
ConvertTojsonString(1,array(),$msg);
//首次同步 需要多次点击已保证历史数据同步完成，因为一次点击仅同步100个用户