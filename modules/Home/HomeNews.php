<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
include_once('vtlib/lingdang/Feed/Parser.php');

global $app_strings, $mod_strings, $theme, $currentModule;

$ftimeout = 60;
$fparser = new lingdang_Feed_Parser();
$fparser->vt_dofetch('http://www.lingdang.com/products/crm/newsfeed.php', $ftimeout);
$items = $fparser->get_items();
$NEWSLIST = Array();
foreach($items as $item) {
	$NEWSLIST[] = $item;
}

require_once('Smarty_setup.php');
$smarty = new lingdangCRM_Smarty;
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", "themes/$theme/images/");
$smarty->assign('NEWSLIST', $NEWSLIST);
$smarty->display("HomeNews.tpl");
?>