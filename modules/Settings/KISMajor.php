<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once('Smarty_setup.php');
$smarty= new lingdangCRM_Smarty;
if(isset($_REQUEST['sa']))
{
    $smarty->assign("SA",getDatainterface('sa'));
    $smarty->assign("PWD",getDatainterface('pwd'));
    $smarty->assign("HOSTNAME",$_REQUEST['hostname']);
    $smarty->assign("DATABASENAME",$_REQUEST['databasename']);
    $smarty->assign("FACETYPE",$_REQUEST['facetype']);
}
if(isset($_REQUEST['setting_mode'])){
    $smarty->assign("SETTING_MODE",$_REQUEST['setting_mode']);
}
echo "&&&&&&&&&&&&//B/";
$smarty->display("modules/DataInterface/KISMajor.tpl");
exit();
?>