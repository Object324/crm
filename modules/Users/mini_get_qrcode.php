<?php
//editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/25 16:38
global $adb;
$sql = 'select para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
$result = $adb->pquery($sql,array());
$nums = $adb->num_rows($result);
$coid=0;
if($nums > 0) {
    $coid = $adb->query_result($result, 0, 'para_three');
}
if(empty($coid))
{
    echo '$##error$##';
}
include globalStatic::$root_directory.'weixinmp/modules/Users/mini_get_qrcode.php';