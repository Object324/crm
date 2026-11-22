<?php
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/14 16:42 ID1000568
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='checkin_setting';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
//editor:gyq_155 reason:钉钉考勤同步  2019/10/28 17:09 ID1000624
$sql = "select para_one,para_two,para_three,switch,usertype from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('checkin_monthly'));
$interfaceTypeLabel = array('dingtalk'=>'DINGTALK',''=>'LBL_ENTERPRISEWECHAT','weixin'=>'LBL_ENTERPRISEWECHAT');
if($adb->num_rows($result)){
    $corpid = $adb->query_result($result,0,'para_two');
    $secret = $adb->query_result($result,0,'para_three');
    $switch = $adb->query_result($result,0,'switch');
    //editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/28 11:02
    $secret_approve = $adb->query_result($result,0,'para_one');
    $interfaceType = $adb->query_result($result,0,'usertype');
    $smarty->assign('SWITCH',$switch);
    $smarty->assign('CORPID',$corpid);
    $smarty->assign('SECTRET',$secret);
    $smarty->assign('SECTRET_APPROVE',$secret_approve);
    $smarty->assign('INTERFACETYPELABEL',getFixedLabel($interfaceTypeLabel[$interfaceType]));
    $smarty->assign('INTERFACETYPE',$interfaceType);
}
$smarty->assign('REPORTTABID',getTabid('OftenUseReport'));

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//企业微信客户联系设置帮助
$labels = array('CheckinSetting');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/checkin_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>