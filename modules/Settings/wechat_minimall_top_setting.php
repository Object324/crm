<?php
/**
* @edit:dong
* @data:2020/08/26
* @reason:小程序商城顶部设置
* @description:
*/
global $adb,$current_user,$languageType;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='wechat_minimall_top_setting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require(globalStatic::$root_directory.'appCommon/appCommon.php');
$smarty = new lingdangCRM_Smarty;
$sql = "SELECT
	name,value
FROM
	ld_wxshoppingmall_config
WHERE
	name IN ( 'miniprogram_title', 'top_nav_text_color', 'top_nav_background_color' )
	";
$result = $adb->pquery($sql);

if($num_row = $adb->num_rows($result)){
    for ($i=0;$i<$num_row;$i++){
        $name =$adb->query_result($result,$i,'name');
        $$name = $adb->query_result($result,$i,'value');
    }
    $smarty->assign('miniprogram_title',$miniprogram_title);
    $smarty->assign('top_nav_text_color',$top_nav_text_color);
    $smarty->assign('top_nav_background_color',$top_nav_background_color);

}

$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='yes';

$arr['content']= $smarty->fetch('Settings/wechat_minimall_top_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>