<?php
//editor:gyq_144 reason:钉钉  2019/9/12 13:55    78_SBLO7mB8PFHP1g3WvGyKOMwZYccRyR7LBaIK3sK8UgXIM2PCMFpmqDbOWxlGz
//editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 17:08
//editor:gyq_165 reason:钉钉消息提醒   2019/12/26 15:00
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='channelcode_settings';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('channelcode_setting'));
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
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
// $smarty->display('Settings/wechat_miniprogram/dingtalk_setting.tpl');
$arr['content']= $smarty->fetch('Settings/wechat_miniprogram/channelcode_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>