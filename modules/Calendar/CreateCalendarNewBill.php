<?php

/**
 *@edit:andy 
 *@date:20140924
 *@reason:日程新建单据弹出层 11670 销售通] 日程管理—日程管理页签—鼠标放在某个时间框里面，出来“+”，点击“+”做个弹出层效果 
 *@version:
 */
global $theme,$currentModule,$current_user,$default_charset;

$smarty = new lingdangCRM_Smarty;
if($currentModule == 'Calendar'){
    $currentModule='Events';
}
$module=$currentModule;
$focus = CRMEntity::getInstance($module);
$fieldobj=$focus->fieldobj;
$disp_view = getView($focus->mode);
$mode = 'create';

$tabid = getTabid($module);

$validationArray = $fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
if($currentModule=='Events'){
    if(!empty($_REQUEST['start_date']) && !empty($_REQUEST['time_start'])){
        $date_start=$_REQUEST['start_date'].' '.$_REQUEST['time_start'];
        $datestrart=new DateTimeField($date_start);
        $focus->column_fields['date_start'] =$datestrart->getDBInsertDateValue().' '.$datestrart->getDBInsertTimeValue();
    }
    if(!empty($_REQUEST['end_date']) && !empty($_REQUEST['time_end'])){
        $due_date=$_REQUEST['end_date'].' '.$_REQUEST['time_end'];
        $duedate=new DateTimeField($due_date);
        $focus->column_fields['due_date'] =$duedate->getDBInsertDateValue().' '.$duedate->getDBInsertTimeValue();
    }
}
$smarty->assign('BLOCKS',getBlocks($module,$disp_view,$mode,$focus->column_fields));

$smarty->assign('MODULE',$module);
$smarty->assign('THEME', $theme);
echo "###SUCCESS###";
$smarty->display('CreateCalendarNewBill.tpl');

?>