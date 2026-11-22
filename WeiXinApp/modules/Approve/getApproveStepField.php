<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    $record = $_REQUEST['record'];
    $module = $_REQUEST['fld_module'];
    $stepid = $_REQUEST['stepid'];
    
    crm_load_class_file("ApproveWX", 'WeiXinApp/modules/Approve/cls_Approve');
    $approveobj = new ApproveWX();
    
    $approvestepinfo = $approveobj->getStepInfo($stepid);//审批步骤信息
    //根据approvestatus 参数判断是新逻辑还是旧逻辑
    if(isset($_REQUEST['approvestatus']) && $_REQUEST['approvestatus']!=''){
        $approvestatus=$_REQUEST['approvestatus'];
        //duan 20230112 移动端审批成功时，添加验证规则判断
        if(in_array($approvestatus,array(1,2,6)) && $_REQUEST['operate_again'] != 'yes'){
            crm_load_class_file('cls_PageValidataSave','data');
            $PageValidataSaveobj=new cls_PageValidataSave($module,$record,0);
            $PageValidataSaveobj->MobileValidataInfo('finish');
        }
        //duan 20230112 移动端反审批时，添加验证规则判断
        if(in_array($approvestatus,array(3,4,5)) && $_REQUEST['operate_again'] != 'yes'){
            crm_load_class_file('cls_PageValidataSave','data');
            $PageValidataSaveobj=new cls_PageValidataSave($module,$record,0);
            $PageValidataSaveobj->MobileValidataInfo('cancel');
        }

        //duan 20230719批量通过修改审批必填字段判断
        crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
        $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($module);
        $choose_fieldname_arr = $mandatoryfieldobj->getMandatoryFieldByApprovesult($stepid,$approvestatus);

        $module_status = $approveobj->getModuleRecordStatus(implode(',',$choose_fieldname_arr),$record,$module,'mobile');

        if($module_status == 'no'){
            ConvertTojsonString(-3,array('stepid'=>$stepid),getFixedLabel('youwanttofillintherequiredfields'));
        }
    }else{
        $module_status = $approveobj->getModuleRecordStatus($approvestepinfo['module_field'],$record,$module,'mobile');
        if($module_status == 'no'){
            ConvertTojsonString(-2,array('stepid'=>$stepid),getFixedLabel('youwanttofillintherequiredfields'));
        }
    }


	ConvertTojsonString(1,array(),'success'); 
?>