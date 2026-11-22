<?php
/**
 * 云之家自建应用鉴权、跳转、单点登录
 */
header("Access-Control-Allow-Origin:*");
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir = dirname(dirname(dirname(__FILE__)));//获取根目录
include($root_dir.'/includefile.php');
// require_once($root_dir.'/include/Zend/Json.php');

$function = $_REQUEST["function"];
$applicationType = $_REQUEST['applicationType'];
$applicationType = empty($applicationType)?'common':$applicationType;//应用类型 market平台应用 common自建应用
$obj = new getAuth($root_dir,$applicationType);
$obj->$function();

class getAuth
{
    //云之家 的appid 与app secret
    public static $default_appid;
    public static $default_secret;
    public $adb;
    public $root_dir;
    public $applicationType;
    //zxm 20231019 中孚  云之家接口请求内网地址
    public $yunzhijiadomain = "https://yunzhijia.com/";//https://yunzhijia.com/ 中孚是https://im.zhongfu.net/
    public function __construct($root_dir,$applicationType)
    {
        global $adb;
        $this->adb = $adb;
        $this->root_dir = $root_dir;
        $this->applicationType = $applicationType;
        $tradeinfo = getVersionTradeInfo();
        if($tradeinfo['trade']=='zhongfu'){
            $this->yunzhijiadomain = 'https://im.zhongfu.net/';
        }
        if($applicationType=='market'){
            //云之家平台级应用自动登录
            self::$default_appid = '11016';
            self::$default_secret = 'LingdangfHiqnXLtyPtKDsG1RZGZPuyoung';
        }else{
            // 初始化参数
            $set_sql = "select * from ld_wx_config where name='yunzhijia_setting'";
            $set_res = $adb->pquery($set_sql);
            $nums = $adb->num_rows($set_res);
            if($nums>=1){
                $para_content = $adb->query_result($set_res, 0, "para_content");
                $para_content = Zend_Json::decode($para_content);
                if(empty($para_content)){
                    exit("请到CRM配置appid,appsecret等相关信息");
                }
                self::$default_appid = $para_content['login_appid'];
                self::$default_secret = $para_content['login_secret'];
            }else{
                exit("请到CRM配置appid,appsecret等相关信息");
            }
        }

    }
    public function getUserInfo(){
        $auth = $this->getOpenId();
        $crm_userinfo = $this->ConfirmUser($auth['userid'],$auth['openid']);
        
        $corpurl = $_REQUEST['corpurl'];
        if(empty($crm_userinfo)){
            $client_id = $_REQUEST['client_id'];
            $expire_time = $_REQUEST['expire_time'];
            $msgShowStyle = $_REQUEST['msgShowStyle'];
            $ticket = $_REQUEST['ticket'];
            //未绑定 跳转登录页 --todo登录之后需绑定用户
            include globalStatic::$root_directory.'Smarty_setup.php';
            $smarty = new lingdangCRM_Smarty;
            $smarty->assign('ticket',$ticket);
            $smarty->assign('client_id',$client_id);
            $smarty->assign('expire_time',$expire_time);
            $smarty->assign('msgShowStyle',$msgShowStyle);
            $smarty->assign('corpurl',$corpurl);
            $smarty->assign('applicationType',$this->applicationType);//应用类型
            $smarty->display('yunzhijia_login.tpl');
        }else {
            //已绑定
            //并且跳首页
            global $adb;
            $_REQUEST['user_name'] = $crm_userinfo['user_name'];
            $_REQUEST['userid'] = $crm_userinfo['id'];
            $_REQUEST['user_password'] = $crm_userinfo['user_password'];
            $_REQUEST['from_yunzhijia'] = 'yes';
            require_once(globalStatic::$root_directory . "Register/RegOp.php");
            require_once(globalStatic::$root_directory . "CRMSecurity.php");
            require_once(globalStatic::$root_directory ."Register/MySessionHandler.php");
 
            require_once(globalStatic::$root_directory ."Register/CRMRedis.php");
            
            global $global_crmredisobj;
            $global_crmredisobj=CRMRedis::getInstance();
            if($global_crmredisobj!='error')
            {
              
                //36059: （1.6）报表库>即时库存余额表：即时库存数量字段的值应该是蓝色可点击跳转的。（需要补丁）
                $handler = new MySessionHandler();
           
                //session_set_save_handler($handler,true);
                session_set_save_handler(
                    array($handler, 'open'),
                    array($handler, 'close'),
                    array($handler, 'read'),
                    array($handler, 'write'),
                    array($handler, 'destroy'),
                    array($handler, 'gc')
                    );
                    register_shutdown_function('session_write_close');
            } 
          //  session_id(SID);
            session_start();
            
            include globalStatic::$root_directory . 'modules/Users/Authenticate.php';
        }
    }
    //获取openid和userid
    public function getOpenId(){
        $accessToken = $this->getAccessTokenOfApp();
        $url = $this->yunzhijiadomain."gateway/ticket/user/acquirecontext?accessToken=".$accessToken;
        $ticket = $_REQUEST['ticket'];
        $param = [
            "appid" => self::$default_appid,
            "ticket" => $ticket,
        ];
        $param = json_encode($param);//设置了Content-Type: application/json，传参要转化为JSON，否则后台接收不到数据
        $header = ["Content-Type: application/json"];
        $res = json_decode($this->curlPost($url,$param,$header));
        $data = $res->data;
        return ['userid'=>$data->userid,'openid'=>$data->openid];
    }
    //比对wbuserid和openid
    public function ConfirmUser($userid,$openid){
        $sql = "select id,user_name,last_name,user_password from ld_users where yunzhijia_openid=?";
        $res = $this->adb->pquery($sql,[$openid]);
        $nums = $this->adb->num_rows($res);

        if($nums>0){
            $userinfo = $this->adb->query_result_rowdata($res);
            //密码为空时 更新下密码
            if(empty($userinfo['user_password'])){
                $userfocus = CRMEntity::getInstance('Users');
                $crypt_type = 'MD5';
                $user_password = rand(1000,999999);
                $userinfo['user_password'] = $user_password;
                $encrypted_password = $userfocus->encrypt_password($user_password, $crypt_type);
                $update_sql = "update ld_users set user_password=? where id=?";
                $this->adb->pquery($update_sql,array($encrypted_password,$userinfo['id']));
            }
            return $userinfo;
        }else{
            return [];
        }
    }
    public function doLogin(){
        $auth = $this->getOpenId();
        $_REQUEST['wbuserid'] = $auth['userid'];
        $_REQUEST['openid'] = $auth['openid'];
        crm_load_class_file('login_model','WeiXinApp/modules/Users/login');
        $model = new login_model();
        $model->yunzhijia_bind();
    }
    //获取app级别的accessToken--以前的 这个session存得有问题
    public function getAccessTokenOfApp1(){
        if(isset($_SESSION['yzj_access_token'])&&(time()>($_SESSION['yzj_access_token']['create_time']+$_SESSION['yzj_access_token']['expires_in']))){
            $token = $_SESSION['yzj_access_token']['access_token'];
        }else {
            $url = $this->yunzhijiadomain."gateway/oauth2/token/getAccessToken";
            list($msec, $sec) = explode(' ', microtime());
            $msectime = (float)sprintf('%.0f', (floatval($msec) + floatval($sec)) * 1000);
            $param = [
                    "appId" => self::$default_appid,
                    "secret" => self::$default_secret,
                    "timestamp" => $msectime,
                    "scope" => "app",
                ];
            $param = json_encode($param);//设置了Content-Type: application/json，传参要转化为JSON，否则后台接收不到数据
            $header = ["Content-Type: application/json"];
            $res = json_decode($this->curlPost($url,$param,$header));
            $res = $res->data;
            $token = $res->accessToken;
            // 存储session以及过期时间
            $_SESSION['yzj_access_token']['access_token'] = $token;
            $_SESSION['yzj_access_token']['expires_in'] = $res->expireIn;
            $_SESSION['yzj_access_token']['create_time'] = time();
        }
        return $token;
    }
    //获取app级别的accessToken
    public function getAccessTokenOfApp(){
        $access_token = file_get_contents(globalStatic::$root_directory.'storage/accesstoken/yzj_access_token.txt');
        $access_token = json_decode($access_token,true);
        if(!empty($access_token['access_token'])&&(time()<($access_token['create_time']+$access_token['expires_in']-600))){
            $token = $access_token['access_token'];
        }else{
            $url = $this->yunzhijiadomain."gateway/oauth2/token/getAccessToken";
            list($msec, $sec) = explode(' ', microtime());
            $msectime = (float)sprintf('%.0f', (floatval($msec) + floatval($sec)) * 1000);
            $param = [
                "appId" => self::$default_appid,
                "secret" => self::$default_secret,
                "timestamp" => $msectime,
                "scope" => "app",
            ];
            $param = json_encode($param);//设置了Content-Type: application/json，传参要转化为JSON，否则后台接收不到数据
            $header = ["Content-Type: application/json"];
            $res = json_decode($this->curlPost($url,$param,$header));
            $res = $res->data;
            $token = $res->accessToken;
            // 存储session以及过期时间
            $access_token['access_token'] = $token;
            $access_token['expires_in'] = $res->expireIn;
            $access_token['create_time'] = time();
            $access_token = json_encode($access_token);
            if(!is_dir(globalStatic::$root_directory.'storage/accesstoken')){
                mkdir(globalStatic::$root_directory.'storage/accesstoken',0777);
            }
            file_put_contents(globalStatic::$root_directory.'storage/accesstoken/yzj_access_token.txt',$access_token);
        }
        return $token;
    }


    /**
     * @param $url
     * @param $data
     * @param $header
     * @return bool|string
     * curl post方法
     */
    public function curlPost($url,$data,$header=''){
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        // POST数据
        curl_setopt($ch, CURLOPT_POST, 1);
        // 把post的变量加上
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch,CURLOPT_HTTPHEADER,$header);
        $output = curl_exec($ch);
        curl_close($ch);
        return $output;
    }
}