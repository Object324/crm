<?php

global $adb;
//反写字段公式
$reversefieldtype=$_REQUEST['reversefieldtype'];
$reversefieldid=$_REQUEST['reversefieldid'];

$reversetable=$_REQUEST['reversetable'];
$reverseparentid=$_REQUEST['reverseparentid'];
$module=$_REQUEST['frommodule'];
$tabid=getTabid($module);
$params=array();
$params[]=$reversefieldid;
$params[]=$tabid;
$params[]=$reversetable;
$sql='delete from ld_reverseformula where relateid=? and reversetabid=? and reversetable=?';
if(!empty($reversefieldtype))
{
    $sql.=" and reversefieldtype=?";
    $params[]=$reversefieldtype;
}
$adb->pquery($sql,$params);
unsetCacheDirectory('productfields');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>