<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_productDetailsHtml extends Parent_ProductDetailsHtml{
	
	public function ____construct($module){
		parent::__construct($module);
	}

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		//$_REQUEST['noCurrency'] = 1;
		//$_REQUEST['row_subtotal'] = 1;
		return parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
	}
    
    //重写添加行按钮
	public function getAddProductDetailBtn() {
        return '';
    }
    
    public function lineitemid_html($productToolFieldsValues,$rowid){
		if($this->focus->id > 0){
			return '<input type="hidden" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['parent_lineitem_id'].'" />';
		}else{
			return '<input type="hidden" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['lineitem_id'].'" />';
		}
	}
    
    //获取产品的清除按钮
	public function getClearBtn($rowid) {
        return '';  
    }

	//获取币种选择项
	public function getCurrencySelect($currencyid,$allCurrencies){
		$table =getFixedLabel('Currency') . '<select disabled="disabled" id="inventory_currency" name="inventory_currency" onchange="updatePrices();">';
		foreach($allCurrencies as $currency_info){
			$selected = '';
			if($currency_info['curid'] == $currencyid){
				$selected = 'selected';
			}
			$table .='<OPTION value="'.$currency_info['curid'].'" currate="'.$currency_info['conversionrate'].'" '.$selected.'>'.getTranslatedCurrencyString($currency_info['currencylabel']).'('.$currency_info['currencysymbol'].')'.'</OPTION>';
		}
		$table .='</select>';
        //<select>属性为disabled值不能提交到后台，这里用隐藏域提交
        $table .='<input type="hidden" name="inventory_currency" value="'.$currencyid.'">';
		return $table;
	}

}
?>