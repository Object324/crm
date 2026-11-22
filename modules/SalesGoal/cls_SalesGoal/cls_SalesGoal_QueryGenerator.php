<?php
crm_load_class_file('QueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_SalesGoal_QueryGenerator  extends QueryGenerator{

	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		parent::__construct($module, $user,$customerview,$productDetailsobj);
    }

    public function gettabshareSql()
    {
        
        return '';
    }

	public function getQuery($puputype='',$type="1") {
		//$sql=parent::getQuery('');
        global $current_user;
		$select_columns=$this->getSelectClauseColumnSQL();

		$this->chart_where = $this->getWhereClause();
		$fromclause=$this->getFromClause();
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		 
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

    public function getSelectClauseColumnSQL(){
        if(!empty($this->columns)){
            return $this->columns;
        }
        $columns = array();
        $moduleFields = $this->fieldobj->getModuleFields();//lingdangcrmobjectmeta.php
        $accessibleFieldList = array_keys($moduleFields);
        $accessibleFieldList[] = 'id';
       // dump($this->customViewColumnList );
        foreach ($this->customViewColumnList as $tmp_key => $customViewColumnInfo) {

            $coltables=explode(':',$customViewColumnInfo);
            $fieldname = $coltables[2];
            $columnname = $coltables[1];
            $tmp_column = $coltables[0].'.'.$coltables[1];
            $fieldinfo=$this->moduleobj->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
           if(!isset($fieldinfo))
           {
                continue;
           }
            if($fieldinfo&&$fieldinfo->getUIType()==1109)
                continue;

            $tmp_sql_column = $tmp_column;
            //统计字段需要判断是否除以币种
            if($tmp_key == 'countfield' && ($this->module == 'CashBill'|| $this->module == 'SendCashBill')){
                if($fieldinfo && ($fieldinfo->istotalFldMoneyField() || $fieldinfo->isPriceField())){
                    if(!empty($moduleFields['currency_id']))
                    {
                        $fields = $moduleFields['currency_id'];
                        $tmp_sql_column = "IF(".$fields->getTableName().".currency_id > 1,$tmp_column/".$fields->getTableName().".conversion_rate,$tmp_column) as ".$coltables[1];
                    }
                }
            }
            $columns[] = $tmp_sql_column;

            $moduleFields = $this->fieldobj->getModuleFields();
            $fieldinfo = $moduleFields[$fieldname];
            if(array_key_exists($fieldinfo->getTableName(),$this->moduleobj->tab_name_index)&&$fieldinfo->getTableName()!=$this->moduleobj->table_name)
            {
                $this->select_column_from_join[$fieldinfo->getTableName()]='  on '.$fieldinfo->getTableName().'.'.$this->moduleobj->tab_name_index[$fieldinfo->getTableName()].'='.$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;

            }
            $this->selecttables[$fieldinfo->getTableName()]='';
        }
        $this->columns_array=$columns;

        $this->columns = implode(', ',$columns);
        
        // 获取其他需要读取出来的字段，例如敏感规则，附件字段权限等
        //$this->columns = $this->getOtherSelectClauseColumn();

        return $this->columns;
    }

	
	public function getLeftOrderBy($tableList){
		return '';
	}
}

?>