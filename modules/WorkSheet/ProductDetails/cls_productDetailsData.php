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
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_productDetailsData extends Parent_ProductDetailsData{
	
    public $record;
    public $worksheet_sourcevalue_arr;
    
	public function __construct($module){
		parent::__construct($module);
        $Detail_table=$this->focus->Detail_table;
        if($Detail_table == 'ld_worksheetdetail'){
            $this->inventoryFields ['related_productid'] = $Detail_table.'.related_productid';
        }
	}
    
    public function getFromModuleProductToolInfo($frommdouleFocus=''){
        parent::getFromModuleProductToolInfo($frommdouleFocus);
        $Detail_table=$this->focus->Detail_table;

        if($Detail_table == 'ld_worksheetdetail'){
            $this->sqlfields['related_productid'] = $Detail_table.'.related_productid';
        }
    }
}
?>