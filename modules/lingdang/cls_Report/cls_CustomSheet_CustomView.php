<?php

class cls_CustomSheet_CustomView extends CustomView
{
    public $columnlist;
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
    public function getStdFilterByautoid() {
		return array();
	}

	/**
	* 获取高级查询条件
	* */
    public function getAdvFilterByautoid() {
		return array();
	}
    public function setColumnsList($columnlist){
        $this->columnlist = $columnlist;
    }
    public function getColumnsListByCvid($cvid) {
        return $this->columnlist;
        /*测试数组return [
            '0'=>'ld_potential:potentialname:potentialname:Potentials_fieldlabel:V',
            '1'=>'ld_potential:accountid:account_id:Potentials_fieldlabe:V',
            '2'=>'ld_potential:sales_stage:sales_stage:Potentials_fieldlabe:V'
        ];*/
    }
}
?>