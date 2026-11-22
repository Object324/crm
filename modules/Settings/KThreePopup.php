<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once('Smarty_setup.php');
if(!isset($smarty))
{
    $smarty = new lingdangCRM_Smarty;
}
if(isset($_REQUEST['sa']))
{
    $smarty->assign("SA",$_REQUEST['sa']);
    $smarty->assign("PWD",$_REQUEST['pwd']);
    $smarty->assign("HOSTNAME",$_REQUEST['hostname']);
    $smarty->assign("DATABASENAME",$_REQUEST['databasename']);
}
//账套数据库连接方式
if(isset($_REQUEST['setting_mode'])){
    $smarty->assign("SETTING_MODE",$_REQUEST['setting_mode']);
}
//连接方式
$smarty->assign('CONNECT_MODE',getDatainterface('connect_mode'));
echo "&&&&&&&&&&&&//B/";
$smarty->display("modules/DataInterface/KThree.tpl");
exit();

?>