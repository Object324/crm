<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('CommonStock','include/Stock');

$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息

//判断出库数量是否大于库存数量
$productinfo =array();
for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
    if($_REQUEST['hidden_rowid_'.$i]==0){
        $productinfo[] = $_REQUEST['hdnProductId'.$i].'|'.$_REQUEST['quantity'.$i];
    }
}
$_REQUEST['productinfo'] = implode(',',$productinfo);
$_REQUEST['frommodule'] = $_REQUEST['module'];
$_REQUEST['type'] = 'save';
require_once(globalStatic::$root_directory.'modules/Products/CheckProductQtyinstock.php');
$focus = cls_Instance::get_module_Instance('OutboundOrder');
$msg = '';
//扫码行业：录入的产品是否有合同订单之前的产品，录入的产品数量（按照产品ID汇总统计）是否超出订单中相应产品的数量。
$products = array();
$quantitys = array();
if(!empty($_REQUEST['rowcnt']) && $_REQUEST['rowcnt'] >= 1){
	for($i = 1; $i <= $_REQUEST['rowcnt']; $i++){
		$products[] = $_REQUEST['hdnProductId'.$i];
		$quantitys[] = $_REQUEST['quantity'.$i];
	}
	$prd_string = implode(',',$products);
	$qty_string = implode(',',$quantitys);
	$msg = $focus->setSaveForSalesOrderCheck($_REQUEST['salesorder_id'],$prd_string,$qty_string);
}
if(empty($msg)){
	$mobj->common_save();
	$mobj->ConvertTojsonStringInSave();
}else{
	ConvertTojsonString(-1,array(),$msg);
}
?>