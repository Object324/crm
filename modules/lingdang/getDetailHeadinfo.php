<?php
global $currentModule;
$_REQUEST['diony']='yes';
$focus = CRMEntity::getInstance($currentModule);
$focus->retrieve_entity_info($_REQUEST['record'],"SalesOrder");
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
$focus->id = $_REQUEST['record'];
$focus->name=$focus->column_fields[$focus->list_link_field];
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$arr = [];
crm_load_function_file('getDetailViewHeadinfo','include/utils','DetailViewUtils');
$arr = getDetailViewHeadinfo($arr,$currentModule,$focus);
ConvertTojsonString(1,$arr,'success');
?>