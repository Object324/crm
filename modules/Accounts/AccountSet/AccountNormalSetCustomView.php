<?php


class AccountNormalSetCustomView extends CustomView
{
	public $autoremindinfoobj;
	private $autoid;
    public $module;
	public  $focus;
	public  $selectcolumn;
	public  function __construct($module,$advfilter,$advfilter_grouping)
	{
		$this->module=$module;
		parent::__construct($this->module);
		$this->advfilter_grouping = json_decode($advfilter_grouping);
		$this->advfilter = json_decode($advfilter);

		$this->focus=CRMEntity::getInstance($this->module) ;
		$this->selectcolumn = $selectcolumn;
	}
     /**
      * 重写父类方法(排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name=$this->focus->table_name;
        return $maintable_name.'.'.$this->focus->table_index.' desc';	
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
         $maintable_name=$this->focus->table_name;
         
        $column_list[0]= "$maintable_name:createdtime:createdtime:$this->module_创建时间:DT";
        if(!empty($this->selectcolumn))
		  $column_list[1]= $this->selectcolumn;
        return $column_list;
    }
    /**
     * 重写父类基本查询方法
     * */
	function getStdFilterByCvid() {
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
	* 获取高级查询条件
	* */
	function getAdvFilterByautoid() {

		global $adb, $default_charset;

		$advft_criteria = array();
		crm_load_class_file('CommonView',"modules/CustomView");
		$datetimestr=CommonView::MysqlFilterDateTimeStr("");//获取日期，时间本年，明年等下拉框字符串
		$i = 1;
		$j = 0;
		foreach($this->advfilter_grouping as $groupId => $groupobj){
			if(!empty($groupId)){
				$groupCondition = $groupobj->groupcondition;
				if(empty($this->advfilter)){
					return array();
				}
				foreach($this->advfilter as $advafilter_obj){
					if($i == $advafilter_obj->groupid){
						$criteria = array();
						$criteria['columnname'] = html_entity_decode($advafilter_obj->columnname, ENT_QUOTES, $default_charset);
						$criteria['comparator'] = $advafilter_obj->comparator;
						$advfilterval = html_entity_decode($advafilter_obj->value, ENT_QUOTES, $default_charset);
						$col = explode(":", $advafilter_obj->columnname);
						if(array_key_exists($advafilter_obj->comparator,$datetimestr))
						{ 
							//如果是本年明年，n天后等
							$temp_val[0]=$datetimestr[$advafilter_obj->comparator][0];
							$temp_val[1]=$datetimestr[$advafilter_obj->comparator][1];
						}else{
							$temp_val = explode(",", $advafilter_obj->value);
						}
						if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
							$val = Array();
							$advfilterval = implode("#", $temp_val);
						}
						$criteria['value'] = $advfilterval;
						$criteria['column_condition'] = $advafilter_obj->columncondition;
		
						$advft_criteria[$i]['columns'][$j] = $criteria;
						$advft_criteria[$i]['condition'] = $groupCondition;
						$j++;
					}
				}
				if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
					$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
				}
				$i++;
			}
		}
		if (!empty($advft_criteria[$i - 1]['condition']))
			$advft_criteria[$i - 1]['condition'] = '';

		return $advft_criteria;
	}
   
}

?>