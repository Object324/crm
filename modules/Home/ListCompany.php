<?php
/**
 * @param $scope
 * @param $senioruserid
 * @param $boardid //看板ID 为0则为旧的首页
 * @param $datarangesql //新看板条件sql
 * @return array|void
 * @throws Exception
 * AUTHOR:BY LD KEVIN
 * 20130301
 * 公司年度销售情况
 */
function getCompanySales($scope,$senioruserid=0,$stuffid=0,$boardid=0,$boardstuffid=0){
    global $adb;
    $system_351 = getSys_deploy(351);
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];    
    }
    $starttime = date("Y")."-01-01 00:00:00";
    $endtime = date("Y")."-12-31 23:59:59";

    /**新的条件解析 兼容了旧的看板start */
    $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
    $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid," between '$starttime' and '$endtime' ",$_REQUEST['approve_value']);
    $homeboard_filterArr = $DataRangeHomeboardObj->filterArr;
    $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;
    /**新的条件解析 兼容了旧的看板end */

	//合同订单
	if(vtlib_isModuleActive('SalesOrder')){
        $salesorder_date=$homeboard_filterArr['timecomponent_SalesOrder']['filtersfield'];//获取时间限制字段是哪个
        $salesorder_approvestatus=$homeboard_filterArr['approvestatuscomponent_SalesOrder']['filterssql']; //审批条件单独 的 sql
        $salesorder_highsearch=$homeboard_filterArr['highsearch_SalesOrder']['filterssql'];//高级查找条件单独 的 sql
        $query="
            SELECT
            	(
            		SELECT
            			SUM(ld_cashbill.total/IFNULL(ld_cashbill.conversion_rate,1)) AS total
            		FROM ld_cashbill
            		INNER JOIN (
            			SELECT DISTINCT
            				CashBillID
            			FROM (
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_salesorder
            				INNER JOIN ld_paymentplan ON ld_salesorder.salesorderid = ld_paymentplan.entitytypeid
            				INNER JOIN ld_cashbill2paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_salesorder.deleted = 0
            				UNION ALL
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_salesorder
            				INNER JOIN ld_cashbill2paymentplan ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_salesorder.deleted = 0
            			) AS t
            		) AS t_tmp ON t_tmp.cashbillid = ld_cashbill.cashbillid
            		".$datarangesqlArr['datarangesql_CashBill']." 
            	) AS total,
            	T1.salesordertotal,
            	T1.salesordercount,
            	(
            		SELECT
            			COUNT(DISTINCT ld_account.accountid)
            		FROM ld_salesorder
            		LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid
            		".$datarangesqlArr['datarangesql_SalesOrder']."  $salesorder_highsearch
            		WHERE ld_account.deleted = 0 
            			AND ld_salesorder.accountid NOT IN (
            				SELECT 
            					DISTINCT accountid
            				FROM ld_salesorder
            				WHERE deleted = 0  $salesorder_approvestatus  
            					AND $salesorder_date < '$starttime'
            				)
            	) AS accountcount
            FROM (
            	SELECT
            		SUM(total/IFNULL(conversion_rate,1)) AS salesordertotal,
            		COUNT(1) AS salesordercount
            	FROM ld_salesorder
                ".$datarangesqlArr['datarangesql_SalesOrder']." 
            ) AS T1
        ";

		$result=$adb->query($query);

		$num_rows=$adb->num_rows($result);
		$open_company_list=array();
		if($num_rows){
			$open_company_list['Sales']=
                array(
                    'modulename' => 'SalesOrder',
                    'AMOUNTTO_Sales'=>getDefaultCurrecySymbol() . setNumberFormat($adb->query_result($result,0,'total'),$system_deploy_351),
			'signNewAccount_Sales'=>$adb->query_result($result,0,'accountcount'),
			'signAmount_Sales'=>getDefaultCurrecySymbol().setNumberFormat($adb->query_result($result,0,'salesordertotal'),$system_deploy_351),
			'signCount_Sales'=>$adb->query_result($result,0,'salesordercount'),
			);
		}
	}
	//服务合同
	if(vtlib_isModuleActive('ServiceContracts')){
        $contract_date=$homeboard_filterArr['timecomponent_ServiceContracts']['filtersfield'];//获取时间限制字段是哪个
        $servicecontracts_approvestatus=$homeboard_filterArr['approvestatuscomponent_ServiceContracts']['filterssql']; //审批条件单独 的 sql
        $servicecontracts_highsearch=$homeboard_filterArr['highsearch_ServiceContracts']['filterssql'];//高级查找条件单独 的 sql
        $query="
            SELECT
            	(
            		SELECT
            			SUM(ld_cashbill.total/IFNULL(ld_cashbill.conversion_rate,1)) AS total
            		FROM ld_cashbill
            		INNER JOIN (
            			SELECT DISTINCT
            				CashBillID
            			FROM (
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_servicecontracts
            				INNER JOIN ld_paymentplan ON ld_servicecontracts.servicecontractsid = ld_paymentplan.entitytypeid
            				INNER JOIN ld_cashbill2paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_servicecontracts.deleted = 0
            				UNION ALL
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_servicecontracts
            				INNER JOIN ld_cashbill2paymentplan ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_servicecontracts.deleted = 0
            			) AS t
            		) AS t_tmp ON t_tmp.cashbillid = ld_cashbill.cashbillid
            		".$datarangesqlArr['datarangesql_CashBill']." 
            	) AS total,
            	T1.servicecontractstotal,
            	T1.servicecontractscount,
            	(
            		SELECT
            			COUNT(DISTINCT ld_account.accountid)
            		FROM ld_servicecontracts
            		LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
            		".$datarangesqlArr['datarangesql_ServiceContracts']."  $servicecontracts_highsearch
            		WHERE ld_account.deleted = 0
            			AND ld_servicecontracts.accountid NOT IN (
            				SELECT 
            					DISTINCT accountid
            				FROM ld_servicecontracts
            				WHERE deleted = 0
            					 $servicecontracts_approvestatus
            					AND $contract_date < '$starttime'
            				)
            	) AS accountcount
            FROM (
            	SELECT
            		SUM(total/IFNULL(conversion_rate,1)) AS servicecontractstotal,
            		COUNT(1) AS servicecontractscount
            	FROM ld_servicecontracts
            	".$datarangesqlArr['datarangesql_ServiceContracts']." 
            ) AS T1
        ";

		$result=$adb->query($query);
	   
		$num_rows=$adb->num_rows($result);
		if($num_rows){
			$open_company_list['Service']=
                array(
                    'modulename' => 'ServiceContracts',
                    'AMOUNTTO_Service'=>getDefaultCurrecySymbol() . setNumberFormat($adb->query_result($result,0,'total'),$system_deploy_351),
			        'signNewAccount_Service'=>$adb->query_result($result,0,'accountcount'),
			        'signAmount_Service'=>getDefaultCurrecySymbol().setNumberFormat($adb->query_result($result,0,'servicecontractstotal'),$system_deploy_351),
			        'signCount_Service'=>$adb->query_result($result,0,'servicecontractscount'
                    ),
			);
		}
	}
    $title=array();
    $header=date('Y').' '.getFixedLabel('YEAR');
    $entries=array();
    foreach($open_company_list as $key=>$list){
            $value=array();
            $value[]='<span title='.getFixedLabel('AMOUNTTO_'.$key).'>' . getFixedLabel('AMOUNTTO_'.$key) . '</span>';
            $value[]='<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.'AMOUNTTO_'.$key.'\',2,ld(this))" title='.$list['AMOUNTTO_'.$key].'>' . $list['AMOUNTTO_'.$key] . '</span>';
            $value[]='<span title='.getFixedLabel('signNewAccount_'.$key).'>' . getFixedLabel('signNewAccount_'.$key) . '</span>';
            $value[]='<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.'signNewAccount_'.$key.'\',2,ld(this))" title='.$list['signNewAccount_'.$key].'>' . $list['signNewAccount_'.$key] . '</span>';
            $entries[$list['modulename']][]=$value;
            $value=array();
            $value[]='<span title='.getFixedLabel('signAmount_'.$key).'>' .getFixedLabel('signAmount_'.$key) . '</span>';
            $value[]='<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.'signAmount_'.$key.'\',2,ld(this))" title='.$list['signAmount_'.$key].'>' .$list['signAmount_'.$key] . '</span>';
            $value[]='<span title='.getFixedLabel('signCount_'.$key).'>' .getFixedLabel('signCount_'.$key) . '</span>';
            $value[]='<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.'signCount_'.$key.'\',2,ld(this))" title='.$list['signCount_'.$key].'>' .$list['signCount_'.$key] . '</span>';
            $entries[$list['modulename']][]=$value;
    }
    $values=Array('ModuleName'=>'','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
    
    if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
		return $values;
 }
?>