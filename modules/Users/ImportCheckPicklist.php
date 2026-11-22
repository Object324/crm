<?php
global $adb,$current_user;
$_REQUEST['diony'] = 'yes';
$smarty = new lingdangCRM_Smarty();
$frommodule = $_REQUEST['curmodule'];
$label=$_REQUEST['label'];

if ($_REQUEST['mode'] == 'save') {
    $selectcolumn_arr=json_decode($_REQUEST['selcolumn']);
    if(count($selectcolumn_arr)==0){ //不选择字段则存值为'yes'（和刚打开参数但没设置检查字段时一样）
        $selectcolumn='yes';
    }else{
        $selectcolumn=implode('##',$selectcolumn_arr);
    }
    setUsersettingByLabel($frommodule, $current_user->id,$label, $selectcolumn);
    ConvertTojsonString(1, '', 'success');
}

if ($_REQUEST['content'] != 'no'){
    $checkPicklist=getUsersettingByLabel($frommodule, $current_user->id,$label);
    $selectcolumn = [];
    if(!empty($checkPicklist) && $checkPicklist!='no' && $checkPicklist!='yes'){//yes代表虽然开启了检查,但没有设置检查字段
        $selectcolumn=explode('##',$checkPicklist);
    }

    $fields=array();
    $selfields=array();
    $focus = CRMEntity::getInstance($frommodule);
    $modulefields = $focus->fieldobj->getModuleFields();
    if($label!='ImportDetailCheckPicklist'){//明细导入不需要主表字段
        //wym 240430 BUG20240426-53 客户模块的首要联系人字段已经在其中,不需要再次获取
        /*$Contactsfields=array();
        if($frommodule=='Accounts'){
            $Contactsfocus=CRMEntity::getInstance('Contacts');
            $Contactsfields=$Contactsfocus->fieldobj->getModuleFields();
        }*/
        $allfields=$modulefields;

        foreach ($allfields as $fieldname => $fieldinfo) {
            if ($fieldinfo->getSaveDataBase() != 'yes') //不存数据库的字段跳过
                continue;
            $bigtype = $fieldinfo->getBigType();
            $uitype = $fieldinfo->getUIType();
            $modulename = getTabModuleName($fieldinfo->getTabid());
            $module_label = getTranstab($modulename);
            if ($uitype != 15) {
                continue;
            }
            $fieldlabel = $fieldinfo->getFieldLabel();
            $tablename = $fieldinfo->getTableName();
            $columnname = $fieldinfo->getColumnName();
            $optionval=$tablename.":".$columnname;
            if(in_array($optionval,$selectcolumn)){
                $selfields[$module_label."_".$fieldlabel] =$optionval;
            }else{
                $fields[$module_label."_".$fieldlabel] =$optionval;
            }
        }
    }
    if ($focus->detailfieldobj) {//分录字段
        if (get_file_address($frommodule, $frommodule . 'DetailFieldsHtml')) {
            $detailfieldlabel_prefix = getTranstab($frommodule) . getFixedLabel('DETAIL') . '_';
        } else if (get_file_address($frommodule, "ProductDetails")) {
            $detailfieldlabel_prefix = getTranstab('Products') . getFixedLabel('DETAIL') . '_';
        }
        $detailfields = $focus->detailfieldobj->getModuleProductToolField();

        foreach ($detailfields as $fieldname => $detailfieldinfo) {
            if ($detailfieldinfo->getSaveDataBase() != 'yes') //不存数据库的字段跳过
                continue;
            $bigtype = $detailfieldinfo->getBigType();
            $fieldtype = $detailfieldinfo->getFieldType();
            if ($bigtype == 'picklist' || $fieldtype=='Select') {
                $fieldlabel = $detailfieldinfo->getFieldLabel();
                $tablename = $detailfieldinfo->getTableName();
                $columnname = $detailfieldinfo->getColumnName();
                $optionval=$tablename.":".$columnname;
                if(in_array($optionval,$selectcolumn)){
                    $selfields[$detailfieldlabel_prefix."_".$fieldlabel] = $optionval;
                }else{
                    $fields[$detailfieldlabel_prefix."_".$fieldlabel] = $optionval;
                }
            }
        }
    }
}

if($_REQUEST['mode'] == 'show'){
    $smarty->assign("fields",$fields);
    $smarty->assign("selfields",$selfields);
    $arr['content'] = $smarty->fetch("ImportXlsNew/SetPicklistColumn.tpl");
    $arr['title'] = getFixedLabel('CHECKPICKLISTCOLUMN');
    $arr['oktext'] = getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel("CANCEL");
    ConvertTojsonString(1, $arr, 'success');
}elseif($_REQUEST['mode'] == 'switch') {//wym BUG20240506-15 240506 导入/导入明细->开启“校验下拉框”参数后，设置校验字段已选字段中默认显示所下拉框字段
    if($_REQUEST['content']=='no'){
        setUsersettingByLabel($frommodule, $current_user->id, $label, 'no');
    }else{
        setUsersettingByLabel($frommodule, $current_user->id, $label, implode('##',$fields));
    }
}

?>
