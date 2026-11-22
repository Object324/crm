<?php
global $adb;
if(!empty($_REQUEST['time_date']) && !empty($_REQUEST['smownerid'])){
	$time_date = $_REQUEST['time_date'];
	$smownerid = $_REQUEST['smownerid'];
	$time_date_arr = explode(',',$_REQUEST['time_date']);
	//$time_date_arr 日期+工时+行
	for($i = 0; $i<count($time_date_arr); $i++){
		$time_info = explode('/',$time_date_arr[$i]);
		if(empty($times[$time_info[0]])){
			$times[$time_info[0]] = $time_info[1];
		}else{
			$times[$time_info[0]] += $time_info[1];
		}
		$times_row[$time_info[2]] = $time_info[0];
	}
	$res_data = [];
	foreach($times as $date => $costtime){
		$query = 'select workdate,sum(costtime) as sum_costtime from ld_timesheet LEFT JOIN ld_timesheetdetail on ld_timesheetdetail.timesheet_id = ld_timesheet.timesheet_id 
					where smownerid = '.$smownerid.' and deleted = 0 and costtime > 0 and workdate = ?';
		if($_REQUEST['record'] > 0){
			$query .= ' and ld_timesheet.timesheet_id != ' . $_REQUEST['record'];
		}
		$result = $adb->pquery($query,array($date));
		$sum_costtime = $adb->query_result($result,0,'sum_costtime');
		$sum_costtime = !empty($sum_costtime)?floatval($sum_costtime):0;
		$costtime = !empty($costtime)?floatval($costtime):0;
		if($sum_costtime + $costtime > 8){
			$res_data[] = $date;
		}
	}
}
$res = array();
if(!empty($_REQUEST['now_rowid']) && sizeOf($res_data) >= 1){
	$now_rowid = $_REQUEST['now_rowid'];
	$row_date = $times_row[$now_rowid];
	if(in_array($row_date,$res_data)){
		$res = $res_data;
	}
}else{
	$res = $res_data;
}

global $PlatformMC;//注意：微信直接调用此文件
if(sizeOf($res) == 0){
    if(!empty($PlatformMC)&&$PlatformMC['type']=='weixin'){
        ConvertTojsonString(1,array(),'');
    }else{
        $res = 'SUCCESS';
    }
}
if((!empty($PlatformMC)&&$PlatformMC['type']=='weixin')||$_REQUEST['responseType']=='htmlfive'){
    ConvertTojsonString(-1,'',getFixedLabel('THESEDATETIMEOVER8').implode(',',$res));
}else{
    require_once('./include/Zend/Json.php');
    $json = new Zend_Json();
    $jsonentity = $json->encode($res);
    echo $jsonentity;die;
}

?>