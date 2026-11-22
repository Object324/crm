<?php
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
foreach($_REQUEST['wx_productFieldInfo'] as $key=>$val){
    $_REQUEST[$key] = $val;
}
foreach($_REQUEST['p_total'] as $key=>$val){
    $_REQUEST[$key] = $val['value'];
}
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>