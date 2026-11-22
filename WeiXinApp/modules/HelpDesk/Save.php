<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//客户最晚服务到期日到期后是否允许创建客户服务单
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
if(!empty($_REQUEST['wx_fieldInfo'])){
	$wx_fieldInfo = $_REQUEST['wx_fieldInfo'];
	$data = array(
		'account_id' => $wx_fieldInfo['account_id'],
		'contact_id' => $wx_fieldInfo['contact_id'],
		'salesorder_id' => $wx_fieldInfo['salesorder_id'],
		'servicecontractsid' => $wx_fieldInfo['servicecontractsid'],
		'product_id' => $wx_fieldInfo['product_id'],
		'projectid' => $wx_fieldInfo['projectid']
	);
	$focus = CRMEntity::getInstance('HelpDesk');
	foreach($data as $column => $record){
		if(!empty($record)){
			$res = $focus->getAccountsForLastservicedate($record,'');
			if($res == 'error'){
				ConvertTojsonString(-1,array(),getFixedLabel('thecurstomerserviceordersarenotallowedtobe'));
				break;
			}
		}
	}
}
$mobj = new cls_SaveWX('HelpDesk');

$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();

// @edit:dong @date:2020/07/24 @reason: 已变成公共方法
////editor:gyq_96 reason:企业微信客户服务单增加签到  2019/1/9 14:04
//$mobj->insert_signin();

$mobj->ConvertTojsonStringInSave();
?>