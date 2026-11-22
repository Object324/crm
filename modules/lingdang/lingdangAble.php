<?php
/*
 * edit:duan
 * date:20230314
 * reason:销售指标操作按钮文件
 * */
global $currentModule, $current_user, $adb;

$mode = $_REQUEST['mode'];
$code = 1;
$msg = 'success';
$scopetype = 'TargetRange';
$arr = array();


if($mode == 'getlinkfieldlabel'){
    $linkfieldname = getEntityName($_REQUEST['selectmodule'],explode(',',$_REQUEST['chooseentityid']));
    $arr['chooseentityname'] = implode(',',$linkfieldname);
}

ConvertTojsonString($code,$arr,$msg);
?>
