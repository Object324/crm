<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_ContactRecords_SaveWX extends cls_SaveWX
{
    public function common_save(){
        //duan 20221117 泰康特殊开发，签到打卡（跟进记录）模块，保存时，判断当前签到地址是否在日程管理规定的拉练计划范围内
        crm_load_class_file("cls_TaiKangSignin",'WeiXinApp/modules/Vendors');
        $taikangobj = new cls_TaiKangSignin();
        $taikangobj->TrainingAreaRange();
        
        parent::common_save();
    }

}
?>