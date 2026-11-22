<?php
//editor:gyq_144 reason:钉钉登陆绑定  2019/9/11 16:28
require_once globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php';
class event_model extends EventFromApiModel
{
    public $token;
    //获取成员ID
    public function get_userid($r_code,$r_corpid){
        global $adb;
        $sql = 'select para_two,para_three from ld_wx_config where name = \'dingtalk_setting\'';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        if($num <= 0){
            ConvertTojsonString(-1,array(),'参数配置错误');
        }
        $appkey = $adb->query_result($result,0,'para_two');
        $appsecret = $adb->query_result($result,0,'para_three');
        $url = 'https://oapi.dingtalk.com/gettoken?appkey='.$appkey.'&appsecret='.$appsecret;
        $url_content = json_decode(CurlGet($url)['content'], true);
        if($url_content['errcode']===0){
            $token = $url_content['access_token'];
            $url = 'https://oapi.dingtalk.com/user/getuserinfo?access_token='.$token.'&code='.$r_code;
            $url_content = json_decode(CurlGet($url)['content'], true);
            if($url_content['errcode']===0){
                $userid =$url_content['userid'];
                return $userid;
            }else{
                ConvertTojsonString(-1,array($url_content),json_encode($url_content));
            }
        }else{
            ConvertTojsonString(-1,array($url_content),json_encode($url_content));
        }
    }
    //editor:gyq_144 reason:钉钉  2019/9/16 14:24
    public function isvConfig(){
        $token = $this->gettoken();
        $corpId = 'dingc7fcc1bcfe6c1876';
        $nonceStr = 'abcdefg';
        $timeStamp = time();
        $ticket = $this->get_jsapi_ticket($token);
        $url = $this->curPageURL();
        $url = 'http://www.51mis.com/kfbcrm/WeiXinApp/dingtalk/debug/index.html';
        $signature = $this->sign($ticket, $nonceStr, $timeStamp, $url);
        $config = array(
            'nonceStr' => $nonceStr,
            'agentId' => AGENT_ID,
            'timeStamp' => $timeStamp,
            'corpId' => $corpId,
            'signature' => $signature,
            'ticket' => $ticket);
        return $config;
    }
    //获取接口秘钥
    public function gettoken(){
        global $adb;
        $appkey = 'dingynymsl8rwowlrlx8';
        $appsecret = 'qNgO5etsxg-wm9TxW6yfz83u3_Z4NkLXzDBHsO2533JcYisfOS3ONngGDjQqXoGe';
        $url = 'https://oapi.dingtalk.com/gettoken?appkey='.$appkey.'&appsecret='.$appsecret;
        $url_content = json_decode(CurlGet($url)['content'], true);
        $token = '';
        if($url_content['errcode']===0) {
            $token = $url_content['access_token'];
            return $token;
        }else{
            ConvertTojsonString(-1,array(),json_encode($url_content));
        }
    }
    public function get_jsapi_ticket($accessToken)
    {
        $url = 'https://oapi.dingtalk.com/get_jsapi_ticket?access_token='.$accessToken;
        $url_content = json_decode(CurlGet($url)['content'], true);
        $jsticket = '';
        if($url_content['errcode']===0) {
            $jsticket = $url_content['ticket'];
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
}