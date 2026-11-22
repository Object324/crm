<?php
//editor:gyq_144 reason:钉钉登陆绑定  2019/9/11 16:28
require_once globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php';
class event_model extends EventFromApiModel
{
    public $token;
    public $_corpid;
    public $_agentid;
    public $_appkey;
    public $_appsecret;
    public $_login_appid;
    public $_login_secret;
    public $_login_url;
    //初始化配置参数
    public function initConfig(){
        global $adb;
        $sql = 'select para_one,para_two,para_three,time,para_content from ld_wx_config where name = \'dingtalk_setting\'';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        if($num > 0){
            //editor:gyq_165 reason:修改钉钉参数格式   2019/12/26 15:06
            $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
            //处理旧数据。处理旧数据总共有两处，一处是这里，另一处是钉钉参数设置的查看界面
            if(!isset($para_content_list['corpid'])){
                $para_content_list['corpid'] = $adb->query_result($result,0,'para_one');
                $para_content_list['key'] = $adb->query_result($result,0,'para_two');
                $para_content_list['secret'] = $adb->query_result($result,0,'para_three');
                $para_content_list['agentid'] =$adb->query_result($result,0,'time');
                $sql = "update ld_wx_config set para_one=?,para_two=?,para_three=?,time=?,para_content=? where name=?";
                $adb->pquery($sql,array('','','',0,json_encode($para_content_list),'dingtalk_setting'));
            }
            foreach ($para_content_list as $paraName=>$paraValue){
                if($paraName=='login_appid'){
                    $this->_login_appid = $paraValue;
                }elseif ($paraName=='login_secret'){
                    $this->_login_secret = $paraValue;
                }elseif ($paraName=='corpid'){
                    $this->_corpid = $paraValue;
                }elseif ($paraName=='key'){
                    $this->_appkey = $paraValue;
                }elseif ($paraName=='secret'){
                    $this->_appsecret = $paraValue;
                }elseif ($paraName=='agentid'){
                    $this->_agentid = $paraValue;
                }elseif ($paraName=='login_url'){
                    $this->_login_url = $paraValue;
                }
            }
        }
        if(empty($this->_corpid)||empty($this->_appkey)||empty($this->_appkey)||empty($this->_appkey)){
            return false;
        }else{
            return $this;
        }
    }
    //初始化配置参数，并给出异常提示
    public function init_config(){
        global $current_user;
        $this->initConfig();
        if(empty($this->_corpid)||empty($this->_appkey)||empty($this->_appkey)||empty($this->_appkey)){
            //editor:gyq_20191216 reason:系统的翻译依赖$current_user->id
            if(empty($current_user->id)){
                $current_user->id = 1;
            }
            //同步按钮提示
            if($_REQUEST['file']=='sync'){
                $remind = getFixedLabel('DINGTALKSYNCBUTTONREMIND');
            }else{
                //常规提示
                $remind = getFixedLabel('DINGTALKREMINDONE');
            }
            ConvertTojsonString(-1,array(),$remind);
        }
    }
    //获取钉钉成员ID
    public function get_userid($r_code){
        $token = $this->gettoken();
        $url = 'https://oapi.dingtalk.com/user/getuserinfo?access_token='.$token.'&code='.$r_code;
        $url_content = json_decode(CurlGet($url)['content'], true);
        if($url_content['errcode']===0){
            $userid =$url_content['userid'];
            return $userid;
        }else{
            ConvertTojsonString(-1,array($url_content),json_encode($url_content));
        }
    }
    //获取钉钉成员信息(包含unionid)
    public function get_userinfo($userid){
        $userinfo = '';
        if (!empty($userid)) {
            if (empty($this->token)) {
                $this->token = $this->gettoken();
            }
            if(!empty($this->token)){
                $url = 'https://oapi.dingtalk.com/topapi/v2/user/get?access_token='.$this->token;
                $param = json_encode(["userid"=>$userid]);
                $url_content = json_decode(_CurlPost($url,$param), true);
                //duan 20240715 BUG20240713-02 如果钉钉用户已注销，或不在应用授权范围内，则清空dingtalkuserid
                if($url_content['errcode']===0){
                    $userinfo = $url_content['result'];
                    $userinfo['active'] = 'yes';
                }else if(in_array($url_content['errcode'],[50002,60121])){
                    $userinfo = $url_content['result'];
                    $userinfo['active'] = 'no';
                }
            }else{
                $userinfo = [];
                $userinfo['active'] = 'no';
            }
        }

        return $userinfo;
    }
    //JSAPI调用鉴权参数
    public function isvConfig($r_corpurl){
        $timeStamp = time();
        $token = $this->gettoken();
        $ticket = $this->get_jsapi_ticket($token);
        $html_url = urldecode($r_corpurl).H5HTML;
        $signature = $this->sign($ticket, NONCESTR, $timeStamp, $html_url);
        $config = array(
            'nonceStr' => NONCESTR,
            'agentId' => $this->_agentid,
            'timeStamp' => $timeStamp,
            'corpId' => $this->_corpid,
            'signature' => $signature,
            'ticket' => $ticket);
        return $config;
    }
    //获取接口秘钥
    public function gettoken(){
        $url = 'https://oapi.dingtalk.com/gettoken?appkey='.$this->_appkey.'&appsecret='.$this->_appsecret;
        $result = CurlGet($url)['content'];
        $url_content = json_decode($result, true);
        $token = '';
        if($url_content['errcode']===0) {
            //editor:gyq_155 reason:钉钉考勤同步  2019/10/27 16:52 ID1000624 
            $this->token = $token = $url_content['access_token'];
            return $token;
        }else{
            return '';
            //ConvertTojsonString(-1,array($url,$result),json_encode($url_content));
        }
    }
    public function get_jsapi_ticket($accessToken)
    {
        $url = 'https://oapi.dingtalk.com/get_jsapi_ticket?access_token='.$accessToken;
        $url_content = json_decode(CurlGet($url)['content'], true);
        $jsticket = '';
        if($url_content['errcode']===0) {
            $jsticket = $url_content['ticket'];
        }else{
            echo "<pre>";
            print_r($url_content);
            echo "<pre/><HR align=left width=1000 color=#987cb9 SIZE=3>";
            exit;//gyqTE
        }
        return $jsticket;
    }
    //获取签名
    public function sign($ticket, $nonceStr, $timeStamp, $url)
    {
        $plain = 'jsapi_ticket=' . $ticket .
            '&noncestr=' . $nonceStr .
            '&timestamp=' . $timeStamp .
            '&url=' . $url;
        return sha1($plain);
    }
    //获取企业下的自定义空间
    public function get_custom_space(){
        $this->token = $this->gettoken();
        $url = 'https://oapi.dingtalk.com/cspace/get_custom_space?access_token='.$this->token.'&domain=ldcrm&agent_id='.AGENT_ID;
        $url_content = json_decode(CurlGet($url)['content'], true);
        $content = '';
        if($url_content['errcode']===0) {
            $grant_custom_space = $this->grant_custom_space();
            if($grant_custom_space['errcode']===0){
                $content = $url_content['spaceid'];
                return $content;
            }else{
                ConvertTojsonString(-1,array(),json_encode($grant_custom_space));
            }
        }else{
            ConvertTojsonString(-1,array(),json_encode($url_content));
        }
    }
    //授权用户访问企业自定义空间
    //*****权限有效时间，有效范围为0~3600秒
    public function grant_custom_space(){
        $USERID = $_REQUEST['userid'];
        $PATH = urlencode('/');
        $DURATION = 3600;
        $url = 'https://oapi.dingtalk.com/cspace/grant_custom_space?access_token='.$this->token.'&domain=ldcrm&agent_id='.AGENT_ID.'&type=add&userid='.$USERID.'&path='.$PATH.'&fileids=&duration='.$DURATION;
        $url_content = json_decode(CurlGet($url)['content'], true);
        return $url_content;
    }
    //单文件上传
    //****文件大小不得大于8M
    public function upload_single(){
        $ACCESS_TOKEN = $this->gettoken();
        $AGENT_ID = AGENT_ID;
        $save_path = globalStatic::$root_directory.$_REQUEST['file_path'];
        $FILE_SIZE = filesize($save_path) ;
        $url = 'https://oapi.dingtalk.com/file/upload/single?access_token='.$ACCESS_TOKEN.'&agent_id='.$AGENT_ID.'&file_size='.$FILE_SIZE;
        $post_data = array(
            'file' => '@' . $save_path
        );
        $info = json_decode( $this->curlUploadFile($post_data, $url),true);
        if($info['errcode']===0){
            $media_id = $info['media_id'];
            return $media_id;
        }else{
            ConvertTojsonString(-1,array(),$info);
        }
    }
    public function curlUploadFile($post_data,$url){
        $ch = curl_init();
        /* $post_data = array(
             'file' => '@'.$fileurl
         );*/
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch,CURLOPT_BINARYTRANSFER,true);
        curl_setopt($ch, CURLOPT_POSTFIELDS,$post_data);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
        $info= curl_exec($ch);
        $error    = curl_error($ch);
        curl_close($ch);
        if ($error != ""){
            return $error;
        }
        return $info;
    }
    //获取当前URL
    public function curPageURL()
    {
        $pageURL = 'http';

        if (array_key_exists('HTTPS',$_SERVER)&&$_SERVER["HTTPS"] == "on")
        {
            $pageURL .= "s";
        }
        $pageURL .= "://";

        if ($_SERVER["SERVER_PORT"] != "80")
        {
            $pageURL .= $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"] . $_SERVER["REQUEST_URI"];
        }
        else
        {
            $pageURL .= $_SERVER["SERVER_NAME"] . $_SERVER["REQUEST_URI"];
        }
        return $pageURL;
    }
    //editor:gyq_163 reason:钉钉内免登第三方网站，获取用户ID   2019/12/13 13:53
    public function getUserId($rCode,$rState){
        include globalStatic::$root_directory.'WeiXinApp/dingtalk/lib/TopSdk.php';
        $c = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_POST , DingTalkConstant::$FORMAT_JSON);
        $req = new OapiSnsGetuserinfoBycodeRequest;
        $req->setTmpAuthCode($rCode);
        $resp=$c->executeWithAccessKey($req, "https://oapi.dingtalk.com/sns/getuserinfo_bycode",$this->_login_appid,$this->_login_secret);
        $userid = 0;
        if($resp->errcode===0){
            $unionid = $resp->user_info->unionid;
            $token = $this->gettoken();
            $client = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_GET , DingTalkConstant::$FORMAT_JSON);
            $request = new OapiUserGetUseridByUnionidRequest;
            $request->setUnionid($unionid);
            $userinfo = $client->execute($request,$token,'https://oapi.dingtalk.com/user/getUseridByUnionid');
            if($userinfo->errcode===0){
                $userid = $userinfo->userid;
            }else{
                $errmsg =  '获取用户信息失败，'.$userinfo->errmsg.'('.$userinfo->errcode.')，请检查钉钉企业通讯录只读权限是否开通';
            }
        }else{
           $errmsg =  '免登失败，'.$resp->errmsg.'('.$resp->errcode.')，请检查钉钉登录参数设置';
        }
        if($userid === 0){
            $current_url = $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
            $deal_url = 'http://' . substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=' . $errmsg;
            header('location:' . $deal_url);
            exit;
        }
        return $userid;
    }
    //reason:钉钉内免登第三方网站   2019/12/13 13:53
    public function crmLogin($wx_userid)
    {


        global $adb;
        $sql = 'SELECT id,last_name,user_name,status FROM ld_users WHERE dingtalk_userid = ? LIMIT 1';
        $result = $adb->pquery($sql, array($wx_userid));
        $userid = $adb->query_result($result, 0, 'id');
        $status = $adb->query_result($result, 0, 'status');
        $user_name = $adb->query_result($result, 0, 'user_name');
        $rows = $adb->num_rows($result);
        $current_url = getCrmUrl();
        if(strrpos($current_url, 'WeiXinApp') !== false){
            $current_url = substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) ;
        }
        $http='http';
        if(strtolower($_SERVER['REQUEST_SCHEME'])=='https')
        {    
            $http='https';
        }
     //   file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/model/3.txt',$http);        
        //file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/model/2.txt',json_encode($_SERVER));
        if ($rows == 1) {
            if ($status == 'Inactive') {//languageType='.$_REQUEST['languageType']
                $deal_url = $current_url . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=登录失败,您绑定的CRM用户已停用';
                header('location:' . $deal_url);
            } else {
                $deal_url = $current_url;
                include(globalStatic::$root_directory.'WeiXinApp/lib/cls_dandian.php');
                $objdandian = new cls_dandian($user_name);

                $deployvalues=getSys_deploy(105);
                $secretKey = $deployvalues['deploy_value'];
                $timestamp = time();//加密key使用的时间戳
                $encryptedKey = $objdandian->getencryptedKeybykey($secretKey,$timestamp);
                $temporaryToken = $objdandian->setgenerateTokenbyencryptedkey($encryptedKey);
                $encryptusername = $objdandian->ldencryptstring($user_name,$timestamp,false);
                //Eidtor:gyq Reason:增加bodywidth参数 Date:2018/5/4 0004 下午 1:23
                //editor:gyq_20190116 0036175: （kehu001）扫码登录后按钮都挤在一起来了。
                if (empty($_REQUEST['bodywidth'])) {
                    $_REQUEST['bodywidth'] = 1366;
                }
                /*$http='http';
                if(strtolower($_SERVER['REQUEST_SCHEME'])=='https')
                {
                    
                    $http='https';
                }*/
             // file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/model/2.txt',$http);
              $corp_link = $deal_url . '/index.php?module=Users&action=Authenticate&temporary_token=' . $temporaryToken . '&timestamp=' . $timestamp . '&bodywidth=' . $_REQUEST['bodywidth'] . '&dandian_weixin=true'. '&from_dingtalk=yes';
                header('location:' . $corp_link);
                exit;
            }
        } else {
            /*若没有绑定CRM账号，则返回到登录界面，再弹出提示信息【请先绑定企业微信】，英文标签【Please bind enterprise WeChat first】*/
            if ($_REQUEST['languageType'] == 'en') {
                $remind = 'Please bind enterprise WeChat first';
            } else {
                // $remind = '请先绑定企业微信';
                //0033020: 企业微信后台点击前往服务商后台，转到crm登录界面提示请先绑定企业微信。（已经绑定过企业微信了）
                $remind = '请登录钉钉APP，进入灵当CRM应用绑定CRM账号';
            }
            $deal_url =  $current_url . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=' . $remind;
            header('location:' . $deal_url);
            exit;
        }
    }
}