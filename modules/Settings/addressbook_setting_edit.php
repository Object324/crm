<?php
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
$token_url = '';
$wx_authinfo=doCorpInfo("get_auth_info",array());
if($wx_authinfo!=''){
	$wx_auth_arr=  json_decode($wx_authinfo,true);
	$token_url = $wx_auth_arr['crm']['corpurl'];
	if(!empty($token_url)){
		$token_url .= 'wxaddressbook/eventNew.php';//通讯录2.0
	}
}
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $StaticField = array('addressbook_corpid','addressbook_secret','addressbook_token','addressbook_encodingaeskey');
    $para_content = array();
    foreach ($StaticField as $key=>$value){
        //任意一个参数没有配置，不保存
        /*if(empty($_REQUEST[$value])){
            $para_content = array();
            break;
        }else{
            $para_content[$value] = trim($_REQUEST[$value]);
        }*/
        $para_content[$value] = trim($_REQUEST[$value]);
    }
	$_REQUEST['diony']='diony';
    if(!empty($para_content)){
		$query = 'select 1 from ld_wx_config where name = ?';
		$result = $adb->pquery($query,array('addressbook_setting'));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$sql = "update ld_wx_config set para_content=?,para_one = ?,para_two = ?,para_three=? where `name`=?";
			$adb->pquery($sql,array($para_content['addressbook_secret'],$token_url,$para_content['addressbook_token'],$para_content['addressbook_encodingaeskey'],'addressbook_setting'));
  	         $query = 'select 1 from ld_wx_config where name = ?';
           	$result = $adb->pquery($query,array('addressbook_setting_corpid'));
            if($adb->num_rows($result)>=1)
            {
                $sql = "update ld_wx_config set para_content=? where `name`=?";
			     $adb->pquery($sql,array($para_content['addressbook_corpid'],'addressbook_setting_corpid'));
            }
            else{
                 $sql = "insert into ld_wx_config(`name`,description,para_content,switch) values (?,?,?,?)";
			     $adb->pquery($sql,array('addressbook_setting_corpid','企业微信通讯录同步设置',$para_content['addressbook_corpid'],'close'));
            }
		       
        }else{
			$sql = "insert into ld_wx_config(`name`,description,para_content,switch,para_one,para_two,para_three) values (?,?,?,?,?,?,?)";
			$adb->pquery($sql,array('addressbook_setting','企业微信通讯录同步设置',$para_content['addressbook_secret'],'close',$token_url,$para_content['addressbook_token'],$para_content['addressbook_encodingaeskey']));
            
            $sql = "insert into ld_wx_config(`name`,description,para_content,switch) values (?,?,?,?)";
			$adb->pquery($sql,array('addressbook_setting_corpid','企业微信通讯录同步设置',$para_content['addressbook_secret'],'close'));
		
        }

        //原来是通讯录回调事件配置成功更改状态，由于有些企业不能使用回调事件，故改为设置保存成功后更改状态
        $adb->pquery("update ld_wx_config set switch=? where `name` = ? and switch='close'",array('open','addressbook_setting'));
        
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('addressbook_setting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('addressbook_setting'));
if($adb->num_rows($result) > 0){
    $para_content = $adb->query_result($result,0,'para_content');
	$para_one = $adb->query_result($result,0,'para_one');
	$para_two = $adb->query_result($result,0,'para_two');
	$para_three = $adb->query_result($result,0,'para_three');
	$smarty->assign('SECRET',$para_content);
    $smarty->assign('TOKENURL',$para_one);
	$smarty->assign('TOKEN',$para_two);
	$smarty->assign('ENCODINGAESKEY',$para_three);
}
$sql = "select para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('addressbook_setting_corpid'));
if($adb->num_rows($result) > 0){
    $para_content = $adb->query_result($result,0,'para_content');
    $smarty->assign('corpid',$para_content);
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('addressbook_setting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/addressbook_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>