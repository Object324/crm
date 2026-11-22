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
 crm_load_class_file("cls_HaigeConst",'modules/Quotes');
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
			}else if($VersionInfo['account'] == 'haige'){
			 //edit:duan 海格二期：编辑、复制的报价单中，产品分录的折扣（包括经销商折扣）不可编辑

                if($this->focus->id >0 && ($this->focus->column_fields['quote_version'] != '1.0'||$_REQUEST['isDuplicate']=='true') && $this->focus->column_fields['quotetype'] == cls_HaigeConst::$QuoteType_Specical){
                    $fieldname_arr = array('discount_percent','agent_discount');
                    if(in_array(trim($productinfo['columnname']),$fieldname_arr)){
                        $productinfo['edit_perssion']=1;
                        $fieldinfo->edit_permission(1);
                    }
                }
                $table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);                
			}else{
				$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			}
            
		}
		return $table;
	}
    
    public function getClearBtn($rowid) {
        
        //海格特殊开发：复制报价单时，原报价单产品显示为只读（不显示清除、重新选择按钮），并且折扣不可修改。
		$VersionInfo = getVersionInfo();
        if($VersionInfo['account'] == 'haige'&&($this->focus->id >0 && ($this->focus->column_fields['quote_version'] != '1.0'||$_REQUEST['isDuplicate']=='true') && $this->focus->column_fields['quotetype'] == cls_HaigeConst::$QuoteType_Specical)){
            return '';
        }elseif($VersionInfo['account'] == 'jinci'){
            $producthtml .= '<span class="icon-homeimg icon-stock cursorPointer marR5 operatetool_more" title="查历史分录" onclick="fun_selectproduct.prototype.getEntryPopupJinci(' . $rowid . ')"></span>';
            $producthtml .= '<a class="icon-homeimg icon-select" name="searchIcon" href="javascript:;" title="' . getTranstab('Products') . '" tag="sourcehidebutton" onclick="fun_selectproduct.getProductPopup(' . $rowid . ')" style="margin-top: -4px;"></a>';

            $producthtml .= '<a class="icon-homeimg icon-clear" href="javascript:;" style="margin-top: -4px;" title="' . getFixedLabel('CLEAR') . '" tag="sourcehidebutton" onclick="fun_selectproduct.btn_clearProductInfo_Row(\'' . $rowid . '\')" ></a>';
            return $producthtml;
        }else{
            return parent::getClearBtn($rowid);
        }
		
	}
    

}
?>