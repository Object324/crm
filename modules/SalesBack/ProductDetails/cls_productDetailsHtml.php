<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_productDetailsHtml extends Parent_ProductDetailsHtml{
	
    private $salesback_deploy;
	public function ____construct($module){
        //未出库订单是否允许退货 1：是，0：否
        $saleback_deploy=getSys_deploy(85);
        $this->salesback_deploy = $saleback_deploy['deploy_value'];
		$this->module = $module;
        parent::__construct($module);
	}

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		return parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
	}
    /*

    //重写添加行按钮
	public function getAddProductDetailBtn() {
        $version=getVersionTradeInfo();//增加控制，如果是金融行业版本的数据库ld_version.trade=’finance’，则产品分录中不显示“新增产品”按钮。
		if($version['trade'] !=TRADE_FINANCE && strtolower($version['trade']) !=strtolower(TRADE_JIJIN)){
            if($this->salesback_deploy == 1 && $this->productdetail_mode != 'Details'){
				$table ='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
				$table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEWPRODUCTS').'" onclick="fnAddProductRow(\''.$this->module.'\',\'yes\');" /></td></tr>';
				$table .='</table>';
			}
        }
        return $table;
    }
    *
     */
	public function lineitemid_html($productToolFieldsValues,$rowid){
		if($this->focus->id > 0){
			return '<input type="hidden" detailcolumnname="lineitem_id"  value="'.$productToolFieldsValues['parent_lineitem_id'].'" />';
		}else{
			return '<input type="hidden" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['lineitem_id'].'" />';
		}
	}
    /*
    //重写产品的清除按钮
	public function getClearBtn($rowid) {
        if($this->salesback_deploy ==1){
			if(!empty($this->productToolTr)){
				$producthtml .='<a class="icon-homeimg icon-select f-l" id="searchIcon'.$rowid.'" href="javascript:;" title="'.getTranstab('Products').'"  onclick="fun_selectproduct.getProductPopup('.$rowid.')" ></a>';
			}
			$producthtml .='<a class="icon-homeimg icon-clear f-l" href="javascript:;" title="'.getTranstab('CLEAR').'" onclick="setInventoryProductClear(\''.$rowid.'\',\''.$this->module.'\',\'ProductDetailRow\')" ></a>';
		}
        return $producthtml;
    }
    */
	//获取币种选择项
	public function getCurrencySelect($currencyid,$allCurrencies){
		$table ='<span style="margin-left: 20%;">'.getFixedLabel('Currency') . '</span><select disabled="disabled" id="inventory_currency" name="inventory_currency" onchange="updatePrices();">';
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