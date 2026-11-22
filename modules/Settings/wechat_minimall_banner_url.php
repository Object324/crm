<?php
/**
* @edit:dong
* @data:2020/08/26
* @reason:小程序商城顶部设置
* @description:
*/
global $adb;
$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");

$arr['title'] = getFixedLabel('wxmall_banner_url');

$arr['content']= $smarty->fetch('Settings/wechat_minimall_banner_url.tpl');

ConvertTojsonString(1,$arr,"success");
?>