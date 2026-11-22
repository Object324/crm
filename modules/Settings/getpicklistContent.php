<?php
//获取下拉框内容
global $adb;
$fld_module=$_REQUEST['fld_module'];
$columnname=$_REQUEST['columnname'];
$focus=CRMEntity::getInstance($fld_module);
$fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$columnname,"fieldname");
crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
$arr['picklist']=getPicklistValesForNORole($fieldname,$adb,array(),"");

$_REQUEST['diony']='diony';

ConvertTojsonString(1,$arr,"success");
?>