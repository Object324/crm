<?php

Class cls_SaveMappingFields{
	
	private $mappingfields_info;
	private $selecttables;
	private $selectcolumns;
	private $fieldobj;
	private $moduleobj;
	private $cls_query;
	private $curfieldvalues;
	private $module_no;

	public function __construct($module,$record){
		crm_load_class_file('cls_Query','modules/Leads');
		$this->cls_query = new cls_Query('Leads');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance($module,$this->db);
		$this->moduleobj= CRMEntity::getInstance($module);
		$this->record = $record;
		$this->tabid = getTabid('Leads');
		$this->module_no = array('Accounts' => 'account_no','Contacts' => 'contact_no');
	}
	
	public function Upgrade(){
		global $current_user;
		crm_load_class_file('cls_MappingFields','modules/Leads');
		$cls_MappingFields = new cls_MappingFields('Leads');
		$this->mappingfields_info = $cls_MappingFields->getMappingFields('Accounts');
		$this->getCurFieldValues();
		$insertfields = $this->getInsertFields();
		if(!empty($insertfields)){
			foreach($insertfields as $mapping_module => $column_array){
				$focus= CRMEntity::getInstance($mapping_module);
				$fieldobj=Field::getInstance($mapping_module,$this->db);
				if($mapping_module == 'Accounts' && empty($this->curfieldvalues['accountname'])){
					continue;
				}
				if($mapping_module == 'Contacts' && empty($this->curfieldvalues['contactname'])){
					continue;
				}
				foreach($column_array as $columns){
					$fieldname = $fieldobj->getFieldInfoBykeyValue('columnname',$columns['mappingcolumn'],'fieldname');
					$focus->column_fields[$fieldname] = $this->curfieldvalues[$columns['curcolumn']];
					if($this->module_no[$mapping_module] == $fieldname){
						$focus->operate_api = 'api';	
						$_REQUEST[$fieldname] = $this->curfieldvalues[$columns['curcolumn']];
					}
				}
				if(isset($focus->column_fields['servicecasher'])){
					$focus->column_fields['servicecasher'] = $current_user->id;
				} 
				if(empty($focus->column_fields['assigned_user_id'])){
					$focus->column_fields['assigned_user_id'] = $current_user->id;
				}
				if(empty($focus->column_fields['creator'])){
					$focus->column_fields['creator'] = $current_user->id;
				}
				if($mapping_module == 'Contacts' && $accountid > 0){
					$focus->column_fields['account_id'] = $accountid;
					$focus->column_fields['reference'] = 1;
				}
				$focus->column_fields['createdtime'] = date('Y-m-d H:i:s');
				$focus->mode="Create";
				$focus->save($mapping_module);
				if($mapping_module == 'Accounts'){
					$accountid = $focus->id;
					$this->db->pquery('update ld_account set servicecasher = ? where accountid = ?',array($current_user->id,$focus->id));
					$this->db->pquery('update ld_tabshare set crmid = ? where crmid = ?',array($focus->id,$this->record));
				}
			}
			$data['accountid'] = $accountid;
			$data['code'] = 1;
		}
		return $data;
	}
	public function saveMappingFields($mappingfields_info,$map_module){
		$this->mappingfields_info = json_decode($mappingfields_info,true);
		if(!empty($this->mappingfields_info)){
			$focus= CRMEntity::getInstance('Leads');
			$fieldobj=Field::getInstance('Leads',$this->db);
             //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段 客户模块有首要联系人
            if($map_module=='Accounts'){
                $query = 'delete from ld_module_mappingfields where tabid = ? and (mapping_module=? or mapping_module="Contacts")';
            }else{
                $query = 'delete from ld_module_mappingfields where tabid = ? and mapping_module=?';
            }
			$this->db->pquery($query,array($this->tabid,$map_module));

			foreach($this->mappingfields_info as $columnname => $mapfields){
				$fieldid = $fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldid');
				$mapFieldsInfo = explode('|',$mapfields);
                if(sizeof($mapFieldsInfo)<=3){
                    $mapFieldsInfo[3] = '';
                }
				if($fieldid > 0){
					$query = 'insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled,mapped_columnname) values (?,?,?,?,?,?,?)';
					$this->db->pquery($query,array($this->tabid,$fieldid,$columnname,$mapFieldsInfo[0],$mapFieldsInfo[1],$mapFieldsInfo[2],$mapFieldsInfo[3]));
				}
			}
		}
		unsetCacheDirectory('mappingfields');
		return 'success';
		/*$this->getCurFieldValues();
		$insertfields = $this->getInsertFields();
		if(!empty($insertfields)){
			foreach($insertfields as $mapping_module => $column_array){
				$focus= CRMEntity::getInstance($mapping_module);
				$fieldobj=Field::getInstance($mapping_module,$this->db);
				foreach($column_array as $columns){
					$fieldname = $fieldobj->getFieldInfoBykeyValue('columnname',$columns['mappingcolumn'],'fieldname');
					$focus->column_fields[$fieldname] = $this->curfieldvalues[$columns['curcolumn']];
					if($this->module_no[$mapping_module] == $fieldname){
						$focus->operate_api = 'api';	
						$_REQUEST[$fieldname] = $this->curfieldvalues[$columns['curcolumn']];
					}
				}
				if(empty($focus->column_fields['assigned_user_id'])){
					$focus->column_fields['assigned_user_id'] = $current_user->id;
				}
				if(empty($focus->column_fields['creator'])){
					$focus->column_fields['creator'] = $current_user->id;
				}
				if($mapping_module == 'Contacts' && $accountid > 0){
					$focus->column_fields['account_id'] = $accountid;
					$focus->column_fields['reference'] = 1;
				}
				$focus->mode="Create";
				$focus->save($mapping_module);
				if($mapping_module == 'Accounts'){
					$accountid = $focus->id;
				}
			}
			return 'success';
		}*/
	}
	//获取对应映射模块的映射字段
	private function getInsertFields(){
		if(!empty($this->curfieldvalues)){
			foreach($this->mappingfields_info as $curcolumn => $module_fields){
				if(!empty($module_fields['mapping_module']) && !empty($module_fields['mapping_columnname'])){
					$insert_fields[$module_fields['mapping_module']][] = array(
						'curcolumn' => $curcolumn,
						'mappingcolumn' => $module_fields['mapping_columnname']
					);
				}
			}
			if(!empty($insert_fields['AccountsContacts'])){
				$contacts_fields = array('bill_country'=>'mailingcountry','bill_state'=>'mailingstate','bill_city'=>'mailingcity','bill_street'=>'mailingstreet');
				foreach($insert_fields['AccountsContacts'] as $column){
					$insert_fields['Accounts'][] = $column;
					if(!empty($insert_fields['Contacts'])){
						if(array_key_exists($column['curcolumn'],$contacts_fields)){
							$insert_fields['Contacts'][] = array(
								'curcolumn' => $column['curcolumn'],
								'mappingcolumn' => $contacts_fields[$column['curcolumn']]
							);
							$this->curfieldvalues[$contacts_fields[$column]] = $this->curfieldvalues[$column['curcolumn']];
						}
						else
							$insert_fields['Contacts'][] = $column;
					}
				}
				unset($insert_fields['AccountsContacts']);
			}
		}
		return $insert_fields;
	}

	//获取当前单据字段在DB中对应的值
	private function getCurFieldValues(){
		$query = $this->cls_query->getQuery($this->mappingfields_info);
		$query .= ' where '.$this->moduleobj->table_name.'.'.$this->moduleobj->table_index . ' = ' . $this->record;
		$result = $this->db->pquery($query);
		$num_rows = $this->db->num_rows($result);
		if($num_rows >= 1){
			foreach($this->cls_query->selectcolumns as $columnname){
				$this->curfieldvalues[$columnname] = $this->db->query_result($result,0,$columnname);
			}
		}
	}
}

?>