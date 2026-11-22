<?php
/*
edit:duan
date:2022-5-11
reason:勾选后，直接保存两个阶段之间的推进关系
*/
global $adb;
//获取基本参数
$frommodule = $_REQUEST['frommodule'];//当前模块
if($frommodule == 'Events'){
    $frommodule = 'Calendar';
}
$module_field = $_REQUEST['module_field'];//追踪字段
$stagename_start = $_REQUEST['stagename_start'];//开始阶段
$stagename_target = $_REQUEST['stagename_target'];//目标阶段
$presence = $_REQUEST['presence'];//是否启用 0表示启用,1表示不启用
$from_tabid = getTabid($frommodule);

$sql = 'select advanceid from ld_advancepicklist where tabid = ? and fieldname = ? and stagename = ? and stagename_target =? order by advanceid desc limit 1';
$result = $adb->pquery($sql,array($from_tabid,$module_field,$stagename_start,$stagename_target));
//判断该推进关系是否已存在
if($adb->num_rows($result)>0){
    $advanceid = $adb->query_result($result,0,'advanceid');
    $sql = 'update ld_advancepicklist set presence = ? where advanceid=?';
    $adb->pquery($sql,array($presence,$advanceid));
}else{
    $sql = 'insert into ld_advancepicklist(tabid,fieldname,stagename,stagename_target,presence) values(?,?,?,?,?)';
    $adb->pquery($sql,array($from_tabid,$module_field,$stagename_start,$stagename_target,$presence));
    $advanceid = $adb->getLastInsertID();
}
$arr['advanceid'] = $advanceid;

ConvertTojsonString(1,$arr,"success");
?>