<?php
/**
 *整理CasheInfo.php 中  产品信息 相关的方法到这里  zxm 20221125
 */
class ProductsUtils
{
    /**
     * edit:can
     * reason:查询字段是否为ld_products,ld_inventoryproductrel,ld_inventoryproductrelscf
     * 是：trued
     * */
    public function isProductTable($tablename,$module="")
    {
        global $currentModule,$related_left_listmodule;
        //$related_left_listmodule 相关信息模块名
        //2016-09-05 Liver 增加$currentModule == 'ServiceCharge'... 原因是服务收费模块增加了导入功能

        if(($currentModule == 'Accounts' && ($related_left_listmodule =='' || $related_left_listmodule == 'Accounts')) )
        {
            if(strtolower($tablename)=='ld_contactdetails'||strtolower($tablename)=='ld_contactscf')
            {
                return true;
            }
        }
        else if($currentModule == 'Vendors' && ($related_left_listmodule =='' || $related_left_listmodule == 'Vendors'))
        {
            if(strtolower($tablename)=='ld_vendorcontacts'||strtolower($tablename)=='ld_vendorcontactscf')
            {
                return true;
            }
        }
        else
        {   if($module!="")
        {
            $focus=CRMEntity::getInstance($module);

        }
        else if(empty($related_left_listmodule))
        {
            $focus=new $currentModule();
        }
        else
        {
            $focus=new $related_left_listmodule();
        }
            if($currentModule == 'ServiceCharge'){
                $deployarray=getSys_deploy(325);	//服务收费列表显示联系人还是合同明细
                $servicecharge_list_show = strtolower($deployarray['deploy_value']);
                if($servicecharge_list_show == 'contacts'){
                    if(strtolower($tablename)=='ld_contactdetails'||strtolower($tablename)=='ld_contactscf')
                    {
                        return true;
                    }
                }
            }
            if(strtolower($tablename)=='ld_products'||strtolower($tablename)=='ld_productcf'|| strtolower($tablename)==$focus->Detail_table||strtolower($tablename)==$focus->Detail_table_scf)
            {
                return true;
            }

        }

        return false;
    }
    /**
     * Add:Liver
     * reason:	0026299: 服务收费管理列表：导入单据界面，提示信息中出现了代码
     * */
    public function importXlsProductTable($tablename)
    {
        global $currentModule,$related_left_listmodule;
        if((($currentModule == 'Accounts' || $currentModule == 'ServiceCharge') && ($related_left_listmodule =='' || $related_left_listmodule == 'Accounts' || $related_left_listmodule=='ServiceCharge')) )
        {
            if(strtolower($tablename)=='ld_contactdetails'||strtolower($tablename)=='ld_contactscf')
            {
                return true;
            }
        }
        else if($currentModule == 'Vendors' && ($related_left_listmodule =='' || $related_left_listmodule == 'Vendors'))
        {
            if(strtolower($tablename)=='ld_vendorcontacts'||strtolower($tablename)=='ld_vendorcontactscf')
            {
                return true;
            }
        }
        else
        {
            $focus=new $currentModule();
            if(strtolower($tablename)=='ld_cashbill2paymentplan' || strtolower($tablename)=='ld_products'||strtolower($tablename)=='ld_productcf'||strtolower($tablename)==$focus->Detail_table||strtolower($tablename)==$focus->Detail_table_scf)
            {
                return true;
            }
        }

        return false;
    }
}