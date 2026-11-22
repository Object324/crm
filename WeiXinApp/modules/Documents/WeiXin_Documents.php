<?php
//editor:gyq_113 reason:新增知识管理模块  2019/5/20 17:45
crm_load_class_file('Documents','modules/Documents');
class WeiXin_Documents extends Documents
{
    //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:24

    public function save_module($module) {
        //gyq161214
        if(isset($_REQUEST['account_id'])){
            crm_load_class_file('Accounts','modules/Accounts');
        }
        parent::save_module($module);
    }
}
?>