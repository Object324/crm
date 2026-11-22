<?php
/*
edit:duan
reason:中孚账套添加收入计划功能，创建页面
*/
global $currentModule;
$smarty=new lingdangCRM_Smarty;
$picklistvalue = picklistvalue();//获取动态日期下拉框的值
$smarty->assign("listvalue",$picklistvalue);
$fld_moudle = 'CustomForm48';
$fld_moudle_focus = CRMEntity::getInstance($fld_moudle);
$frommodule_focus = CRMEntity::getInstance($currentModule);
setObjectValuesFromRequest($fld_moudle_focus);//读取模块默认值
if($currentModule == 'SalesOrder'){//获取对应模块的金额字段
    $smarty->assign("LABEL",$frommodule_focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldlabel'));
}else{
    $smarty->assign("LABEL",$frommodule_focus->fieldobj->getFieldInfoBykeyValue("columnname",'amount','fieldlabel'));
}
$smarty->assign("YEAR",$fld_moudle_focus->fieldobj->getFieldInfoBykeyValue("columnname",'cf_4288','fieldlabel'));
$smarty->assign("MOUTH",$fld_moudle_focus->fieldobj->getFieldInfoBykeyValue("columnname",'cf_4285','fieldlabel'));
$smarty->assign("AMOUNT",$fld_moudle_focus->fieldobj->getFieldInfoBykeyValue("columnname",'cf_4284','fieldlabel'));
$smarty->assign("MODULE",$currentModule);
$field_value = array(
    'cf_4284' => $fld_moudle_focus->column_fields['cf_4284'],
    'cf_4285' => $fld_moudle_focus->column_fields['cf_4285'],
    'cf_4288' => $fld_moudle_focus->column_fields['cf_4288']    
);
$smarty->assign('FIELDVALUES',$field_value);
$_REQUEST['diony']='yes';
$title = getFixedLabel('CREATEBATCH').'-'.getTranstab($fld_moudle);
$arr['title'] = $title;
$arr['frommodule']=$currentModule;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('Createrevenue.tpl');

ConvertTojsonString(1,$arr,"success");

function picklistvalue()//获取动态日期下拉框的值
{
    global $adb;
    $sql = "select ld_picklist_values.listvalue from ld_picklist_set 
    LEFT JOIN ld_picklist_values on ld_picklist_set.listid = ld_picklist_values.listid 
    where listname = 'cf_4288' and relatetable = 'ld_field' order by sequence";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++)
    {
        $picklistvalue[] = array(
        'value'=>$adb->query_result($result,$i,'listvalue')
    );
    }
    $picklistvalues['year']=$picklistvalue;
    
    $sql = "select ld_picklist_values.listvalue from ld_picklist_set 
    LEFT JOIN ld_picklist_values on ld_picklist_set.listid = ld_picklist_values.listid 
    where listname = 'cf_4285' and relatetable = 'ld_field' order by sequence";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++)
    {
        $picklistvalue_mouth[] = array(
            'value'=>$adb->query_result($result,$i,'listvalue')
        ); 
    }
    $picklistvalues['mouth']=$picklistvalue_mouth;
    return $picklistvalues; 
}
?>