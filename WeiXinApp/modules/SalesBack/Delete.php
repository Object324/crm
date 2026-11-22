<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
//ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(移动端销售退货单删除时)
$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,
            entitytypeid ,ld_salesbackdetail.entitytype,lineitem_id
                    from ld_salesbackdetail 
                    left join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));
$num_rows = $adb->num_rows($result);
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    $arr = DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'',"yes");
}
//反写合同订单已入库和未入库数量
crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
for($i=0;$i<$num_rows;$i++)
{
    $entitytypeid = $adb->query_result($result,$i,'entitytypeid');
    $productid = $adb->query_result($result,$i,'productid');
    $qty = $adb->query_result($result,$i,'quantity');
    $entitytype = $adb->query_result($result,$i,'entitytype');
    $parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
    $lineitem_id = $adb->query_result($result,$i,'lineitem_id');

    if($entitytypeid > 0){

        cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
    }
}



if($focus->column_fields['account_id']>0){

    $focus->updateRelatedTableInfo('ld_account',array($focus->column_fields['account_id']));

}
if($focus->column_fields['potential_id']>0){

    $focus->updateRelatedTableInfo('ld_potential',array($focus->column_fields['potential_id']));

}


$trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
$tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。
if(!empty($tradename)&&file_exists('../include/trade/'.$tradename.'/'.$tradename.'_SalesBack.php'))
{
    require_once('../include/trade/'.$tradename.'/'.$tradename.'_SalesBack.php');
    $trade_class_name=$tradename.'_SalesBack';   
    if(class_exists($trade_class_name))     
    {
        $trade_focus=new $trade_class_name($focus);  
        if(method_exists($trade_focus,"Delete")){
            $trade_focus->Delete($_REQUEST['record'],$currentModule);//合同订单删除时，生成产品购买交易记录。(金融/基金行业)
        }
    }
}

ConvertTojsonString('1',$arr,'');
?>