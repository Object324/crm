<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$return_module = $_REQUEST['return_module'];
$productid = $_REQUEST['productid'];
$currencyid = $_REQUEST['currencyid'];
$wareid = $_REQUEST['wareid'];
$row_id = $_REQUEST['row_id'];
$accountid = $_REQUEST['accvenid'];


//@edit:liushuai,2021-03-18,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
require globalStatic::$root_directory.'WeiXinApp/modules/Products/getProductInfo.php';
$jsonArray = getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid);
//chj 2022/4/14 企业微信移动端和微信小程序，增加“客户服务卡”和“维保计划”个性化开发需求（贺桃-黄杰宗）
$version_info = getVersionInfo();
//贺桃特殊开发
if($version_info['account'] == 'hetao'){
	if(empty($jsonArray['list']['baoyang_zhouqi'])){
		$focus = CRMEntity::getInstance('Products');
		$focus->retrieve_entity_info($productid, 'Products');
		$jsonArray['list']['baoyang_zhouqi'] = $focus->column_fields['cf_4568'];
	}
	
}
if($version_info['account'] =='hetao' && $_REQUEST['frommodule'] == 'CustomForm17' && !empty($_REQUEST['ht_entrycount'])){
	if(urldecode($jsonArray['list']['productcategory']) == '滤芯'){
		if(!empty($jsonArray['list']['baoyang_zhouqi'])){
			switch($jsonArray['list']['baoyang_zhouqi']){
				case '1':
				   $jsonArray['list']['quantity'] = $_REQUEST['ht_entrycount']*12;
				   break;
				case '2':
				   $jsonArray['list']['quantity'] = $_REQUEST['ht_entrycount']*6;
				   break;
				case '3':
				   $jsonArray['list']['quantity'] = $_REQUEST['ht_entrycount']*4;
				   break;
				case '6':
				   $jsonArray['list']['quantity'] = $_REQUEST['ht_entrycount']*2;
				   break;
				case '12':
				   $jsonArray['list']['quantity'] = $_REQUEST['ht_entrycount'];
				   break;
			}
		}
	}
}

//接口调用
crm_load_class_file('cls_module_api','include/Module_Api');
$cls_module_api = new cls_module_api($_REQUEST['frommodule']);
$cls_module_api->setProductInfo($jsonArray['list']);
$api_data = $cls_module_api->get();
if(!empty($api_data)){
    foreach($api_data as $colname => $value){
        $jsonArray['list'][$colname]=$value;
    }
}
ConvertTojsonString(1,$jsonArray,'');
?>