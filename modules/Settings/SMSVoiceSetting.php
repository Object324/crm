<?php

global $adb,$theme,$mod_strings,$app_strings;
$smarty = new lingdangCRM_Smarty;
$mode='look';
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='SMSSetting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
if(isset($_REQUEST['mode'])&&$_REQUEST['mode']!=''){
    $mode=$_REQUEST['mode'];
}
if($mode=='logout')
{
    //腾讯云语音消息设置 -注销 清空数据
    $query="update ld_wx_config set  para_content='',para_one='',para_two='',para_three='' where name ='tencentcloud_sms_voice' ";
    $result=$adb->query($query);
}

if(isset($_REQUEST['error'])&&$_REQUEST['error']!=''){
    $error_str=strip_tags(base64_decode($_REQUEST['error']));
    $error_str=getFixedLabel($error_str);
}
$smarty->assign('ERROR_MSG',$error_str);

$SMSVoicearray = tencentcloud_sms_voice();
$templates = $SMSVoicearray['para_content'];
$templates = Zend_Json::decode($templates);
$smarty->assign('secretId',$SMSVoicearray['para_one']);
$smarty->assign('secretKey',$SMSVoicearray['para_two']);
$smarty->assign('sdkAppId',$SMSVoicearray['para_three']);
$smarty->assign('templates',$templates);
$smarty->assign('THENME',$theme);
$smarty->assign('MODE',$mode);

$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('LBL_SMS_VOICE_SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('Settings/SMSVoiceSetting.tpl');
ConvertTojsonString(1,$arr,"success");
?>