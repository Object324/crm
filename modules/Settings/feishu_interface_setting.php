<?php
global $adb,$current_user;
global $current_user;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='FeishuInterfaceSettings';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');

$smarty = new lingdangCRM_Smarty;
$sql = "select para_content from ld_wx_config where `name`=?";
$result = $adb->pquery($sql,array('FeishuInterfaceSettings'));

if($adb->num_rows($result)){
    // 将查询的数据嵌入到模板中
    $para_content_json = $adb->query_result($result,0,'para_content');
    $para_content_list =  Zend_Json::decode ( $para_content_json);
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}

$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/feishu_interface_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>