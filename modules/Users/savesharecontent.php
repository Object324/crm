<?php

$viewuserid=$_REQUEST['viewuserid'];
$crmid=$_REQUEST['crmid'];

$columnname=$_REQUEST['columnname'];
$content=$_REQUEST['content'];
global $adb;

$sql=" update ld_tabshare  set $columnname=? where crmid=? and viewuserid=?";

$adb->pquery($sql,array($content,$crmid,$viewuserid));
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array('content'=>$content),'success');
?>