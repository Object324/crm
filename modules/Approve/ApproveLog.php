<?php
/********************************************
**edit:kevin
**date:2013-09-12
**reason:查看审批历史
********************************************/
global $adb;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
//if(isset($_REQUEST['approveid']) && $_REQUEST['approveid'])
//$approveid=$_REQUEST['approveid'];
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
if(isset($_REQUEST['fld_module']) &&$_REQUEST['fld_module'])
$fld_module=$_REQUEST['fld_module'];

$approve=new Approve();
$approvelog=$approve->approveLog($record);
echo "###SUCCESS###";
//print_r($approvelog);
$smarty->assign('APPROVE',$approvelog);
$smarty->display('Approve/ApproveLog.tpl');
exit();
?>