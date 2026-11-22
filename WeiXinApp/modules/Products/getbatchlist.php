<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb;
//editor:gyq_86 reason:产品批次 2018/11/2 11:07
crm_load_class_file('ModelBatch','modules/Products/batch');
$module_obj = new ModelBatch();
//editor:gyq_20191010 reason:出库单选择批次，支持搜索
$_REQUEST['searchbatchtext']  = $_REQUEST['search_content'];
if($_REQUEST['frommodule']=='OutboundOrder') {
    $tmparr = $module_obj->getSelectMultibatchList();
}else
    $tmparr = $module_obj->getbatchList();
$list_final = array();
$list_first = $tmparr['content'];
$list_title = $tmparr['title'][0];
//chj 2022/6/20 设置：选择批次，批次数量自动覆盖产品数量
$query = "select 1 from ld_batchqtysetting where module = ? and userid = ?";
$result = $adb->pquery($query,array($_REQUEST['frommodule'],$current_user->id));
if($adb->num_rows($result) >= 1){
	$select_batch_qty = 'yes';
}else{
	$select_batch_qty = 'no';
}
foreach ($list_first as $key=>$value){
    $temp_list = array();
    $list_final[$key]['title'] = $list_title['batch'].':'.$value['batch'];
    $list_final[$key]['field'][0] = $list_title['warehoursename'].':'.$value['warehoursename'].' | '.$list_title['quantity'].':'.$value['quantity'];
    //editor:gyq_20191023 reason:生成日期字段若隐藏，则需要判断空值
    //0038329: （珞落计划）企业微信端，出库单新建界面选择“入库单”源单，编辑产品明细，选择批次界面显示字段名称问题
    if(!empty($list_title['productdate'])){
        $temp_list[] =  $list_title['productdate'].':'.$value['productdate'];
    }
    if(!empty($list_title['protectqualitydate'])){
        $temp_list[] = $list_title['protectqualitydate'].':'.$value['protectqualitydate'];
    }
	if($select_batch_qty == 'no'){
		$value['quantity'] = 1;
	}
    $list_final[$key]['field'][1] =  implode(' | ',$temp_list) ;
    $list_final[$key]['hiddentitle'] = $value['batch'];
    $list_final[$key]['hiddenqty'] = $value['quantity'];
    $list_final[$key]['curid'] = $value['batch'];
}
$list_result['list1'] = $list_final;
$list_result['search_reminds'] = getFixedLabel('BATCH');
ConvertTojsonString(1,$list_result,'success');