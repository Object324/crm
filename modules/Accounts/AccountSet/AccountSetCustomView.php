<?php


class AccountSetCustomView extends CustomView
{
    public $autoremindinfoobj;
     private $autoid;
     private $module;
     public  $focus;
	 public  $selectcolumn;
     public  function __construct($pool_id)
     {
        $this->module='Accounts';
        parent::__construct($this->module);
  
        
        $this->pool_id = $pool_id;	//公海池id
        
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

	

		$i = 1;
		$j = 0;
         crm_load_class_file('CommonView',"modules/CustomView");
         $datetimestr=CommonView::MysqlFilterDateTimeStr("");//获取日期，时间本年，明年等下拉框字符串
		  $sql='select * from ld_account_set_advfilter_grouping where pool_id = ?  ORDER BY groupid';
        $groupresult=$adb->pquery($sql,array($this->pool_id));
        
      	while ($relcriteriagroup = $adb->fetch_array($groupresult)) 
       {
      	              $groupId = $relcriteriagroup["groupid"];
		             	$groupCondition = $relcriteriagroup["group_condition"];
            			$ssql = 'select ld_account_set_advfilter.* from ld_account_set_advfilter';
            			$ssql.= " where groupid=? and pool_id = ? order by ld_account_set_advfilter.columnindex";
                       
                
            			$result = $adb->pquery($ssql, array($groupId,$this->pool_id));
            			$noOfColumns = $adb->num_rows($result);
            			if ($noOfColumns <= 0)
            				return array();
                        
                      
    			     while ($relcriteriarow = $adb->fetch_array($result)) 
                     {
            				$columnIndex = $relcriteriarow["columnindex"];
            				$criteria = array();
            				$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
            				$criteria['comparator'] = $relcriteriarow["comparator"];
            				$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
            				$col = explode(":", $relcriteriarow["columnname"]);
                             if(array_key_exists($criteria['comparator'],$datetimestr))
                            {
                                
                           
                                //如果是本年明年，n天后等
                                $temp_val[0]=$datetimestr[$criteria['comparator']][0];
                                $temp_val[1]=$datetimestr[$criteria['comparator']][1];
                               
                            }
                            else
            			     	$temp_val = explode(",", $relcriteriarow["value"]);
            				if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end')
                             || ($col[4] == 'DT')) {
            					$val = Array();
                             
            					$advfilterval = implode("#", $temp_val);
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
                $i++;
        }
	
		// Clear the condition (and/or) for last group, if any.
		if (!empty($advft_criteria[$i - 1]['condition']))
			$advft_criteria[$i - 1]['condition'] = '';
         //echo '<pre>';
          //print_r($advft_criteria);
        //  echo '</pre>';
          //exit();
        
		return $advft_criteria;
	}
   
}

?>