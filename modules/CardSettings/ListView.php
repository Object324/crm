<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $app_list_strings, $mod_strings;
global $adb, $current_user, $currentModule;
$smarty = new lingdangCRM_Smarty;
//require_once(globalStatic::$root_directory . 'modules/Settings/SetmenuControl.php');

$smarty->assign('current_language', getLanguageType($current_user));

$smarty->assign("MODULE_NAME",$currentModule);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("menufile",$_REQUEST['menufile']);


setGLobalURLSmarty($smarty);//js,css加载的url

$_REQUEST['diony']='yes';
$arr['content']=$smarty->fetch("modules/CardSettings/SettingLeftRight.tpl");
ConvertTojsonString(1,$arr,'success');

?>