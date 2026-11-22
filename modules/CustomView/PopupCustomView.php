<?php
/**
 * 弹出框查询（例如选择客户，选择联系人，选择产品等)
**/
class PopupCustomView extends CustomView
{


    public $module;
    public  $focus;
    private $tabid;
    public $searchFieldArr;

    public  function __construct($module='')
    {
    
        $this->module=$module;
        $this->tabid=getTabid($module);
        $this->focus=CRMEntity::getInstance($module) ;
        $tmp_field_obj=$this->focus->fieldobj;
        $this->searchFieldArr=$tmp_field_obj->getSearchKeyField();
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
      
        foreach($this->searchFieldArr as $index=>$content)
        {
            $column_list[$index]=$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$this->module.'_fieldlabel'.$content['typeofdata'];
        }
     
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
      * 获取基本查询条件
      * */
    function getStdFilterByautoid() {
	    return array();
	}
    
   
    /**
     * 获取高级查询条件
     * */
	function getAdvFilterByautoid() {

        $keywords = $_REQUEST['keywords'];

        if (!empty($keywords)) {
            foreach ($this->searchFieldArr as $index => $content) {
                //20791: 新建单据界面：选择客户名称弹出层，输入字母查询，建议统一不区分大小写。
                if ($index != count($this->searchFieldArr) - 1)
                    $advft_criteria[1]['columns'][] = array(
                        'columnname' => $content['tablename'] . ':' . $content['columnname'] . ':' . $content['fieldname'] . ':' . $this->module . '_fieldlabel' . $content['typeofdata'],
                        'comparator' => 'c',
                        'value' => $keywords,
                        'column_condition' => 'or'
                    );
                else
                    $advft_criteria[1]['columns'][] = array(
                        'columnname' => $content['tablename'] . ':' . $content['columnname'] . ':' . $content['fieldname'] . ':' . $this->module . '_fieldlabel' . $content['typeofdata'],
                        'comparator' => 'c',
                        'value' => $keywords,
                        'column_condition' => ''
                    );
            }
            $advft_criteria[1]['condition'] = '';
        } else {
            $advft_criteria = array();
        }

        return $advft_criteria;
    }
  
}



?>