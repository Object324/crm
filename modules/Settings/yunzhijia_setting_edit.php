<?php
//editor:gyq_144 reason:钉钉  2019/9/12 14:41
//editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 16:25
//editor:gyq_165 reason:钉钉消息提醒   2019/12/26 14:57
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $yunzhijiaStaticField = array('login_appid','login_secret','login_url','login_appname');
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
        //调用51接口，上传用户绑定   2020/1/2 9:53
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
        $login_url = checkAuthLink($_REQUEST['login_url']);
        if(!$login_url){
            ConvertTojsonString(-1,array(),getFixedLabel('WECHATAPPLETSETTINGSTITLE02').' '.getFixedLabel('FORMATERROR'));
        }
        $para_content['login_url'] = $login_url;
        $url = StaticConst::$server_api_header . 'yunzhijia/server.php?action=register_app&appid='.$para_content['login_appid'].'&web_url='.urlencode($para_content['login_url']);
        $result_curl = CurlGet($url);
        $result_arr = json_decode($result_curl['content'],true);
        if($result_arr['code']>0){
            //更新钉钉绑定的链接
            $para_content['login_url'] = $result_arr['result']['web_url'];
            $switch = 'uploaded';
        }else{
            $switch = 'no_uploaded';
        }
		$query = 'select 1 from ld_wx_config where name = ?';
		$result = $adb->pquery($query,array('yunzhijia_setting'));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$sql = "update ld_wx_config set para_content=?,switch=? where name=?";
			$adb->pquery($sql,array(json_encode($para_content),$switch,'yunzhijia_setting'));
		}else{
			$sql = "insert into ld_wx_config(name,description,para_content,switch) values (?,?,?,?)";
			$adb->pquery($sql,array('yunzhijia_setting','云之家应用秘钥',json_encode($para_content),$switch));
		}
        
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('yunzhijia_setting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
// 注销按钮执行逻辑
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='delete'){
    // 结合save逻辑进行删除数据库信息,其余信息逻辑不清楚
    $sql = "delete from ld_wx_config where name=?";
    $adb->pquery($sql,array('yunzhijia_setting'));
    ConvertTojsonString(1,array(),'success');
    exit();
}
$smarty = new lingdangCRM_Smarty;
$sql = "select switch,para_one,para_two,para_three,para_content,time from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('yunzhijia_setting'));
if($adb->num_rows($result) > 0){
    //editor:gyq_20191216 reason:0038917: （kfbcrm）钉钉接口设置中，H5微应用接口设置参数中没有设置参数保存时，AgentId参数显示为0
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
    if(empty($para_content_list['agentid']))
        $para_content_list['agentid'] = '';
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('yunzhijia_setting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/wechat_miniprogram/yunzhijia_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>