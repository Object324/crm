<?php
/*
edit:duan
date:2022-5-24
reason:切换目标阶段后更新对应的任务信息
*/

$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$advanceid = $_REQUEST['advanceid'];

$smarty=new lingdangCRM_Smarty();

crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance_obj =  cls_module_advance::getInstance($module);
$cls_module_advance_obj->showtype = 'inpopup';
$cls_module_advance_obj->setRequestColumn($_REQUEST['requestvalue']);
$alltaskinfo_detailview = $cls_module_advance_obj->get_alltaskinfo_detailview($record);

$tmp_taskinfo_arr = $alltaskinfo_detailview[$advanceid];

$operatestyle = $cls_module_advance_obj->moduleadvance['operatestyle'];
if($operatestyle == 'inpopup'){
    $inpopup = 'yes';
}else{
    $inpopup = 'no';
}
if(isset($_REQUEST['inpopup'])){
    $inpopup = $_REQUEST['inpopup'];
}

if(is_array($tmp_taskinfo_arr['taskinfo']['taskvalue']) && sizeof($tmp_taskinfo_arr['taskinfo']['taskvalue'])>0){
    $smarty->assign('TASKLOG',$tmp_taskinfo_arr['tasklog']);
    $smarty->assign('TASKINFO',$tmp_taskinfo_arr['taskinfo']);
    $smarty->assign('ALLOWEDIT',$tmp_taskinfo_arr['allow_edit']);
    $smarty->assign('STAGENAME',$tmp_taskinfo_arr['stagename']);
    $smarty->assign('RECORD',$record);
    $smarty->assign('MODULENAME',$module);
    $smarty->assign('inpopup',$inpopup);
    $content = $smarty->fetch('Taskprogress.tpl');
}else{
    $content = '<span style="margin-top:10px;" ></span>';
}
$arr['advancedata'] = $cls_module_advance_obj->getReturnAdvanceData();
//涉及自动化任务的字段信息
if(sizeof($cls_module_advance_obj->advancetaskfield_arr)>0){
    $advancefields = $cls_module_advance_obj->advancetaskfield_arr;
    $arr['advancefields'] = $advancefields;

    $len = sizeof($advancefields);
    for($i=0;$i<$len;$i++){
        $tmp_fields = $advancefields[$i];
        if($tmp_fields['uitype'] == 15 || $tmp_fields['uitype'] == 33){
            $picklistfield = 'yes';
        }
    }

    if($picklistfield == 'yes'){
        global $global_pick_list_values,$global_picklist_colors_byvalue;
        global $global_pick_list_depencyfield;
        crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
        $DependentPicklistFields = lingdang_DependencyPicklist::getDependentPicklistFields($module);
        $picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
        $arr['global_picklist_colors_values']=$global_picklist_colors_byvalue;
        $arr['picklistcontent']=$global_pick_list_values;
        $arr['picklistdepency']=$DependentPicklistFields;
        $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
    }else{
        $arr['global_picklist_colors_values']=array();
        $arr['picklistcontent']=array();
    }
}

$arr['content'] = $content;
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");

?>