<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$approvebyid=$current_user->id;
//editor:gyq_20190806 reason:0037704: （公司自用）企业微信>灵当CRM>审批中心：审批操作一点击就转圈卡死。（需要补丁）
$module=$frommodule = $_REQUEST['fld_module'];
$focus=cls_Instance::get_module_Instance($module);
$moduleid=$focus->table_index;
$tabname=$focus->table_name;
if(isset($_REQUEST['approvestatus']) && $_REQUEST['approvestatus']!='')
$approvestatus=$_REQUEST['approvestatus'];

if(isset($_REQUEST['pagevalidata']) && $_REQUEST['pagevalidata'] == 'no'){
    //duan 20230721 新版本验证规则改到跟审批必填字段一起判断
}else{
    //duan 20230112 移动端审批成功时，添加验证规则判断
    if(in_array($approvestatus,array(1,2)) && $_REQUEST['operate_again'] != 'yes'){
        crm_load_class_file('cls_PageValidataSave','data');
        $PageValidataSaveobj=new cls_PageValidataSave($module,$_REQUEST['record'],0);
        $PageValidataSaveobj->MobileValidataInfo('finish');
    }
    //duan 20230112 移动端反审批时，添加验证规则判断
    if(in_array($approvestatus,array(3,4,5)) && $_REQUEST['operate_again'] != 'yes'){
        crm_load_class_file('cls_PageValidataSave','data');
        $PageValidataSaveobj=new cls_PageValidataSave($module,$_REQUEST['record'],0);
        $PageValidataSaveobj->MobileValidataInfo('cancel');
    }
}

require_once(globalStatic::$root_directory.'modules/Approve/Remind.php');

crm_load_class_file("ApproveCommon","modules/Approve");
$approvecommonobj = ApproveCommon::getInstance($module);
$approveid = $_REQUEST['approveid'];
$approve = $approvecommonobj->getApproveobjByApproveid($approveid);
require_once(globalStatic::$root_directory.'appCommon/modules/Approve/SaveApproveLog.php');
?>