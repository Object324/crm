<?php

//获取出入库的天数
//b.计费方式=按天：费用金额=价格*（天数-免仓期）字段
$commissionid=$_REQUEST['commissionid'];//出入库的id

global $adb;
$sql='select out_date,source_list,commissiontype from ld_commission where commission_id=?';
$result=$adb->pquery($sql,array($commissionid));
$out_date=$adb->query_result($result,0,'out_date');
$source_list=$adb->query_result($result,0,'source_list');
$commissiontype=$adb->query_result($result,0,'commissiontype');//出入库类型
$sql='select min(in_date) as max_out_date from ld_commission where deleted=0 and  FIND_IN_SET(commission_id,"'.$source_list.'")';
$result=$adb->pquery($sql,array());
if($adb->num_rows($result)>0)
{
    $max_out_date=$adb->query_result($result,0,0);
  $days= abs( DateOperation::days_between_date($max_out_date,$out_date));
    
}
else{
    $days=0;
}
$_REQUEST['diony']='yes';

ConvertTojsonString(1,array("days"=>$days,'commissiontype'=>$commissiontype),'success');




?>