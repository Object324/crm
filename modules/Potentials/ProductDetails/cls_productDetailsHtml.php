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
	
    //获取明细行默认的产品显示行数
    public function getModuleProductRow()
    {
        global $adb;
        $productrow = parent::getModuleProductRow();
        //zkt 20230525 BUG0067079新增项目（Potentials）的时候，产品分录自动添加 product_remark='项目销售预测用产品组' 的所有产品 目前有15个 
        if($this->version_info['account'] == 'haige'&&$this->productdetail_mode == 'create'){
            $sql = "select * from ld_products where product_remark='项目销售预测用产品组' and deleted=0;";
            $result = $adb->pquery($sql,array());
            $rows = $adb->num_rows($result);
            $tmp_productall=$this->ProductDetailsData->productToolAll;
            $tmp_inventoryFields = $this->ProductDetailsData->inventoryFields;
            if($rows>0){
                $fieldobj=Field::getInstance('Products',$adb);
                for($i=0;$i<$rows;$i++){
                    $tmpcolumnname_value = array();
                    $productid = $adb->query_result($result,$i,'productid');
                    $productname = $adb->query_result($result,$i,'productname');
                    $tmpcolumnname_value['productid'] =  $productid;
                    foreach($tmp_productall as $columnname => $productToolFieldsInfo){
                        if(($productToolFieldsInfo->getTableName() == 'ld_products' || $productToolFieldsInfo->getTableName() == 'ld_productcf') ){
    						$fieldid = $productToolFieldsInfo->getFieldid();
    						$profieldarr=$fieldobj->FieldInfoListByKeyValue('fieldid',$fieldid);
                            $tmpcolumnname_value[$columnname] = $this->db->query_result($result,$i,$profieldarr['columnname']);
    					}
                        else{
                            $valueStr = '';
                            $tmpcolumnname_value[$columnname] = html_entity_decode($valueStr);
                        }
                    }
                    $this->productToolFieldsValues[$i] = $tmpcolumnname_value;
                }
                return $rows;
            }
        }
        return $productrow;
    }
}
?>