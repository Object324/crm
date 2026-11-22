<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
ini_set('error_reporting', 'on');
error_reporting(E_ALL & ~E_NOTICE);

$lingdang_Utils_Log = true;

include_once 'vtlib/lingdang/Module.php';

$smsnotifierModuleInstance = lingdang_Module::getInstance('SMSNotifier');
$smsnotifierModuleInstance->addLink("HEADERSCRIPT", "SMSNotifierCommonJS", "modules/SMSNotifier/SMSNotifierCommon.js");

$leadsModuleInstance = lingdang_Module::getInstance('Leads');

$leadsModuleInstance->addLink("LISTVIEWBASIC", "Send SMS", "SMSNotifierCommon.displaySelectWizard(this, '\$MODULE\$');");
$leadsModuleInstance->addLink("DETAILVIEWBASIC", "Send SMS", "javascript:SMSNotifierCommon.displaySelectWizard_DetailView('\$MODULE\$', '\$RECORD\$');");

$contactsModuleInstance = lingdang_Module::getInstance('Contacts');
$contactsModuleInstance->addLink('LISTVIEWBASIC', 'Send SMS', "SMSNotifierCommon.displaySelectWizard(this, '\$MODULE\$');");
$contactsModuleInstance->addLink("DETAILVIEWBASIC", "Send SMS", "javascript:SMSNotifierCommon.displaySelectWizard_DetailView('\$MODULE\$', '\$RECORD\$');");

$accountsModuleInstance = lingdang_Module :: getInstance('Accounts'); 

?>