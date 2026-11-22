<?php
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='addressbook_setting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('addressbook_setting'));
if($adb->num_rows($result)){
    $para_content = $adb->query_result($result,0,'para_content');
	$para_one = $adb->query_result($result,0,'para_one');
	$para_two = $adb->query_result($result,0,'para_two');
	$para_three = $adb->query_result($result,0,'para_three');
	$smarty->assign('SECRET',$para_content);
	$smarty->assign('TOKENURL',$para_one);
	$smarty->assign('TOKEN',$para_two);
	$smarty->assign('ENCODINGAESKEY',$para_three);
}
$sql = "select para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('addressbook_setting_corpid'));
if($adb->num_rows($result) > 0){
    $para_content = $adb->query_result($result,0,'para_content');
    $smarty->assign('corpid',$para_content);
}
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/addressbook_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>