<?php
//editor:gyq_144 reason:钉钉  2019/9/11 17:49
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(dirname(__FILE__)));
require_once($root_dir."/include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
include_once($root_dir.'/includefile.php');
//editor:gyq_129 reason:选择源单字段增加保存到数据库功能  2019/7/12 11:25 ID1000529
include_once($root_dir.'/include/fields/cls_module_uitype.php');
include_once($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
include_once($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
// require_once($root_dir.'/include/Zend/Json.php');
//微信多版本
if(!empty($_REQUEST['get_version'])){
    cls_StaticCommonFun::websaas_multi_version();
}
//include($root_dir.'/crmapi/crmoperation.php');
include_once($root_dir.'/appCommon/appCommon.php');
include_once($root_dir.'/WeiXinApp/WeiXin_common/cls_Instance.php');
include_once $root_dir.'/WeiXinApp/modules/Users/weixin_user.php';

//异地登录验证
crm_load_class_file('LoginHistory','modules/Users');
if(isset($_REQUEST['loginsession']) && $_REQUEST['loginsession']!=""){
    $loginhistoryobj=new LoginHistory();
    $loginhistoryobj->yidong_checkLogin($_REQUEST,'ajax');
}
//editor:gyq_120 reason:企业微信增加外挂类,专有key->plug  2019/6/10 18:18
if($_REQUEST['plug']=='update_authkey'){
    $plug_action = $_REQUEST['plug'];
    require_once($root_dir.'/WeiXinApp/lib/Plug.php');
    $o_plug = new Plug();
    $o_plug->$plug_action();exit;
}
$_REQUEST['diony']='yes';
//	0032682: 微信授权时间和到期时间，都应该依据我们的服务器时间，而不是客户电脑时间
//客户001自动分配账套是否到期  gyq_54 20171214
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
$regop=RegOp::getInstance();
if($regop->isExistFile() != 1){
    ConvertTojsonString(-2, null, '未注册不允许登录，请立即注册');
}
//判断是否授权中英文
$enorzh=$regop->isEnorZh();
if($_REQUEST['module']=='Home'&&$_REQUEST['action']=='eventToApi'&&$_REQUEST['method']=='update_expired_time'){
    //userid=GaoYanQing&corpindex=902&module=Home&action=eventToApi&method=update_expired_time  kehu001
    // eidtor:gyq  date:20180123 过期预置账套延长到期日期
}else{
    //editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/18 15:45
    if($_REQUEST['login_mark']=='log_in'){
        if($regop->isExpired()=='yes'){
            ConvertTojsonString(-2, null, '您的软件已经过期，请联系供应商！');
        }
        $correctfile=$regop->isCorrectFile();//微信登录检测
        if($correctfile!="1")
        {
            ConvertTojsonString(-2, null, $correctfile);
        }
    }
}
$module=$_REQUEST['module'];
$weixin_user = new weixin_user();
global $weixin_user,$PlatformMC;
//editor:gyq_127 对应$PlatformMC['type'] = 'weixin';区分出微信端和PC端，true=>微信端，false=>PC端 2019/6/26 15:45
$weixin_user->environment_weixin = true;
//editor:gyq_144 reason:钉钉  2019/9/11 17:53
$weixin_user->environment = 'yunzhijia';
$PlatformMC['type'] = 'weixin';
$PlatformMC['userid'] = $_REQUEST['userid'];
global $adb,$currentModule,$display_mode_WX,$mobile_pagerecordcount;
$mobile_pagerecordcount = 10;
$currentModule = $module;
$wx_userid = $_REQUEST['userid'];
$display_mode_WX = array('CreateView'=>'create','DetailView'=>'detail','EditView'=>'edit');
//	Bug:0025966: （微信端）客户：当前用户已经达到批量操作上限，新增公海未分配客户后，明细界面分配给”王杰“，分配后在到明细界面分配给当前用户时，没有提示
//eidtor:gyq reason:原mode参数有值就不要覆盖了 date:20161118
if(empty( $_REQUEST['mode'])){
    $_REQUEST['mode'] = $display_mode_WX[$_REQUEST['action']];
}
//editor:gyq_128 reason:loginWX替换成index_login  2019/7/8 16:29 ID1000504
if($_REQUEST['action'] == 'index_login'){
    include(globalStatic::$root_directory.'WeiXinApp/modules/'.$module.'/index.php');
}else {
    //微信免登陆
    /*if(cls_StaticCommonFun::check_source()!='weixin'&&empty($_SESSION['authenticated_user_id'])){
        ConvertTojsonString(-1, null, '请在微信端登录');
    }*/
    
    if(empty($wx_userid)){
        //duan 20221009 未绑定用户登录时返回值
        $register_arr = getRegisterFixedlabel($enorzh);
        ConvertTojsonString(-3, $register_arr, '登录失败，CRM账号绑定云之家，才能登录');
    }

    $sql = 'SELECT id,user_name,last_name,status,crm_user_type FROM ld_users WHERE id = ? LIMIT 1';
    $result = $adb->pquery($sql, array($wx_userid));
    $rows = $adb->num_rows($result);
    if($rows > 0){
        $userid = $adb->query_result($result, 0, 'id');
        $username = $adb->query_result($result, 0 , 'user_name');
        $status = $adb->query_result($result, 0, 'status');
        $user_type = $adb->query_result($result, 0, 'crm_user_type');
        $MobileLanguageType = getMobileLanguageType($userid);
        //用户修改密码后未重新登录移动端时，点击消息也需要重新登录
        if($_REQUEST['fromlogintype'] == 'remindsmsg'){
            global $global_remindsstoragecode;
            //判断用户密码是否修改，若修改返回重新登陆
            $msg = $MobileLanguageType=='en'?'The CRM user password you have bound is incorrect. Please log in again!':'您绑定的CRM用户密码错误，请重新登陆！';
            if(LoginHistory::CheckpasswordChange_bymobiletype($userid,$weixin_user->getMobiletype())){
                ConvertTojsonString('logincontrol',array(),$msg);
            }
        }
        //0033027: 企业微信：企业微信端没有控制数据库用户超出许可用户后不允许登录
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
        if($regop->compareCount($usercount,$adb->num_rows($usernumresult))<=0 && strtolower($username) != 'admin'){
            $num_str = sprintf(getMobileFixedLabel('INSUFFICIENTUSERS'),$usercount,$usercount);
            ConvertTojsonString(-5, array('num'=>$usercount,'num_str'=>$num_str),'');
        }
    }
    global $dbconfig;
    require_once(globalStatic::$root_directory."config.inc.php");

    if ($rows == 1) {
        $loginpolicy = LoginHistory::loginPolicy($username,'mobile',$MobileLanguageType); //2023-7-10 xxy XUQIU1001427 【广东丰明】成员登录内外网登录控制，登录策略管理
        if(!$loginpolicy){
            ConvertTojsonString(-1, null, '登录失败，您在当前状态下被限制登录');
        }
        if(strtolower($status) == 'inactive'){
            if(judgeCorpInfo('kehu001'))
            {
                //32631: 企业微信：手机端登录的时候，允许数据库中为“离职”状态的用户登录
                //客户001预置帐套
                $sql='update ld_users set status=? where id=?';
                $adb->pquery($sql,array('Active',$userid));
                require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
                createUserPrivilegesfile($userid);

                cls_StaticCommonFun::indexView($userid, $module);
            }
            else
                ConvertTojsonString(-2, null, '您绑定的CRM用户已停用');
        }else{
            cls_StaticCommonFun::indexView($userid, $module);
        }
    } else {
        //duan 20221009 未绑定用户登录时返回值
        $register_arr = getRegisterFixedlabel($enorzh);
        ConvertTojsonString(-3, $register_arr, '登录失败，CRM账号绑定云之家，才能登录');
    }
}



?>