<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('TabDetails','include/TabDetailFields');

class cls_SalesGoal_TabDetails extends TabDetails 
{
	public $productFields;

    public function getSelectColumn($tabid)
    {
        $column_arr = [];

        foreach ($this->customViewColumnList as $customViewColumnInfo){
            $details = explode(':', $customViewColumnInfo);
            $column_arr[] = $details[0].'.'.$details[1];
        }
        return implode(',',$column_arr);
    }
}
?>