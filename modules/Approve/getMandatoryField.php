<?php
/*
 * edit:duan
 * reason:获取审批方式对应的字段
 * date:20230717
 * */
$module = $_REQUEST['frommodule'];
$record = $_REQUEST['record'];
$stepid = $_REQUEST['stepid'];
$approvestatus = $_REQUEST['approvestatus'];

$arr = [];
crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
$mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($module);
global $current_user;
$mandatoryfieldobj->setRequestColumn($_REQUEST['requestvalue']);
$mandatoryfieldobj->CommonEditFieldobj->setEmptyFieldOnly('no');
$result_arr = $mandatoryfieldobj->CreateFieldHtml($record,$stepid,$approvestatus);
$arr['mandatory_field_arr'] = $result_arr['field'];
$arr['content'] = $result_arr['html'];
$arr['approvedata'] = $mandatoryfieldobj->getReturnApproveData();
$arr['isadmin'] = is_admin($current_user)?'yes':'no';

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");
?>