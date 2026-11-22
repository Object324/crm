<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='wechat_miniprogram_setting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require(globalStatic::$root_directory.'WeiXinApp/minipro/EventMiniModel.php');
//require(globalStatic::$root_directory.'appCommon/appCommon.php');
$model = new EventMiniModel();
$smarty = new lingdangCRM_Smarty;
$sql = "select switch,para_content,para_one,para_two,para_three,usertype from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('wechat_miniprogram_setting'));
if($adb->num_rows($result)){
    $switch = $adb->query_result($result,0,'switch');
    //zxm  20220728 系统设置增加小程序消息提醒设置
    $para_content = $adb->query_result($result,0,'para_content');
    $content_one = $adb->query_result($result,0,'para_one');
    $content_two = $adb->query_result($result,0,'para_two');
    //editor:gyq_154 reason:小程序扫码自动绑定企业号  2019/10/19 17:53
    $coid = $adb->query_result($result,0,'para_three');
    $const_type = $adb->query_result($result,0,'usertype');
    //editor:gyq_20191025 reason:未配置参数，应隐藏动态内容
    //0038349: 系统设置>小程序设置：当【企业号和CRM外网访问地址】没有填写的情况下， CRM微信小程序下载这一行隐藏不显示。
    $img_url = '';
    $para_content = (array)Zend_Json::decode($para_content);
    //zxm 20221013没有设置过小程序提醒参数，或者设置使用的小程序AppID是“wx608d4c0ec205411f”，则升级后默认为“使用灵当CRM小程序和微信公众号”
    if(empty($para_content)||$para_content['mini_appid']=="wx608d4c0ec205411f"||$para_content['msgsend_type']=='msgsend_typeld'){
        $para_content['msgsend_type'] = 'msgsend_typeld';
    }else{
        $para_content['msgsend_type'] = 'msgsend_typeoem';
    }
    $para_content['msgsend_typename'] = getFixedLabel($para_content['msgsend_type']);
    if(!empty($coid))
        $img_url = $model->mini_get_qrcode($coid,$const_type);
    $smarty->assign('SWITCH',$switch);
    //zxm  20220728 系统设置增加小程序消息提醒设置
    $smarty->assign('CONTENT',$para_content);
    $smarty->assign('CONTENTONE',$content_one);
    $smarty->assign('CONTENTTWO',$content_two);
    $smarty->assign('CONTENTCONSTTYPE',$const_type);
    $smarty->assign('IMGURL',$img_url);
}
$smarty->assign('LANGUAGETYPE',$languageType);
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//企业号设置帮助
$labels = array('EnterpriseNumber');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/wechat_miniprogram_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>