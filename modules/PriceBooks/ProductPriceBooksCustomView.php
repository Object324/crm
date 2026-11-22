<?php
class ProductPriceBooksCustomView extends CustomView
{
    public static function getInstance($module="")
    {
        static $global_ProductPriceBooksCustomView;
        if($global_ProductPriceBooksCustomView)
        {
           
            return $global_ProductPriceBooksCustomView;
            
        }
        
        $global_ProductPriceBooksCustomView=new ProductPriceBooksCustomView("Products");
        return $global_ProductPriceBooksCustomView;
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
         
        $column_list[0]= "$maintable_name:productname:productname:$this->module_fieldlabel:V";
        //$column_list[1]= "$maintable_name:productcode:productcode:$this->module_fieldlabel:V";
       // $column_list[2]= "$maintable_name:unit_price:unit_price:$this->module_fieldlabel:n";
       // if(!empty($this->selectcolumn))
		//  $column_list[1]= $this->selectcolumn;

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
         return array();
     
     
     }
}


?>