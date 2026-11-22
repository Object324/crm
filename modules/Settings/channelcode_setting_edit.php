<?php
//editor:gyq_144 reason:钉钉  2019/9/12 14:41
//editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 16:25
//editor:gyq_165 reason:钉钉消息提醒   2019/12/26 14:57
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
$token_url = '';
$wx_authinfo=doCorpInfo("get_auth_info",array());       
if($wx_authinfo!=''){
	$wx_auth_arr=  json_decode($wx_authinfo,true);
	$token_url = $wx_auth_arr['crm']['corpurl'];
	if(!empty($token_url)){
		$token_url .= 'crmapi/weixin/event.php';
	}
}
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $yunzhijiaStaticField = array('channelcode_secret','channelcode_token','channelcode_encodingaeskey');
    $para_content = array();
    foreach ($yunzhijiaStaticField as $key=>$value){
        //任意一个参数没有配置，不保存
        if(empty($_REQUEST[$value])){
            $para_content = array();
            break;
        }else{
            $para_content[$value] = trim($_REQUEST[$value]);
        }
    }
	$_REQUEST['diony']='diony';
    if(!empty($para_content)){
		$query = 'select 1 from ld_wx_config where name = ?';
		$result = $adb->pquery($query,array('channelcode_setting'));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$sql = "update ld_wx_config set para_content=?,para_one = ?,para_two = ?,para_three=? where name=?";
			$adb->pquery($sql,array($para_content['channelcode_secret'],$token_url,$para_content['channelcode_token'],$para_content['channelcode_encodingaeskey'],'channelcode_setting'));
		}else{
			$sql = "insert into ld_wx_config(name,description,para_content,para_one,para_two,para_three) values (?,?,?,?,?,?)";
			$adb->pquery($sql,array('channelcode_setting','企业微信渠道码设置',$para_content['channelcode_secret'],$token_url,$para_content['channelcode_token'],$para_content['channelcode_encodingaeskey']));
		}
        
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('channelcode_settings').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,para_content,time from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('channelcode_setting'));
if($adb->num_rows($result) > 0){
    $para_content = $adb->query_result($result,0,'para_content');
	$para_one = $adb->query_result($result,0,'para_one');
	$para_two = $adb->query_result($result,0,'para_two');
	$para_three = $adb->query_result($result,0,'para_three');
	$smarty->assign('SECRET',$para_content);
	
	$smarty->assign('TOKEN',$para_two);
	$smarty->assign('ENCODINGAESKEY',$para_three);
}
$smarty->assign('TOKENURL',$token_url);
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('channelcode_settings');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/wechat_miniprogram/channelcode_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>