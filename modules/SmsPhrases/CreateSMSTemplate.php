<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * edit:kevin
 * date:2013-06-25
 * reason:创建短信模板
 */ 
 global $app_strings;
 require_once('Smarty_setup.php');
 $smarty=new lingdangCRM_smarty;
 $mode="create";
 $smarty->assign('MODE',$mode);
 $smarty->assign('APP',$app_strings);
 
 require_once("modules/Settings/SetmenuControl.php");
 $smarty->display("createsmstemplate.tpl");
?>