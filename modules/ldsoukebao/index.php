<?php
global $current_user, $currentModule;
$smarty = new lingdangCRM_Smarty();
$smarty->assign('module', $currentModule);
$smarty->assign('component', 'ConditionalCustomer');
$smarty->assign('current_user_id', $current_user->id);
$smarty->display("soukebao.tpl");
?>