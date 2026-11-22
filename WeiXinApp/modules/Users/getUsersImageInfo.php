<?php
/**
*  获取用户头像信息
*/
global $adb;

$userid = $_REQUEST['userids'];

$entity['list'] = cls_StaticCommonFun::getUserDetailInfo($userid);

ConvertTojsonString(1,$entity,'success');
?>