<?php
/***
 * 接口文件
 * 放在51mis的index.php代码中
 */
header("Access-Control-Allow-Origin:*");
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
include($root_dir.'/includefile.php');
include_once ($root_dir.'/WeiXinApp/marketing/controller/WxUsers.php');
// require_once($root_dir.'/include/Zend/Json.php');
$function = $_REQUEST["function"];
$obj = new  WechatPublicInterface($root_dir);
$obj->$function();

class WechatPublicInterface
{
    //微信公众号-服务号的appid 与app secret  签名token默认值
    public static $default_appid;
    public static $default_secret;
    public static $signToken;
    public $adb;
    public $root_dir;
    public function __construct($root_dir)
    {
        global $adb;
        $this->adb = $adb;
        $this->root_dir = $root_dir;
        // 初始化参数
        $set_sql = "select * from ld_articles_appid_set";
        $set_res = $adb->pquery($set_sql);
        $nums = $adb->num_rows($set_res);
        if($nums>=1){
           self::$default_appid = $adb->query_result($set_res, 0, "app_id");
           self::$default_secret = $adb->query_result($set_res, 0, "app_secret");
           self::$signToken = $adb->query_result($set_res, 0, "token");
        }else{
            exit("请到CRM配置相关信息");
        }
    }

    /**
     * 微信公众号 授权回调方法
     */
    public function index()
    {
        //打开页面之前先做授权
        $auth = $this->auth();
        $corpurl = $_REQUEST['corpurl'];
        $pagename =  isset($_REQUEST['pagename'])?$_REQUEST['pagename']:'home';
        //跳转之前 判断模块授权情况 articles授权 不改变pagename articles未授权 再判断ambassador是否授权 授权则跳到个人中心页 未授权则给提示未授权
        $user_obj = new WxUsers($this->adb,$this->root_dir);
        $is_active = $user_obj->getModuleActive();
        if($is_active['have_articles'] !="yes"){
            if($is_active['have_ambassador'] =="yes"){
                $pagename = "personal";
            }else{
                exit("获客文章与推广大使均未授权！");
            }
        }
        $appid = "&appid=".self::$default_appid;
        if(empty($auth) || $auth->errcode > 0 ){
            //echo "授权失败！";
            $fromUserId = $_REQUEST['fromUserId'];
            header("Location: ".$corpurl."WeiXinApp/marketing/ldcrm/index.html#!/".$pagename."?userid=".$fromUserId."&corpurl=".$corpurl.$appid);
            exit();
        }
        $user_res = $this->curlPost($corpurl."WeiXinApp/marketing/index.php?function=updateUser",$auth);
        $user_res = json_decode($user_res);
        header("Location: ".$corpurl."WeiXinApp/marketing/ldcrm/index.html#!/".$pagename."?userid=".$user_res->data."&corpurl=".$corpurl.$appid);
        exit();
    }

    /**
     * @return mixed
     * 获取全局access_token
     * //该方法暂时不用了  灵当软件 裂变文章和公众号消息都用到这个token 不重复获取
     */
    public function getAccessToken1111()
    {
        $appid = self::$default_appid;
        $appsecret = self::$default_secret;
        $projectname = 'Acticles';
        //accesstoken 存到文件中
        $access_token_offiaccount = file_get_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt');
        $access_token_offiaccount = json_decode($access_token_offiaccount,true);
        if(!empty($access_token_offiaccount['access_token'])&&(time()<($access_token_offiaccount['create_time']+3600))){
            $token = $access_token_offiaccount['access_token'];
        }else{
            $url = "https://api.weixin.qq.com/cgi-bin/token?appid=".$appid."&grant_type=client_credential&secret=".$appsecret;
            $jsonwx = json_decode($this->curlGet($url));
            // 存储session以及过期时间
            $access_token_offiaccount['access_token'] = $jsonwx->access_token;
            $access_token_offiaccount['expires_in'] = $jsonwx->expires_in;
            $access_token_offiaccount['create_time'] = time();
            $access_token_offiaccount = json_encode($access_token_offiaccount);
            if(!is_dir(globalStatic::$root_directory.'storage/accesstoken')){
                mkdir(globalStatic::$root_directory.'storage/accesstoken',0777);
            }
            file_put_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt',$access_token_offiaccount);
            $token = $jsonwx->access_token;
        }
        return $token;
    }
    //zxm 20220103 灵当软件 裂变文章和公众号消息都用到这个token 使用统一的方法获取
    public function getAccessToken(){
        $appid = self::$default_appid;
        $appsecret = self::$default_secret;
        include_once globalStatic::$root_directory.'include/weixinMsg/cls_WXaccessToken.php';
        $wxObj = new cls_WXaccessToken($appid,$appsecret,'CRMoffiaccount','CRM公众号','CRMoffiaccount');
        return $wxObj->getAccessToken();
    }
    /**
     * @param $code
     * @return array
     * 网页授权用token
     */
    public function getSubTokenInfo($code)
    {
        $appid = self::$default_appid;
        $appsecret = self::$default_secret;
        $url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=".$appid."&code=$code&grant_type=authorization_code&secret=".$appsecret;
        $jsonwx = json_decode($this->curlGet($url));
        return ['sub_token'=>$jsonwx->access_token,'openid'=>$jsonwx->openid];


        $projectname = 'ActiclesAuth';
        //accesstoken 存到文件中
        $access_token_offiaccount = file_get_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt');
        $access_token_offiaccount = json_decode($access_token_offiaccount,true);
        if(!empty($access_token_offiaccount['access_token'])&&(time()<($access_token_offiaccount['create_time']+3600))){
            $token = $access_token_offiaccount['access_token'];
            $openid = $access_token_offiaccount['openid'];
        }else{
            $url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=".$appid."&code=$code&grant_type=authorization_code&secret=".$appsecret;
            $jsonwx = json_decode($this->curlGet($url));
            // 存储session以及过期时间
            $access_token_offiaccount['access_token'] = $jsonwx->access_token;
            $access_token_offiaccount['openid'] = $jsonwx->openid;
            $access_token_offiaccount['expires_in'] = $jsonwx->expires_in;
            $access_token_offiaccount['create_time'] = time();
            $access_token_offiaccount = json_encode($access_token_offiaccount);
            if(!is_dir(globalStatic::$root_directory.'storage/accesstoken')){
                mkdir(globalStatic::$root_directory.'storage/accesstoken',0777);
            }
            file_put_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt',$access_token_offiaccount);
            $token = $jsonwx->access_token;
            $openid = $jsonwx->openid;
        }
        return ['sub_token'=>$token,'openid'=>$openid];
    }
    /**
     * @param $url
     * @return bool|string
     * curl get方法
     */
    public function curlGet($url)
    {
        //初始化
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL,$url);
        // 执行后不直接打印出来
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        // 跳过证书检查
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        // 不从证书中检查SSL加密算法是否存在
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

        //执行并获取HTML文档内容
        $output = curl_exec($ch);

        //释放curl句柄
        curl_close($ch);

        return $output;
    }

    /**
     * @param $url
     * @param array $data
     * @return bool|string
     * curl post方法
     */
    public function curlPost($url , $data=array()){

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);

        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);

        // POST数据

        curl_setopt($ch, CURLOPT_POST, 1);

        // 把post的变量加上

        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

        $output = curl_exec($ch);

        curl_close($ch);

        return $output;

    }
    public function renderHtml()
    {
        //打开页面之前先做授权
        $auth = $this->auth();

        //打开页面
        echo file_get_contents('./index.html');
    }
    /**
     *获取局部授权token
     */
    public function getToken()
    {
        $echoStr = $_GET["echostr"];
        if($this->checkSignature()){
            echo $echoStr;
            exit;
        }
    }

    private function checkSignature()
    {
        $signature = $_GET["signature"];

        $timestamp = $_GET["timestamp"];

        $nonce = $_GET["nonce"];
        $tmpArr = array(self::$signToken, $timestamp, $nonce);

        sort($tmpArr);

        $tmpStr = implode( $tmpArr );

        $tmpStr = sha1( $tmpStr );


        if( $tmpStr == $signature ){

            return true;

        }else{

            return false;

        }
    }
    //获取微信公从号ticket
    public function wx_get_jsapi_ticket() {
        if(isset($_SESSION['ticket'])&&(time()>($_SESSION['ticket']['create_time']+$_SESSION['ticket']['expires_in']))){
            $ticket = $_SESSION['ticket']['ticket'];
        }else{
            $url = sprintf("https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=%s&type=jsapi", $this->getAccessToken());
            $res = $this->curlGet($url);
            $res = json_decode($res, true);

            // 存储session以及过期时间
            $_SESSION['ticket']['ticket'] = $res['ticket'];
            $_SESSION['ticket']['expires_in'] = $res['expires_in'];
            $_SESSION['ticket']['create_time'] = time();
            $ticket = $res['ticket'];

        }
        return  $ticket;
    }
    public function getSign()
    {
        $corpurl = $_REQUEST['corpurl'];
        $wx = array();
        //生成签名的时间戳
        $wx['timestamp'] = time();
        //生成签名的随机串
        $wx['noncestr'] = 'Wm3WZYTPz0wzccnW';
        //jsapi_ticket是公众号用于调用微信JS接口的临时票据。正常情况下，jsapi_ticket的有效期为7200秒，通过access_token来获取。
        $wx['jsapi_ticket'] = $this->wx_get_jsapi_ticket();
        //分享的地址，注意：这里是指当前网页的URL，不包含#及其后面部分，曾经的我就在这里被坑了，所以小伙伴们要小心了
        //$wx['url'] = 'http://180.76.151.127/index.html';
        $wx['url'] = $corpurl.'WeiXinApp/marketing/ldcrm/index.html';
        $string = sprintf("jsapi_ticket=%s&noncestr=%s&timestamp=%s&url=%s", $wx['jsapi_ticket'], $wx['noncestr'], $wx['timestamp'], $wx['url']);
        //生成签名
        $wx['signature'] = sha1($string);
        $wx['corpid'] = self::$default_appid;
        echo json_encode($wx);
    }


    /**
     * @return array|mixed
     * 微信授权方法
     */
    public function auth()
    {
        //061DZ7Ga1uMKlD0piAIa15HOav1DZ7Gi
        if(isset($_REQUEST["code"])){
            $code = $_REQUEST["code"];
            //第二步：通过code换取网页授权access_token
            $info = $this->getSubTokenInfo($code);//网页授权用token

            $access_token = $this->getAccessToken();//微信公众号 获取信息通用token
            //这个接口的token是sub_token
            $scope = $_REQUEST['scope'];
            if($scope == "snsapi_userinfo"){
                $urlwx = "https://api.weixin.qq.com/sns/userinfo?access_token=".$info['sub_token']."&openid=".$info['openid']."&lang=zh_CN";
            }else{
                //这个接口的token是$this->getAccessToken()的token
                $urlwx = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=".$access_token."&openid=".$info['openid']."&lang=zh_CN";
            }
            $jsonwx = json_decode(file_get_contents($urlwx),true);
            $jsonwx['scope'] = $scope;//授权方式
        }else{
            $jsonwx = [];
        }

        return $jsonwx;
    }

}