<?php
//editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/15 15:49
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
if($_REQUEST['second_action']=='qrcode_window'){
    $sql_wx_config='select para_three from ld_wx_config where name=?';
    $result_wx_config = $adb->pquery($sql_wx_config, array('wechat_miniprogram_setting'));
    $corpindex = $adb->query_result($result_wx_config,0,'para_three');
    $result_json = 'userid='.$current_user->id.'&corpindex='.$corpindex;
    $smarty->assign('CORPLINK',$result_json);
    $smarty->display('Settings/wechat_miniprogram/qrcode_window.tpl');
}
exit();

?>