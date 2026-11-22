<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $adb;
if(!empty($_REQUEST['ReportLogType']) && !empty($_REQUEST['reportlogid'])){
	$reportlogid = $_REQUEST['reportlogid'];
	if($_REQUEST['ReportLogType'] == 'month'){
		$query = 'delete from ld_monthreport where MonthReportID = ?';
		$adb->pquery($query,array($reportlogid));
	}else if($_REQUEST['ReportLogType'] == 'daily'){
		$query = 'delete from ld_dailyreport where dailyid = ?';
		$adb->pquery($query,array($reportlogid));
	}else if($_REQUEST['ReportLogType'] == 'week'){
		$query = 'delete from ld_weekreport where weekreportid = ?';
		$adb->pquery($query,array($reportlogid));
	}
}
?>