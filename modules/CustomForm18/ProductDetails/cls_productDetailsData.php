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
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_productDetailsData extends Parent_ProductDetailsData{
	
	public function __construct($module){
		parent::__construct($module);
	}

	public function getProductToolTrData($frommdouleFocus='',$productdetail_mode=''){
		$data = parent::getProductToolTrData($frommdouleFocus='',$productdetail_mode='');
		$versioninfo = getVersionInfo();
		//郎捷：6.费用项目->费用单->特殊业务控制需求
		/*if($versioninfo['account'] == 'langjie'){
			$order_detailfield = $this->getLangjieOrderDetailField();
			if(!empty($order_detailfield['fields'])){
				foreach($data as $key => $field){
					$col_name = $field->getColumnName();
					if($col_name == 'productname')$col_name = 'productid';
					if(!in_array($col_name,$order_detailfield['fields'])){
						unset($data[$key]);
					}
				}
			}
			return $data;
		}else{
			return $data;
		}*/
		return $data;
	}
	
	//郎捷：6.费用项目->费用单->特殊业务控制需求
	public function getLangjieOrderDetailField(){
		global $adb;
		$tabid = getTabid($this->module);
		crm_load_class_file('ProductToolFields','include/ProductDetails');
		$ProductToolFields =  new ProductToolFields($this->declare_module);
		$moduleProductToolField = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
		if(!empty($moduleProductToolField)){
			$col_name[] = 'productid';
			$col_name[] = 'comment';
			foreach($moduleProductToolField as $field){
				if($field->getTableName() == 'ld_customform18detailscf'){
					$col_name[] = $field->getColumnName();
					$col_wdith[$field->getColumnName()] = $field->getWidth();
				}
			}
			$width = 0;
			$query = 'select ' . implode(',',$col_name) . ' from ld_customform18detailscf 
			LEFT JOIN ld_customform18detail on ld_customform18detail.lineitem_id = ld_customform18detailscf.lineitem_id where ld_customform18detail.id = ?';
			$result = $adb->pquery($query,array($_REQUEST['record']));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					foreach($col_name as $db_name){
						$value = $adb->query_result($result,$i,$db_name);
						if(is_numeric($value)){
							if($value > 0.00){
								$order_detailfield[$db_name] = $db_name;
								$width += $col_wdith[$db_name];
							}
						}else{
							if(!empty($value)){
								$order_detailfield[$db_name] = $db_name;
								$width += $col_wdith[$db_name];
							}
						}
						
					}
				}
			}
		}
		return array('fields'=>$order_detailfield,'width'=>$width);
	}
}
?>