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
	
	public function ____construct($module){
		parent::__construct($module);
	}

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$_REQUEST['noCurrency'] = 1;
		$_REQUEST['row_subtotal'] = 1;
		return parent::getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
	}

    /*重写最后行
	 public function getProductHtmlLastContent() {
       $discount_type = 0;
        $discount_percent = 0;
        $tableContent = '<table class="ProductTab DetailContentTable" id="proTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">'; 
        $tableContent .='<tr><td width="70%" align="right"><input type="hidden" id="checksqtyTotal" name="checksqtyTotal" value="'.$this->productBoomPrice.'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>'.getFixedLabel('PACKAGEPRICELABEL').'：</b>';
		if($this->productdetail_mode == 'details'){
			$tableContent .=setNumberFormat($this->frommdouleFocus->column_fields['hdnGrandTotal']);
		}else{

			$tableContent .='<input type="hidden" id="packageTotal" name="packageTotal" maxlength = "19" value="'.number_format($this->frommdouleFocus->column_fields['hdnGrandTotal'],2,".","").'">';
			$tableContent .='<span id="span_packageTotal" name="span_packageTotal">'.number_format($this->frommdouleFocus->column_fields['hdnGrandTotal'],2,".","").'</span>';
		}           	
		$tableContent .='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>';
        $tableContent .='</table>';
		return $tableContent;
        
    }*/
}
?>