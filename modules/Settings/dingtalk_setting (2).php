<?php
//editor:gyq_144 reason:钉钉  2019/9/12 13:55
//editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 17:08
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,time,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('dingtalk_setting'));
if($adb->num_rows($result)){
    $corpid = $adb->query_result($result,0,'para_one');
    $key = $adb->query_result($result,0,'para_two');
    $secret = $adb->query_result($result,0,'para_three');
    $AgentId = $adb->query_result($result,0,'time');
    $para_content_json = $adb->query_result($result,0,'para_content');
    $para_content_list =  Zend_Json::decode ( $para_content_json);
    foreach ($para_content_list as $paraName=>$paraValue){
        if($paraName=='login_appid'){
            $login_appid = $paraValue;
            $smarty->assign('LOGINAPPID',$paraValue);
        }elseif ($paraName=='login_secret'){
            $smarty->assign('LOGINSECRET',$paraValue);
        }elseif ($paraName=='login_url'){
            $login_url = $paraValue;
            $smarty->assign('LOGINURL',$paraValue);
        }
    }
    $redirectUrl = urlencode( $login_url.'/WeiXinApp/dingtalk/event.php?action=crm_login');
    $url = 'https://oapi.dingtalk.com/connect/oauth2/sns_authorize?appid='.$login_appid.'&response_type=code&scope=snsapi_auth&state=1&redirect_uri='.$redirectUrl;
    $smarty->assign('CORPID',$corpid);
    $smarty->assign('KEY',$key);
    $smarty->assign('SECTRET',$secret);
    $smarty->assign('AGENTID',$AgentId);
    $smarty->assign('AUTHLOGINURL',$url);
}
require_once('SetmenuControl.php');
$smarty->display('Settings/wechat_miniprogram/dingtalk_setting.tpl');

?>