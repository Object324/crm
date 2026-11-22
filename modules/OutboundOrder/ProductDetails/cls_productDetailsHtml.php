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
				//选择源单 或者  关联创建
				if($this->productdetail_mode == 'sourcemodule_create'){
					$listval = $_REQUEST['listval'];
					$lists = explode(',',$listval);
					if(!empty($lists[0])){
						$lineitem_info = getLineitemModuleInfo($lists[0]);
						$sourcemodule_focus = CRMEntity::getInstance($lineitem_info['module']);
						$sourcemodule_focus->retrieve_entity_info($lineitem_info['id'], $lineitem_info['module']);
						if(array_key_exists('wareid',$sourcemodule_focus->column_fields)){
							$wareid = $sourcemodule_focus->column_fields['wareid'];
							if(!empty($wareid)){
								crm_load_function_file('getZN_ProductQty','include/utils','ListViewUtils');
								$product_wareqty = getZN_ProductQty($productinfo['productid'],$wareid);
							}
						}
					}
				}
				$table = '<td id="productdetails_input_'.$productinfo['controlbol'].'" align="right"><input type="hidden" id="'.$productinfo['controlbol'].'" name="'.$productinfo['controlbol'].'" value="" /><span id="span_'.$productinfo['controlbol'].'">'.$product_wareqty.'</span></td>';
			}else{
				$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			}
			
		}else if(get_versiontrade() == 'yangduan'){
			if('sf2693' == $productinfo['columnname'] && $this->productdetail_mode == 'sourcemodule_create' && $productinfo['lineitem_id'] > 0 && $productinfo['productid'] > 0){
				$detailtable=$this->frommdouleFocus->Detail_table;
                $query = 'SELECT
					b.productid,
					SUM(b.tax_amount) AS yishou
				FROM ld_servicecontracts a
				LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
				WHERE a.deleted=0
					AND a.approvestatus=\'已批准\'
					AND a.salesorderid=(select id from '. $detailtable.' where lineitem_id = ?) and productid = ?';
				$result = $this->db->pquery($query,array($productinfo['lineitem_id'],$productinfo['productid']));
				$yishou = $this->db->query_result($result,0,1);
				$showvalue['rawvalue'] = sprintf('%.2f',$yishou);
				$showvalue['value'] = $yishou;
			}
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			
		}else{
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
		}
		return $table;
	}

	public function getAddProductDetailBtn() {
		//克莱门特 ：维修内容的产品明细不允许修改
		if($this->version_info['account'] == 'climaveneta'){
			return '';
		}else{
			return parent::getAddProductDetailBtn();
		}
	}

}
?>