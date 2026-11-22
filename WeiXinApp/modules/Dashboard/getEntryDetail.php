<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_20191119 reason:优化报表内容载入速度
crm_load_class_file('ReportModel','modules/OftenUseReport');
$listvalue = explode(',',$_REQUEST['get_entry_detail']) ;
$reportmodel = new ReportModel();
//editor:gyq_20191120 reason:$_REQUEST['show_zero_quantity']
//0038625: （kfbcrm）移动端，即时库存查询报表，查询条件显示库存数量为0的记录为“否”时没有生效
$_REQUEST['show_zero_quantity'] = $listvalue[4];
if($_REQUEST['stock_view'] == 'ERP'){
	$_REQUEST['from_mobile']='yes';//来自移动端
	$_REQUEST['record'] = $listvalue[0];
	$_REQUEST['from_mobile_product']='yes';
	require_once globalStatic::$root_directory.'modules/ReportAnalysis/stock_report.php';
	die;
}else{
	$list = $reportmodel->product_detail_qtyinstock($listvalue[0],$listvalue[1],$listvalue[2],$listvalue[3]);
	ConvertTojsonString(1,array('entry'=>$list),'');
}
