<?php

global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';

if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){

    //接收GET参数
    $zhiyuanStaticField = array('crm_url','zhiyuan_url','registerCode','userName','password');

    $para_content = array();
    foreach ($zhiyuanStaticField as $key=>$value){
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


        //检测链接是否正确
        $login_url = checkAuthLink($_REQUEST['crm_url']);
        if(!$login_url){
            ConvertTojsonString(-1,array(),getFixedLabel('WECHATAPPLETSETTINGSTITLE02').' '.getFixedLabel('FORMATERROR'));
        }
        $para_content['crm_url'] = $login_url;

        $url = StaticConst::$server_api_header . 'zhiyuan/server.php?action=register_app&userName='.$para_content['userName'].'&crm_url='.urlencode($para_content['crm_url']);
        $result_curl = CurlGet($url);
        $result_arr = json_decode($result_curl['content'],true);

        if($result_arr['code']>0){
            //更新钉钉绑定的链接
            $para_content['crm_url'] = $result_arr['result']['crm_url'];
            $switch = 'uploaded';
        }else{
            $switch = 'no_uploaded';
        }

        //查询并修改数据表
        $query = 'select 1 from ld_wx_config where name = ?';
        $result = $adb->pquery($query,array('zhiyuan_setting'));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $sql = "update ld_wx_config set para_content=?,switch=? where name=?";
            $adb->pquery($sql,array(json_encode($para_content),$switch,'zhiyuan_setting'));
        }else{
            $sql = "insert into ld_wx_config(name,description,para_content,switch) values (?,?,?,?)";
            $adb->pquery($sql,array('zhiyuan_setting','致远设置',json_encode($para_content),$switch));
        }

        //返回前端成功响应
        ConvertTojsonString(1,array(),'success');
    }else{

        //返回前端失败响应
        ConvertTojsonString(-1,array(),getFixedLabel('zhiyuan_setting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}

$smarty = new lingdangCRM_Smarty;
$sql = "select para_one,para_two,para_three,para_content,time from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('zhiyuan_setting'));

if($adb->num_rows($result) > 0){

    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('zhiyuan_setting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/wechat_miniprogram/zhiyuan_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>