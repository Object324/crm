<?php
global $adb,$current_user,$currentModule,$languageType;
$smarty=new lingdangCRM_Smarty();
$_REQUEST['diony']='diony';
$buttonhide = 'yes';
$isEntryModule = 'no';//是否为分录模块
$fld_module=$_REQUEST['currentmodule'];
$focus = CRMEntity::getInstance($fld_module);
if (get_file_address($fld_module, 'ProductDetails') || get_file_address($fld_module, $fld_module . "DetailFieldsHtml")) {
    $isEntryModule = 'yes';
        if (get_file_address($fld_module, $fld_module . 'DetailFieldsHtml')) {
        crm_load_class_file('TabDetailFields', 'include/TabDetailFields');
        $ProductToolFields = TabDetailFields::getInstance($fld_module);
        $ProductToolFieldsInfo = $ProductToolFields->setTabDetailFields();
    } else {
        crm_load_class_file('ProductToolFields', 'include/ProductDetails');
        $ProductToolFields = ProductToolFields::getInstance($fld_module);
        $tabid = getTabid($fld_module);
        $languageType = getLanguageType($current_user);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid, $languageType);
    }
    $detailtable = $focus->Detail_table;
    $detailtablescf = $focus->Detail_table_scf;
    foreach ($ProductToolFieldsInfo as $tmpindex => $productfieldinfo) {
        if (is_array($productfieldinfo)){
            foreach ($productfieldinfo as $tmpkey => $tmp_productfieldinfo){
                $tablename = $tmp_productfieldinfo->getTableName();
                if ($tablename == $detailtable || $tablename == $detailtablescf) {
                    //根据分录函数显示不同类型的字段
                    if ($tmp_productfieldinfo->isFldNumOrMoney()) {
                        $EntryFuncfieldarr['numamount'][$tmp_productfieldinfo->getColumnName()] = $tmp_productfieldinfo->getfieldLabel();
                    } elseif (in_array($tmp_productfieldinfo->getUIType(), array("5", "51", "256", "23", "14", "86", "70"))) {//date：5、51、256、23 time：14 datetime：86、70
                        $EntryFuncfieldarr['date'][$tmp_productfieldinfo->getColumnName()] = $tmp_productfieldinfo->getfieldLabel();
                    } elseif (!in_array($tmp_productfieldinfo->getUIType(), array("69"))){
                        $EntryFuncfieldarr['string'][$tmp_productfieldinfo->getColumnName()] = $tmp_productfieldinfo->getfieldLabel();
                    }
                }
            }
        }else{
            $tablename = $productfieldinfo->getTableName();
            if ($tablename == $detailtable || $tablename == $detailtablescf) {
                //根据分录函数显示不同类型的字段
                if ($productfieldinfo->isFldNumOrMoney()) {
                    $EntryFuncfieldarr['numamount'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                } elseif (in_array($productfieldinfo->getUIType(), array("5", "51", "256", "23", "14", "86", "70"))) {//date：5、51、256、23 time：14 datetime：86、70
                    $EntryFuncfieldarr['date'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                } elseif (!in_array($productfieldinfo->getUIType(), array("69"))){
                    $EntryFuncfieldarr['string'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                }
            }
        }
    }

    // 数字金额类型；数字金额日期类型（maxdate、mindate合并到了max、min）；其他类型，显示全部字段
    $smarty->assign('EntryFunction', array("Avg"=>getFixedLabel("Avg"), "Count"=>getFixedLabel("COUNT"), "CountDistinct"=>getFixedLabel("CountDistinct"), "First"=>getFixedLabel("FirstLine"), "Last"=>getFixedLabel("LastLine"), "Max"=>getFixedLabel("Max"), "Min"=>getFixedLabel("Min"), "Sum"=>getFixedLabel("Summation")));//分录函数
    $smarty->assign('EntryFuncfieldarr', $EntryFuncfieldarr);//分录函数-参数字段
}
$smarty->assign('isEntryModule',$isEntryModule);
$smarty->assign('MODULE',$_REQUEST['currentmodule']);
$smarty->assign('buttonhide',$buttonhide);
$smarty->assign('blockid',$_REQUEST['blockid']);
$content=$smarty->fetch("Settings/addPicklistField.tpl");
$arr['title']=getFixedLabel("Add_custom_fields");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");
?>