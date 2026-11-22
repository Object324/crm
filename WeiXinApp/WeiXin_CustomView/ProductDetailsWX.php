<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 *  The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *********************************************************************************/
crm_load_class_file('ProductDetails', 'include/ProductDetails');

Class ProductDetailsWX extends ProductDetails
{
    private $focus;

    public function getSelectColumn($tabid)
    {
        //editor:gyq_32  data:20170519 reason:移动端序时簿显示列内容统一
        crm_load_class_file('QueryGenerator_FunctionsMC', 'appCommon/include/QueryGenerator');
        $OBJ = new QueryGenerator_FunctionsMC();
        $result = $OBJ->getSelectColumn_SQL($this->customviewmodule);
        $columnlist=$this->setHeaderColumnInfo($result);
        $focus = CRMEntity::getInstance(getTabname($tabid));
        //列表界面查询需要将链接字段查询出来，前端选择单据的时候要带出来字段信息 xxs 2017-12-16
        $modulefields = $focus->fieldobj->getModuleFields();
        $linkfield = $focus->list_link_field;
        if(array_key_exists($linkfield,$modulefields)){
            $linkfieldobj = $modulefields[$linkfield];
            $tablename = $linkfieldobj->getTableName();
            if(!in_array($tablename.'.'.$linkfield,$columnlist)){
                $columnlist[] = $tablename.'.'.$linkfield;
            }
        }
        return implode(',', $columnlist);
    }

    /**
     * 重写父类方法(排序)
     * */
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name = $this->focus->table_name;
        return $maintable_name . '.createdtime desc';
    }

    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
        return array();
    }

    public function getModuleFields()
    {
        //edit:can 20210326 合同订单未出库数量无法查询
        crm_load_class_file("ProductDetails",'include/ProductDetails');
        $this->productDetails=ProductDetails::getInstance($this->customviewmodule);
         if (!is_array($this->modulefields) || sizeof($this->modulefields) < 0)
                $this->productDetails->setModuleFields();
                
        return $this->productDetails->getModuleFields();
            
        /*if (!is_array($this->modulefields) || sizeof($this->modulefields) < 0)
            parent::setModuleFields();

        return parent::getModuleFields();*/
        
    }

    /**
     * 重写父类基本查询方法
     * */
    function getStdFilterByCvid($cvid)
    {

        return $this->getStdFilterByautoid();

    }

    function getStdFilterByautoid()
    {
        return array();
    }

}

?>