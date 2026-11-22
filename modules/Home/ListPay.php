<?php
/**
 * *{*修改编码格式:统一编码：UTF-8*} 
 * AUTHOR:BY LD KEVIN
 * DATE:20130227
 * DESCRIPTION:应收款/应付款客户汇总
 */ 
function getPay($scope,$senioruserid=0,$stuffid=0,$boardid=0,$boardstuffid=0){
    global $adb;
    $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];    
    }
    $scopedate=getHomeDateScope($_REQUEST['search_date']);
    /**新的条件解析 兼容了旧的看板start */
    $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
    $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid,$scopedate,$_REQUEST['approve_value']);
    $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;
    /**新的条件解析 兼容了旧的看板end */
   /* add lmx 2014022  0007117: 首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
        说明	首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
        1.关闭“回款计划”、“付款计划”、“采购订单”时，相应信息在“应收/应付汇总”组件中，依然显示，与需求不符，应更改为：当“相应模块关闭时，不显示该内容；
   */
    if(vtlib_isModuleActive('SalesOrder')&&vtlib_isModuleActive('ServiceContracts'))
    {
		$query ="
            SELECT SUM(oftenusereport_PaymentBalance) as PaymentBalance FROM (SELECT 
            (IFNULL(SalesOrder_Total, 0) - IFNULL(F1.received_amount, 0)
            ) AS oftenusereport_PaymentBalance
            FROM (
            SELECT 
            		DISTINCT ld_SalesOrder.smownerid AS SmOwnerid,
            		ld_SalesOrder.signed_data AS SalesOrder_signed_data,
            		ld_salesorder.sostatus AS 'SalesOrder_sostatus',
            		if(ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total) AS 'SalesOrder_Total',
					IF (
						ld_salesorder.currency_id > 1,
						ld_salesorder.received_amount / ld_salesorder.conversion_rate,
						ld_salesorder.received_amount
					) AS 'received_amount',
            		ld_salesorder.salesorderid AS id
            	FROM
            		ld_salesorder
            	".$datarangesqlArr['datarangesql_SalesOrder']."
            UNION
            SELECT 
            		DISTINCT ld_servicecontracts.smownerid AS SmOwnerid,
            		ld_servicecontracts.due_date AS SalesOrder_signed_data,
            		ld_servicecontracts.contract_status AS 'SalesOrder_sostatus',
            		if(ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total) AS 'SalesOrder_Total',
					IF (
						ld_servicecontracts.currency_id > 1,
						ld_servicecontracts.received_amount / ld_servicecontracts.conversion_rate,
						ld_servicecontracts.received_amount
					) AS 'received_amount',
            		ld_servicecontracts.servicecontractsid AS id
            	FROM
            		ld_servicecontracts
            	".$datarangesqlArr['datarangesql_ServiceContracts']."
            	) AS F1 
            ) as F5";
        $result=$adb->query($query);
        $num_rows=$adb->num_rows($result);
        $open_pay_list=array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $PaymentBalance=(float)$adb->query_result($result,$i,'paymentbalance');
                $paytotal=number_format($PaymentBalance,'2');
                $open_pay_list[]=array(
                    'saleordercount'=>$adb->query_result($result,$i,'salesordercount'),
                    'paytotal'=>$paytotal,
                    'labelbol'=>'RECEIVEBYORDER',
                    'paymenttypes'=>getFixedLabel('RECEIVEBY').getTranstab('ORDER').')：',
                    'url'=>'index.php?pageto_module=ReportAnalysis&pageto_action=newindex','page_addurl'=>'&UseReport=5'
                );
            }
        }
    }
    /* add lmx 2014022  0007117: 首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
    说明	首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
    1.关闭“回款计划”、“付款计划”、“采购订单”时，相应信息在“应收/应付汇总”组件中，依然显示，与需求不符，应更改为：当“相应模块关闭时，不显示该内容；
    */
    if(vtlib_isModuleActive('PaymentPlan'))
    {
        //按回款计划
        $paymentplan_sql="select sum(if(ld_paymentplan.currency_id >1,(ld_paymentplan.amount-IFNULL(actualamount,0))/ld_paymentplan.conversion_rate,ld_paymentplan.amount-IFNULL(actualamount,0))) as paymentplan_sums  
            from ld_paymentplan 
            ".$datarangesqlArr['datarangesql_PaymentPlan'];
        $paymentplan_result=$adb->query($paymentplan_sql);
        $paytotal=$adb->query_result($paymentplan_result,0,'paymentplan_sums');
        $paytotal=number_format((float)$paytotal,$system_deploy_351);
        $open_pay_list[] = array(
            'paytotal'=>$paytotal,
            'labelbol'=>'RECEIVEBYPaymentplan',
            'paymenttypes'=>getFixedLabel('RECEIVEBY').getTranstab('PaymentPlan').')：',
            'url'=>'index.php?pageto_module=ReportAnalysis&pageto_action=newindex','page_addurl'=>'&UseReport=4'
        );
    }
        
     /* add lmx 2014022  0007117: 首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
        说明	首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
        1.关闭“回款计划”、“付款计划”、“采购订单”时，相应信息在“应收/应付汇总”组件中，依然显示，与需求不符，应更改为：当“相应模块关闭时，不显示该内容；
        */
    if(vtlib_isModuleActive('PurchaseOrder'))
     {
        //按采购合同
        $paymentplan_sql="select sum(if(ld_purchaseorder.currency_id >1,IFNULL(ld_purchaseorder.total,0)/ld_purchaseorder.conversion_rate,IFNULL(ld_purchaseorder.total,0))-IFNULL(temps.total_Amount,0)) as amounts 
        from ld_purchaseorder  left JOIN
            (SELECT 	sum(if(ld_sendcashbill2payment.currency_id >1,IFNULL(amount,0)/ld_sendcashbill2payment.conversion_rate,IFNULL(amount,0))) AS total_Amount,
		ld_sendcashbill2payment.Purchaseorder_id,
		ld_sendcashbill.sendcashbillid
	FROM ld_sendcashbill2payment 
    INNER JOIN ld_sendcashbill  on ld_sendcashbill.sendcashbillid=ld_sendcashbill2payment.sendcashbillid
    ".$datarangesqlArr['datarangesql_SendCashBill']."
    GROUP BY	ld_sendcashbill2payment.purchaseorder_id) as temps on  ld_purchaseorder.purchaseorderid=temps.Purchaseorder_id
    inner join ld_users on ld_users.id=ld_purchaseorder.smownerid
    ".$datarangesqlArr['datarangesql_PurchaseOrder'];
    $paymentplan_result=$adb->query($paymentplan_sql);
    $paymentplan_rows=$adb->num_rows($paymentplan_result);
    $sqlpo="select usereportid from ld_usereport where name='SendCashBillSum_PurchaseOrder'";
    $poid_result=$adb->query($sqlpo);
    $usereportid=$adb->query_result($poid_result,0,'usereportid');
    for($i=0;$i<$paymentplan_rows;$i++){
        $paytotal=number_format((float)$adb->query_result($paymentplan_result,0,'amounts'),$system_deploy_351);
        $open_pay_list[]=array(
            'paytotal'=>$paytotal,
            'labelbol'=>'PaymentPurchase',
            'paymenttypes'=>getFixedLabel('PAYABLEBY').getTranstab('PurchaseOrder').')：',
            'url'=>'index.php?pageto_module=ReportAnalysis&pageto_action=newindex','page_addurl'=>'&UseReport='.$usereportid
            );
        }
     }

      /* add lmx 2014022  0007117: 首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
            说明	首页“应收/应付汇总”组件，内容显示逻辑，与需求不符，具体如下：
            1.关闭“回款计划”、“付款计划”、“采购订单”时，相应信息在“应收/应付汇总”组件中，依然显示，与需求不符，应更改为：当“相应模块关闭时，不显示该内容；
        */
    if(vtlib_isModuleActive('SendPayment'))
    { 
    //按付款计划
    $paymentplan_sql="select sum(if(ld_sendpayment.currency_id >1,(ld_sendpayment.amount-IFNULL(actualamount,0))/conversion_rate,ld_sendpayment.amount-IFNULL(actualamount,0))) as sendpayment_sum  from ld_sendpayment 
		inner join ld_users on ld_users.id=ld_sendpayment.smownerid
		".$datarangesqlArr['datarangesql_SendPayment'];
    $paymentplan_result=$adb->query($paymentplan_sql);
    $paymentplan_rows=$adb->num_rows($paymentplan_result);
    $sqlsp="select usereportid from ld_usereport where name='SendCashBillSum_SendPayment'";
    $spid_result=$adb->query($sqlsp);
    $usereportid=$adb->query_result($spid_result,0,'usereportid');
    for($i=0;$i<$paymentplan_rows;$i++){
        $paytotal=number_format((float)$adb->query_result($paymentplan_result,0,'sendpayment_sum'),$system_deploy_351);
            $open_pay_list[]=array(
                'paytotal'=>$paytotal,
                'labelbol'=>'PaymentSendPayment',
                'paymenttypes'=>getFixedLabel('PAYABLEBY').getTranstab('SendPayment').')：',
                'url'=>'index.php?pageto_module=ReportAnalysis&pageto_action=newindex','page_addurl'=>'&UseReport='.$usereportid
            );
        }
    }
    $title=array();
    $header=array();
    $entries=array();
    foreach($open_pay_list as $pay){
        $value=array();
        $valuestr=$pay['paymenttypes'];
        if($pay['paytotal'] !='')
        $valuestr .= '<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.$pay['labelbol'].'\','.$stuffid.',ld(this))">'.getDefaultCurrecySymbol().$pay['paytotal'].'</a>';
        else
        $valuestr .= '<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.$pay['labelbol'].'\','.$stuffid.',ld(this))">'.getDefaultCurrecySymbol().'0.00'.'</a>';
        $url=$pay['url']!=''?$pay['url']:'#';
        $valuestr .="&nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:;' onclick='home_href(\"".$url."\",\"".$pay['page_addurl']."\")'>".getFixedLabel("VIEWDETAIL").'</a>';
        $value[]=$valuestr;
        $entries[]=$value;
    }
    $values=Array('ModuleName'=>'','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
   
    if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
		return $values;
 }
 

?>