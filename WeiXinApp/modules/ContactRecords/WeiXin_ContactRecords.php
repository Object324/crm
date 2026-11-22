<?php
crm_load_class_file('ContactRecords','modules/ContactRecords');
class WeiXin_ContactRecords extends ContactRecords
{
    //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:10

    public function save_module($module) {
        //gyq161214
        if(isset($_REQUEST['account_id'])){
            crm_load_class_file('Accounts','modules/Accounts');
        }
        parent::save_module($module);
    }
}
?>