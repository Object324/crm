<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$focus->id=$_REQUEST['record'];
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,wareid 
                ,entitytype,lineitem_id ,batchtext
                    from ld_outboundorderdetail 
                    left join ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));
$num_rows = $adb->num_rows($result);
//反写合同订单的出库库状态
crm_load_function_file('insertCondtion','include/Stock','CommonStock');
crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
$deploy_values=getSys_deploy("69");
if($deploy_values['deploy_value']==1&&Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    $entity['log']['value'] = $srt1;
    $entity['title']['value'] = getFixedLabel('DELETE');
    $json = new Zend_Json();
    $jsonentity = $json->encode($entity);
    echo $jsonentity;die;
}
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    $arr = DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'',"yes");
}

$adb->pquery('delete from ld_outboundorderdetail where id = ?',array($focus->id));
$deployarray=getSys_deploy(48);//灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
for($i = 0; $i<$num_rows; $i++){
	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
	$productid = $adb->query_result($result,$i,'productid');
	$qty = $adb->query_result($result,$i,'quantity');
	$entitytype = $adb->query_result($result,$i,'entitytype');
	$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
	$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
	$wareid = $adb->query_result($result,$i,'wareid');
    $batchtext=$adb->query_result($result,$i,'batchtext');
	if($deployarray['deploy_value']== 1){
		insertCondtion($batchtext, $_REQUEST['record'],'删除出库单',$focus->column_fields['wareid'],$productid,$currentModule,$focus->column_fields['assigned_user_id'],0,$qty,$parent_lineitem_id,$lineitem_id);
	}
	//更新原单的出库状态、未出库和已出库数量
    cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
}
ConvertTojsonString('1',$arr,'');