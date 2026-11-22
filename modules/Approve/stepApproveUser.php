<?php
/**
 * edit:can
 * reason:获取步骤的审批人
 * */
global $adb;
$approve =new Approve();
$approveid=$_REQUEST['approveid'];
$stepid=$_REQUEST['stepid'];
$crmid = $_REQUEST['recordid'];
$sql='select approvetype,approvevalue,specifyapproverid,countersigner,emptyapproverdeal from ld_approvestep where approveid=? and  id=?';
$result=$adb->pquery($sql,array($approveid,$stepid));
$approvetype = $adb->query_result($result,0,'approvetype');//审批人状态
$approvevalue = $adb->query_result($result,0,'approvevalue');//下一步审批人
$specifyapproverid=$adb->query_result($result,0,'specifyapproverid');//修改本步骤的审批（1：否）
$countersigner=$adb->query_result($result,0,'countersigner');

$nextsetpby = $approve->getApproveBy($approvetype,$approvevalue,$crmid);
//duan 2022-3-31 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
if(empty($nextsetpby) && $approve->get_allow_emptyapprover($tmpnextstepid,$approvetype) == 'yes'){ //如果该类型可以设置对应参数
	$emptyapproverdeal=$adb->query_result($result,0,'emptyapproverdeal');
	$nextsetpby = $approve->getTransferUsers($emptyapproverdeal);
}
$countersigner=$approve->getisCounterSigner($countersigner,$nextsetpby,$stepid);//是否为会签
$nextstepidtoname = '';
if(!empty($nextsetpby)){
	$ids = explode(',',$nextsetpby);
	foreach($ids as $value){
        $tmpusername = getUserFullName($value);
        $nextsetpbyuser .=$tmpusername.",";
        $nextstepidtoname .= $value."##".$tmpusername.",";
	}
}
$nextsetpbyuser = trim($nextsetpbyuser,',');
$nextstepidtoname = trim($nextstepidtoname,',');


 //}  
 echo '###SUCCESS###';
 echo  $nextsetpby.':'.$nextsetpbyuser.':'.$specifyapproverid.":".$countersigner.":".$nextstepidtoname;
 exit();
?>