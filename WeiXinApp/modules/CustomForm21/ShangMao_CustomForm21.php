<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if(!empty($_REQUEST['type'])){
	global $adb;
	//更改客户状态
	if($_REQUEST['type']  == 'ChangeAccountStatus'){
		if(!empty($_REQUEST['value']) && !empty($_REQUEST['record']) && !empty($_REQUEST['lineitemid'])){
			if($_REQUEST['value'] == '有效客户'){
				$_REQUEST['value'] = '无效客户';
			}else{
				$_REQUEST['value'] = '有效客户';
			}
			$query = "update ld_customform21detail 
			LEFT JOIN ld_customform21detailscf on ld_customform21detail.lineitem_id = ld_customform21detailscf.lineitem_id 
			set sf316 = ? where ld_customform21detail.lineitem_id = ? and id = ?";
			$adb->pquery($query,array($_REQUEST['value'],$_REQUEST['lineitemid'],$_REQUEST['record']));

			ConvertTojsonString(1, array(), getFixedLabel('SUCCESSFULLYMODIFIED'));
		}
	}
}

?>