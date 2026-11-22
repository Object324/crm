<?php

Class cls_Query{
	
	private $mappingfields_info;
	private $selecttables;
	public $selectcolumns;
	private $fieldobj;
	private $moduleobj;
	public function __construct($module){
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance($module,$this->db);
		$this->moduleobj= CRMEntity::getInstance($module);
	}

	public function getQuery($mappingfields_info){
		$this->mappingfields_info = $mappingfields_info;
		$query = 'select ';
		$query .= $this->getSelectClauseColumnSQL();
		$query .= $this->getFromClause();
		return $query;
	}

	private function getSelectClauseColumnSQL(){
		if(!empty($this->mappingfields_info)){
			$modules = $this->fieldobj->getModuleFields();
			$columns = array_keys($this->mappingfields_info);
			foreach($columns as $columnname){
				$tablename=$this->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'tablename');
				if(!empty($tablename) && !empty($columnname)){
					$selectColumns[] = $tablename . '.'.$columnname;
				}
				$this->selecttables[$tablename] = '';
				$this->selectcolumns[] = $columnname;
			}
		}
		return implode(',', $selectColumns);
	}

	private function getFromClause(){
		$sql = ' from ' . $this->moduleobj->table_name;
		$selecttables = array_keys($this->selecttables);
		foreach($selecttables as $tablename){
			if(($tablename!=$this->moduleobj->table_name&&array_key_exists($tablename,$this->moduleobj->tab_name_index))){
				$sql.=" left join ".$tablename." on $tablename.".$this->moduleobj->tab_name_index[$tablename]." = ".$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;
			}
		}
		return $sql;
	}
}

?>