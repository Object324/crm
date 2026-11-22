<?php

class MarketSpread extends CRMEntity
{
     var $db;
    var $table_name='ld_market_person';
    public $table_index='marketpersonid';

    var $tab_name=Array('ld_market_person');
    var $tab_name_index=Array('ld_market_person'=>'marketpersonid');
   	

    var $Detail_table="ld_market_accountsave";//明细表名称
    var $Detail_table_index="market_personid";//明细表和主表关联ID
    var $Detail_table_id="accountsaveid";//明细表主键名称
    
	var $column_fields = Array();
    var $module_name='MarketSpread';
   
            var $list_link_field= '';
            
            
            	var $search_fields_name = Array(
		          
			);
            
            var $required_fields =  array();

//比录项

	var $default_order_by = 'createdtime';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="cashbill_no";
    
    
    var $detailfieldobj;//明细字段对象
    
    	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('MarketSpread',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('MarketSpread');
        $this->list_link_field=$entityname['fieldname'];
	}
    
    
     public function getEntityDeletedQuery(){
			
			return ' 1=1 ';
	}
    
    /**
      * 获取模块创建人字段
      * */
     public function getCreateColumnName()
     {
        return "";
     }
}

?>