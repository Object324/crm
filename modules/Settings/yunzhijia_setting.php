<?php
//editor:gyq_144 reason:钉钉  2019/9/12 13:55    78_SBLO7mB8PFHP1g3WvGyKOMwZYccRyR7LBaIK3sK8UgXIM2PCMFpmqDbOWxlGz
//editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 17:08
//editor:gyq_165 reason:钉钉消息提醒   2019/12/26 15:00
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='dingtalk_setting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,time,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('yunzhijia_setting'));
if($adb->num_rows($result)){
    //editor:gyq_165 reason:检测旧格式数据，更新数据结构   2019/12/26 14:53
    $para_content_json = $adb->query_result($result,0,'para_content');
    $para_content_list =  Zend_Json::decode ( $para_content_json);
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//云之家接口设置帮助
$labels = array('YunzhijiaSetting');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
// $smarty->display('Settings/wechat_miniprogram/dingtalk_setting.tpl');
$arr['content']= $smarty->fetch('Settings/wechat_miniprogram/yunzhijia_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>