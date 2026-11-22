<?php
global $adb;
$_REQUEST['diony'] = 'yes';
$selectid = $_REQUEST['selectid'];
$selectid = rtrim($selectid,',');
$sql = "CALL ldcrm_reset_expensebudget_byid('$selectid');";

$res = $adb->pquery($sql);
$adb->getAffectedRowCount($res);
$_REQUEST['diony'] = 'yes';

//执行批量重算  传入id
ConvertTojsonString(1, ['effectrows'=>1], getFixedLabel('SUCCESS'));