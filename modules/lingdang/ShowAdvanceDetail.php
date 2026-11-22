<?php
/*
edit:duan
date:2022-5-22
reason:显示推进阶段详情信息
*/
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$stagename = $_REQUEST['stagename'];

$smarty=new lingdangCRM_Smarty();

crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance_obj =  cls_module_advance::getInstance($module);

if($cls_module_advance_obj->moduleadvance['method'] == 'field'){
    $fieldname = $cls_module_advance_obj->moduleadvance['module_field'];
}else{
    $fieldname = 'advance_stage';
}

$modtracker_value = $cls_module_advance_obj->getModtrackerData_public($record,$fieldname);

$smarty->assign('ModtrackerData',$modtracker_value[$stagename]);

//如果选择追踪字段类型，则可以关联任务信息
if($cls_module_advance_obj->moduleadvance['method'] == 'field'){
    $DetailTaskinfo = $cls_module_advance_obj->getAdvanceDetailTaksinfo($record,$stagename);
    $smarty->assign('DetailTaskinfo',$DetailTaskinfo);
}
$smarty->assign('RECORD',$record);
$smarty->assign('MODULENAME',$module);
$smarty->assign('inpopup','yes');

$content = $smarty->fetch('DetailView/ShowAdvanceDetail.tpl');

$_REQUEST['diony']='diony';
$arr['stagename'] = $stagename;
$arr['showstaytimecontent'] = getFixedLabel('STAGEDETENTIONDURATION').'：'.$modtracker_value[$stagename]['showstaytimecontent'];
$arr['content'] = $content;
$arr['title'] = getFixedLabel('ADVANCEPUSHDETAIL').'：'.$stagename;
$arr['oktext']=getFixedLabel("CONFIRME");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>