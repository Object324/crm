<?php
//标签查找
global $current_user,$adb;
$smarty = new lingdangCRM_Smarty();
if($_REQUEST['frommodule'] == 'ServiceCharge'){
    $_REQUEST['frommodule'] = 'Accounts';
}
$focus = CRMEntity::getInstance($_REQUEST['frommodule']);
$fieldobj=Field::getInstance($module,$adb);
$moduleFields=$fieldobj->getModuleFields();
$customView = CustomView::getInstance($_REQUEST['frommodule']);
$viewid = $customView->getViewId($_REQUEST['frommodule']);
$queryGenerator =  QueryGenerator::getInstance($_REQUEST['frommodule'], $current_user,$customView);
$queryGenerator->initForCustomViewById($_REQUEST['viewid']);
$page_list_query = $queryGenerator->getQuery('','groupby');
$result = $adb->pquery($page_list_query,array());
$table_index = $focus->table_index;
$num_rows = $adb->num_rows($result);
$arr = array();
if($num_rows >= 1){
	$query = "select ld_module_tag.tag,ld_module_tag.id,ld_module_tag.tag_type from ld_moduledata_tag 
	inner join ld_module_tag on ld_module_tag.id = ld_moduledata_tag.parentid 
	inner join ($page_list_query) as tmp on tmp.$table_index = ld_moduledata_tag.record
	GROUP BY id ORDER BY FIELD(tag_type,'personal','company'),ld_moduledata_tag.id asc";
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
			$tag = $adb->query_result($result,$i,'tag');
			$tag_type = $adb->query_result($result,$i,'tag_type');
			$module_tag[] = $tag;
			$module_tag_id[] = $id;
			$moduel_tag_type[] = $tag_type;
		}
	}
	foreach($moduleFields as $field){
		//模块标签字段
		$fieldName=$field->getFieldName();
		if($field->getUIType() == '301'){
			$typeOfData = $field->getTypeOfData();
			$typeOfData = explode("~", $typeOfData);
			$typeOfData = $typeOfData[0];
			$label = $field->getFieldLabelKey();
			$fieldname_str = $field->getTableName() . ":" . $field->getColumnName() . ":" . $fieldName . ":".$_REQUEST['frommodule']."_" . $label . ":" . $typeOfData;
		}
	}
	$smarty->assign('MODULE',$_REQUEST['frommodule']);
	$smarty->assign('MODULE_TAG',implode(',',$module_tag));
	$smarty->assign('MODULE_TAG_ID',implode(',',$module_tag_id));
	$smarty->assign('MODULE_TAG_TYPE',implode(',',$moduel_tag_type));
	$smarty->assign('FIELDNAME',$fieldname_str);
	
	
}
$_REQUEST['diony']='diony';
$str=$smarty->fetch("ListTag.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");


?>