<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('ProductDetails','include/ProductDetails');

class cls_SalesGoal_Productdetail extends ProductDetails
{
	public $productFields;
    public $customViewColumnList;
    public function getSelectColumn($tabid)
    {
        $column_arr = [];

        foreach ($this->customViewColumnList as $customViewColumnInfo){
            $details = explode(':', $customViewColumnInfo);
            $column_arr[] = $details[0].'.'.$details[1];
        }
        return implode(',',$column_arr);
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