<?php
/**
 * 地图视图字段
**/
class cls_map_field 
{
	public $all_map_field;
	protected $module;
    function __construct($module) {
		$this->module = $module;
		$this->getAllMapFields();
	}
	
	//地图视图设置列表字段
	public function getMapField_List(){
		return $this->all_map_field['list'];
	}
	//地图视图设置详情字段
	public function getMapField_Detail(){
		return $this->all_map_field['detail'];
	}
	//获取所有的地图视图设置字段
	public function getAllMapFields(){
		global $adb;
		$cachekey = 'cache_map_field'.$this->module;
		$cachemodulelistview = Cache($cachekey);
		if($cachemodulelistview){
			$this->all_map_field=$cachemodulelistview;
			return $this->all_map_field;
		}
		$query = "select columnname,map_type,sequence from ld_map_field where module = ?";
		$result = $adb->pquery($query,array($this->module));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$map_type = $adb->query_result($result,$i,'map_type');
				$sequence = $adb->query_result($result,$i,'sequence');
				$this->all_map_field[$map_type][$sequence] = $adb->query_result($result,$i,'columnname');
			}
		}
		Cache($cachekey,$this->all_map_field);
		return $this->all_map_field;
	}
}

?>