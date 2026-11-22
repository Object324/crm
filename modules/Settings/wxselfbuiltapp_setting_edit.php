<?php
global $adb,$current_user,$languageType;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $StaticField = array('corp_link','corpid','secret','agentid');
    $para_content = array();
    foreach ($StaticField as $key=>$value){
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
        //调用51接口，上传用户绑定，自动提醒需要用到这些参数
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
        $corp_link = checkAuthLink($_REQUEST['corp_link']);
        if(!$corp_link){
            ConvertTojsonString(-1,array(),getFixedLabel('WECHATAPPLETSETTINGSTITLE02').' '.getFixedLabel('FORMATERROR'));
        }
        $corp_link = rtrim($corp_link,'/').'/';
        $para_content['corp_link'] = $corp_link;

        $url = StaticConst::$server_api_header . 'wxselfbuiltapp/server.php?action=register_corp&corpid='.$para_content['corpid'].'&secret='.$para_content['secret'].'&agentid='.$para_content['agentid'].'&web_url='.urlencode($corp_link);
        $result_curl = CurlGet($url);
        $result_arr = json_decode($result_curl['content'],true);
        if($result_arr['code']>0){
            //更新绑定的链接
            $para_content['corp_link'] = $result_arr['result']['web_url'];
            $switch = 'uploaded';

            //以自建应用为主
            if (file_exists(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt')) {
                @rename(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt',globalStatic::$root_directory . 'dataCache/weixin/auth_info_abandon.txt');
            }
        }else{
            $switch = 'no_uploaded';
        }
        $sql = "update ld_wx_config set para_content=?,switch=? where name=?";
        $adb->pquery($sql,array(json_encode($para_content),$switch,'wxselfbuiltapp_setting'));
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('wxselfbuiltapp_setting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
elseif(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='uninstall'){
    require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
    $sql = "select para_content from ld_wx_config where name=? and ifnull(para_content,'')<> '' ";
    $result = $adb->pquery($sql,array('wxselfbuiltapp_setting'));
    $switch = 'no_uploaded';
    if($adb->num_rows($result) > 0){
        $para_content =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));

        $url = StaticConst::$server_api_header . 'wxselfbuiltapp/server.php?action=uninstall_corp&corpid='.$para_content['corpid'].'&agentid='.$para_content['agentid'];
        $result_curl = CurlGet($url);
        $result_arr = json_decode($result_curl['content'],true);
        if($result_arr['code']>0){
            //卸载成功
            if (file_exists(globalStatic::$root_directory . 'dataCache/weixin/auth_info_abandon.txt')) {
                if (!file_exists(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt')) {
                    @rename(globalStatic::$root_directory . 'dataCache/weixin/auth_info_abandon.txt',globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt');
                }elseif(empty(file(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES))){
                    //基本是会走这里
                    @unlink(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt');
                    @rename(globalStatic::$root_directory . 'dataCache/weixin/auth_info_abandon.txt',globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt');
                }
            }

        }else{
            $switch = 'uploaded';
        }
    }

    $sql = "update ld_wx_config set para_content='',switch=? where name=?";
    $adb->pquery($sql,array($switch,'wxselfbuiltapp_setting'));
    ConvertTojsonString(1,array(),'success');
}
$smarty = new lingdangCRM_Smarty;
$sql = "select switch,para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('wxselfbuiltapp_setting'));
if($adb->num_rows($result) > 0){
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('wxselfbuiltapp_setting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$smarty->fetch("Settings/wxselfbuiltapp_setting_edit.tpl");
ConvertTojsonString(1,$arr,"success");
?>