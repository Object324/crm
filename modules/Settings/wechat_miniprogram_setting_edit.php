<?php
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'WeiXinApp/minipro/const_mini.php';
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
$sql = "select id,switch,para_content,para_one,para_two,para_three,usertype from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('wechat_miniprogram_setting'));
$config_num = $adb->num_rows($result);
//获取灵当小程序 灵当公众号的appid secret
require_once globalStatic::$root_directory.'include/weixinMsg/MsgConfig.php';
$ldappidsecret = MsgConfig::$ldappidsecret;

if($config_num > 0){
    $config_id = $adb->query_result($result,0,'id');
    $switch = $adb->query_result($result,0,'switch');
    //zxm  20220728 系统设置增加小程序消息提醒设置
    $para_content = $adb->query_result($result,0,'para_content');
    $para_one = $adb->query_result($result,0,'para_one');//企业号
    $para_two = $adb->query_result($result,0,'para_two');//服务器地址
    $para_three = $adb->query_result($result,0,'para_three');//企业号主键ID
    $const_type = $adb->query_result($result,0,'usertype');//微信小程序号
    $para_content = (array)Zend_Json::decode($para_content);
    //zxm 20221013没有设置过小程序提醒参数，或者设置使用的小程序AppID是“wx608d4c0ec205411f”，则升级后默认为“使用灵当CRM小程序和微信公众号”
    if(empty($para_content)||$para_content['mini_appid']=="wx608d4c0ec205411f"||$para_content['msgsend_type']=='msgsend_typeld'){
        $para_content['msgsend_type'] = 'msgsend_typeld';
    }else{
        $para_content['msgsend_type'] = 'msgsend_typeoem';
    }
    if(empty($para_one)){
        if(empty($para_three))
            $para_three=0;
        //客户001账套，自动启用小程序设置，并且企业号和CRM外网访问地址默认配置好
        $auth_info = doCorpInfo('get_auth_info',array());
        $auth_info_arr = json_decode($auth_info,true);
        if($auth_info_arr['crm']['auth_type']=='market'){
            $corp_url = $auth_info_arr['crm']['corpurl'];
            $final_sign = substr($corp_url,-1,1);
            if($final_sign=='/'){
                $para_two = substr($corp_url,0,strlen($corp_url)-1);
                $strrpos = strrpos($para_two,'/');
                $para_one = substr($para_two,$strrpos+1);
            }else{
                $para_two = $corp_url;
                $strrpos = strrpos($para_two,'/');
                $para_one = substr($para_two,$strrpos+1);
            }
        }
    }
}
if($_REQUEST['mode']=='save'){
    //zxm  20220728 系统设置增加小程序消息提醒设置
    $msgsend_type = $_REQUEST['msgsend_type'];
    if($msgsend_type=='msgsend_typeoem'){
        //使用使用oem 小程序和微信公众号 发送消息
        $para_content_arr = [
            'msgsend_type'=>$_REQUEST['msgsend_type'],
            'mini_appid'=>$_REQUEST['mini_appid'],
            'mini_secret'=>$_REQUEST['mini_secret'],
            'offiaccount_appid'=>$_REQUEST['offiaccount_appid'],
            'offiaccount_secret'=>$_REQUEST['offiaccount_secret'],
        ];
        //将appid secret改成用户设置的值 zxm 20221013
        $ldappidsecret['mini_appid'] =$_REQUEST['mini_appid'];
        $ldappidsecret['mini_secret'] =$_REQUEST['mini_secret'];
        $ldappidsecret['offiaccount_appid'] =$_REQUEST['offiaccount_appid'];
        $ldappidsecret['offiaccount_secret'] =$_REQUEST['offiaccount_secret'];
    }else{
        //使用使用灵当CRM小程序和微信公众号 发送消息
        $para_content_arr = [
            'msgsend_type'=>$_REQUEST['msgsend_type'],
        ];
    }

    //BUG0054538 wyt 小程序企业号编辑界面的四个信息字段，填与不填应该都可以正常保存，去掉判断提示
    //    if(empty($para_content_arr['mini_appid'])){
    //        ConvertTojsonString(-1,array(),getFixedLabel('Appletremindersettings').getFixedLabel('CANOTEMPTYGTH'));
    //    }
    $para_content_str = Zend_Json::encode($para_content_arr);

    $mini_account = $_REQUEST['mini_account'];
    $mini_url = $_REQUEST['mini_url'];
    $mini_switch = $_REQUEST['mini_switch'];
    $mini_switch = 'open';// editor:gyq_20181109 隐藏了是否企业按钮，故写死
    $mini_check = 1;
    if(preg_match('/\W+/', $mini_account) || empty($mini_account)){
        $mini_check = -1;
        //$msg = '企业号只能录入字母、数字和下划线';
        $msg = getFixedLabel('WECHATAPPLETSETTINGSREMIND01');
    }
    //editor:gyq_20191112 reason:修改了CRM外网访问地址 的验证方法，原是放在本地验证，现在是在51CN上验证地址是否正确
    if($mini_check > 0) {
        $mini_url = urlencode($mini_url);
        $url = const_mini::$api_url.'?action_api=register_account&corpid='.$para_three.'&account='.$mini_account.'&web_url='.$mini_url;
        //zxm 将小程序消息提醒设置的四个参数传过去保存  //将appid secret改成用户设置的值 zxm 20221013
        $url .= '&mini_appid='.$ldappidsecret['mini_appid'].'&mini_secret='.$ldappidsecret['mini_secret'].'&offiaccount_appid='.$ldappidsecret['offiaccount_appid'].'&offiaccount_secret='.$ldappidsecret['offiaccount_secret'];
        $result_curl = CurlGet($url);
        $result_arr = json_decode($result_curl['content'],true);
        //edit: xll 2023/02/08 BUG0061414 增加服务器无法访问网络提示
        if($result_arr != ''){
            if($result_arr['code']>0){
                $para_three = $result_arr['result']['corpid'];
                $mini_url = rtrim(urldecode( $mini_url),'/');
                $sql = 'delete from ld_wx_config where name=\'wechat_miniprogram_setting\'';
                $adb->pquery($sql,array());
                //zxm  20220728 系统设置增加小程序消息提醒设置
                $sql = 'insert into ld_wx_config ( name, description, switch,para_content, para_one,para_two,para_three,usertype)
                  select \'wechat_miniprogram_setting\',\'小程序设置\',?,?,?,?,?,? from dual
                  where not exists(select 1 from ld_wx_config where name=\'wechat_miniprogram_setting\')';
                $adb->pquery($sql,array($mini_switch,$para_content_str,$mini_account,$mini_url,$para_three,$const_type));
                ConvertTojsonString(1,array(),'小程序设置更新成功');
            }else{
                //根据接口返回的label显示不同的提示内容
                if(isset($result_arr['result']['label'])){
                    $label = $result_arr['result']['label'];
                    if($label=='WECHATAPPLETSETTINGSREMIND02'){
                        $msg = getFixedLabel($label).'：http://www.51mis.com/crm';
                    }else{
                        //此企业号已被绑定，请输入其他企业号 WECHATAPPLETSETTINGSREMIND03
                        $msg = getFixedLabel($label);
                    }
                }else{
                    //兼容旧版本,此企业号已被绑定，请输入其他企业号
                    $msg = getFixedLabel('WECHATAPPLETSETTINGSREMIND03');
                }
                ConvertTojsonString(-1,array(),$msg);
            }
        }else{
            $msg = getFixedLabel('WECHATAPPLETSETTINGSREMIND10');
            ConvertTojsonString(-1,array(),$msg);
        }
    }else{
        ConvertTojsonString(-1,array(),$msg);
    }
}
if($_REQUEST['mode']=='logout'){ //注销 BUG0074202
    if(isset($config_id)){
        $sql = 'update ld_wx_config set para_one =NULL, para_two=NULL, para_three=NULL where id=?';
        $adb->pquery($sql,array($config_id));
        ConvertTojsonString(1,'',getFixedLabel("LOGOUTS").getFixedLabel("SUCCESS"));
    }else{
        ConvertTojsonString(-1,'',getFixedLabel("LOGOUTS").getFixedLabel("CALLACTIONRESULTFAILED"));
    }
}
$smarty = new lingdangCRM_Smarty;
$smarty->assign('SWITCH',$switch);
$smarty->assign('CONTENT',$para_content);
$smarty->assign('CONTENTONE',$para_one);
$smarty->assign('CONTENTTWO',$para_two);
//editor:gyq_154 reason:小程序扫码自动绑定企业号  2019/10/19 18:49
$smarty->assign('CONTENTCONSTTYPE',$const_type);
$smarty->assign('LANGUAGETYPE',$languageType);
//editor:gyq_20191216 reason:0038829: pc端>系统设置>企业号设置：在账套第一次设置小程序的情况下不要弹出“编辑后会影响当前正在登录和使用的小程序，如果有异常请退出后重新登录！”提示
$smarty->assign('CORPID',$para_three);
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("WECHATAPPLETSETTINGS");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/wechat_miniprogram_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

?>