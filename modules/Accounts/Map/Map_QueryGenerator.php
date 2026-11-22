<?php
crm_load_class_file('ServiceChargeQueryGenerator','include/QueryGenerator');
class Map_QueryGenerator extends ServiceChargeQueryGenerator
{
	public function  __construct($module, $user,$customerview='')
	{
		parent::__construct($module, $user,$customerview='');
		 $this->ownerFields['promodifiedby']='modifiedby';
        $this->ownerFields['procreator']='creator';
        $this->ownerFields['proassigned_user_id']='assigned_user_id';
        
        $this->ownerFields['ServiceContractsassigned_user_id']='ServiceContractsassigned_user_id';
        $this->ownerFields['ServiceContractsmodifiedby']='ServiceContractsmodifiedby';
        $this->ownerFields['ServiceContractscreator']='ServiceContractscreator';
       
		$this->createProductDetailsObj();
        $this->productFocus=CRMEntity::getInstance('Products');
        $this->serviceContactFocus=CRMEntity::getInstance("ServiceContracts");
	}
	
	public function createProductDetailsObj()
    {
        crm_load_class_file('Map_ProductDetails','modules/Accounts/Map');
        $this->productDetails=Map_ProductDetails::getInstance($this->module);
        $this->productDetails->querygenerator=$this;
    }

	function getSelectColumn($tabid){
        global $adb,$current_user;

        if(!empty($this->HeaderColumns)){
            //zxm 20230830 这个方法返回值应该是个字符串
            return implode(',', $this->HeaderColumns);;
            return $this->HeaderColumns;;
        }
        $module = 'Accounts';
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
			$columnlist[] = 'ld_account.accountid';
		}
		$this->ProductTableColumn = array(1);
		$columnlist=array_filter($columnlist);
        $this->HeaderColumns=$columnlist;
        return implode(',', $columnlist);
    }
}


?>