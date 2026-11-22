<?php
crm_load_class_file('VendorsQueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_SalesGoal_VendorsQueryGenerator  extends VendorsQueryGenerator{

	public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($popup='',$type='1'){
        global $current_user;

		$select_columns=$this->getSelectColumn(getTabid($this->module));


		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$this->chart_where = $this->getWhereClause();
        $fromclause=$this->getFromClause();
		if($type==1)
		{
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause ;
            $sql.=$this->chart_where;
			return $sql;
		}
		else if($type==2)
		{
            $sql= ' SELECT ' . $select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '.$fromclause;
            $sql.=$this->chart_where;

            return $sql;
		}
	}

	public function getLeftOrderBy($tableList){
		return '';
	}

}

?>