<?php

/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * edit:kevin
 * date:2013-06-04
 * reason:验证码
 */

global $theme,$mod_strings,$adb;
$query="select deploy_value from ld_systems_deploy where deploy_type = 73";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    $status=$adb->query_result($result,0,'deploy_value');
 }
require_once('Smarty_setup.php');
$smarty = new lingdangCRM_Smarty;
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
if($status == 1){
    $code='false';
}
else{
    $code='true';
}
$smarty->assign('CODE',$code);
require_once('SetmenuControl.php');
$smarty->display('DefSecutityCode.tpl');
?>