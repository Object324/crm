<?php
crm_load_class_file("ProductDetails",'include/ProductDetails');

class AccountSetProductDetails extends ProductDetails
{
     public $autoremindinfoobj;
     private $autoid;
     private $module;
     private $focus;
	 private $selectcolumn;
     public  function __construct($pool_id)
     {
		$this->pool_id = $pool_id;	//公海池id
       
        $this->module='Accounts';
        
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

		$i = 1;
		$j = 0;
		
			$ssql = 'select ld_account_set_advfilter.* from ld_account_set_advfilter where pool_id = ? ';
			$ssql.= "   order by ld_remindcvadvfilter.columnindex";
           
			$result = $adb->pquery($ssql, array($this->pool_id));
			$noOfColumns = $adb->num_rows($result);
			if ($noOfColumns <= 0)
				return array();
      
			while ($relcriteriarow = $adb->fetch_array($result)) {
				$columnIndex = $relcriteriarow["columnindex"];
				$criteria = array();
				$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
				$criteria['comparator'] = $relcriteriarow["comparator"];
				$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
				$col = explode(":", $relcriteriarow["columnname"]);
				$temp_val = explode(",", $relcriteriarow["value"]);
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
				$criteria['column_condition'] = $relcriteriarow["column_condition"];

				$advft_criteria[$i]['columns'][$j] = $criteria;
				$advft_criteria[$i]['condition'] = $groupCondition;
				$j++;
			}
			if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
				$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
			}
	
		// Clear the condition (and/or) for last group, if any.
		if (!empty($advft_criteria[$i - 1]['condition']))
			$advft_criteria[$i - 1]['condition'] = '';
          
		return $advft_criteria;
	}
   
}

?>