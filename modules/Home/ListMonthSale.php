<?php
 /**
 * AUTHOR:BY Can
 * DATA:20130626 
 * param:$index=0 个人本月销售数据，$index=1 小组本月销售数据 
 */ 
 function getMonthSale($index,$scope,$senioruserid,$stuffid,$boardid,$boardstuffid){
    global $adb,$current_user;
    $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];    
    }
     $querysmownerid = '';
     $querysmowneridactivity = '';
    if($index==0){
        $querysmownerid = " where  smownerid=".$current_user->id;
        $querysmowneridactivity = " where  smownerid=".$current_user->id." and ld_activity.activitytype <> 'Emails' ";
    }
    $startDate = date("Y-m")."-01 00:00:00";
    $MaxDays = date("t",strtotime($startDate));
    $enddate = date("Y-m")."-$MaxDays 23:59:59";
     /**新的条件解析 兼容了旧的看板start */
     $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
     $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid," between '$startDate' and '$enddate' ",$_REQUEST['approve_value']);
     $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;

     /**新的条件解析 兼容了旧的看板end */

	$query="select count(1),'Accounts' as setype,sum(0) from ld_account ".$datarangesqlArr['datarangesql_Accounts']." $querysmownerid
        union all
		select count(1),'Calendar' as setype,sum(0) from ld_activity ".$datarangesqlArr['datarangesql_Calendar']." $querysmowneridactivity 
        union all
		select count(1),'Potentials' as setype,sum(0) from ld_potential  ".$datarangesqlArr['datarangesql_Potentials']." $querysmownerid
        union all
        SELECT sum(aa),'SalesOrder' AS setype,sum(bb) 
        FROM (SELECT count(1) as aa,'SalesOrder' AS setype,sum(ifnull(IF(currency_id > 1,total / conversion_rate,total),0)) as bb FROM ld_salesorder  ".$datarangesqlArr['datarangesql_SalesOrder']." $querysmownerid
        UNION ALL
        SELECT count(1) as aa,'ServiceContracts' AS setype,sum(ifnull(
        IF (currency_id > 1,total / conversion_rate,total),0)) as bb FROM ld_servicecontracts ".$datarangesqlArr['datarangesql_ServiceContracts']." $querysmownerid
        ) as nn
        union all
        select count(1),'CashBill' as setype , sum(ifnull(if(currency_id>1,total/conversion_rate,total),0))   from ld_cashbill ".$datarangesqlArr['datarangesql_CashBill']." $querysmownerid";

    $result=$adb->query($query);
    $num_rows=$adb->num_rows($result);
 
    
    $month_list[]=array(
        'ACCOUNTCOUNT'=>0,
        'CALENDARCOUNT'=>0,
        'POTENTIALCOUNT'=>0,
        'SALESORDERCOUNT'=>0,
        'SALESORDERTOTAL'=>'¥'.setNumberFormat(0,$system_deploy_351),
        'CASHBILLTOTAl'=>'¥'.setNumberFormat(0,$system_deploy_351),
        );
        
   for($i=0;$i<$num_rows;$i++)
   {
        $setype=$adb->query_result($result,$i,'setype');
        switch($setype)
        {
            case'Accounts':
                $month_list[0]["ACCOUNTCOUNT"]=$adb->query_result($result,$i,0);
               break;
            case 'Calendar':
                $month_list[0]['CALENDARCOUNT']=$adb->query_result($result,$i,0);
               break;
            case 'Potentials':
                $month_list[0]['POTENTIALCOUNT']=$adb->query_result($result,$i,0);
               break;
            case 'SalesOrder':
                $month_list[0]['SALESORDERCOUNT']=$adb->query_result($result,$i,0);
                $month_list[0]['SALESORDERTOTAL']='¥'.setNumberFormat($adb->query_result($result,$i,2),$system_deploy_351);
                break;
            case 'CashBill':
                 $month_list[0]['CASHBILLTOTAl']='¥'.setNumberFormat($adb->query_result($result,$i,2),$system_deploy_351);
                break;
        }
   }
    
    $title=array();
    
    $header=array();
    
    $entries=array();
    foreach($month_list as $list){
        foreach($list as $key=>$val){
            $value=array();
            $value[]='<span title="'.getFixedLabel($key).'">' . getFixedLabel($key) . '</span>';
            $value[]='<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou(\''.$key.'\','.$stuffid.',ld(this))" title="'.$val.'">' . $val . '</span>';
            $entries[]=$value;
        }
    }

    $values=Array('ModuleName'=>'','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
    
   // $log->debug("Exiting getMonthSale method ...");
    if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
		return $values;
 }
?>