<?php
/*
edit:duan
date:20220926
reason:将高级查询条件转换成字符串显示
*/
crm_load_class_file('cls_AdvftOperate','include');
$arr = array();
$frommodule = $_REQUEST['frommodule'];
$advft_criteria = ldcrm_json_decode($_REQUEST['advft_criteria']);
$advft_criteria_groups = ldcrm_json_decode($_REQUEST['advft_criteria_groups']);

$AdvftOperateobj = cls_AdvftOperate::getInstance($frommodule);
$advftlabel = $AdvftOperateobj->TransAdvftTostring($advft_criteria,$advft_criteria_groups);

$arr['advftlabel'] = $advftlabel;
ConvertToJsonString(1,$arr,'success');
?>