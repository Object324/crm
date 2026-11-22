<?php
global $current_user, $currentModule;
$smarty = new lingdangCRM_Smarty();
$smarty->assign('module', $currentModule);
$smarty->assign('root_directory', globalStatic::$root_directory);
$smarty->display("modules/BIReportScreen/index.tpl");
?>