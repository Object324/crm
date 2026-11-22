<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/4/17 0017
 * Time: 下午 4:43
 */
crm_load_class_file('cls_ProductEntry_DetailViewMC', 'appCommon/detail');
class cls_ProductEntry_DetailViewWX extends cls_ProductEntry_DetailViewMC
{
    public function __construct($module)
    {
        parent::__construct($module);
        crm_load_class_file('ProductFields','include/ProductDetails');
    }
}