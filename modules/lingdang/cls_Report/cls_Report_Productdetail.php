<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('ProductDetails','include/ProductDetails');

class cls_Report_Productdetail extends ProductDetails
{
	public $productFields;
    //单例
    public static function getInstance($module="",$languagetran="")
    {
        if(isset(self::$_instance_products[$module])){
            return self::$_instance_products[$module];
        }
    
        self::$_instance_products[$module] = new cls_Report_Productdetail($module,$languagetran);
        return self::$_instance_products[$module];
    }
	function getSpecialTableName(){
		return 'tmp_approve';
	}

	//处理明细数据  合同列
	function getListViewEntries($list,$pagetype){
		$list = parent::getListViewEntries($list,1);
		return $list;
	}

}
?>