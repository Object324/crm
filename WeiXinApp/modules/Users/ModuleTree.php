<?php
//列表树形结构，获取下级菜单
$modulelisttree = [];
global $adb;
if(!empty($_REQUEST['sourcefield']) && !empty($_REQUEST['targetfield']) && !empty($_REQUEST['listid'])){
	$sourcefield = $_REQUEST['sourcefield'];
	$targetfield = $_REQUEST['targetfield'];
	$selectrecord = $_REQUEST['listid'];
	$result = $adb->pquery('select * from ld_picklist_values where id = ?',array($selectrecord));
	if($adb->num_rows($result)>0){
		$sourcevalue = $adb->query_result($result,0,'listvalue');
		crm_load_class_file('cls_Module_Tree','include/utils');
		$cls_module_tree = new cls_Module_Tree($_REQUEST['frommodule']);
		$modulelisttree = $cls_module_tree->getFieldTargetDependency($sourcefield,$targetfield,$sourcevalue);
		$listtree_key = array_keys($modulelisttree['list']);
		$modulelisttree['list'] = array_merge($modulelisttree['list']);
		foreach($modulelisttree['list'] as $key => $arr){
			$modulelisttree['list'][$key]['listid'] = $listtree_key[$key];
			$modulelisttree['list'][$key]['parentlistid'] = $_REQUEST['listid'];
			$modulelisttree['list'][$key]['parent'] = json_encode(array($_REQUEST['sourcefield']=>$_REQUEST['listid']));
		}
	}
}
ConvertTojsonString(1,$modulelisttree,"success");