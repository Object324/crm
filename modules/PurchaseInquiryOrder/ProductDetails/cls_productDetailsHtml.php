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

	public function getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue){
		$VersionInfo = getVersionInfo();
		if(get_versiontrade() == 'yangduan'){
			//sf2281 实际交货日期   sf3723  实际销售确认日期
			if(('sf2281' == $productinfo['columnname']||'sf3723' == $productinfo['columnname']||'taxprice' == $productinfo['columnname']||'tax_amount' == $productinfo['columnname']) && $this->productdetail_mode == 'sourcemodule_create' && $productinfo['lineitem_id'] > 0 && $productinfo['productid'] > 0){
				$detailtable=$this->frommdouleFocus->Detail_table;
                $detailtablescf=$this->frommdouleFocus->Detail_table_scf;
                $query = "select tax_amount - IFNULL(sf2796,0) as yue,tax_amount,sf2281,sf3723 from $detailtable
					LEFT JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id 
					where $detailtable.lineitem_id = ?";
				$result = $this->db->pquery($query,array($productinfo['lineitem_id']));
				if('tax_amount' == $productinfo['columnname']){
					$res = $this->db->query_result($result,0,0);
					$showvalue['rawvalue'] = sprintf('%.2f',$res);
					$showvalue['value'] = $res;
				}else if('taxprice' == $productinfo['columnname']){
					$res = $this->db->query_result($result,0,1);
					$showvalue['rawvalue'] = sprintf('%.2f',$res);
					$showvalue['value'] = $res;
				}else if('sf2281' == $productinfo['columnname']){
					$res = $this->db->query_result($result,0,2);
					$showvalue['rawvalue'] = $res;
					$showvalue['value'] = $res;
				}else if('sf3723' == $productinfo['columnname']){
					$res = $this->db->query_result($result,0,3);
					$showvalue['rawvalue'] = $res;
					$showvalue['value'] = $res;
				}	
			}
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			
		}else{
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
		}
		return $table;
	}
	
	public function getAddProductDetailBtn() {
		//克莱门特 ：发货单不能单独选择产品，只能选择源单
		if($this->version_info['account'] == 'climaveneta'){
			return '';
		}else{
			return parent::getAddProductDetailBtn();
		}
	}
}
?>