<?php

crm_load_class_file('WareHouseTransfer','modules/WareHouseTransfer');
class WeiXin_WareHouseTransfer extends WareHouseTransfer
{
    //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:37
    public function __construct()
    {
        parent::__construct();
        // @edit:dong @date:2020/07/30 @reason: 0042181: （曙光计划）调拨单新增界面，手动选择产品时报错，界面加载不出来
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }
}
?>