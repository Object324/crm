<?php 

class DefinedCustomView extends CustomView
{
      public $autoremindinfoobj;
     private $autoid;
     private $module;
     public  $focus;
	 public  $selectcolumn;
     public  function __construct($module)
     {
       
        $this->module=$module;
        
        
        $this->focus=CRMEntity::getInstance($module) ;
	
     }
     /**
      * 重写父类方法(排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
      
    }
    /**
     * 重写父类基本查询方法
     * */
	function getStdFilterByCvid() {
	 
      
	}
    /**
     * 重写父类高级查询方法
     * */
     public function  getAdvFilterByCvid($cvid) {
        
     
     
     }
  
}

?>