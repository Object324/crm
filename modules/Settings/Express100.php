<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
global $adb;
$smarty=new lingdangCRM_Smarty;
$mode = $_REQUEST['mode'];
$kuaiDi_100_Obj = crm_load_class_obj('KuaiDi100','WeiXinApp/kuaidi100');
if ($mode == 'save'){
    $kuaiDi_100_Obj->key_type = $_REQUEST['key_type'];
    $kuaiDi_100_Obj->key = $_REQUEST['key'];
    $kuaiDi_100_Obj->customer = $_REQUEST['customer'];
    $kuaiDi_100_Obj->updateSettingsInfo($kuaiDi_100_Obj);
}else{
    $smarty->assign('KEYTYPE', $kuaiDi_100_Obj->key_type);
    $smarty->assign('KEY', $kuaiDi_100_Obj->key);
    $smarty->assign('CUSTOMER', $kuaiDi_100_Obj->customer);
    $smarty->assign('MODE',$mode);
    $smarty->assign('SELECT',0);
    $arr['title'] = getFixedLabel('LBL_EXPRESS100_SETTINGS');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']= $smarty->fetch('Settings/Express100.tpl');
}
ConvertTojsonString(1,$arr,"success");
?>