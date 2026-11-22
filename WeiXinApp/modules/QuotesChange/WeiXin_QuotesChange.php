<?php

crm_load_class_file('QuotesChange','modules/QuotesChange');
class WeiXin_QuotesChange extends QuotesChange
{
    public function __construct()
    {
        parent::__construct();
        //editor:gyq_20190726 reason:0037614报价单相关界面：报价变更单新增->追加，选择产品名称界面产品加载不出来 2019/7/26 11:42
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }

    //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:29
}
?>