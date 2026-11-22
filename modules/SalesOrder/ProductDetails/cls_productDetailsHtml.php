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
	
	public function __construct($module){
		parent::__construct($module);
	}

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$table = parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
		return $table;
	}
	
    public function lineitemid_html($productToolFieldsValues,$rowid){
       
		if($this->focus->id > 0){
			return '<input type="hidden" name="lineitem_id" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['parent_lineitem_id'].'" />';
		}else{
			return '<input type="hidden" name="lineitem_id" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['lineitem_id'].'" />';
		}
	}
}
?>