<?php

//布局规则新增和编辑界面
global $adb,$current_user;
$smarty=new lingdangCRM_Smarty();
if($_REQUEST['modulename'] == 'Events'){
    $_REQUEST['modulename'] = 'Calendar';
}
if(!empty($_REQUEST['modulename'])){
	$module = $_REQUEST['modulename'];
	$focus=CRMEntity::getInstance($module);
    $modulefields=$focus->fieldobj->getModuleFields();
	if(!empty($modulefields)){
		foreach($modulefields as $fieldname => $field){
			$uitype = $field->getUIType();
			$fieldtype = $field->getFieldDataType();
			$displaytype = $field->getDisplaytype();
			$tablename = $field->getTableName();
            if($tablename != $focus->table_name && $tablename != $focus->customFieldTable[0]){
                continue;
            }
			if($uitype == 15){
				$fieldname = $field->getFieldName();
				$fieldlabel = $field->getFieldLabelKey();
				$selectField[$fieldname] = $fieldlabel;
                $filedname_arr[] = $fieldname;
			}else if(($fieldtype == 'date' || $fieldtype == 'datetime') && $displaytype == 1){
				$fieldname = $field->getFieldName();
				$fieldlabel = $field->getFieldLabelKey();
				$selectFieldDate[$fieldname] = $fieldlabel;
			}
		}
	}

	crm_load_class_file('cls_module_advance','modules/Settings');
	$cls_module_advance_obj =  cls_module_advance::getInstance($module);
	$module_advance = $cls_module_advance_obj->getModuleAdvance();

    if(sizeof($filedname_arr)>0){
        if(!empty($_REQUEST['fieldname'])&&$_REQUEST['fieldname']!='null'){ //切换跟踪字段时获取对应的阶段任务信息。
            $fieldname = $_REQUEST['fieldname'];
            $AdvanceRelation_arr = $cls_module_advance_obj->getAdvanceRelations($fieldname);
            $alladvance = $cls_module_advance_obj->getAdvanceStageValuesbyfiled($fieldname);
            $module_advance['method'] = 'field';
        }else if(empty($module_advance['module_field']) && $module_advance['method']!='period'){
            $fieldname = $filedname_arr[0];
            $AdvanceRelation_arr = $cls_module_advance_obj->getAdvanceRelations($fieldname);
            $alladvance = $cls_module_advance_obj->getAdvanceStageValuesbyfiled($fieldname);
        }else{
            $fieldname = $module_advance['module_field'];
            //0048025:如果设置的字段未启用，改为默认第一个下拉框字段
            if(empty($modulefields[$fieldname])){
                $fieldname = $filedname_arr[0];
                $AdvanceRelation_arr = $cls_module_advance_obj->getAdvanceRelations($fieldname);
                $alladvance = $cls_module_advance_obj->getAdvanceStageValuesbyfiled($fieldname);
            }else{
                $AdvanceRelation_arr = $cls_module_advance_obj->getAdvanceRelations($fieldname);
                $alladvance = $cls_module_advance_obj->getAdvanceStageValues();
            }
        }   
    }
}
$smarty->assign('MODULEADVANCE',$module_advance);

if($module_advance['method']!='period'){
    $smarty->assign('ADVANCERELATION',$AdvanceRelation_arr);
    $smarty->assign('ALLADVANCE',$alladvance);
}
$smarty->assign('FROMMODULE',$module);
$smarty->assign('SELECTFIELD',$selectField);
$smarty->assign('SELECTFIELDDATE',$selectFieldDate);
$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['title']=getFixedLabel('PROJECTSETTINGS');
if(!empty($_REQUEST['fieldname'])){
    $str=$smarty->fetch('Settings/moduleadvance.tpl');
}else{
    $str=$smarty->fetch('Settings/LayoutBlockModuleAdvance.tpl');
}
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>