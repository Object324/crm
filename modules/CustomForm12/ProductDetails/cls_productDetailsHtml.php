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
	
	public function getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue){
		$VersionInfo = getVersionInfo();
		if($productinfo['columnname'] == 'qtyinstock' && $productinfo['tablename'] == 'ld_products' && $productinfo['input_type'] == 1){
			global $current_user;
			if($current_user->is_admin == 'off' && isset($current_user->column_fields['view_quantity']) && $current_user->column_fields['view_quantity'] == 0){
				$value = str_replace(',', '', $showvalue['rawvalue']);
				if($value >= 21){
					$label = getFixedLabel('many');	//多
				}else if($value <=20 && $value > 0){
					$label = getFixedLabel('less');	//少
				}else{
					$label = getFixedLabel('NONE');	//无
				}
				$showvalue['rawvalue'] = $label;
				$showvalue['value'] = $label;
				foreach($this->productToolTr as $key => $product_field){
					if($product_field->getColumnName() == 'qtyinstock' && $product_field->getTableName() == 'ld_products' && $product_field->getinput_type() == 1){
						unset($this->ProductDetailsData->subtotalTrData[$key]);

					}	
				}
			}
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
		}else{
			if($VersionInfo['account'] == 'zhongneng'){
				if('zhongneng_ware_qty' == $productinfo['columnname']){
					$value = 0;
					if(($this->focus->mode == 'edit' || $this->focus->id > 0)){
						$wareid = $this->focus->column_fields['wareid'];
						if(!empty($wareid)){
							crm_load_function_file('getZN_ProductQty','include/utils','ListViewUtils');
							$product_wareqty = getZN_ProductQty($productinfo['productid'],$wareid);
						}
					}
					$table = '<td id="productdetails_input_'.$productinfo['controlbol'].'" align="right"><input type="hidden" id="'.$productinfo['controlbol'].'" name="'.$productinfo['controlbol'].'" value="" /><span id="span_'.$productinfo['controlbol'].'">'.$product_wareqty.'</span></td>';
				}else{
					$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
				}
				
			}else{
				$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			}
		}
		return $table;
	}

}
?>