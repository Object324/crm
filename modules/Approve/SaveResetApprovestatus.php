<?php
//zkt 20231116 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

//ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
$_REQUEST['diony']='yes';
$fldmodule = vtlib_purify($_REQUEST['fld_module']);

$saveResetApprovestatus = false;

$focus = CRMEntity::getInstance($fldmodule);
if ($_REQUEST['record'] > 0) {
    $focus->mode = 'edit';
    $focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id, $fldmodule);
}
setObjectValuesFromRequest($focus);

$approveobj = new Approve();
if($approveobj->SaveResetApprovestatus($fldmodule)){
    ConvertTojsonString("1",array(),'success');//允许再次提交审批，需要提示信息 //“已批准/已拒绝的单据允许再次提交审批” 且 “审批结束允许编辑单据” 都勾选时，编辑保存给出提示信息，并重置审批状态为“未提交”，反写模块数据（相当于反审批）
}
else{
    ConvertTojsonString("2",array(),"success");//不允许再次提交审批，不需要提示信息
}


?>