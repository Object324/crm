<?php
/**
 * User: Administrator
 * Project: crm
 * Date: 2020/6/8 11:19
 * Description:
 */
global $current_user,$adb,$currentModule;

$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony'] ='diony';
$content = $smarty->fetch($currentModule."H5PageHelp.tpl");

$arr['content'] = $content;
$arr['title'] = getFixedLabel('ACTIVITYH5PAGEHELP');
$arr['oktext']  = getFixedLabel('LBL_FINISH_BUTTON_LABEL');

ConvertTojsonString(1,$arr,'success');