<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//chj 地图视图保存
global $adb;
$frommodule=$_REQUEST['frommodule'];
$leftfields = explode(";",$_REQUEST['selectedAssmablyColumnsString']);
$module = $_REQUEST['frommodule'];
$map_type = $_REQUEST['map_type'];
if(!empty($leftfields) && !empty($module) && !empty($map_type)){
	$query = "delete from ld_map_field where module = ? and map_type = ?";
	$adb->pquery($query,array($module,$map_type));
	foreach($leftfields as $key => $columnname){
		if(!empty($columnname)){
			$query = "insert into ld_map_field(module,sequence,columnname,map_type) values (?,?,?,?)";
			$adb->pquery($query,array($module,$key,$columnname,$map_type));
		}
	}
}
$_REQUEST['diony']='yes';
$cachekey = 'cache_map_field'.$frommodule;
unsetCache($cachekey);
ConvertTojsonString(1,array(),'success');

?>