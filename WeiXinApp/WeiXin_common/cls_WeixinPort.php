<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/10/27 0027
 * Time: 下午 5:36
 */
class cls_WeixinPort
{
    public $appid;//服务商套件中的对应应用id
    public $access_token;
    public $agentid;
    public $corp_link;
    public $corpid;
    public $userid;
    public $entitytype; // workreport  cocmd  weibo
    public $corpindex;//数组
    public $cache_data;
    public $suitename_single;
    public $corpindex_single;
    public $suite_crm ;
    public $suite_app ;
    public $suite_txl ;
    public $type_mini=false ;// editor:gyq_110 reason:是否是小程序  2019/5/9 15:46
    public $suitename_coll = array();  //套件名集合
    public $token_coll = array();//access_token集合 暂只适用于消息提醒
    public $static_address;
    public function __construct($appid='')
    {
        include_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
        crm_load_class_file("StaticConst", 'WeiXinApp/WeiXin_common');
        $this->suite_crm = StaticConst::$suite_crm;
        $this->suite_app = StaticConst::$suite_app;
        $this->suite_txl = StaticConst::$suite_txl;
        $this->appid = $appid;
        $this->static_address = StaticConst::$server_address;
    }
    //editor:gyq_110 reason:初始化提醒需要的参数值.企业微信小程序提醒 2019/5/9 15:03
    public function init_port_info(){
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $auto_info_json = doCorpInfo('get_auth_info','');
        $info_arr = json_decode($auto_info_json, true);
        $crm_auth = $info_arr[StaticConst::$suite_crm];
        if(!empty($crm_auth)) {
            $this->corpindex[StaticConst::$suite_crm] = $crm_auth['corpindex'];
            //editor:gyq_20190508 reason:0037000:没有virtual_module，账套OEM授权绑定企业微信无法收到消息提醒。
            $this->agentid['ldcrm'] = $crm_auth['auth_info']['agent'][0]['agentid'];
            $this->corpid = $crm_auth['auth_corp_info']['corpid'];
            $this->corp_link = $crm_auth['corpurl'];
            $this->suitename_coll[StaticConst::$suite_crm] = $crm_auth['suitename'];
            if($crm_auth['suitename']=='crm_mini')
                $this->type_mini = true;
        }else{
            $this->corpindex = array();
        }
    }
    //gyq_53
    public function push_news($url,$data){
        $ch = curl_init ();
        curl_setopt ( $ch, CURLOPT_URL, $url );
        curl_setopt ( $ch, CURLOPT_POST, 1 );
        curl_setopt ( $ch, CURLOPT_HEADER, 0 );
        curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
        $output = curl_exec ( $ch );
        $errno = curl_errno( $ch );
        curl_close ( $ch );
        return $errno;
    }

    public function getMedia_id($rImgpath,$rToken){

        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {//获取系统类型，如果是非windows系统则不用修改编码格式
            $fileurl =urldecode($rImgpath);
        }else{
            $fileurl = iconv('utf-8','gbk',$rImgpath);
        }
        $url = 'https://qyapi.weixin.qq.com/cgi-bin/media/upload?access_token='.$rToken.'&type=file';
        
       // $post_data=array("media"=> new \CURLFile(globalStatic::$root_directory.$fileurl));
       if(PHP_VERSION>=7){
        //edit:can 20200713 php5.5废弃了@
            $post_data=array("media"=> new \CURLFile(globalStatic::$root_directory.$fileurl));
       }
        else
        $post_data = array(
        
            "file"=>'@'.globalStatic::$root_directory.$fileurl, //这里要注意@符串
        );
        
        
        $info = $this->curlUploadFile($post_data,$url);
         
      // dump(globalStatic::$root_directory.$fileurl);
        $infoArr=json_decode($info,true);
        $media_id = $infoArr['media_id'];
        return $media_id;
    }

     /**
     * kehu001上传导出文件且转义用户和部门名称
     * $filepath:文件本地路径
     * $renamefile:前端下载的文件名称
     * */
     public function UploadUserInfoFile($filepath,$renamefile){


        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {//获取系统类型，如果是非windows系统则不用修改编码格式
            $fileurl =urldecode($filepath);
        }else{
            $fileurl = iconv('utf-8','gbk',$filepath);
        }
         $url = StaticConst::$server_api . '?action=getProvideTokenAccess';
           
         $url_result_json = $this->primary_curl($url);
         $url_result_arr = json_decode($url_result_json, true);
         $provider_access_token=$url_result_arr['token'];
        //上传导出文件
        $url = 'https://qyapi.weixin.qq.com/cgi-bin/service/media/upload?provider_access_token='.$provider_access_token.'&type=file';
    
      if(PHP_VERSION>=7){
            //edit:can 20200713 php5.5废弃了@，但是kehu001还要php5.4
            $fileobj=new \CURLFile($fileurl);
            $fileobj->setPostFilename($renamefile);
            $post_data=array("media"=> $fileobj
                        
                        );
       }
        else
        $post_data = array(
            "media"=>'@'.realpath($fileurl).';filename='.$renamefile,
           
           
        );
       
        $info = $this->curlUploadFile($post_data,$url);
    
        $infoArr=json_decode($info,true);
        $media_id = $infoArr['media_id'];
      
        //开始转义文件
        $auto_info_json = doCorpInfo('get_auth_info','');
        $info_arr = json_decode($auto_info_json, true);
        $auth_info = $info_arr[StaticConst::$suite_crm];
         $corpid = $auth_info['auth_corp_info']['corpid'];
        $url="https://qyapi.weixin.qq.com/cgi-bin/service/contact/id_translate?provider_access_token=$provider_access_token";
    
        $post_data=array('auth_corpid'=>$corpid,"media_id_list"=>array($media_id));
       
        $tmpdata=json_encode($post_data,JSON_UNESCAPED_UNICODE);
        $result=$this->curlPost($url,$tmpdata);
     
        $arrjobinfo=json_decode($result,true);
         //file_put_contents(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/jobid.txt',$arrjobinfo['jobid']);
        $url="https://qyapi.weixin.qq.com/cgi-bin/service/batch/getresult?provider_access_token=$provider_access_token&jobid=".$arrjobinfo['jobid'];
     set_time_limit(0);
    // $url="https://qyapi.weixin.qq.com/cgi-bin/service/batch/getresult?provider_access_token=kfSRpriOF3ZTZi_9UGWkubniPkORTA2bKTkQP0OCpimXbApyID2iDFkvHnmHLGMP-Le31bEGapbUz-NZq4uPkHGQZxc5UylmCsxIMEOtwUE2tAUd5mm4RmTapD7r08cn&jobid=7GMacuBUS-dKijbg7SD6eUoUqL4-mIiW5jBkoPG8ogo";
     while(true){
        
        $result=  $this->primary_get($url);
       
        $arr=json_decode($result,true);
        if($arr['status']=='3'){//任务状态，整型，1表示任务开始，2表示任务进行中，3表示任务已完成
            break;
        }
        sleep(3);//每个3秒检测异步转义是否完成
     }
     
       $user_agent = $_SERVER['HTTP_USER_AGENT'];
     if (stripos($user_agent, 'MicroMessenger') === false) {
         return $arr['result']['contact_id_translate']['url'];
     }
     else{
        //pc端企业微信登录
         $encodeurl=urlencode($arr['result']['contact_id_translate']['url']);
      
       //$this->curlDownLoadUrl($arr['result']['contact_id_translate']['url'],'storage/test.xls');
           $loc="https://open.weixin.qq.com/connect/oauth2/authorize?appid=$corpid&redirect_uri=$encodeurl&state=1#wechat_redirect";
           return $loc;
     }
    
      // header("Location:".$loc);
       //https://open.weixin.qq.com/connect/oauth2/authorize?appid=wwe1ea05f91cf95336&redirect_uri=&state=1#wechat_redirect
    //   header("Location:".$arr['result']['contact_id_translate']['url']);
       //exit();
        
    }
    public function getMediaFile($meidalid){
        $ACCESS_TOKEN=$this->getCorpToken();
        $url="https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=$ACCESS_TOKEN&media_id=$meidalid";
        dump($this->primary_get($url));
        
    }
    //gyq_45
    public function doChangeContact($rData){
        //$auto_info_json = file_get_contents(globalStatic::$root_directory.'dataCache/weixin/auth_gyq_info.txt');
        $auto_info_json = doCorpInfo('get_auth_info');
        if(!empty($auto_info_json)) {
            $info_arr = json_decode($auto_info_json, true);
            $auth_info = $info_arr[$this->suite_txl];
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $rData["corpindex"] = $corpindex;
                $rData["rediskey"] = $corpid.$suitename;
               /* $rData['corpindex'] = $corpindex;
                $rData['rediskey'] = $corpid . $suitename;*/
                $URL = StaticConst::$server_multiapi;

                $url_result_json = $this->curlPost($URL,$rData);
            }
            return $url_result_json;
        }else{
            return 'auth_info empty';
        }


    }
    //gyq170913  51mis.cn
    public function getCorpToken(){ //gyq_33TE

        //$auto_info_json = file_get_contents(globalStatic::$root_directory.'dataCache/weixin/auth_gyq_info.txt');
        $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            /*if(!empty($auto_info_json)){
                $info_arr = json_decode($auto_info_json, true);
                $agentid = null;
                $suitename = null;
                $agentArr = $info_arr['auth_info']['agent'];
                $corpid = $info_arr['auth_corp_info']['corpid'];
                foreach($agentArr as $val){
                    $suitename = $val['suite_name'];
                    break;
                }
            }*/
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
            $ACCESS_TOKEN = '';
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $access_token_url = StaticConst::$server_api . '?action=get_access_token_cache&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
                $url_result_json = $this->primary_curl($access_token_url);
                $url_result_arr = json_decode($url_result_json, true);
                $ACCESS_TOKEN = $url_result_arr['result'];
            }
            return $ACCESS_TOKEN;
        }else{
            return '';
        }
    }
    public function getConvertUserId($useridarr)
    {
        $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
          $url_result_arr=[];
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $access_token_url = StaticConst::$server_api . '?action=convertuserid&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
                $url_result_json = $this->curlPost($access_token_url,['useridlist'=>json_encode($useridarr)]);
                $url_result_arr = json_decode($url_result_json, true);
              
            }
            return $url_result_arr;
        }else{
            return [];
        }
    }
    
    public function getcheckindata($starttime,$endtime,$useridlist)
    {
        $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
            $ACCESS_TOKEN = '';
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
               // if(isset($_COOKIE[$corpindex.'_jsapi_ticket'])&&$_COOKIE[$corpindex.'_jsapi_ticket']!=''){
//                    return $_COOKIE[$corpindex.'_jsapi_ticket'];
//                    
//                }  
                $para = array(
                            'opencheckindatatype'=> 1,
                            'starttime'=> $starttime,
                            'endtime'=> $endtime,
                            'useridlist'=> json_encode($useridlist)
                           
                        );
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $url = StaticConst::$server_api . '?action=getcheckindata&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
		
                 $url_result_json=$this->curlSend($url,$para);
				
                $url_result_arr = json_decode($url_result_json, true);
             
            }
            return $url_result_arr;
        }else{
            return '';
        }
    }
    /**
     * 获取应用的jsApiTicket
     * */
    public function getJsApiTicket(){
          $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
            $ACCESS_TOKEN = '';
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
               // if(isset($_COOKIE[$corpindex.'_jsapi_ticket'])&&$_COOKIE[$corpindex.'_jsapi_ticket']!=''){
//                    return $_COOKIE[$corpindex.'_jsapi_ticket'];
//                    
//                }
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $url = StaticConst::$server_api . '?action=get_jsapiticket&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
           
                $url_result_json = $this->primary_curl($url);
                $url_result_arr = json_decode($url_result_json, true);
                $jsapiticket = $url_result_arr['result'];
                setcookie($corpindex.'_jsapi_ticket',$jsapiticket,time()+3600);
            }
            return $jsapiticket;
        }else{
            return '';
        }
    }
    
    /**
     * 获取应用的jsApiTicket
     * */
    public function getAgentJsApiTicket(){
          $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
            $ACCESS_TOKEN = '';
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                //if(isset($_COOKIE[$corpindex.'agent_jsapi_ticket'])&&$_COOKIE[$corpindex.'agent_jsapi_ticket']!=''){
//                    return $_COOKIE[$corpindex.'agent_jsapi_ticket'];
//                    
//                }
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $url = StaticConst::$server_api . '?action=get_agent_jsapiticket&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
           
                $url_result_json = $this->primary_curl($url);
                $url_result_arr = json_decode($url_result_json, true);
                $jsapiticket = $url_result_arr['result'];
                setcookie($corpindex.'agent_jsapi_ticket',$jsapiticket,time()+3600);
            }
            return $jsapiticket;
        }else{
            return '';
        }
    }
    
    //$type:eq like
    public function getwxUserid($type,$searchvalue){
          $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
          
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $agentid=$info_arr['crm']['auth_info']['agent'][0]['agentid'];
                if($type=='eq'){
                     $url = StaticConst::$server_api . '?action=get_equser&corpindex=' . $corpindex . '&agentid='.$agentid.'&rediskey=' . $corpid . $suitename;
                }
                else
                     $url = StaticConst::$server_api . '?action=get_likeuser&corpindex=' . $corpindex . '&agentid='.$agentid.'&rediskey=' . $corpid . $suitename;
                //外国人的姓名有空格
                $searchvalue=urlencode($searchvalue);
                $url.='&searchvalue='.$searchvalue;
                //dump($url);
                $url_result_json = $this->primary_curl($url);
              
                $url_result_arr = json_decode($url_result_json, true);
                
                $jsapiticket = $url_result_arr['result'];
                //setcookie($corpindex.'agent_jsapi_ticket',$jsapiticket,time()+3600);
            }
            return $jsapiticket;
        }else{
            return '';
        }
    }
    
     public function getwxGroupid($type,$searchvalue){
          $auto_info_json = doCorpInfo('get_auth_info',array());
        if(!empty($auto_info_json)) {
            
            $info_arr = json_decode($auto_info_json, true);
            if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
                $auth_info = $info_arr[$this->suite_app];
            }else{
                $auth_info = $info_arr[$this->suite_crm];
            }
          
            if (!empty($auth_info)) {
                $corpindex = $auth_info['corpindex'];
                $suitename =  $auth_info['suitename'];
                $corpid = $auth_info['auth_corp_info']['corpid'];
                $agentid=$info_arr['crm']['auth_info']['agent'][0]['agentid'];
                if($type=='eq'){
                     $url = StaticConst::$server_api . '?action=get_eqgroup&corpindex=' . $corpindex . '&agentid='.$agentid.'&rediskey=' . $corpid . $suitename;
                }
                else
                     $url = StaticConst::$server_api . '?action=get_likegroup&corpindex=' . $corpindex . '&agentid='.$agentid.'&rediskey=' . $corpid . $suitename;
                $url.='&searchvalue='.$searchvalue;
              
                $url_result_json = $this->primary_curl($url);
                $url_result_arr = json_decode($url_result_json, true);
               
                $jsapiticket = $url_result_arr['result'];
                //setcookie($corpindex.'agent_jsapi_ticket',$jsapiticket,time()+3600);
            }
            return $jsapiticket;
        }else{
            return '';
        }
    }
    //gyq_33
    public function getAccessToken($type){//$type crm apply
        if(isset($_REQUEST['suite_from']) && $_REQUEST['suite_from']=='app'){
            $corpindex = $this->corpindex['app'];
            $suitename = $this->suitename_coll['app'];
        }else{
            $corpindex = $this->corpindex[$type];
            $suitename = $this->suitename_coll[$type];
        }
        if(isset($this->token_coll[$type])){
            return $this->token_coll[$type];
        }else{
            $this->suitename_single = $suitename;
            $this->corpindex_single = $corpindex;
            $corpid = $this->corpid;
            if(!empty($corpindex)) {
                $access_token_url = StaticConst::$server_api . '?action=get_access_token_cache&corpindex=' . $corpindex . '&rediskey=' . $corpid . $suitename;
                $url_result_json = $this->primary_curl($access_token_url);
                $url_result_arr = json_decode($url_result_json, true);
                $this->token_coll[$type] = $this->access_token = $url_result_arr['result'];
                return $this->access_token;
            }else{
                return false;
            }
        }
    }
    //消息提醒中获取agentid gyq_33
    public function getAgentId(){


        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $judge = judgeCorpInfo('install_app');
        if($judge){
            //$auto_info_json = file_get_contents(globalStatic::$root_directory.'dataCache/weixin/auth_gyq_info.txt');
            $auto_info_json = doCorpInfo('get_auth_info');
            $info_arr = json_decode($auto_info_json, true);
            $txl_auth = $info_arr[StaticConst::$suite_txl];
            if(!empty($txl_auth)) {
                $this->corpindex['txl'] = $txl_auth['corpindex'];
                $agentArr = $txl_auth['auth_info']['agent'];
                foreach ($agentArr as $val) {
                    $virmodule = $val['virtual_module'];
                    if ($virmodule == 'Users') {//gyq_33TE
                        $this->agentid[$virmodule] = $val['agentid'];
                        break;
                    }
                }
                $this->corpid = $txl_auth['auth_corp_info']['corpid'];
                $this->corp_link = $txl_auth['corpurl'];

                if(isset($this->agentid['Users'])){
                    $this->suitename_coll['txl'] = StaticConst::$suite_txl;
                }

            }
            $crm_auth = $info_arr[StaticConst::$suite_crm];
            if(!empty($crm_auth)) {
                $this->corpindex[StaticConst::$suite_crm] = $crm_auth['corpindex'];
                //editor:gyq_20190508 reason:0037000:没有virtual_module，账套OEM授权绑定企业微信无法收到消息提醒。
                $this->agentid['ldcrm'] = $crm_auth['auth_info']['agent'][0]['agentid'];
               /*  $agentArr = $crm_auth['auth_info']['agent'];
                    foreach ($agentArr as $val) {
                    $virmodule = $val['virtual_module'];
                    if ($virmodule == 'ldcrm') {//gyq_33TE
                        $this->agentid[$virmodule] = $val['agentid'];
                        break;
                    }
                }*/
                $this->corpid = $crm_auth['auth_corp_info']['corpid'];
                $this->corp_link = $crm_auth['corpurl'];
            }
            $apply_auth = $info_arr[StaticConst::$suite_app];
            $agentid_arr = array();
            if(!empty($apply_auth)) {
                $this->corpindex['app'] = $apply_auth['corpindex'];
                $agentArr = $apply_auth['auth_info']['agent'];
                foreach ($agentArr as $val) {
                    $virmodule = $val['virtual_module'];
                    if ($virmodule == 'Home'||$virmodule == 'Approve') {
                        $this->agentid[$virmodule] = $val['agentid'];
                    }
                }
                $this->corpid = $apply_auth['auth_corp_info']['corpid'];
                $this->corp_link = $apply_auth['corpurl'];
            }
            if(isset($this->agentid['ldcrm'])){
                $this->suitename_coll[StaticConst::$suite_crm] = StaticConst::$suite_crm;
            }
            if(isset($this->agentid['Home'])){
                $this->suitename_coll['app'] = StaticConst::$suite_app;
            }else{
                $this->corpindex['app'] = $crm_auth['corpindex'];
                $this->agentid['Home'] = $this->agentid['ldcrm'];
                $this->suitename_coll['app'] = StaticConst::$suite_crm;
            }
            if(isset($this->agentid['Approve'])){
                $this->suitename_coll['Approve'] = StaticConst::$suite_app;
                $this->corpindex['Approve'] = $this->corpindex['app'];
            }else{
                $this->corpindex['Approve'] = $crm_auth['corpindex'];
                $this->agentid['Approve'] = $this->agentid['ldcrm'];
                $this->suitename_coll['Approve'] = StaticConst::$suite_crm;
            }
            return false;

        }else{
            $this->corpindex = array();
            return false;
        }
    }
    //获取服务器版本号  20170817 gyq_41
    public function get_server_version(){
        if(!empty($this->cache_data['version'])){
            return $this->cache_data['version'];
        }else{
            crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
            $version= cls_StaticCommonFun::websaas_multi_version('data');
            /* $corp_link = $this->corp_link;
             $static_address = $this->static_address;
             $urlarr = array(urlencode($static_address));
             $urljson = json_encode($urlarr);
             $getVersionUrl = $corp_link . 'WeiXinApp/index.php?get_version=' . $urljson;
             $infojson = $this->primary_get($getVersionUrl);
             $infoArr = json_decode($infojson, true);
             $version = $infoArr['result'][0];*/
            $this->cache_data['version'] = $version;
            return $version;
        }
    }

    //php模拟上传文件  gyq_31
    public function curlUploadFile($post_data,$url){
        $ch = curl_init();
        /* $post_data = array(
             'file' => '@'.$fileurl
         );*/
       //  $size=filesize('storage/2_Contacts.xls');
        //$header=array('Content-Type:multipart/form-data','Content-Disposition:form-data;name=media;filename="wangcan.xls";filelength='.$size);
        curl_setopt($ch, CURLOPT_HEADER, $header);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch,CURLOPT_BINARYTRANSFER,true);
        curl_setopt($ch, CURLOPT_POSTFIELDS,$post_data);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
        $info= curl_exec($ch);
       //  $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
       // $header = substr($info, 0, $headerSize);
      // $body = substr($info, $headerSize);
        
        $error    = curl_error($ch);
        
        curl_close($ch);
        if ($error != ""){
            return $error;
        }
        return $info;
    }
    public function curlPost($uri,$data){
        $ch = curl_init ();

        curl_setopt ( $ch, CURLOPT_URL, $uri );
        curl_setopt ( $ch, CURLOPT_POST, 1 );
        curl_setopt ( $ch, CURLOPT_HEADER, 0 );
        curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
        $output = curl_exec ( $ch );
        curl_close ( $ch );
        return $output;
    }
    public function curlSend($url, $post_data)
    {
        $chr = curl_init();
        curl_setopt($chr, CURLOPT_URL, $url);
        curl_setopt($chr, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($chr, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($chr, CURLOPT_HEADER, 0);//设置header
        curl_setopt($chr, CURLOPT_POST, true);
        curl_setopt($chr, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($chr, CURLOPT_RETURNTRANSFER, true);
        $output = curl_exec($chr);
        if ($error = curl_error($chr)) {
            die($error);
        }
        curl_close($chr);
        return $output;
    }
    public function primary_curl($url)
    {
        $ch = curl_init();
        global $LINGDANGCURLOPT_PROXYINFO;
        if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'])){
            $curlopt_porxy = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'];
            if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'])){
                $curlopt_porxyport = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'];
            }
            if(!empty($curlopt_porxy)){
                $newurl = $curlopt_porxy;
                if(!empty($curlopt_porxyport)){
                    $newurl .= ':'.$curlopt_porxyport;
                }
                $newurl .= '/crmprox/index.php?getproturl='.urlencode($url);
                $url = $newurl;
            }
        }
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        }
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        $output = curl_exec($ch);
        curl_close($ch);
        //$php52 = json_decode($output, true);
        return $output;
    }
    //执行get请求
    public function primary_get($url){

        //访问数据接口
        $ch = curl_init();
        global $LINGDANGCURLOPT_PROXYINFO;
        if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'])){
            $curlopt_porxy = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'];
            if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'])){
                $curlopt_porxyport = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'];
            }
            if(!empty($curlopt_porxy)){
                $newurl = $curlopt_porxy;
                if(!empty($curlopt_porxyport)){
                    $newurl .= ':'.$curlopt_porxyport;
                }
                $newurl .= '/crmprox/index.php?getproturl='.urlencode($url);
                $url = $newurl;
            }
        }
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        }
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($ch);
        if(curl_errno($ch)) {
         $output=  file_get_contents($url);
       
        }

        curl_close($ch);

        return $output;
    }
    /*
     * Function:往指定目录下载超链接文件
     * Editor:gyq_47
     * Time:20171120
     * Parm:$rUrl 待下载的URL  $rLocalUrl要保存的本地地址
     * */
    public function curlDownLoadUrl($rUrl,$rLocalUrl){
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $rUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
        $file = curl_exec($ch);
        curl_close($ch);
        $resource = fopen( $rLocalUrl, 'a');
        fwrite($resource, $file);
        fclose($resource);
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
    //editor:gyq_110 reason:企业微信小程序提醒  2019/5/14 11:13
    public function miniprogram_notice($r_describ,$r_title,$r_reltab,$r_related_to,$r_date_time,$r_list_type){
        //editor:gyq_20190709 reason:审批提醒的list_type特殊
        if(empty($r_list_type))
            $r_list_type = 'list';
        $newArr['msgtype'] = 'miniprogram_notice';//小程序提醒标识
        $newArr['miniprogram_notice']['appid'] = StaticConst::$miniprogram_noticeid;
        $newArr['miniprogram_notice']['title'] = $r_title;
        //工作协同类型的提醒，新增发布人格式
        if ($r_reltab == 'CooperativeWork') {
            
            
            $newArr['miniprogram_notice']['content_item'] = $r_describ;
        }else{
            $newArr['miniprogram_notice']['content_item'][0]['key'] = '内容';
            $describ = strip_tags(str_replace('"', '\"', $r_describ));
            $newscontent = mb_substr($describ, 0, 30, 'utf-8');
            $newArr['miniprogram_notice']['content_item'][0]['value'] = $newscontent;
            $newArr['miniprogram_notice']['content_item'][1]['key'] = '操作时间';
            $newArr['miniprogram_notice']['content_item'][1]['value'] = $r_date_time;
        }
        if (!empty($r_related_to) && !empty($r_reltab) && $r_reltab !='Users') {
            $newArr['miniprogram_notice']['page'] = 'pages/detailview/detailview?getcode=yes&listType='.$r_list_type.'&modulename=' . $r_reltab . '&recordID=' . $r_related_to;
            if($r_reltab=='CooperativeWork')
                $newArr['miniprogram_notice']['page'] = 'pages/work/detailview/detailview?getcode=yes&curid='.$r_related_to.'&worktype=workreport';
        }
        return $newArr;
    }
}