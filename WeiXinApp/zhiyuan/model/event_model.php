<?php
require_once globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php';
class event_model extends EventFromApiModel
{
    public $token;

    public $zhiyuan_url;

    //发消息用的账号密码
    public $registerCode;
    public $userName;
    public $password;


    public function initConfig(){
        global $adb;
        $sql = 'select para_content from ld_wx_config where name = \'zhiyuan_setting\'';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        if($num > 0){
            $para_content_list =  Zend_Json::decode($adb->query_result($result,0,'para_content'));

            $this->zhiyuan_url = rtrim($para_content_list['zhiyuan_url'],'/');
            $this->registerCode = $para_content_list['registerCode'];//系统注册编码，致远提供
            $this->userName = $para_content_list['userName'];//发送消息时先需要获取token，token接口需要用户名和密码。
            $this->password = $para_content_list['password'];

        }
        if(empty($this->zhiyuan_url)){
            return false;
        }else{
            return $this;
        }
    }

	public function get_userid($zhiyuan_ticket){
        global $adb;
        $id = 0;
        $zhiyuan_userid = '';
        if (!empty($zhiyuan_ticket)) {
            //http://127.0.0.1:8080/seeyon/thirdpartyController.do?ticket=45612365487987
            $url = $this->zhiyuan_url.'/seeyon/thirdpartyController.do?ticket='.$zhiyuan_ticket;
            $zhiyuan_userid = $this->_CurlPost($url,[]);
            if(!empty($zhiyuan_userid)){
                $query = "select id from ld_users where zhiyuan_userid = ? limit 1";
                $result = $adb->pquery($query,array($zhiyuan_userid));
                $num_rows = $adb->num_rows($result);
                if($num_rows >= 1){
                    $id = $adb->query_result($result,0,0);
                }
            }
        }

		return array("userid"=>$id,"zhiyuan_userid"=>$zhiyuan_userid);
	}

    public function _CurlPost($url,$body){
        $oCurl = curl_init();
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
        }
        curl_setopt($oCurl, CURLOPT_URL, $url);
        curl_setopt($oCurl, CURLOPT_POST, true);
        curl_setopt($oCurl, CURLOPT_POSTFIELDS, $body);
        curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($oCurl, CURLOPT_HTTPHEADER,array('content-type: application/json;charset=utf-8;'));
        curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 100);
        curl_setopt($oCurl, CURLOPT_TIMEOUT, 100);
        $sContent = curl_exec($oCurl);
        curl_close($oCurl);
        return $sContent;
    }
    
}