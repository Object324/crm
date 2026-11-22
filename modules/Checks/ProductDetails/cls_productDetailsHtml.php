<?php
/**
* 产品明细HTML
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
		$_REQUEST['noCurrency'] = 1;
		$_REQUEST['row_subtotal'] = 1;
		return parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
	}
    public function getProductHtmlLastContent() {
        //edit:can 2020-10-22 042979: （8.2.7安装包）盘点单新建界面，选择产品后，合计显示NAN
    }
    //重写整单折扣、选择方式   
	public function getInventoryDiscount(){
		$discount = array(
			'discount_type' => '',
			'discount_percent' => '',
		);
		return $discount;
	}

}
?>