<?php
/**
 * edit:can
 * reason:获取步骤的审批人
 * */

//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

require_once(globalStatic::$root_directory.'WeiXinApp/modules/Approve/cls_Approve/ApproveWX.php');
$approve = new ApproveWX();
$approveid=$_REQUEST['approveid'];
$stepid=$_REQUEST['stepid'];
$crmid = $_REQUEST['recordid'];
$sql='select approvetype,approvevalue,specifyapproverid,countersigner,emptyapproverdeal from ld_approvestep where approveid=? and  id=?';
$result=$adb->pquery($sql,array($approveid,$stepid));
$approvetype = $adb->query_result($result,0,'approvetype');//审批人状态
$approvevalue = $adb->query_result($result,0,'approvevalue');//下一步审批人
$specifyapproverid=$adb->query_result($result,0,'specifyapproverid');//修改本步骤的审批（1：否）
$emptyapproverdeal=$adb->query_result($result,0,'emptyapproverdeal');
$nextsetpby = $approve->getApproveBy($approvetype,$approvevalue,$crmid,$emptyapproverdeal);
$countersigner=$adb->query_result($result,0,'countersigner');
$countersigner=$approve->getisCounterSigner($countersigner,$nextsetpby,$stepid);//是否为会签

if(!empty($nextsetpby)){
	$ids = explode(',',$nextsetpby);
	foreach($ids as $value){
		$nextsetpbyuser .= getUserFullName($value).",";
	}
}
$arrapprove['list']['id'] = $nextsetpby;
$arrapprove['list']['name'] = rtrim($nextsetpbyuser,',');
$arrapprove['list']['specifyuser'] = $specifyapproverid;
$arrapprove['list']['countersigner']=$countersigner;
ConvertTojsonString(1,$arrapprove,'');
?>