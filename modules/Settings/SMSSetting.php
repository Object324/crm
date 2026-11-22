<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * edit:kevin
 * date:2013-06-24
 * reason:通讯账户
 */ 

global $adb,$theme,$mod_strings,$app_strings;
$smarty=new lingdangCRM_Smarty;
$_REQUEST['diony']='yes';
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
    //删除当前关联表数据
    $query="delete ld_smsrelated from ld_smsrelated inner join ld_smstemplates on ld_smsrelated.template_id = ld_smstemplates.templateid 
where ld_smstemplates.platform = (select platform from ld_communicationaccount where status='yes' limit 1)";
    $result=$adb->query($query);
    //删除短信模板数据
    $query="delete from ld_smstemplates where platform = (select platform from ld_communicationaccount where status='yes' limit 1)";
    $result=$adb->query($query);
    //清除当前配置厂商信息
    $query="update ld_communicationaccount set  account_name='',account_pwd='',autograph='',balance='',productid='',pwd='',status='no' where status='yes' ";
    $result=$adb->query($query);

}
elseif ($mode=='getsmsconf') {
    $platform = $_REQUEST['platform']??'';
    $SMSConfigInfo = [];
    if (!empty($platform)) {
        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();

        $SMSConfigInfo = $cls_Send_MassSms->GetSMSConfigInfo($platform);
    }
    ConvertTojsonString(1,$SMSConfigInfo,"success");
}

if(isset($_REQUEST['error'])&&$_REQUEST['error']!=''){
    $error_str=strip_tags(base64_decode($_REQUEST['error']));
    $error_str=getFixedLabel($error_str);
}
$smarty->assign('ERROR_MSG',$error_str);
//短信账户
$SMSarray = GetSMSAutograph();
$smsname= $SMSarray['account_name'];
if(!empty($smsname)){
    $username=$smsname;
    $password= $SMSarray['account_pwd'];
    $smarty->assign('PLATFORM',$SMSarray['platform']);
    $smarty->assign('USERNAME',$username);
    $smarty->assign('PASSWORD',$password);
	$smarty->assign('AUTOGRAPH',$SMSarray['autograph']);
	$smarty->assign('SERVTEL',$SMSarray['service_tel']);
}
$smarty->assign('THENME',$theme);
$smarty->assign('MODE',$mode);
//获取帮助手册入口链接，为空则不显示
$helpHtmlArr = array();
//云之家接口设置帮助
$labels = array('SMSSetting');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
// require_once('SetmenuControl.php');

$arr['title'] = getFixedLabel('LBL_SMS_SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('Settings/SMSSetting.tpl');
ConvertTojsonString(1,$arr,"success");
?>