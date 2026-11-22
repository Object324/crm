<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$focus->id=$_REQUEST['record'];
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
$query = 'select entitytype,quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,wareid,lineitem_id ,batchtext
from ld_stockdetail 
left join ld_stock on ld_stock.stock_id = ld_stockdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));
$num_rows = $adb->num_rows($result);
crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');

//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    $arr = DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'',"yes");
}
$adb->pquery('delete from ld_stockdetail where id = ?',array($focus->id));
$deployarray=getSys_deploy(48);
for($i = 0; $i<$num_rows; $i++){
	$productid = $adb->query_result($result,$i,'productid');
	$qty = $adb->query_result($result,$i,'quantity');
    $entitype=$adb->query_result($result,$i,'entitytype');
	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
	$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
	$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
	$wareid = $adb->query_result($result,$i,'wareid');
    $batchtext=$adb->query_result($result,$i,'batchtext');
	//更新采购订单的入库状态、未入库和入出库数量
    if($entitytypeid>0&&!in_array($entitytypeid,$exist_entitytypeids))
        cls_Source_InverseCompute::Source_InveverseCompute($entitype,$entitytypeid);
    $exist_entitytypeids[]=$entitytypeid;
	if($deployarray['deploy_value']== 1){
		insertCondtion($batchtext,$_REQUEST['record'],'删除入库单',$focus->column_fields['wareid'],$productid,$currentModule,$focus->column_fields['assigned_user_id'],0,$qty,$parent_lineitem_id,$lineitem_id);   
	}
}
ConvertTojsonString('1',$arr,'');