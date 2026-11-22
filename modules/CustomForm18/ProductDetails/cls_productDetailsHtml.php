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
		//郎捷：6.费用项目->费用单->特殊业务控制需求
		/*$versioninfo = getVersionInfo();
		if($versioninfo['account'] == 'langjie'){
			$order_detailfield = $this->ProductDetailsData->getLangjieOrderDetailField();
			if(!empty($order_detailfield['fields'])){
				$this->width = $order_detailfield['width'];
				$this->width += 23;//第一列操作行宽度
				if($this->width < 255)$this->width = 255;
			}
		}*/
	}

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$table = parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
		return $table;
	}
	
	public function getAddProductDetailBtn() {
		$versioninfo = getVersionInfo();
		//郎捷开发需求：费用单分录不允许增、删、移动行
		if($versioninfo['account'] == 'langjie'){
			return '';
		}else{
			$table = parent::getAddProductDetailBtn();
			return $table;
		}
	}

}
?>