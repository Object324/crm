<?php
$workingdaytype=$_REQUEST['workingdaytype'];
$workcalender_id=$_REQUEST['workcalender_id'];
$operatetype=$_REQUEST['operatetype'];
$smarty=new lingdangCRM_Smarty;
$smarty->assign('WORKCALENDERID',$workcalender_id);
$smarty->assign('WORKINGDAYTYPE',$workingdaytype);
$smarty->assign('OPERATETYPE',$operatetype);
echo '&#&#&#';
$smarty->display("AddWorkingday.tpl");
exit();
?>