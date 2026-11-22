<?php
global $calpath;

global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
global $adv_filter_options;


class BusinessCustomView extends CustomView{
    
    private static $_instance;
    public $advfiltertablename="";
    public $advfiltergrouptablename="";
    
    function __construct($module = "") {
		
       
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
    
    /**
     * 防止被克隆
     */
    private function __clone(){}
    /**
     * 单例初始化类对象
     */
    public static function getInstance($module = ''){
        if(FALSE == (self::$_instance[$module] instanceof self)){
            self::$_instance[$module] = new self($module);
           
        }
        return self::$_instance[$module];
    }
    
    
    
    //获取数据库存储的没有工商信息不允许存储的例外条件
    public function getSearchConditon(){
        $module = $this->customviewmodule;
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($module);
        $businessinformation_arr = $businessinformationobj->getBusinessInformation();
        $advance_search=$businessinformation_arr['nosave_exception_column'];
        $groupcondition = $businessinformation_arr['nosave_exception_group'];
        //zkt 0047984: （https://81mis.com/kfbcrm [^]）客户模块中，开启了只允许工商信息查询结果才能保存，但是参数控制没有生效
        $advance_search=ldcrm_json_decode(trim(html_entity_decode($advance_search)));
        //客户未设置条件时，应查询工商查询结果
        if(empty($advance_search))
        {
            //[{"groupid":"1","columnname":"ld_account:account_no:account_no:Accounts_fieldlabel:V","comparator":"e","value":"-1","columncondition":""}]
            $advance_search[0]=array('groupid'=>1,'columnname'=>'ld_account:accountid:accountid:Accounts_fieldlabel:V',
                                        'comparator'=>'e','value'=>-1,'columncondition'=>''
                                        ); 
        }
        $groupcondition=ldcrm_json_decode(trim(html_entity_decode($groupcondition)));
        $this->advance_search = $advance_search;
        $this->groupcodition = $groupcondition;
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
            if(is_array($this->tablename_arr) && !in_array($table_name,$this->tablename_arr))
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