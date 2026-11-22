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
		if(get_versiontrade() == 'yangduan'){
			if('sf1309' == $productinfo['columnname'] && $this->productdetail_mode == 'sourcemodule_create' && $productinfo['lineitem_id'] > 0 && $productinfo['productid'] > 0){
				$detailtablescf=$this->frommdouleFocus->Detail_table_scf;
                $query =" select sf3311 from $detailtablescf where lineitem_id = ? ";
				$result = $this->db->pquery($query,array($productinfo['lineitem_id']));
				$sf3311 = $this->db->query_result($result,0,0);
				if(!empty($sf3311)){
					$showvalue['rawvalue'] = date("Y-m-d",strtotime("$sf3311   +18   day"));
					$showvalue['value'] = date("Y-m-d",strtotime("$sf3311   +18   day"));
				}
			}
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			
		}else{
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
		}
		return $table;
	}

}
?>