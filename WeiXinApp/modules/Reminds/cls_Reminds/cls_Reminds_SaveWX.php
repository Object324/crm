<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');
class cls_Reminds_SaveWX extends cls_SaveWX{
    //2024-4-29 xxy 移动端创建消息提醒，有多个提醒接收人，需要循环save数据
    function common_save(){
        global $current_user;

        $this->before_save();

        $focus = $this->focus;
        $module = $this->module;

        //edit:can 2020-12-23 43917: （企业微信移动端，kfbcrm）审批-合同订单；单据编号SO103，审批流“合同订单加签和条件”，填写必填项后，当前审批人审批提示“该记录正在审批中，不允许编辑！ 请联系审批人”
        $_REQUEST['cur_module_step']='1';
        if($module=='ServiceCharge') $module='Accounts';
        //0025802: （微信端-安卓）联系人：新增自定义的多选框字段，新增联系人选择多选框信息，出现代码
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        setObjectValuesFromRequest($focus);
        //editor:gyq_129 reason:选择源单字段增加保存到数据库功能  2019/7/11 17:34 ID1000529
        //原单
        //$_REQUEST['selectlistval']=$_REQUEST['salesorder_id'];
        //03gyqDis date:20170320 reason:币种保存方法暂时写在公告保存方法中，客户联系人保存除外！。
        global $adb;
        $currency_id_post = $_REQUEST['currency_id'];
        if($this->action=='EditView')
        {
            $currency_id = $focus->column_fields['currency_id'];
        }
        //edit:can 20220113 49636: （企业微信-kfbtest）（需要补丁）出库单新建》选择合同源单SO119，保存时提示分录的数量、合计和源单不一致
        $_REQUEST['inventory_currency']=$currency_id_post;
        if($currency_id !=$currency_id_post)
            $focus->currency_status = true;
        else
            $focus->currency_status = false;
        $focus->column_fields['currency_id']=$currency_id_post;
        $currencyobj=Currency::getInstance($adb,$currency_id_post);
        $currencySymbol = $currencyobj->getCurrencySymbol();
        $currencyRate = $currencyobj->getCurrencyRate();
        $focus->column_fields['conversion_rate'] = $currencyRate;
        $focus->column_fields['currency_symbol'] = decode_html($currencySymbol);
        if(empty($_REQUEST['confirm_save']))
        {
            crm_load_class_file('cls_PageValidataSave','data');//验证规则，提示保存
            $PageValidataSaveobj=new cls_PageValidataSave($this->module,$this->focus->id,$_REQUEST['rowcnt']);
            $PageValidataSaveobj->setAllowSave('yes');
            
         
            $PageValidataSaveobj->setCurrencyId($focus->column_fields['currency_id']);
            $PageValidataSaveobj->getValidDataInfoPhp();
            
            if(!empty($PageValidataSaveobj->errortip)){
            //edit:can 20210425 保存验证规则
                $_REQUEST['diony']='yes';
                //zkt 20230809 BUG0070825  从钉钉进入灵当CRM，从报价单下推生成销售订单，当订单金额超出客户信誉金额时无法保存。详见附件视频。 
                ConvertTojsonString("confirm_save",array(),$PageValidataSaveobj->errortip);
            }
        }
        $focus->column_fields['status_rmd'] = '未读';
        $focus->saveReminds();

        $this->after_save();
    }
}