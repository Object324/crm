<?php
/***
首页组件视图-》销售漏斗点击弹出层查询
***/
class cls_SalesGoal_CustomView extends CustomView
{
     public  function __construct($module='')
     {
        parent::__construct($module);
     }

     /**
      * 重写父类方法(分类排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        return '';
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
		global $adb;
		//$columnviewlist=parent::getColumnsListByCvid($viewid);

        $column_list = [];
        $sql = "SELECT referencefield,countfield,datefield from ld_salestarget_detail where id = ?";
        $result = $adb->pquery($sql,[$viewid]);
        if($adb->num_rows($result)>0){
            $all_result = $adb->query_result_all($result);
            foreach ($all_result[0] as $tmp_column => $tmp_value){
                $column_list[$tmp_column] = $tmp_value;
            }
        }
        return $column_list;
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