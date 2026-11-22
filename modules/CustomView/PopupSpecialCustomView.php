<?php
/**
 * 弹出框查询（例如选择客户，选择联系人，选择产品等)
**/
class PopupSpecialCustomView extends CustomView
{
    
   
     private $module;
     public  $focus;
     private $tabid;
	 private $moduleFields;
	 private $listheader;
	 private $searchFieldArr;
     public  function __construct($module=''){
        $this->module=$module;
        $this->tabid=getTabid($module);
        $this->focus=CRMEntity::getInstance($module) ;
        $tmp_field_obj=$this->focus->fieldobj;
		$this->moduleFields=$tmp_field_obj->getModuleFields();
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
		if($this->module == 'Faq'){
			//显示列： 常见问题编号， 问题， 回答
			$list = array('faq_no','question','faqcategories','faqtype');
			foreach($list as $fieldname){
				if(!empty($this->moduleFields[$fieldname])){
					$tableName = $this->moduleFields[$fieldname]->getTableName();
					$columnName = $this->moduleFields[$fieldname]->getColumnName();
					$fieldName = $this->moduleFields[$fieldname]->getFieldName();
					$typeofData = $this->moduleFields[$fieldname]->getTypeOfData();
					$column_list[] = $tableName . ':' . $columnName . ':' . $fieldName . ':' . $this->module .'_fieldlabel' . ':' . $typeofData;
					$this->listheader[$fieldname] = $this->moduleFields[$fieldname]->getfieldLabel();
					$this->searchFieldArr[] = $columnName;
				}
			}
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
	* 获取列表列头
	* */
	function getListViewHeader(){
		return $this->listheader;
	}
	/**
	* 获取固定查询字段
	* */
	function getSearchField(){
		return $this->searchFieldArr;
	}
    /**
     * 获取高级查询条件
     * */
	function getAdvFilterByautoid() {

	  $keywords=$_REQUEST['keywords'];
      if(!empty($keywords))
      {
         foreach($this->searchFieldArr as $index=>$content)
          {
             if($index!=count($this->searchFieldArr)-1)
                $advft_criteria[1]['columns'][]=array('columnname'=>$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$this->module.'_fieldlabel'.$content['typeofdata'],
                                                    'comparator'=>'binary','value'=>$keywords,'column_condition'=>'or');
             else
                  $advft_criteria[1]['columns'][]=array('columnname'=>$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$this->module.'_fieldlabel'.$content['typeofdata'],
                                                    'comparator'=>'binary','value'=>$keywords,'column_condition'=>'');
          }
          $advft_criteria[1]['condition']='';
      }
     else
     {
        $advft_criteria=array();
     }
      
		return $advft_criteria;
	}
  
}



?>