<?php
//当前模块的用户字段
$module = $_REQUEST['frommodule'];
$return_fieldname = $_REQUEST['choose_fieldname'];
$select_fieldname_arr = explode(',',$select_fieldnamestr);
$focus = CRMEntity::getInstance($module);
$all_fields=$focus->fieldobj->getModuleFields();
$all_fieldlabel_arr = [];

//取出回传字段中的fieldname,用于判断是否选中
$choose_fieldname_arr = [];
if(!empty($return_fieldname)){
    $return_fieldname_arr = explode(',',$return_fieldname);
    foreach ($return_fieldname_arr as $tmp_fieldname_info){
        if(empty($tmp_fieldname_info))continue;
        $tmp_field_arr = explode(':',$tmp_fieldname_info);
        $tmp_fieldname = $tmp_field_arr[2];
        $choose_fieldname_arr[] = $tmp_fieldname;
    }
}


foreach($all_fields as $fieldname=>$fieldinfo)
{
    if(empty($fieldinfo))continue;
    $columnname=$fieldinfo->getColumnName();
    $fieldlabel=$fieldinfo->getFieldLabel();
    $fieldname = $fieldinfo->getFieldName();
    $tablename = $fieldinfo->getTableName();
    $typeofdata = $fieldinfo->getTypeOfData();
    $bigtype = $fieldinfo->getBigType();
    $allowedit = $fieldinfo->get_allowedit();
    $displaytype = $fieldinfo->getDisplaytype();
    if($fieldinfo->getSaveDataBase()=='no')
        continue;
    if($bigtype == 'boolean'){
        continue;
    }
    //获取typeofdata中的字段类型
    $tmp_fieldtype_len = 1;
    if(strpos('~',$typeofdata)!==false)$tmp_fieldtype_len = strpos('~',$typeofdata)+1;
    $fieldtype = substr($typeofdata,0,$tmp_fieldtype_len);
    //组合完整的字段信息
    $full_fieldname = $tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$fieldtype;
    if($displaytype == 1  && $allowedit == 'yes'){
        if(in_array($fieldname,$choose_fieldname_arr)){
            $actions_arr_used[$full_fieldname] = $fieldlabel;
        }else{
            $actions_arr[$full_fieldname] = $fieldlabel;
        }
        $all_fieldlabel_arr[$full_fieldname] = $fieldlabel;
    }

}
$smarty = new lingdangCRM_Smarty();
$smarty->assign('related_modules', $actions_arr);
$smarty->assign('related_module_selected',$actions_arr_used);
$smarty->assign('MODULE',$module);
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('Setmandatoryfield');
$arr['all_fieldlabel_arr']=$all_fieldlabel_arr;
$str=$smarty->fetch('Approve/SetModuleField.tpl');
$arr['reminds_field'] = getFixedLabel('pleaseenterthecategoryyouarelookingforfield');
$arr['content']=$str;

$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>