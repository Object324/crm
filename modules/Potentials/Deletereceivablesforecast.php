<?php
//回款预测删除
global $currentModule,$adb;

$reid=$_REQUEST['id'];
$pid=$_REQUEST['record'];
$dsql = "DELETE from ld_receivablesforecast WHERE receivablesforecastid=$reid AND potentialsid=$pid;";
$adb->pquery($dsql, array());
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

//header("Location: index.php?module=Potentials&action=DetailView&record=$pid&parenttab=".getParentTab());
?>