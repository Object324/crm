<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$mobileversion;
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){    
    $fld_module=$_REQUEST['fld_module'];
}
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];

$setype = $_REQUEST['setype'];//类型，info:获取

require_once(globalStatic::$root_directory.'WeiXinApp/modules/Approve/cls_Approve/ApproveWX.php');
$approve = new ApproveWX();

crm_load_class_file('cls_getCancelApprove','appCommon/modules/Approve');
$cancelapprove = new cls_getCancelApprove($record,$approve,$fld_module);

if( $setype == 'approveinfo' ){//获取适用的审批流程
	$cancelapprove->getApproveInfo();
} else if( $setype == 'cancel' ){
    //duan 20230224 移动端反审批时，添加验证规则判断
    if($_REQUEST['operate_again'] != 'yes'){
        crm_load_class_file('cls_PageValidataSave','data');
        $PageValidataSaveobj=new cls_PageValidataSave($fld_module,$record,0);
        $PageValidataSaveobj->MobileValidataInfo('cancel');
    }
    
    
    $canceltype = $_REQUEST['canceltype'];

	$cancelapprove->setApproveCancel($canceltype);
    ConvertTojsonString(1,array(),'');
}
?>