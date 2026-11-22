<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//获取单据关联信息
global $adb,$current_user;
crm_load_class_file('cls_ParentRelatedFields','include/RelatedFields');
if(!empty($_REQUEST['frommodule']) && !empty($_REQUEST['recordid'])){
	$module = $_REQUEST['frommodule'];
	$record = $_REQUEST['recordid'];
	$columnname = $_REQUEST['columnname'];
	$data = getRelatedData($module,$record,$columnname);
	ConvertTojsonString(1,$data,'success');
}
function getRelatedData($module,$record,$columnname){
	$cls_tabledetail_focus=cls_ParentRelatedFields::getInstance("$module","$record","$columnname");
	$data = $cls_tabledetail_focus->getData();
	//佣金单 - 选择合同订单、服务合同 带出最近收款日期，这里先做特殊处理
	if($module == 'Commission'){
		$related_module = getSalesEntityType($record);
		$cashbillinfo = getCashBillDate($related_module,$record);
		foreach($data['related_list'] as $key =>  $related_info){
			$recordid = $related_info['recordid'];
			if(!empty($cashbillinfo[$recordid])){
				$data['related_list'][$key]['detail'][sizeOf($related_info['detail'])] = array(
					'rawValue' => array('input_name'=>'cashbilldate','value'=>$cashbillinfo[$recordid]),
					'value' => array('input_name'=>'cashbilldate','value'=>$cashbillinfo[$recordid])
				);	
			}
		}
	}
	return  $data;
}
//获取合同订单、服务合同的最近收款日期
function getCashBillDate($relatedmodule,$record) {
	global $adb;
	$query = "select  ld_cashbill.cashbilldate,ld_cashbill2paymentplan.entitytypeid from ld_cashbill
		INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
		where ld_cashbill2paymentplan.entitytypeid in ($record) and ld_cashbill2paymentplan.entitytype = ?  
		group by cashbilldate order by  cashbilldate desc limit 1";
	$result = $adb->pquery($query,array($relatedmodule));
	$num_rows = $adb->num_rows($result);
	for($i = 0; $i<$num_rows; $i++){
		$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
		$res[$entitytypeid] = $adb->query_result($result,$i,'cashbilldate');
	}
	return $res;
}
?>