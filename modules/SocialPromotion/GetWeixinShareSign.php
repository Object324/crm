<?php
/**
 * User: Dong
 * Project: ldcrm
 * Date: 2020/7/29 14:13
 * Description: 表单推广 静态html 请求微信分享的参数
 */
require_once ('ExternalAccessRequire.php');
$url = $_REQUEST['url'];
//require_once ('WeiXinApp/WeiXin_common/StaticConst.php');
//$getUrl = StaticConst::$server_api;
//$getUrl .= '?action=getWeixinShareSign&url='.$url;
//$getBackResult = CurlGets($getUrl);
//$result_info = json_decode($getBackResult,true);
//
//$auth_info = $result_info['result']['auth_info'];

//本地测试
$_REQUEST['diony'] ='yes';
global $site_URL;
if(!checkSiteUrl($site_URL)){
    ConvertTojsonString(-1,array('errorMsg'=>'Wechat sharing is not configured for the current website'),'success');
}

require_once ('./cls_wxjssdk.php');
$jssdk = new Wxjssdk();
$signPackage = $jssdk->getSignPackage($url);
//    返回对象是错误的直接输出错误信息
if(is_object($signPackage)){
    ConvertTojsonString(1,json_decode(json_encode($signPackage),true),'success');
}

ConvertTojsonString(1,$signPackage,'success');

function checkSiteUrl($url){
    $urlArr = array('51mis.com','61mis.com','xiaoshou360.com');
    foreach ($urlArr as $value){
       if(strpos($url,$value) !==false){
           return true;
       }
    }
    return false;
}