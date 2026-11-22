<?php
/***
首页组件视图-》销售漏斗点击弹出层查询
***/
class cls_Report_CustomView extends CustomView
{
     public  function __construct($module='')
     {
        parent::__construct($module);
     }

     /**
      * 重写父类方法(分类排序)
      * */
    public function getCustomViewOrderBy($cvid)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getCustomViewOrderBy($cvid);
    }

	/**
	* 重写父类基本查询方法
	* */
	function getStdFilterByCvid() {
		return array();
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
		return array();
	}
}
?>