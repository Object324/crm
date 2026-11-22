<?php
crm_load_class_file("ProductDetails",'include/ProductDetails');

class AccountNormalSetProductDetails extends ProductDetails
{
     public $autoremindinfoobj;
     private $autoid;
     private $module;
     private $focus;
	 private $selectcolumn;
     public  function __construct($module,$advfilter,$advfilter_grouping)
     {
		$this->advfilter_grouping = json_decode($advfilter_grouping);
		$this->advfilter = json_decode($advfilter);
		$this->module=$module;

		$this->focus=CRMEntity::getInstance($this->module) ;
		$this->selectcolumn = $selectcolumn;
		parent::__construct($this->module,'');
       
     }
     /**
      * 重写父类方法(排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name=$this->focus->table_name;
        return $maintable_name.'.'.$this->focus->table_index.' desc';	
    }
    public function getSelectColumn($tabid)
    {
       return $this->selectcolumn;
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
         $maintable_name=$this->focus->table_name;
         
        $column_list[0]= "$maintable_name:createdtime:createdtime:$this->module_创建时间:DT";
		$column_list[1]= $this->selectcolumn;
        return $column_list;
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
      * 获取自动提醒基本查询条件
      * */
    function getStdFilterByautoid() {
		global $adb;

		
		return $stdfilterlist;
	}
    
   
    /**
     * 获取自动提醒高级查询条件
     * */
	function getAdvFilterByautoid() {
		global $adb, $default_charset;
		$advft_criteria = array();
		$i = 1;$j = 0;
		if(empty($this->advfilter)){
			return array();
		}
		foreach($this->advfilter as $advafilter_obj){
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($advafilter_obj->columnname, ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $advafilter_obj->comparator;
			$advfilterval = html_entity_decode($advafilter_obj->value, ENT_QUOTES, $default_charset);
			$col = explode(":", $advafilter_obj->columnname);
			$temp_val = explode(",", $advafilter_obj->value);
			if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
				$val = Array();
				for ($x = 0; $x < count($temp_val); $x++) {
					if ($col[4] == 'D') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDate();
					} elseif ($col[4] == 'DT') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDateTimeValue();
					} else {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayTime();
					}
				}
				$advfilterval = implode(",", $val);
			}
			$criteria['value'] = $advfilterval;
			$criteria['column_condition'] = $advafilter_obj->columncondition;
			$advft_criteria[$i]['columns'][$j] = $criteria;
			$j++;
		}
		if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
			$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
		}
		return $advft_criteria;
	}
   
}

?>