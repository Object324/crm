<?php
global $current_user,$currentModule,$adb,$languageType;

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['record'])){
	$record = $_REQUEST['record'];
	$query = 'select service_type,customform22_id,customform23_id,customform24_id from ld_customform18 where customform18id = ? and deleted = 0';
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$service_type = $adb->query_result($result,0,'service_type');
	$record = 0;
	if($service_type == '报关订单'){
		$record = $adb->query_result($result,0,'customform22_id');
	}else if($service_type == '空运订单'){
		$record = $adb->query_result($result,0,'customform24_id');
	}
	crm_load_class_file('cls_LangjieModuleDetails','modules/CustomForm18');
	$cls_LangjieModuleDetails = new cls_LangjieModuleDetails(0,$record,$service_type);
	$order_detailfield_all = $cls_LangjieModuleDetails->getOrderModuleFields();
	crm_load_class_file('cls_productDetailsData',"modules/CustomForm18/ProductDetails");
	$ProductDetailsData = new cls_productDetailsData('CustomForm18');
	$order_detailfield = $ProductDetailsData->getLangjieOrderDetailField();
	$order_detailfield['width'] += 23;//第一列操作行宽度
	if($order_detailfield['width'] < 255)$order_detailfield['width'] = 281;
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array('object_field'=>$order_detailfield_all['fields'],'width'=>$order_detailfield['width'],'object_field_all'=>$order_detailfield['cur_fields']),"success");
	exit();
}else{
	crm_load_class_file('cls_LangjieModuleDetails','modules/CustomForm18');
	$cls_LangjieModuleDetails = new cls_LangjieModuleDetails(0,0,'报关订单');
	$cls_LangjieModuleDetails->declare_module = 'CustomForm12';	//默认进口
	$order_detailfield = $cls_LangjieModuleDetails->getOrderModuleFields();
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array('object_field'=>$order_detailfield['fields'],'width'=>$order_detailfield['width'],'object_field_all'=>$order_detailfield['cur_fields']),"success");
	exit();
}
?>