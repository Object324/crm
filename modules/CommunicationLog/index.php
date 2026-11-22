<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
/*require_once('Smarty_setup.php');
global $currentModule;

$smarty->display(vtlib_getModuleTemplate($currentModule,'smswork.tpl'));*/

global $currentModule;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='CommunicationLog';
$smarty=new lingdangCRM_Smarty();

$smarty->assign("tabtype",'smslist');
$smarty->display("modules/CommunicationLog/CommunicationAllContent.tpl");

 
?>
