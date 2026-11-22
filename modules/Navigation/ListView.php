<?php
/*******************************************************
**更新操作
**edit:kevin
**date:2013-11-14
**reason:库存初始化
*******************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('Smarty_setup.php');
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user;
global $list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty;

if($current_user->is_admin == 'off'){
	$smarty->assign('URL','');
	$smarty->assign('WAREURL','');
}else{
	$smarty->assign('URL','href=\'index.php?module=Settings&action=listroles&parenttab=Settings&blockidsetting=2&fieldidsetting=2\'');
	$smarty->assign('WAREURL','href=\'index.php?module=Settings&action=ListWareHouse&parenttab=Settings\'');
}
$smarty->display('Navigation/ListView.tpl');
?>