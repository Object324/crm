<?php
/**
 * 
**/
crm_load_class_file("ProductDetails",'include/ProductDetails');

class Map_ProductDetails extends ProductDetails
{
     private $module;
     private $focus;
     private $tabid;
     private $listfields;
    
    function __construct($module){
        global $current_user;
        $languageType=getLanguageType($current_user);
        parent::__construct($module,$languageType);
    }
   
    /**
     *
     * @param String:ModuleName $module
     * @return EntityMeta
     */
   function getSelectColumn($tabid){
        global $adb,$current_user;
        $module = $this->customviewmodule;
		crm_load_class_file("cls_map_field",'modules/Accounts/Map');
		$cls_map_field = new cls_map_field($module);
		$map_field_list = $cls_map_field->getAllMapFields();
		$map_field = array();
		if(!empty($map_field_list)){
			$focus = CRMEntity::getInstance($module);
			$objmoduleFields=$focus->fieldobj->getModuleFields();
			$this->fields_property[]=$module;
			foreach($map_field_list as $map_type => $map_fields){
				foreach($map_fields as $columns){
					$col_arr = explode(':',$columns);
					$fieldname = $col_arr[2];
					$Objfield=$objmoduleFields[$fieldname];
					if(!isset($Objfield)){
						continue;
					}
					if(isset($map_field[$fieldname])){
						continue;
					}
					$map_field[$fieldname] = $fieldname;
					$field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                    $fieldlabel=$field->getFieldLabelKey();
					$this->listViewHeaderSearch[$field->getColumnName()]=$fieldlabel;
					$columnlist[] = $field->getTableName(). '.' . $field->getColumnName();
					$this->list_fields[]=$fieldname;
				}
			}
		}
		$columnlist=array_filter($columnlist);
        $this->HeaderColumns=$columnlist;
        return implode(',', $columnlist);
    }
   
    /**
     * 重写父类基本查询方法
     * */
    function getStdFilterByCvid($cvid) {
        return $this->getStdFilterByautoid();

    }
    /**
     * 重写父类高级查询方法
     * */
    public function  getAdvFilterByCvid($cvid) {
        return $this->getAdvFilterByautoid();
    }
    /**
     * 获取基本查询条件
     * */
    function getStdFilterByautoid() {
       
        return array();
    }

}

?>