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
	id,filename,path,url,createdtime,sequence
FROM
	ld_wxshoppingmall_banner 
ORDER BY sequence,id
";
$result = $adb->pquery($sql);
$smartyArr = array();
if($num_row = $adb->num_rows($result)){
    for ($i=0;$i<$num_row;$i++){
        $smartyArr[] =$adb->fetch_array($result);
    }
    $smarty->assign('fileArr',$smartyArr);
    $smarty->assign('fileArrLength',count($smartyArr));
}

$smarty->assign('site_URL',$site_URL);
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='yes';

$arr['content']= $smarty->fetch('Settings/wechat_minimall_banner_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>