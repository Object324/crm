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
			if(('tax_amount' == $productinfo['columnname']||'sf7019' == $productinfo['columnname']) 
                && $this->productdetail_mode == 'sourcemodule_create' && $productinfo['lineitem_id'] > 0 
                && $productinfo['productid'] > 0){
                  $detailtable=  $this->frommdouleFocus->Detail_table;
                  $detailtablescf=$this->frommdouleFocus->Detail_table_scf;
				$query = " select tax_amount - IFNULL(sf2796,0) as yue,tax_amount from $detailtable
					LEFT JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id 
					where $detailtable.lineitem_id = ? ";
				$result = $this->db->pquery($query,array($productinfo['lineitem_id']));
				if('tax_amount' == $productinfo['columnname'])
					$amount = $this->db->query_result($result,0,0);
				else
					$amount = $this->db->query_result($result,0,1);
				$showvalue['rawvalue'] = sprintf('%.2f',$amount);
				$showvalue['value'] = $amount;
			}
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
			
		}else{
			$table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
		}
		return $table;
	}

	public function getProductHtmlContent($jsAddRowid=''){
		//设置服务合同关联销售合同后是否自动带出产品
		$deployarray=getSys_deploy(164);
		//43435: （https://61mis.com/kfbcrm/ [^]）客户问题（苏宁），“设置服务合同关联合同订单后是否自动带出产品”参数为“否”，服务合同新建界面，选择“合同订单”单据后，仍然带出了产品（需要补丁）
		if( $deployarray['deploy_value'] == 0 && ($this->productdetail_mode == 'sourcemodule_create' || $this->productdetail_mode == 'module_create')){
			$this->productdetail_mode = 'addrow_create';
		}
		return parent::getProductHtmlContent($jsAddRowid);
	}

}
?>