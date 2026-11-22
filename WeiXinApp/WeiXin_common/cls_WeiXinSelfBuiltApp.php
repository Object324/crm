<?php

class cls_WeiXinSelfBuiltApp
{
    public $corp_link;
    public $corpid;
    public $corpsecret;
    public $agentid;
    public $nonceStr;
    public $timestamp;
    public $deviceId;

    public $corpApiObj;

    public $cache_data;

    public $wx_version;
    public $http_html_url;//当前请求jssdk的网页的URL，不包含#及其后面部分。前端签名时使用

    public $installWXSelfBuilt;
    public function __construct()
    {
        include_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
        global $adb;
        $result = $adb->pquery('select para_content from ld_wx_config where name = ?',array('wxselfbuiltapp_setting'));
        if($adb->num_rows($result) > 0){
            $para_content_json = $adb->query_result($result,0,'para_content');
            $para_content_list =  Zend_Json::decode($para_content_json);
            if(empty($para_content_list)) {
                return '';
            }
            $this->corp_link = $para_content_list['corp_link'];
            $this->corpid = $para_content_list['corpid'];
            $this->corpsecret = $para_content_list['secret'];
            $this->agentid = $para_content_list['agentid'];
            if(empty($this->agentid))
            {
                return '';
            }
            if (empty($this->corpApiObj)) {
                include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
                $this->corpApiObj = new CorpAPI($this->corpid, $this->corpsecret);
            }
            $this->nonceStr = getRandChar(16);
            $this->timestamp = time();
            $this->deviceId = '';

            $this->installWXSelfBuilt = true;
        }else{
            $this->installWXSelfBuilt = false;
            $adb->pquery("insert into ld_wx_config (name,description) select 'wxselfbuiltapp_setting','企业微信自建应用设置' from dual where not exists(select 1 from ld_wx_config where name='wxselfbuiltapp_setting')",array());
        }

        $this->wx_version = $this->get_server_version();//  V8.4.6.2   没有右斜杠
        $this->http_html_url =$this->corp_link."WeiXinApp/selfbuildSass/ldcrm/index.html";


    }

    //获取企业的jsapi_ticket
    /*jsapi_ticket是H5应用调用企业微信JS接口的临时票据。正常情况下，jsapi_ticket的有效期为7200秒，通过access_token来获取。由于获取jsapi_ticket的api调用次数非常有限（一小时内，一个企业最多可获取400次，且单个应用不能超过100次），频繁刷新jsapi_ticket会导致api调用受限，影响自身业务，开发者必须在自己的服务全局缓存jsapi_ticket*/
    public function getJsApiSignature(){
        $http_html_url = $this->http_html_url;
        $nonceStr = $this->nonceStr;
        $timestamp = $this->timestamp;
        $jsapi_ticket = '';

        if (file_exists(globalStatic::$root_directory . "dataCache/weixin/selfbuiltticket.txt")) {
            $content_arr = explode("\n", file_get_contents(globalStatic::$root_directory . "dataCache/weixin/selfbuiltticket.txt"));
            if (DateOperation::sencods_between_time(date("Y-m-d H:i:s"), $content_arr[1]) < 60 * 60) {
                $jsapi_ticket = trim($content_arr[0]);

            }
        }
        if(empty($jsapi_ticket))
        {
            $jsapi_ticket = $this->corpApiObj->JsApiTicketGet();
            if (!empty($jsapi_ticket))
                file_put_contents(globalStatic::$root_directory . "dataCache/weixin/selfbuiltticket.txt", $jsapi_ticket . "\n" . date("Y-m-d H:i:s"));

        }

        $jsapi_string = "jsapi_ticket=" . $jsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=" . $http_html_url;
        $signature = sha1($jsapi_string);//企业签名

        return $signature;
    }

    //获取应用的jsapi_ticket
    /*正常情况下，应用的jsapi_ticket的有效期为7200秒，通过access_token来获取。由于获取jsapi_ticket的api调用次数非常有限（一小时内，一个企业最多可获取400次，且单个应用不能超过100次），频繁刷新jsapi_ticket会导致api调用受限，影响自身业务，开发者必须在自己的服务全局缓存应用的jsapi_ticket。*/
    public function getAgentJsApiSignature()
    {
        $http_html_url = $this->http_html_url;
        $nonceStr = $this->nonceStr;
        $timestamp = $this->timestamp;
        $agent_jsapi_ticket = '';

        if(file_exists(globalStatic::$root_directory."dataCache/weixin/selfbuiltagentticket.txt"))
        {
             $content_arr=explode("\n",file_get_contents(globalStatic::$root_directory."dataCache/weixin/selfbuiltagentticket.txt"));
             if(DateOperation::sencods_between_time(date("Y-m-d H:i:s"),$content_arr[1])<60*60)
             {
                $agent_jsapi_ticket=trim($content_arr[0]);
                
             }
        }
        if(empty($agent_jsapi_ticket))
        {
             $agent_jsapi_ticket = $this->corpApiObj->getAgentTicket();
             if(!empty($agent_jsapi_ticket))
                file_put_contents(globalStatic::$root_directory."dataCache/weixin/selfbuiltagentticket.txt",$agent_jsapi_ticket."\n".date("Y-m-d H:i:s"));
        
        }
        $agentjsapi_string = "jsapi_ticket=" . $agent_jsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=" . $http_html_url;
        $agent_signature = sha1($agentjsapi_string);//应用签名

        return $agent_signature;
    }

    //获取服务器版本号
    public function get_server_version(){
        if(!empty($this->cache_data['version'])){
            return $this->cache_data['version'];
        }else{
            global $adb;
            $sql = 'SELECT wx_version from ld_version LIMIT 1';
            $result = $adb->pquery($sql, array());
            $rows = $adb->num_rows($result);
            //默认版本为V2
            if($rows==1){
                $wx_version = $adb->query_result($result,0,'wx_version');
            }else{
                $wx_version = 'V2';
            }

            $this->cache_data['version'] = $wx_version;
            return $wx_version;
        }
    }

    //企业微信移动端导入外部联系人
    public function get_external_contact($r_userids)
    {
        if(empty($r_userids)){
            return array();
        }else {
            $userid_arr = explode(';', rtrim($r_userids,';'));
            $userinfo_arr = array();
            foreach ($userid_arr as $key=>$userid){
                $info = $this->corpApiObj->get_external_contact($userid);
                if (empty($info)) {
                    continue;
                }
                if(isset($info['follow_user']))
                    $info['external_contact']['follow_user'] = $info['follow_user'];//follow_user移到同一个数组里

                $userinfo_arr[$key] = $info['external_contact'];
            }
            $result['result']['contact'] = $userinfo_arr;
            return $result;
        }
    }

    //PC端导入外部联系人
    public function get_external_contact_list($r_userid,$r_corpid,$r_curosr='',$r_intervalrow=100){
        if(empty($r_corpid) || empty($r_userid)){
            return array();
        }else {
            $userid = $r_userid;
            $userinfo_arr = array();
            if(empty($r_curosr)){ //第一次请求时读取所有外部联系人数量
                $curosr = "";
                $contactlist_arr = $this->corpApiObj->get_externalcontact_list($userid);
                if (empty($contactlist_arr))
                    return array();
                $userinfo_arr['contact_listlen'] = $contactlist_arr;
                $list_len = sizeof($contactlist_arr['external_userid']);
                if($list_len <=0){ //当前用户客户列表为空时直接返回
                    return array();
                }
                $limit = $r_intervalrow;

                $contactinfo_arr = $this->corpApiObj->get_external_contact_batch($userid,$curosr,$limit);//批量获取用户外部联系人信息(批量获取客户详情)
                $userinfo_arr['contactinfo'] = $contactinfo_arr;
            }else{ //之后的请求只读取联系人信息
                $curosr = $r_curosr;
                $limit = $r_intervalrow;
                $contactinfo_arr = $this->corpApiObj->get_external_contact_batch($userid,$curosr,$limit);
                $userinfo_arr['contactinfo'] = $contactinfo_arr;
            }
            $result['result']['contact'] = $userinfo_arr;//同crm_free接口返回值格式保持一致。
            return $result;
        }
    }

    //获取外部联系人的标签(获取企业标签库)
    public function get_contact_corp_tag() {
        $contact_tag = [];
        $result = $this->corpApiObj->get_corp_tag_list();
        if(!empty($result)){
            foreach($result['tag_group'] as $key => $channellabel){
                foreach($channellabel['tag'] as $key2 => $labelobj){
                    $contact_tag[$labelobj['id']] = $labelobj['name'];
                }
            }
        }
        return $contact_tag;
    }

    //检查远程服务器是否含某个文件
    public function check_remote_file_exists($url)
    {
        $curl = curl_init($url);
// 不取回数据
        curl_setopt($curl, CURLOPT_NOBODY, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'GET'); //不加这个会返回403，加了才返回正确的200，原因不明
// 发送请求
        $result = curl_exec($curl);
        $found = false;
// 如果请求没有发送失败
        if ($result !== false)
        {
// 再检查http响应码是否为200
            $statusCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
            if ($statusCode == 200)
            {
                $found = true;
            }
        }
        curl_close($curl);
        return $found;
    }
}