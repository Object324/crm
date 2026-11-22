<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
/**
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_productDetailsHtml extends Parent_ProductDetailsHtml{
	
    
	public function __construct($module,$sourcemodulename){
	 
     
	   $this->sourcemodulename=$sourcemodulename;
       
       parent::__construct($module);
      
	}

    //BUG20240124-41 ls 240125 收款单分录小计行不显示(当源单设置启用带出产品明细时),分录没有字段subtotal
    public function getTableWidth()
    {
        parent::getTableWidth();
        $this->subtotalTr = 'yes';
    }
     public function setProductDataObj(){
            $module=$this->getmodule() ;
             
   	       $this->ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$module/productDetail",array($module,$this->sourcemodulename));
    }
	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$table = parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
		return $table;
	}
    
   
    

}
?>