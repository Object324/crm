<?php
/**
 * 审批中心：返回包含模块和处理数量的数组,按数量倒序排序
**/
crm_load_class_file('cls_Approve_countListViewMC','appCommon/modules/Approve');//gyqCom0309
class cls_Approve_CountListViewWX extends cls_Approve_countListViewMC
{
	//获取手机端审批模块
	public function getapprovemodule(){
	   	require_once(globalStatic::$root_directory.'WeiXinApp/modules/Approve/cls_Approve/ApproveWX.php');
       	$jsonApprove = new ApproveWX();
       	return $jsonApprove->getApproveModuleInfoWX();
	}
}

?>