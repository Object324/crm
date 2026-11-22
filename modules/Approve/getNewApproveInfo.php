<?php

//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$smarty = new lingdangCRM_Smarty;
$record = $_REQUEST['record'];
$module = $_REQUEST['frommodule'];

$cur_approveinfo = $_REQUEST['cur_approveinfo'];
if(isset($_REQUEST['requestvalue_arr'])){
    $requestvalue_arr = $_REQUEST['requestvalue_arr'];
}else{
    $requestvalue = $_REQUEST['requestvalues'];
    $requestvalue_arr = ldcrm_json_decode($requestvalue);
}
$columnvalue_arr = $requestvalue_arr;
if(isset($_REQUEST['detaildata_arr'])){
    $detaildata_arr = $_REQUEST['detaildata_arr'];
    $columnvalue_arr = array_merge($columnvalue_arr,$detaildata_arr);
}


$focus = CRMEntity::getInstance($module);
//获取不在界面上显示的字段值
if($record > 0){
    $focus->mode = 'edit';
    $focus->id = $record;
    $focus->retrieve_entity_info($record,$module);
    //布局规则控制不显示的字段不应该赋值
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($module);
    $fieldruleobj->setColumnValues($requestvalue_arr);
    $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
    $hidden_column = $fieldrulecolsproperty['hidecolumns'];
    foreach ($hidden_column as $tmp_column){
        $columnvalue_arr[$tmp_column] = '';
    }
}
//$approveinfo = $this->submitApprove($tabid);
crm_load_class_file("cls_approvestep_change","modules/Approve");
$approvestep_change_obj = new cls_approvestep_change($module);
$approvestep_change_obj->set_focus($focus);
$approvestep_change_obj->set_approveobj('');
$approvestep_change_obj->set_column_value($columnvalue_arr);
$approvestep_change_obj->setdetailrowcnt($detaildata_arr['rowcnt']);

$approve_arr = $approvestep_change_obj->getApplicableApproveInfo();

$cur_approveid = 0;
foreach ($approve_arr as &$tmp_info){
    if($cur_approveid == 0){
        $cur_approveid = $tmp_info['approveid'];
    }
    if($tmp_info['approveid'] == $cur_approveinfo['approveid']){
        $tmp_info['selected'] = 'selected';
        $cur_approveid = $tmp_info['approveid'];
    }else{
        $tmp_info['selected'] = '';
    }

}

$arr = [];
$arr['approve_arr'] = $approve_arr;
$nextStepInfo = [];
if($cur_approveid > 0){
    crm_load_class_file("ApproveCommon","modules/Approve");
    $approvecommonobj = ApproveCommon::getInstance($module);
    $approveobj = $approvecommonobj->getApproveobjByApproveid($cur_approveid);
    $approveobj->setApprovechangeCheck($columnvalue_arr);
    $nextStepInfo = $approveobj->getApproveStepInfo($cur_approveid, $record);
}

$smarty->assign('APPROVEFIRSTSTEP', $nextStepInfo);
$smarty->assign('APPROVE', $approve_arr);
$smarty->assign('RECORD', $record);
$smarty->assign('ApproveModule', $module);
$smarty->assign('APPROVETYPE', $_REQUEST['approvetype']);
$smarty->assign('SELECTLEN', $_REQUEST['selectlen']);

$str = $smarty->fetch("Approve/SubmitApproveNew.tpl");
$arr['approve_html'] = $str;

$_REQUEST['diony'] = 'diony';
ConvertTojsonString(1,$arr,'success');
?>
