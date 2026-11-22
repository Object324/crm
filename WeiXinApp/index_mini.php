<?php
/* creator:gyq_73 date:20180710 */
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(__FILE__));
//小程序参数获取
$json_request_arr = json_decode(file_get_contents("php://input"),true);
if(!empty($json_request_arr)){
    $_REQUEST = $json_request_arr;
}
require_once($root_dir."/include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
$_REQUEST['diony']='yes';
//小程序接口事件特殊类
if(isset($_REQUEST['ajax_file'])){
    if($_REQUEST['ajax_file']=='event_mini'){
        include $root_dir.'/WeiXinApp/minipro/event_mini.php';
        exit;
    }
}
include($root_dir.'/includefile.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');

require_once($root_dir.'/appCommon/appCommon.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/cls_Instance.php');
require_once $root_dir.'/WeiXinApp/modules/Users/weixin_user.php';
$wx_userid = $_REQUEST['userid'];
//0032682: 微信授权时间和到期时间，都应该依据我们的服务器时间，而不是客户电脑时间
//客户001自动分配账套是否到期  gyq_54 20171214
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
$regop=RegOp::getInstance();
//异地登录验证
crm_load_class_file('LoginHistory','modules/Users');
if(isset($_REQUEST['loginsession']) && $_REQUEST['loginsession']!=""){
    $loginhistoryobj=new LoginHistory();
    $loginhistoryobj->yidong_checkLogin($_REQUEST,'ajax');
}
if($_REQUEST['module']=='Home'&&$_REQUEST['action']=='eventToApi'&&$_REQUEST['method']=='update_expired_time'){
    //过期预置账套延长到期日期，跳过下方判断
}else{
    $correctfile=$regop->isCorrectFile();//微信登录检测
    if($correctfile!="1")
    {   //editor:gyq_20191024 reason:过期的账套，跳转登陆界面
        ConvertTojsonString(-3,  array(0=>array('action_api'=>'login','bind_api_userid'=>$wx_userid)), $correctfile);
    }
}
$module=$_REQUEST['module'];
$weixin_user = new weixin_user();
global $adb,$currentModule,$weixin_user,$display_mode_WX,$mobile_pagerecordcount,$PlatformMC;
//editor:gyq_127 对应$PlatformMC['type'] = 'weixin';区分出微信端和PC端，true=>微信端，false=>PC端 2019/6/26 15:45
$weixin_user->environment_weixin = true;
if($_REQUEST['get_home_environment']=='wxwork'){
    //editor:gyq_128 reason:允许用户替换微信绑定  2019/7/9 14:27 ID1000504
    $weixin_user->environment = 'wxwork';//企业微信小程序
}else{
    $weixin_user->environment = 'weixin';
}
//总共有四种运行环境：PC、企业微信、企业微信小程序、（个人）微信小程序，服务、订单小程序暂不包含
$PlatformMC['userid'] = $_REQUEST['userid'];
$PlatformMC['type'] = 'weixin';//区分微信和PC
$PlatformMC['type_mini'] = true;//区分企业微信和小程序
$mobile_pagerecordcount = 10;
$currentModule = $module;

$display_mode_WX = array('CreateView'=>'create','DetailView'=>'detail','EditView'=>'edit');
//	Bug:0025966: （微信端）客户：当前用户已经达到批量操作上限，新增公海未分配客户后，明细界面分配给”王杰“，分配后在到明细界面分配给当前用户时，没有提示
//eidtor:gyq reason:原mode参数有值就不要覆盖了 date:20161118
if(empty( $_REQUEST['mode'])){
    $_REQUEST['mode'] = $display_mode_WX[$_REQUEST['action']];
}
//登录日志
$_REQUEST['login_mark']='log_in';
//企业微信小程序绑定界面保存操作特殊处理
//reason:【特殊处理】企业微信小程序登陆前端保留loginWX，而不是企业微信改为index_login  2019/7/8 16:29 ID1000504
if($_REQUEST['action'] == 'loginWX') {
    $_REQUEST['action'] = 'index_login';
    $_REQUEST['second_action'] = 'check_and_bind';
}
if($_REQUEST['action'] == 'index_login'){
    include(globalStatic::$root_directory.'WeiXinApp/modules/'.$module.'/index.php');
} else {
    //用户ID或wx_userid必须有值
    if(empty($wx_userid)){
        ConvertTojsonString(-1, null, 'ERROR:WX_USERID EMPTY');
    }
    //editor:gyq_20190321 从企业微信登陆小程序
    if($weixin_user->environment=='wxwork'){
        $sql = 'SELECT id,user_name,last_name,status,wx_userid,crm_user_type as bind_apid FROM ld_users WHERE wx_userid = ?  LIMIT 1';
    }else{
        $sql = 'SELECT id,user_name,last_name,status,wx_openid,crm_user_type as bind_apid FROM ld_users WHERE id = ?  LIMIT 1';
    }
    $result = $adb->pquery($sql, array($wx_userid));
    $rows = $adb->num_rows($result);
    //editor:gyq_114 reason:小程序绑定优化  2019/5/23 20:38
    if($rows > 0){
        $userid = $adb->query_result($result, 0, 'id');
        $username = $adb->query_result($result, 0 , 'user_name');
        $status = $adb->query_result($result, 0, 'status');
        $user_type = $adb->query_result($result, 0, 'crm_user_type');
        //获取移动端语言类型
        $MobileLanguageType = getMobileLanguageType($userid);
        //准备为未激活用户提供绑定用的openid/wx_userid
        $bind_apid = $adb->query_result($result, 0, 'bind_apid');
        //企业微信控制数据库用户超出许可用户后不允许登录
        if($user_type == 'prm'){
            $usernumsql = "select user_name from ld_users where status='active'  and crm_user_type = 'prm'";//获取启动的用户数
            $usernumresult=$adb->pquery($usernumsql,array());
            $usercount = $regop->getPrmUserCount();
        }
        else{
            $usernumsql = "select user_name from ld_users where status='active'  and crm_user_type = 'crm'";//获取启动的用户数
            $usernumresult=$adb->pquery($usernumsql,array());
            $usercount = $regop->GetUserCount();
        }
        //editor:gyq_20190531 reason:过期提示增加网址
        //0037202: 微信小程序：当小程序所绑定的账套过期后，登录小程序时弹出的提示在添加一个绑定账套的URL。（邱，然后退出，返回结果不要返回-1，返回-5，当前-5代表是超出用户数）
        $server_uri_o = $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"] . $_SERVER["REQUEST_URI"];
        $server_uri_a = explode('/WeiXinApp',$server_uri_o);
        if($regop->isExpired()=='yes'){
            ConvertTojsonString(-2, array(0=>array('action_api'=>'login','bind_api_userid'=>$bind_apid)), '您的软件已经过期，请联系供应商！['.$server_uri_a[0].']');
        }
        if($regop->compareCount($usercount,$adb->num_rows($usernumresult))<=0 && strtolower($username) != 'admin'){
            ConvertTojsonString(-5, array('num'=>$usercount),'');
        }
        //判断用户状态
        $loginpolicy = LoginHistory::loginPolicy($username,'mobile',$MobileLanguageType); //2023-7-10 xxy XUQIU1001427 【广东丰明】成员登录内外网登录控制，登录策略管理
        if(!$loginpolicy){
            ConvertTojsonString(-1, null, '登录失败，您在当前状态下被限制登录');
        }
        if(strtolower($status) == 'inactive'){
            if(judgeCorpInfo('kehu001')){
                //客户001预置帐套 32631: 企业微信：手机端登录的时候，允许数据库中为“离职”状态的用户登录
                $sql='update ld_users set status=? where id=?';
                $adb->pquery($sql,array('Active',$userid));
                require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
                createUserPrivilegesfile($userid);
                cls_StaticCommonFun::indexView($userid, $module);
            }
            else
                ConvertTojsonString(-2, array(0=>array('action_api'=>'login','bind_api_userid'=>$bind_apid)), '您绑定的CRM用户已离职或停用[IND]');
        }else{
            //正常获取数据
            cls_StaticCommonFun::indexView($userid, $module);
        }
    }elseif($weixin_user->environment == 'wxwork'){
        ConvertTojsonString(-3, array(0=>array('action_api'=>'login','bind_api_userid'=>$wx_userid)), '登录失败，CRM账号绑定企业微信后，才能登录');
    }else{
        ConvertTojsonString(-1, array(), '您绑定的用户数据异常，请重启小程序'.$wx_userid);
    }
}
//reason:弃用['environment']  2019/7/9 13:56
//$PlatformMC['environment'] = 'wxwork';//区分企业微信小程序wxwork和微信小程序weixin，运行环境默认企业微信wxwork


?>