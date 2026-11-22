<?php

class CommonEditViewReturn
{
    public function getReturnArr($focus){
        //editview.php 结尾返回的arr提取  zxm
        global $currentModule;
        global $current_user;
        if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
            require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
            $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
        } else {
            $arr['title'] = getTranstab($currentModule);
        }
        //zxm 2021-0902 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
        $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
        $is_page_setting = "no";
        if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
            $is_page_setting = "yes";
        }
        $arr['mainfieldformula']=$focus->fieldobj->getFormula();
        $arr['is_page_setting'] = $is_page_setting;
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $arr['isadmin']=$current_user->is_admin;
        $arr['isduplicate'] = getTabDuplicate($currentModule);
        $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');

        ///保存判断
        $arr["validatasave"]=getValidataSave($currentModule);
        $arr["validatasaverule"]=getAllRule($currentModule);
        //布局规则
        crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
        $fieldruleobj=cls_fieldrule::getInstance($currentModule);
        $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
        //敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
        crm_load_class_file('cls_fieldSensitiverule','include/fields');
        $fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
        $arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段

        //duan 推进触发布局规则后更新返回的字段值
        if(!empty($_REQUEST['miniedit_fieldrule']) && !empty($_REQUEST['fieldvaluejson'])){
            $fieldvaluejson = $_REQUEST['fieldvaluejson'];
            $fieldvalue_arr = ldcrm_json_decode($fieldvaluejson);
            foreach ($fieldvalue_arr as $tmp_key => $tmp_value){
                $focus->column_fields[$tmp_key]=urldecode($tmp_value);
            }
        }
        $arr['columnfields_value'] = $focus->column_fields;

        return $arr;
    }
    //duan 20240124 对编辑页返回值增加统一操作
    public function setReturnArr($arr){
        global $currentModule;
        // duan 20240923 获取审批需要使用的条件判断字段
        crm_load_class_file("cls_approvestep_change","modules/Approve");
        $approvestep_change_obj = new cls_approvestep_change($currentModule);
        $arr['approve_fieldname_arr'] = $approvestep_change_obj->get_approve_fieldname();

        // XUQIU20240930-02 duan 20241008 增加模块自定义设置参数获取
        $module_setting = getModuleSettingBytype($currentModule,'editview');
        $arr['module_setting'] = $module_setting;

        return $arr;
    }

}