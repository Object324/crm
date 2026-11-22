<?php

global $adb;
$id=$_REQUEST['id'];

$sql='DELETE from ld_validatasavedetail  where  relateid in (select id from ld_validatasave where validatasavemainid = ?)';
$adb->pquery($sql,array($id));

$sql='DELETE from ld_validatasave where validatasavemainid = ?';
$adb->pquery($sql,array($id));

$sql='DELETE from ld_validatasavemain where  id=? ';
$adb->pquery($sql,array($id));

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>