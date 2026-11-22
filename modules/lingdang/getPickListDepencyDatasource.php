<?php
$module=$_REQUEST['module'];
$parentfieldname=$_REQUEST['parentfieldname'];

crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
//$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasourceByParentFieldname($module,$parentfieldname,$_REQUEST['targetfield'],$_REQUEST['parentdependfieldvalue']);
$arr['picklistDependencyDataSource']=$picklistDependencyDatasource;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");

?>