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


    //zkt 20240614 BUG20240614-30   项目底下这个产品预测，原来是默认填入了选项的，现在没有了
    public function getProductToolFieldsInfos($productToolFieldsValues,$frommdouleFocus,$productdetail_mode) {
        $arr = parent::getProductToolFieldsInfos($productToolFieldsValues,$frommdouleFocus,$productdetail_mode);
        $version_info = getVersionInfo();
        if($version_info == 'haige'&&$productdetail_mode == 'create'){
            $productdetail_value = $arr['productdetail_value'];
            $productinfo = $arr['producttoolfield_info'];
            foreach ($productToolFieldsValues as $columnname=>$column_value){
                if(array_key_exists($columnname,$productdetail_value)){
                    $productdetail_value[$columnname] = $column_value;
                }
                if(array_key_exists($columnname,$productinfo)){
                    $productinfo[$columnname]['column_value'] = $column_value;
                }
            }
            $arr['productdetail_value'] = $productdetail_value;
            $arr['producttoolfield_info'] = $productinfo;
        }
        return $arr;
    }
}
?>