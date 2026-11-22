<?php
global $current_user,$currentModule,$adb,$languageType;

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
$record = $_REQUEST['record_id'];
$selectmodule = $_REQUEST['selectmodule'];
crm_load_class_file('cls_LangjieModuleDetails','modules/CustomForm25');
$cls_LangjieModuleDetails = new cls_LangjieModuleDetails($record,$selectmodule);

$data = $cls_LangjieModuleDetails->getOrderDetails();

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('object_data'=>$data),"success");
exit();
?>