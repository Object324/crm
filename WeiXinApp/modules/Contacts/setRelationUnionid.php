<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
	global $adb;
	if(!empty($_REQUEST['record']) && !empty($_REQUEST['weixin_external_userid'])){
		$query = "select weixin_external_userid,unionid_external_userid from ld_contactdetails where contactid = ?";
		$result = $adb->pquery($query,array($_REQUEST['record']));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$weixin_external_userid = $adb->query_result($result,0,'weixin_external_userid');
			$unionid_external_userid = $adb->query_result($result,0,'unionid_external_userid');
			if(empty($weixin_external_userid)){
				$update = "update ld_contactdetails set weixin_external_userid = ? where contactid = ?";
			}else{
				$update = "update ld_contactdetails set unionid_external_userid = ? where contactid = ?";
			}
			$adb->pquery($update,array($_REQUEST['weixin_external_userid'],$_REQUEST['record']));
		}
	}
	ConvertTojsonString(1, array(), 'success');
?>