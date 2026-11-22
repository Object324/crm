<?php
//多选模块，获取超链接
global $current_user,$adb,$currentModule;
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
$entityarray = getEntitynameInfo(getTabid($currentModule));
$tabname = $entityarray['tablename'];//模块主表
$moduleid = $entityarray['entityidfield'];//模块主表ID
$tabfieldname = $entityarray['fieldname'];//模块链接字段
$idstring = explode(';',$_REQUEST['idstring']);
$records = [];
foreach($idstring as $id){
	if(!empty($id)){
		$records[] = $id;
	}
}
$query = "select $focus->table_name.$focus->table_index,$tabname.$tabfieldname from " . $focus->table_name . ' where ' . $focus->table_index . ' in ('.implode(',',$records).')';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
$href_id = [];
$href_name = [];
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$href_id[] = $adb->query_result($result,$i,$focus->table_index);
		$href_name[] = $adb->query_result($result,$i,$tabfieldname);
	}
}
$_REQUEST['diony']='diony';
$arr['href_id']=implode(',',$href_id);
$arr['href_name']=implode(',',$href_name);
ConvertTojsonString(1,$arr,"success");


?>