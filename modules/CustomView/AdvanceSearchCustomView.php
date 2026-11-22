<?php


class AdvanceSearchCustomView extends CustomView
{
    private static $_instance;
     public  function __construct($module='')
     {
        parent::__construct($module);
        global $current_user, $adb;
		$this->customviewmodule = $module;
		$this->escapemodule[] = $module . '_';
		$this->escapemodule[] = '_';
		$this->smownerid = $current_user->id;
		$this->moduleMetaInfo = array();
		$this->focus=CRMEntity::getInstance($module);
        $this->tablename_arr = $this->focus->tab_name;
     }
    public static function getInstance($module = ''){
        if(FALSE == (self::$_instance[$module] instanceof self)){
            self::$_instance[$module] = new self($module);

        }
        return self::$_instance[$module];
    }
    public function setSearchConditon($advft_criteria,$dvft_criteria_groups){
        $advance_search=$advft_criteria;
        $advance_search=ldcrm_json_decode(trim(html_entity_decode($advance_search)));
        $groupcondition = $dvft_criteria_groups;
        $groupcondition=ldcrm_json_decode(trim(html_entity_decode($groupcondition)));
        //wym 240426 BUG20240426-32 共享规则-如果第一条条件为默认的空选项,判断为没有设置条件
        if(!$advance_search[2]['columnname'] && $advance_search[2]['comparator']=='无'){
            $advance_search=[];
        }
        $this->advance_search = $advance_search;
        $this->groupcodition = $groupcondition;
    }
	public function getSearchConditon(){

    }
    
    //函数重写，通过数据库中储存的高级查询条件，作为customview的高级查询条件
    public function getAdvFilterByCvid($cvid='') {
        $this->getSearchConditon();
        $advance_search = $this->advance_search;
        $groupcondition = $this->groupcodition;
        foreach($advance_search as $key=>$columnsearch)
        {
            $groupid = $columnsearch['groupid'];
            $tmp_column = array();
            $tmp_column['columnname'] = $columnsearch['columnname'];
            $name = explode(':',$columnsearch['columnname']);
	        $table_name = $name[0];
            if(!in_array($table_name,$this->tablename_arr))
            {
                $this->tablename_arr[]=$table_name;//获取高级查询条件中涉及的表名
            }
            $tmp_column['comparator'] = $columnsearch['comparator'];
            $tmp_column['value'] = $columnsearch['value'];
            $tmp_column['column_condition'] = $columnsearch['columncondition'];
            $search_list[$groupid]['columns'][$key] = $tmp_column;
        }
        foreach($groupcondition as $key=>$value)
        {
            if($key == 0) continue;
            $search_list[$key]['condition']=$value['groupcondition'];
        }
        return $search_list;
    }
    
    public function getTablename_arr()
    {
        
        if(empty($this->tablename_arr)){
            return $this->tablename_arr =$this->focus->tab_name;
        }
        return $this->tablename_arr;
    }
	
}
?>