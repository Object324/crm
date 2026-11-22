<?php
//微信扫码登录，输出二维码跳转的链接 gyq_51
function getQRcodeForLogin(){
    //editor:gyq_131 reason:企业微信新增服务商  2019/7/31 16:44
    $exist_auth_info = doCorpInfo('get_auth_info',array());
    $exist_auth_arr = json_decode($exist_auth_info, true);
    $locationurl = '';
    if(isset($exist_auth_arr['crm'])){
        $corpurl = $exist_auth_arr['crm']['corpurl'];
        $corpid = $exist_auth_arr['crm']['auth_corp_info']['corpid'];
        if(!empty($corpurl)){
            require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
            $locationurl = StaticConst::$server_qrcode_url.'function/crm_login_transfer.html?orignurl='.$corpurl.'&corpid='.$corpid;
        }
    }
    return $locationurl;
    /*if($_SERVER["HTTP_HOST"]=='localhost'){//localhost依然可以登录   gyq_51 20171213   gyqTE

        }else{
            $current_url = $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
            if(strrpos($current_url,'index.pAhp') > 0){
                $corpurl = 'http://'.substr($current_url,0,strrpos($current_url,'index.php'));
            }else{
                $corpurl = 'http://'.$current_url;
            }
        }*/
}
function doCorpInfo($rAction,$rParam)
{
    global $adb;
//    @edit:liushuai,2021-03-31,reason:0045223: （本地8.4.2版本）新安装的本地CRM，安装路径‘ldcrm\www\crm\dataCache’下面没有自动生成‘weixin’文件夹；导致0045222问题的出现
    if (!file_exists(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt')) {
        mkdir(globalStatic::$root_directory . 'dataCache/weixin/', 0777, true);
        file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt', '');
    }
    switch ($rAction) {
        //gyq_62 auth_info缓存修改，ld_version备份，清除缓存清空，使用微信APP生成D:\wamp\www\ldcrm\appCommon\appCommon.php
        case 'update_auth_info':
            $exist_auth_info = getWeiXinAuthInfo();
            $corpindex = $_REQUEST['corpindex'];
            if (strlen($exist_auth_info)<10 &&  !empty($corpindex)){
                //向API传递动作信息
                require_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
                require_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
                $o_port = new cls_WeixinPort();
                $url = StaticConst::$server_api . '?action=update_auth_info&corpindex=' . $corpindex ;
                $result = $o_port->primary_curl($url);
                $result_info = json_decode($result,true);
                $auth_info = $result_info['result']['auth_info'];
                if(empty($auth_info))
                    ConvertTojsonString(-1,array(),'Fail:update_auth_info');
                else{
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt',  encryptStringByLabel(json_encode($auth_info),'auth_info'));
                    /*$sql = "UPDATE ld_version SET wx_auth_info = ?";
                    $adb->pquery($sql, array(json_encode($auth_info)));*/
                    ConvertTojsonString(1,array(),'Success:update_auth_info');
                }
            }
            break;
        case 'save_auth_info'://保存企业号信息
            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt',  encryptStringByLabel(json_encode($rParam['auth_info']),'auth_info'));
            /*$sql = "UPDATE ld_version SET wx_auth_info = ?";
            $adb->pquery($sql, array(json_encode($rParam['auth_info'])));*/
            $result = true;
            break;
        case 'get_auth_info':
            $result = '';
            if(isset($rParam['root_directory'])){
                $getWeiXinAuthInfoParams=array();
                $getWeiXinAuthInfoParams['root_directory']=$rParam['root_directory'];
                $exist_auth_info = getWeiXinAuthInfo($getWeiXinAuthInfoParams);
            }else{
                $exist_auth_info = getWeiXinAuthInfo();
            }
            if (strlen($exist_auth_info)>10)
                $result = $exist_auth_info;
            else{
                /*$sql="SELECT wx_auth_info FROM ld_version limit 1";
                $result_sql = $adb->query($sql);
                $exist_auth_info=$adb->query_result($result_sql,0,'wx_auth_info');
                if (strlen($exist_auth_info)>10){
                    $result = $exist_auth_info;
                }*/
            }
            break;
        case 'uninstall'://保存企业号信息
            //删除授权缓存文件
            if($rParam){
                exec('rm -Rf '.globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt');
                exec('rm -Rf '.globalStatic::$root_directory . 'index.php');
                exec('rm -Rf '.globalStatic::$root_directory . 'WeiXinApp/index.php');
            }else {
                file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt','');//gyqX20180312
                exec('rm -Rf ' . globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt');
            }
            /*$sql = "UPDATE ld_version SET wx_auth_info = ?";
            $adb->pquery($sql, array(''));*/
            $result = true;
            break;
    }
    return $result;
}
function judgeCorpInfo($rType){
    $result = false;
    switch($rType){
        case 'install_app' ://是否安装企业微信
            $exist_auth_info = doCorpInfo('get_auth_info',array());
            $exist_auth_arr = json_decode($exist_auth_info, true);
            if(isset($exist_auth_arr['crm']))
                $result =$exist_auth_arr;
            else
                $result = false;
            break;
        case  'kehu001'://是否是客户001预置账套
            $exist_auth_info = doCorpInfo('get_auth_info',array());
            $exist_auth_arr = json_decode($exist_auth_info, true);
            if($exist_auth_arr['crm']['auth_type']=='market'){
                $result =  $exist_auth_arr;
            }else
                $result = false;
            break;
    }
    return $result;
}
//新企业号信息处理方法 逐步弃用judgeCorpInfo

/**
 * 二维数组根据字段进行排序
 * @params array $array 需要排序的数组
 * @params string $field 排序的字段
 * @params string $sort 排序顺序标志 SORT_DESC 降序；SORT_ASC 升序
 */
function arraySequence($array, $field, $sort = 'SORT_DESC')
{
    $arrSort = array();
    foreach ($array as $uniqid => $row) {
        foreach ($row as $key => $value) {
            $arrSort[$key][$uniqid] = $value;
        }
    }
    array_multisort($arrSort[$field], constant($sort), $array);
    return $array;
}
//判定字段值是否重复，返回值样式##success##正确，#error#错误
function judgeFieldDuplicate($rModule,$rFieldname,$rFieldvalue,$rFieldid){
    if($rFieldid=="")
        $rFieldid=0;
    require_once globalStatic::$root_directory.'modules/lingdang/staticlingdang.class.php';
    $ldcls = new staticlingdang();
    $rest = $ldcls->getFieldDuplicateInfo($rModule,$rFieldname,$rFieldvalue,$rFieldid);
    return $rest;
}
//生成介于min和max两个数之间的一个指定长度的随机整数
function getRandChar($length){
    $str = null;
    $strPol = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz";
    $max = strlen($strPol)-1;
    for($i=0;$i<$length;$i++){
        $str.=$strPol[rand(0,$max)];//rand($min,$max)生成介于min和max两个数之间的一个随机整数
    }
    return $str;
}
//判断是否是客户001账套
 function checkVersionIs001(){
    $regop=RegOp::getInstance();
    $crmversion=$regop->GetVersionNo();
    if($crmversion>=55&&$crmversion<=58){
        return $crmversion;
    }
    return 0;
}//D:\wamp\www\ldcrm\appCommon\appCommon.php
//过滤emoji表情 20180224  	0032974: 企业微信：在企业微信中邀请用户，用户未加入之前，在CRM系统看成员管理，用户姓名显示为空白
function filterEmoji($str)
{
    $str = preg_replace_callback(
        '/./u',
        function (array $match) {
            return strlen($match[0]) >= 4 ? '' : $match[0];
        },
        $str);

    return $str;
}
/**
 * GET 请求
 * @param string $url
 */
function CurlGet($url){
    global $LINGDANGCURLOPT_PROXYINFO;
    if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'])){
        $curlopt_porxy = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'];
        if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'])){
            $curlopt_porxyport = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'];
        }
        if(!empty($curlopt_porxy)){
            $newurl  = $curlopt_porxy;
            if(!empty($curlopt_porxyport)){
                $newurl  .= ':'.$curlopt_porxyport;
            }
            $newurl .= '/crmprox/index.php?getproturl='.urlencode($url);
            $url = $newurl;
        }
    }

    $oCurl = curl_init();
    if(stripos($url,"https://")!==FALSE){
        curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($oCurl, CURLOPT_SSLVERSION, 1); //CURL_SSLVERSION_TLSv1
    }
    curl_setopt($oCurl, CURLOPT_URL, $url);
    curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt($oCurl, CURLOPT_VERBOSE, 1);
    curl_setopt($oCurl, CURLOPT_HEADER, 1);
    curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 100);
    curl_setopt($oCurl, CURLOPT_TIMEOUT, 100);

    // $sContent = curl_exec($oCurl);
    // $aStatus = curl_getinfo($oCurl);
    $sContent = ExecCURL($oCurl);
    curl_close($oCurl);

    return $sContent;
}
/**
 * POST 请求
 * @param string $url
 * @param array $param
 * @param boolean $post_file 是否文件上传
 * @return string content
 */
function CurlPost($url,$param,$post_file=false){
    $oCurl = curl_init();

    if(stripos($url,"https://")!==FALSE){
        curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($oCurl, CURLOPT_SSLVERSION, 1); //CURL_SSLVERSION_TLSv1
    }
    if(PHP_VERSION_ID >= 50500 && class_exists('\CURLFile')){
        $is_curlFile = true;
    }else {
        $is_curlFile = false;
        if (defined('CURLOPT_SAFE_UPLOAD')) {
            curl_setopt($oCurl, CURLOPT_SAFE_UPLOAD, false);
        }
    }

    if($post_file) {
        if($is_curlFile) {
            foreach ($param as $key => $val) {
                if(isset($val["tmp_name"])){
                    $param[$key] = new \CURLFile(realpath($val["tmp_name"]),$val["type"],$val["name"]);
                }else if(substr($val, 0, 1) == '@'){
                    $param[$key] = new \CURLFile(realpath(substr($val,1)));
                }
            }
        }
        $strPOST = $param;
    }else{
        $strPOST = json_encode($param,JSON_UNESCAPED_UNICODE);//20180109 gyq 不转义中文
    }

    curl_setopt($oCurl, CURLOPT_URL, $url);
    curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt($oCurl, CURLOPT_POST,true);
    curl_setopt($oCurl, CURLOPT_POSTFIELDS,$strPOST);
    curl_setopt($oCurl, CURLOPT_VERBOSE, 1);
    curl_setopt($oCurl, CURLOPT_HEADER, 1);

    // $sContent = curl_exec($oCurl);
    // $aStatus  = curl_getinfo($oCurl);

    $sContent = ExecCURL($oCurl);
    curl_close($oCurl);

    return $sContent;
}
function _CurlPost($url,$body){
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
/**
 * 执行CURL请求，并封装返回对象
 */
function ExecCURL($ch){
    $response = curl_exec($ch);
    $error    = curl_error($ch);
    $result   = array( 'header' => '',
        'content' => '',
        'curl_error' => '',
        'http_code' => '',
        'last_url' => '');

    if ($error != ""){
        $result['curl_error'] = $error;
        return $result;
    }

    $header_size = curl_getinfo($ch,CURLINFO_HEADER_SIZE);
    $result['header'] = str_replace(array("\r\n", "\r", "\n"), "<br/>", substr($response, 0, $header_size));
    $result['content'] = substr( $response, $header_size );
    $result['http_code'] = curl_getinfo($ch,CURLINFO_HTTP_CODE);
    $result['last_url'] = curl_getinfo($ch,CURLINFO_EFFECTIVE_URL);
    $result["base_resp"] = array();
    $result["base_resp"]["ret"] = $result['http_code'] == 200 ? 0 : $result['http_code'];
    $result["base_resp"]["err_msg"] = $result['http_code'] == 200 ? "ok" : $result["curl_error"];

    return $result;
}
//editor:gyq_74 reason:自助服务平台_客户注册 客户保存需要用到这个方法  2018/7/26 15:20 
function initUserPrivileges($userid){
    global $current_user;
    $current_user = new Users();
    if(!is_numeric($userid)){
        ConvertTojsonString(-1,[],'userid  error');
    }
    //$current_user->retrieve_entity_info($userid, 'Users');//默认当前登录用户为管理员；
    //登录微信自动生成相应登录文件
    $afile = fopen(globalStatic::$root_directory . "user_privileges/user_language_" . $userid . ".php", "w");
    $txt = "<?php \$languageType='zh'; ?>";
    fwrite($afile, $txt);
    fclose($afile);
    //self::cacheCorpDetail();
    if(!file_exists(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php'))
    {
        require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
        createUserPrivilegesfile($userid);
    }
    //require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
    //createUserPrivilegesfile($userid);
    //初始化用户权限
    $current_user->retrieveCurrentUserInfoFromFile($userid);
    //userid没值 赋值一下  zxm 20230807 小程序商城previewOrder方法报错 因为$current_user->id没值
    $current_user->id=$userid;
}

//针对指定时间，将时间范围标识转换为开始结束日期数组
//editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/28 15:20
function rangeTimeToDate($timemark,$r_time){
    $time=strtotime(date('Y-m-d',$r_time));
    switch($timemark){
        case 'today':
            $startdate = date('Y-m-d',$r_time);
            $enddate = date('Y-m-d',$r_time);
            break;
        case 'yesterday':
            $startdate = date("Y-m-d",$r_time-24*60*60);
            $enddate = date("Y-m-d",$r_time-24*60*60);
            break;
        case 'thisweek':
        case 'week':
            $startdate = date("Y-m-d",mktime(0, 0, 0,date("m",$r_time),date("d",$r_time)-date_week($r_time),date("Y",$r_time)));
            $enddate = date("Y-m-d",mktime(23,59,59,date("m",$r_time),date("d",$r_time)-date_week($r_time)+6,date("Y",$r_time)));
            break;
        case 'lastweek':
            //editor:gyq_90 reason:日志日期修改为自定义选择日期 2018/12/6 16:40
            $date = date("Y-m-d",$r_time);  //当前日期
            $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
            $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
            $d = $w ? $w - $first : 6;  //如果是周日 -6天
            $nowdate  = date("Y-m-d", strtotime("$date -".$d." days"));
            $startdate  = date("Y-m-d", strtotime("$nowdate - 7 days")); //上周开始时间
            $enddate    = date("Y-m-d", strtotime("$startdate +6 days"));  //上周结束时间
            break;
        case 'lastlastweek':
            //editor:gyq_90 reason:日志日期修改为自定义选择日期 2018/12/6 16:40
            $date = date("Y-m-d",$r_time);  //当前日期
            $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
            $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
            $d = $w ? $w - $first : 6;  //如果是周日 -6天
            $nowdate  = date("Y-m-d", strtotime("$date -".$d." days"));
            $startdate  = date("Y-m-d", strtotime("$nowdate - 14 days")); //上上周开始时间
            $enddate    = date("Y-m-d", strtotime("$startdate + 6 days"));  //上上周结束时间
            break;
        case 'lastmonth':
            $startdate = date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-1).'-01'));
            $enddate = date('Y-m-d',strtotime("$startdate +1 month -1 day"));
            break;
        case 'lastlastmonth':
            $startdate = date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-2).'-01'));
            $enddate = date('Y-m-d',strtotime("$startdate +1 month -1 day"));
            break;
        case 'thismonth':
        case 'month':
            $startdate = date("Y-m-d",mktime(0, 0, 0,date("m",$time),1,date("Y",$time)));
            $enddate = date("Y-m-d",mktime(23,59,59,date("m",$time),date("t",$time),date("Y",$time)));
            break;
        case 'thisyear':
            $startdate = date('Y-01-01',$time);
            $enddate = date('Y-12-31',$time);
            break;
        case 'all':
        default:
            $startdate = '2000-01-01';
            $enddate = date('2050-12-31',$time);
            break;

    }
    return array($startdate,$enddate);
}
//editor:gyq_20190318 reason:周日期改为从周一开始
function date_week($r_time){
    //w - 数字型的星期几,如: "0" (星期日) 至 "6" (星期六)
    //            //0036585: 企业微信>灵当CRM>工作汇报>写周计划>选择日期：,当服务器的时间为周日的时候,企业微信端新建周报选择本周/上周,存在日期区间错误的情况.
    $number = date("w",$r_time);

    if($number==0){
        $number = 6;
    }else{
        $number--;
    }
    return $number;
}
//editor:gyq_89 reason:小程序有分录的模块暂隐藏新增按钮 2018/12/6 13:13
function judge_productdetail($r_module){
    return false;
}


 /**
  * 是否为客户 001服务器
  * */
function isKehu001ServerPc(){
    //return 'no';
    $direct_file=globalStatic::$root_directory;
    $prev_dirname=pathinfo($direct_file,PATHINFO_DIRNAME);
	$serverself=$_SERVER['PHP_SELF'];
    $http_host=$_SERVER['HTTP_HOST'];
    
   if(substr($prev_dirname,-1)=="/")
	{
	
	}
	else
	{
			$prev_dirname.="/";
	}

    if( (strtolower($http_host)=='kehu001.com'&&(stripos($serverself,'weixin')!==false||stripos($serverself,'kh')!==false))||file_exists($prev_dirname."login/cls_weixinInfo.php")){
       
        return 'yes';
    }
    else {
        return 'no'; 
    }
    
    /*
    if(strpos($http_host,"http://")!==false&&strpos($http_host,"http://")<=5)
    {
        $http_host=substr($http_host,strlen("http://"));

    }
   if(strpos($http_host,"https://")!==false&&strpos($http_host,"https://")<=5)
    {
        $http_host=substr($http_host,strlen("https://"));

    }
    if(strpos($http_host,"www.")!==false&&strpos($http_host,"www.")<=5)
    {
        $http_host=substr($http_host,strlen("www."));

    }


    if( strtolower($http_host)=='kehu001.com'){
        return 'yes';
    }
    else
    {
        return 'no';

    }
    */

}
//editor:gyq_155 reason:钉钉考勤同步  2019/10/27 15:33 ID1000624 
function object_array($array) {
    if(is_object($array)) {
        $array = (array)$array;
    }
    if(is_array($array)) {
        foreach($array as $key=>$value) {
            $array[$key] = object_array($value);
        }
    }
    return $array;
}
//毫秒格式化为日期
function dateMilliscond($rTime){
    $date = date('Y-m-d H:i:s', substr($rTime,0,-3));
    return $date;
}
//editor:gyq_165 reason:检测链接是否正确   2019/12/31 16:06
function checkAuthLink($rCorpLink){
    $corp_link = rtrim($rCorpLink,'/');
    if(substr($corp_link,0,7) != 'http://'){
        if(substr($corp_link,0,8) != 'https://'){
            $corp_link = 'http://'.$corp_link;
        }
    }
    if(substr($corp_link,-4,4)=='.php' || strpos($corp_link,'?')!==false){
        return false;
    }else{
        return $corp_link;
    }
}
//editor:gyq_20200227 reason:避免kehu001没有dingtalk目录，也走了event_model。故将是否安装钉钉抽出event_model
function judgeDingTalkInstall(){
    global $adb;
    $sql = 'select para_one,para_two,para_three,time,para_content from ld_wx_config where name = \'dingtalk_setting\'';
    $result = $adb->pquery($sql,array());
    $num = $adb->num_rows($result);
    if($num > 0){
        //editor:gyq_165 reason:修改钉钉参数格式   2019/12/26 15:06
        $para_content_list =  (array)Zend_Json::decode( $adb->query_result($result,0,'para_content'));
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
                $login_appid = $paraValue;
            }elseif ($paraName=='login_secret'){
                $login_secret = $paraValue;
            }elseif ($paraName=='corpid'){
                $corpid = $paraValue;
            }elseif ($paraName=='key'){
                $appkey = $paraValue;
            }elseif ($paraName=='secret'){
                $appsecret = $paraValue;
            }elseif ($paraName=='agentid'){
                $agentid = $paraValue;
            }elseif ($paraName=='login_url'){
                $login_url = $paraValue;
            }
        }
    }
 
    if(empty($corpid)||empty($appkey)||empty($agentid)||empty($appsecret)){
        return false;
    }else{
        return true;
    }
}
//editor:gyq_169 reason:删除腾讯云存储桶中的指定文件   2020/3/2 13:33
function deleteQcloudFile($rFileList){
    require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
    $sts = new QcloudSTS();
    $sts->deleteCloudFile($rFileList);
}
//下载云端文件
//！！！！注意：$_GET['temp_saved_filename']是输出文件名,需要在调用时外部定义
function downloadCloudFile($url){
    //$url = 'https://public-filelist.oss-cn-hangzhou.aliyuncs.com/MicrosoftOffice2010%E7%A0%B4%E8%A7%A3%E7%89%88.zip';

    $url=urldecode($url);
  
    $ch  = curl_init($url);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
     curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_BINARYTRANSFER, true);
    //curl_setopt($ch, CURLOPT_HTTPHEADER, ['user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36']);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 600);
    curl_setopt($ch, CURLOPT_TIMEOUT, 3600);
    curl_setopt($ch, CURLOPT_BUFFERSIZE, 20971520);
    $flag=0;
 
    curl_setopt($ch, CURLOPT_WRITEFUNCTION, function($ch ,$str) use (&$flag){
        $len = strlen($str);
        $flag++;
        $type = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
        if($flag==1){
            $size = curl_getinfo($ch, CURLINFO_CONTENT_LENGTH_DOWNLOAD);
            $type = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
            $httpcode  = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            header("HTTP/1.1 ".$httpcode);
            header("Content-Type: ".$type);
            header("Content-Length: ".$size);
            header('Content-Transfer-Encoding: binary');
            header('Cache-Control:max-age=2592000');
            header('Content-Disposition: attachment; filename="'.$_GET['temp_saved_filename'].'"');
        }
      echo $str;
        return $len;
    });
    $output = curl_exec($ch);
   curl_close($ch);
  
//   exit();
  //
}
//duan 20220930 获取移动端语言类型
function getMobileLanguageType($userid,$environment=''){
    global $weixin_user,$MobileLanguageType;
    //如果绑定用户，或切换语言类型时，按照请求中的语言类型进行设置
    if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
        $MobileLanguageType = $_REQUEST['mobile_language_type'];
        return $MobileLanguageType;
    }
    //参数为空时，从全局变量获取移动端环境
    if(empty($environment)&&!empty($weixin_user)){
        $environment = $weixin_user->environment;
    }else{
        $MobileLanguageType = 'zh';
        return $MobileLanguageType;
    }
    //根据移动端环境判断登陆方式
    $login_type = '';
    switch($environment){
        case 'weixinh5':$login_type = 'qiyeweixin';break; //企业微信
        case 'weixin':$login_type = 'mini_weixin';break; //小程序
        case 'dingtalk':$login_type = 'dingtalk';break; //钉钉
        case 'yunzhijia':$login_type = 'yunzhijia';break; //云之家
        case 'fanwei':$login_type = 'fanwei';break; //泛微
        case 'app':$login_type = 'app';break;//源生app
        case 'zhiyuan':$login_type = 'zhiyuan';break;//致远
        default:$login_type = 'other';break; //其他登陆方式，例如oem小程序，表单码等
    }
    
    //其他登陆方式默认使用中文
    if(empty($login_type)||$login_type == 'other'){
        $MobileLanguageType = 'zh';
        return $MobileLanguageType;
    }
    
    //获取移动端语言类缓存
    $AllMobileLanguageArr = CreateMobileLanguageCache();
    
    //根据用户id和登陆方式获取移动端语言类型
    if(isset($AllMobileLanguageArr[$userid])){
        if(isset($AllMobileLanguageArr[$userid][$login_type])){
            $languagetype = $AllMobileLanguageArr[$userid][$login_type];
            $MobileLanguageType = $languagetype;
        }else{
            //如果此种登陆方式未在缓存文件中，则是第一次使用此种方式登陆，默认使用中文
            $MobileLanguageType = 'zh';
        }
    }else{
        //如果当前用户不在缓存文件中，则尝试重新生成缓存文件，如果还没有当前用户，则默认使用中文
        $AllMobileLanguageArr = CreateMobileLanguageCache('yes');
        if(isset($AllMobileLanguageArr[$userid])){
            if(isset($AllMobileLanguageArr[$userid][$login_type])){
                $languagetype = $AllMobileLanguageArr[$userid][$login_type];
                $MobileLanguageType = $languagetype;
            }else{
                //如果此种登陆方式未在缓存文件中，则是第一次使用此种方式登陆，默认使用中文
                $MobileLanguageType = 'zh';
            }
        }else{
            $MobileLanguageType = 'zh';
        }
    }
    return $MobileLanguageType; 
}

//duan 20220930 生成移动端用户语言设置缓存,包含所有用户所有移动端,$reset 为yes时表示重新生成缓存
function CreateMobileLanguageCache($reset='no'){
    global $adb;
    $cache_key = 'mobile_language_cache';
    $AllMobileLanguageArr = cache($cache_key);
    if(empty($AllMobileLanguageArr)||$reset=='yes'){
        unsetCache($cache_key);
        $login_type_arr = array('qiyeweixin','mini_weixin','dingtalk','yunzhijia','app','fanwei','zhiyuan');
        $login_type_str = implode(',',$login_type_arr);
        $default_logintype = 'qiyeweixin';
        $default_languagetype = 'zh';
        //查询所有用户在多个移动端的最新登陆日志
        $query="SELECT ld_users.id,ld_loginhistory.languagetype,ld_loginhistory.login_type
                FROM ld_users
                LEFT JOIN (
                	SELECT user_name,MAX(login_id) AS latest_id
                	FROM ld_loginhistory
                	WHERE FIND_IN_SET(login_type,'$login_type_str')
                	GROUP BY user_name,login_type
                	ORDER BY user_name
                ) as tmp_data on ld_users.user_name = tmp_data.user_name
                LEFT JOIN ld_loginhistory on tmp_data.latest_id = ld_loginhistory.login_id
                ORDER BY ld_users.id;";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        $AllMobileLanguageArr = array();
        for($i=0;$i<$num_rows;$i++){
            $userid = $adb->query_result($result,$i,'id');
            $languagetype = $adb->query_result($result,$i,'languagetype');
            $login_type = $adb->query_result($result,$i,'login_type');
            if(empty($login_type)){
                $login_type = $default_logintype;
            }
            if(empty($languagetype)){
                $languagetype = $default_languagetype;
            }
            $AllMobileLanguageArr[$userid][$login_type] = $languagetype;
        }
        cache($cache_key,$AllMobileLanguageArr);
    }
    return $AllMobileLanguageArr;
}
//获取移动端翻译文本
function getMobileFixedLabel($labebol){
    global $MobileLanguageType,$current_user;
    
    if(empty($labebol))
    {
        return '';
    }
    
    if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
        //移动端切换语言类型时传值
        $MobileLanguageType = $_REQUEST['mobile_language_type'];
    }else{
        if(empty($MobileLanguageType)){
            if(!empty($current_user)){
                $userid = $current_user->id;
                $MobileLanguageType = getMobileLanguageType($userid);
            }else{
                $MobileLanguageType = 'zh';
            }
        }
    }
    
	static $cachelangfixedlabelinfo;
    static $cur_language;
    static $cachelangfixedlabelinfo_count;
    
	if(!empty($cachelangfixedlabelinfo) && isset($cachelangfixedlabelinfo[$labebol]) && $cur_language == $MobileLanguageType)
		return $cachelangfixedlabelinfo[$labebol];
        
    
    $cur_language = $MobileLanguageType;
    $languageType = $MobileLanguageType;
    
    if(!file_exists(globalStatic::$root_directory.'include/language/'.$languageType.'.php'))
    {
        setMobileFixedLable($languageType);
    }
	require(globalStatic::$root_directory.'include/language/'.$languageType.'.php');
  
        
	$cachelangfixedlabelinfo = $arrFixedLabel;
	if(isset($cachelangfixedlabelinfo[$labebol]))
		return $cachelangfixedlabelinfo[$labebol];
    else
    {     
        
        if(!is_array($cachelangfixedlabelinfo_count))
        {
            $cachelangfixedlabelinfo_count=[];
            
        }
        if(!array_key_exists($labebol,$cachelangfixedlabelinfo_count))
        {
            $cachelangfixedlabelinfo_count[$labebol]=1;
        }
        else
        {
            $cachelangfixedlabelinfo_count[$labebol]+=1;
        }
        if($cachelangfixedlabelinfo_count[$labebol]>=2)
        { 
            return $labebol;
        } 
        setMobileFixedLable($languageType);
        require(globalStatic::$root_directory.'include/language/'.$languageType.'.php');
        if(array_key_exists($labebol,$arrFixedLabel))//公海操作日志中有没有翻译的字符串需要原样输出
            return $arrFixedLabel[$labebol];
    }
	return $labebol;
}

//根据语言类型生成语言缓存文件
function setMobileFixedLable($MobileLanguageType)
{
    global $adb;
    $languageType= $MobileLanguageType;
    // @include('dataCache/tabdatas/tabdata.php');
    @include('dataCache/tabdatas/tab_language.php');
    $tabsql='select ld_tranlabel.fieldlabel,ld_tab.name from ld_tab inner join ld_tranlabel 
        on ld_tab.tabid=ld_tranlabel.relateid
        where languagetype=? and  ld_tranlabel.trantable=? and ld_tab.presence in(0,2)';
    $tab_result=$adb->pquery($tabsql,array($languageType,'ld_tab'));
    for($tab_i=0;$tab_i<$adb->num_rows($tab_result);$tab_i++)
    {
        $tab_info_array[$adb->query_result($tab_result,$tab_i,'name')]=$adb->query_result($tab_result,$tab_i,'fieldlabel');
    }
    
    $sql='select labelbol,fieldlabel from ld_desk where languagetype=? and labeltype=? ';
    $result=$adb->pquery($sql,array($languageType,'fixedstr'));
    
    $fileName=globalStatic::$root_directory.'include/language/'.$languageType.'.php';
    
    $haveSearchModule=array();
    $haveSearchField=array();

    
    $newbuf = '';
    $newbuf .="<?php\n\n". '$arrFixedLabel=array( ';
    $rows=$adb->num_rows($result);
    
    for($i=0;$i<$rows;$i++)
    {
        $labelbol=$adb->query_result($result,$i,'labelbol');
        $arrlabels=array();
        $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
        if(strpos($fieldlabel,'{Var}')) //对于同时使用了两种插入格式的字符串，例如：'在所有{$Accounts.Accounts}中进行查重，最多只显示符合条件的前{Var}条数据。'
            $fieldlabel = str_replace('{Var}','[Var]',$fieldlabel);//切换{Var}的括弧格式避免分割
        $arrlabels=explode('{$',$fieldlabel);
        $label=$arrlabels[0];
        
        for($j=1;$j<sizeof($arrlabels);$j++)
        {
            $arrrelateobj=explode('}',$arrlabels[$j]);
            $expdian=explode('.',$arrrelateobj[0]);
            $module=$expdian[0];//获取弹出框所在模块
            //$arrrelateobj=explode('}',$expdian[1]);//获取弹出框所在模块名称或标签名称
            
            $relateobj=$expdian[1];
            if(is_array($haveSearchField[$module])&&array_key_exists($relateobj,$haveSearchField[$module]))
            {
                $label.=$haveSearchField[$module][$relateobj];
            }
            else  if(is_array($tab_info_array)&&array_key_exists($relateobj,$tab_info_array))
            {
                $label.=$tab_info_array[$relateobj];
            }
            else
            {
                $tabid=getTabid($module);
                $sql='select fieldlabel from ld_tranlabel where languagetype=? and trantable=\'ld_field\' and
                relateid =(select fieldid from ld_field where  tabid=?  and fieldname=?) and tabid=?';
                
                $resultt=$adb->pquery($sql,array($languageType,$tabid,$relateobj,$tabid));
                if($adb->num_rows($resultt)>0)
                {
                    $haveSearchField[$module][$relateobj]=$adb->query_result($resultt,0,0);
                    $haveSearchModule[$relateobj]=$adb->query_result($resultt,0,0);
                    $label.=$adb->query_result($resultt,0,0);
                }
            }
            $label.=$arrrelateobj[1];
        }
        if(strpos($label,'[Var]'))
            $label = str_replace('[Var]','{Var}',$label);//切换回括弧格式保持输出
        if(!empty($label))
            $fieldlabel=$label;
        else if(sizeof($arrlabels)>0)
        {
            $fieldlabel='';
        }
        $fieldlabel=str_replace('"','\"',$fieldlabel);
        $newbuf .="\n '$labelbol'=>".'"'.$fieldlabel.'",';
    }
    $newbuf .= ");\n?>";
    file_put_contents(globalStatic::$root_directory. "dataCache/createlanend.txt",date("Y-m-d H:i:s"));
    $handle = fopen($fileName, 'w+');
    fputs($handle, $newbuf);
    fclose($handle);
    @unlink(globalStatic::$root_directory. "dataCache/createlanend.txt");
}

//根据语言类型获取移动端翻译文本
function getMobileFixedLabelBylanguage($labebol,$languageType){
    if(empty($labebol))
    {
        return '';
    }
    if(!file_exists(globalStatic::$root_directory.'include/language/'.$languageType.'.php'))
    {
        setMobileFixedLable($languageType);
    }
	require(globalStatic::$root_directory.'include/language/'.$languageType.'.php');
	if(isset($arrFixedLabel[$labebol]))
		return $arrFixedLabel[$labebol];
    else
    {     
        return $labebol;
    }
}
//通用方法，将移动端需要的字符串转换后生成数组,
//留个type用来以后做特殊判断
function TransFieldlabel($label_arr,$type='default'){
    //每个页面都可能用到的公共字符串，比如：加载中...、温馨提示、取消、确认、设置、是、否
    $common_label_arr = array('LOADING','WARMPROMPT','CANCEL','APPSETTINGS','CONFIRMED','HOMEPAGEAPP');
    //公共数组和特殊数组做交集
    if($type == 'no'){ //不需要公共字符串
        $all_label_arr = array_unique($label_arr);
    }else{
        $all_label_arr = array_merge($label_arr,$common_label_arr);
        $all_label_arr = array_unique($all_label_arr);
    }
    $fieldlabel_arr = array();
    foreach($all_label_arr as $tmp_label){
        $fieldlabel_arr[$tmp_label] = getMobileFixedLabel($tmp_label);
    }
    return $fieldlabel_arr;
}
//获取移动端登陆绑定界面的翻译，比较特殊，需要中英文都给，并且企业微信、钉钉、云之家的index都需要加
function getRegisterFixedlabel($enorzh){
    $register_arr = array();
    $register_arr['settings']['system']['enorzh'] =$enorzh;//移动端判断是否需要显示中英文切换
    $register_arr['settings']['system']['languagetype'] ='zh';
    $register_label_arr = array(
        'ENTERUSERACCOUNT', //请输入用户账号
        'ENTERPASSWORD', //请输入密码
        'RELATIONAL', //关联
        'ACCOUNTCANOTEMPTY', //账号不能为空
        'WARMPROMPT', //温馨提示
        'LOADING',//加载中
        'CONFIRMED',//确定
        'CANCEL',//取消
    );
    foreach($register_label_arr as $tmp_label){
        $register_arr['arrFixedLabel'][$tmp_label] = getMobileFixedLabel($tmp_label);
        if($enorzh == 'yes'){
            $register_arr['arrFixedLabel_en'][$tmp_label] = getMobileFixedLabelBylanguage($tmp_label,'en');
        }
    }
    return $register_arr;
}
/* 
duan 20221014 组合字符串通用做法，先在后台分割，再传到前端进行组合
例如将 请选择%dM以内的图片（Please select pictures within %dM） 直接拆分成两个翻译字符串的话，会出现中英文意思不同的问题
所以选择以 %d 进行分隔，分别给两个字符串加上序号，放在移动端再进行组合
$key_str:分割依据,例如 '%d' ，$labelbol:需要分割的字符串标签, 
$fixedlabel_arr:包含当前页面所有字符串的数组，分割后的字符串会按序号重新加到数组里
*/
function CombineLabelSolution($key_str,$labelbol,$fixedlabel_arr){
    if(!isset($fixedlabel_arr[$labelbol])||empty($fixedlabel_arr[$labelbol])){
        return $fixedlabel_arr;
    }
    $tmp_fixedlabel = $fixedlabel_arr[$labelbol];
    $tmp_fixedlabel_arr = explode($key_str,$tmp_fixedlabel);
    $count = 1;
    foreach($tmp_fixedlabel_arr as $tmp_str){
        $fixedlabel_arr[$labelbol.$count] = $tmp_str;
        $count ++;
    }
    unset($fixedlabel_arr[$labelbol]);
    return $fixedlabel_arr;
}
/**
 * edit:xll 2023/02/08
 * 根据移动deploy_type端系统参数
 * */
function getAppsys_deploy($key, $id = 'not_zero'){
    static $deployarr;
    global $adb, $current_user;
    if($id == 'not_zero')
    {
        $id = $current_user->id;
    }
    if(!empty($deployarr) && isset($deployarr[$key]) && isset($deployarr[$key][$id])) 
    {        
        return $deployarr[$key][$id];
    }
    $deployarr = array();
    $sql = 'select userid, deploy_value, deploy_type, description, is_open from ld_appsystem ORDER BY id';
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $userid = $adb->query_result($result,$i,'userid');
		$deploy_value = $adb->query_result($result,$i,'deploy_value');
		$deploy_type = $adb->query_result($result,$i,'deploy_type');
		$description = $adb->query_result($result,$i,'description');
		$is_open = $adb->query_result($result,$i,'is_open');
		$deployarr[$deploy_type][$userid] = array('deploy_value'=>$deploy_value,'deploy_type'=>$deploy_type,'description'=>$description,'is_open'=>$is_open);
	}
    if(isset($deployarr[$key][$id]))
		return $deployarr[$key][$id];
	return '';
}

//liushuai 20230518 XUQIU1001398 服务小程序，增加英文版
function setFuWuLable($MobileLanguageType)
{
    global $adb;
    // @include('dataCache/tabdatas/tabdata.php');
    @include('dataCache/tabdatas/tab_language.php');
    $tabsql='select ld_tranlabel.fieldlabel,ld_tab.name from ld_tab inner join ld_tranlabel
        on ld_tab.tabid=ld_tranlabel.relateid
        where languagetype=? and  ld_tranlabel.trantable=? and ld_tab.presence in(0,2)';
    $tab_result=$adb->pquery($tabsql,array($MobileLanguageType,'ld_tab'));
    for($tab_i=0;$tab_i<$adb->num_rows($tab_result);$tab_i++)
    {
        $tab_info_array[$adb->query_result($tab_result,$tab_i,'name')]=$adb->query_result($tab_result,$tab_i,'fieldlabel');
    }

    $sql='select labelbol,fieldlabel from ld_desk where languagetype=? and labeltype=? ';
    $result=$adb->pquery($sql,array($MobileLanguageType,'fuwu'));

    $fileName=globalStatic::$root_directory.'include/language/'.$MobileLanguageType.'_fuwu.php';

    $haveSearchModule=array();
    $haveSearchField=array();

    $handle = fopen($fileName, 'w+');

    $newbuf = '';
    $newbuf .="<?php\n\n". '$arrFixedLabel=array( ';
    $rows=$adb->num_rows($result);

    for($i=0;$i<$rows;$i++)
    {
        $labelbol=$adb->query_result($result,$i,'labelbol');
        $arrlabels=array();
        $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
        if(strpos($fieldlabel,'{Var}')) //对于同时使用了两种插入格式的字符串，例如：'在所有{$Accounts.Accounts}中进行查重，最多只显示符合条件的前{Var}条数据。'
            $fieldlabel = str_replace('{Var}','[Var]',$fieldlabel);//切换{Var}的括弧格式避免分割
        $arrlabels=explode('{$',$fieldlabel);
        $label=$arrlabels[0];

        for($j=1;$j<sizeof($arrlabels);$j++)
        {
            $arrrelateobj=explode('}',$arrlabels[$j]);
            $expdian=explode('.',$arrrelateobj[0]);
            $module=$expdian[0];//获取弹出框所在模块
            //$arrrelateobj=explode('}',$expdian[1]);//获取弹出框所在模块名称或标签名称

            $relateobj=$expdian[1];
            if(is_array($haveSearchField[$module])&&array_key_exists($relateobj,$haveSearchField[$module]))
            {
                $label.=$haveSearchField[$module][$relateobj];
            }
            else  if(is_array($tab_info_array)&&array_key_exists($relateobj,$tab_info_array))
            {
                $label.=$tab_info_array[$relateobj];
            }
            else
            {
                $tabid=getTabid($module);
                $sql='select fieldlabel from ld_tranlabel where languagetype=? and trantable=\'ld_field\' and
                relateid =(select fieldid from ld_field where  tabid=?  and fieldname=?) and tabid=?';

                $resultt=$adb->pquery($sql,array($MobileLanguageType,$tabid,$relateobj,$tabid));
                if($adb->num_rows($resultt)>0)
                {
                    $haveSearchField[$module][$relateobj]=$adb->query_result($resultt,0,0);
                    $haveSearchModule[$relateobj]=$adb->query_result($resultt,0,0);
                    $label.=$adb->query_result($resultt,0,0);
                }
            }
            $label.=$arrrelateobj[1];
        }
        if(strpos($label,'[Var]'))
            $label = str_replace('[Var]','{Var}',$label);//切换回括弧格式保持输出
        if(!empty($label))
            $fieldlabel=$label;
        else if(sizeof($arrlabels)>0)
        {
            $fieldlabel='';
        }
        $fieldlabel=str_replace('"','\"',$fieldlabel);
        $newbuf .="\n '$labelbol'=>".'"'.$fieldlabel.'",';
    }
    $newbuf .= ");\n?>";
    fputs($handle, $newbuf);
    fclose($handle);
}
function getFuWuLabelBylanguage($labebol,$languageType){
    if(empty($labebol))
    {
        return '';
    }
    if(!file_exists(globalStatic::$root_directory.'include/language/'.$languageType.'_fuwu.php'))
    {
        setFuWuLable($languageType);
    }
    require(globalStatic::$root_directory.'include/language/'.$languageType.'_fuwu.php');
    if(isset($arrFixedLabel[$labebol]))
        return $arrFixedLabel[$labebol];
    else
        return $labebol;
}
//获取服务小程序的Labelbol的值 ls 20230519
function getFuWuLabel($labebol){
    global $MobileLanguageType;

    if(empty($labebol))
    {
        return '';
    }

    if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
        //移动端切换语言类型时传值
        $MobileLanguageType = $_REQUEST['mobile_language_type'];
    }else{
        if(empty($MobileLanguageType)){
            $MobileLanguageType = getFuWuLanguageType();
        }
    }

    static $cachelangfixedlabelinfo;
    static $cachelangfixedlabelinfo_count;

    if(!empty($cachelangfixedlabelinfo) && isset($cachelangfixedlabelinfo[$labebol]))
        return $cachelangfixedlabelinfo[$labebol];

    if(!file_exists(globalStatic::$root_directory.'include/language/'.$MobileLanguageType.'_fuwu.php'))
    {
        setFuWuLable($MobileLanguageType);
    }
    require(globalStatic::$root_directory.'include/language/'.$MobileLanguageType.'_fuwu.php');


    $cachelangfixedlabelinfo = $arrFixedLabel;
    if(isset($cachelangfixedlabelinfo[$labebol]))
        return $cachelangfixedlabelinfo[$labebol];
    else
    {
        if(!is_array($cachelangfixedlabelinfo_count))
        {
            $cachelangfixedlabelinfo_count=[];
        }
        if(!array_key_exists($labebol,$cachelangfixedlabelinfo_count))
        {
            $cachelangfixedlabelinfo_count[$labebol]=1;
        }
        else
        {
            $cachelangfixedlabelinfo_count[$labebol]+=1;
        }
        if($cachelangfixedlabelinfo_count[$labebol]>=2)
        {
            return $labebol;
        }
        setFuWuLable($MobileLanguageType);
        require(globalStatic::$root_directory.'include/language/'.$MobileLanguageType.'_fuwu.php');
        if(array_key_exists($labebol,$arrFixedLabel))//公海操作日志中有没有翻译的字符串需要原样输出
            return $arrFixedLabel[$labebol];
    }
    return $labebol;
}

//获取用户的语言类型
function getFuWuLanguageType(){
    global $adb,$weixin_user,$MobileLanguageType;
    //如果绑定用户，或切换语言类型时，按照请求中的语言类型进行设置
    if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
        $MobileLanguageType = $_REQUEST['mobile_language_type'];
        return $MobileLanguageType;
    }

    //判断是否绑定过
    $openid = $_REQUEST['userid'];
    if(empty($openid)){
        $MobileLanguageType = 'zh';
        return $MobileLanguageType;
    }
    $user_sql = 'select languagetype from ld_weixinmp_users where openid=? order by id desc limit 1';
    $user_result = $adb->pquery($user_sql,array($openid));
    $nums = $adb->num_rows($user_result);
    if($nums > 0){
        //绑定过
        $lastlanguagetype = $adb->query_result($user_result,0,'languagetype');
        $MobileLanguageType = !empty($lastlanguagetype)?$lastlanguagetype:'zh';
    }else{
        //未绑定过
        $MobileLanguageType = 'zh';
    }

    return $MobileLanguageType;
}

//获取服务小程序登陆绑定界面、手机号登录注册的翻译，比较特殊，需要中英文都给;  扩展其他想要返回翻译的labelbol,格式为一维数组
function getFuWuLabelExtend($enorzh='',$labelbol_arr=''){
    if (empty($enorzh) || !in_array($enorzh,array('yes','no'))) {
        include_once(globalStatic::$root_directory.'Register/RegOp.php');
        $reg=RegOp::getInstance();
        $enorzh=$reg->isEnorZh();
    }
    $all_arr = array();
    $all_arr['settings']['system']['enorzh'] =$enorzh;//移动端判断是否需要显示中英文切换/是否授权中英文
    $all_arr['settings']['system']['languagetype'] ='zh';
    $all_label_arr = array(
        'OnlineService',//在线服务
        'EnterPhoneNumber',//请输入手机号码
        'EnterVerificationCode',//请输入验证码
        'GetVerificationCode',//获取验证码
        'SResend',//s后重新发送
        'Tips',//温馨提示
        'Tips1BindVerification',//绑定时会验证手机号码和验证码
        'Tips2CodeMaximum5Times',//当日最多可获取5次验证码，若无法接收，请联系微信在线客服
        'Login',//登录
        'PhoneCannotEmpty',//手机号码不能为空
        'PhoneFormatIncorrect',//手机号码格式错误
        'VerificationCodeFailedMsg',//发送验证码失败，请检查：1.CRM服务器系统设置-短信账号设置；2.短信模板是否设置正确
        'VerificationCodeCannotEmpty',//验证码不能为空
        'VerificationCodeIsIncorrect',//验证码不正确
        'PhoneNotRegisteredToRegisterAccount',//手机号未注册，直接注册客户
        'PhoneNotRegisteredToRegisterContact',//手机号未注册，直接注册联系人

        'Registration',//注册
        'Add',//新增
        'Edit',//编辑
        'Details',//详情
        'PhoneRegisteredToBindAccount',//手机号已注册，直接绑定客户
        'PhoneRegisteredToBindContact',//手机号已注册，直接绑定联系人
        'RegisteredSuccess',//注册成功
        'HomePage',//首页
        'MyInfo',//我的信息
        'MyInfoHint',//实时查看我的个人信息！

        'Me',//我
        'WeChatUser',//微信用戶
        'Unbind',//解除绑定
        'ConfirmUnbind',//你确定要解除绑定的客户吗?

        'Search',//搜索
        'All',//全部
        'ToBeEvaluate',//待评价
        'Evaluated',//已评价
        'Evaluate',//评价
        'Loading',//加载中...
        'PleaseSelect',//请选择
        'PleaseSelectFirst',//请先选择
        'Reselecting',//，再选择
        'UpToUpload',//最多可上传
        'Pictures',//个图片
        'Photograph',//拍照
        'PhotoAlbum',//相册
        'Attachments',//个附件
        'PleaseSelectType',//请选择源单类型后，再选择源单
        'AreLocationAddressesUsed',//是否用定位地址覆盖国家、省份、城市及地址？
        'PrimaryContactCannotEmpty',//首要联系人姓名不能为空
        'CanNotBeEmpty',//不能为空
        'FormatError',//格式错误
        'PleaseEnterCorrect',//请输入正确的
        'PleaseEnter',//请输入

        'BasicInformation',//基本信息
        'Save',//保存
        'Confirmed',//确定
        'Cancel',//取消
        'Submit',//提交
        'SubmitSuccessfully',//提交成功
        'AddedSuccess',//新增成功

        'FillInContent',//请填写内容
        'FillInReply',//请填写回复内容
        'NotFillInContent',//您还没有填写内容
        'CommunicationAndReply',//沟通回复
        'FailedShutdown',//失败关闭
        'Release',//发布
        'Content1',//内容
        'BINDTIPS',//根据所填号码获取到以下客户，请确认后选择绑定
        'BINDTIPS2',//您确定绑定所选信息？

        'ServiceEvaluation',//服务评价
        'BindingSuccess',//绑定成功
		'Communicate',//沟通
        'CommunicateInfo',//沟通信息
        'PleaseFillIn',//请填写
        'NoCommunicateInfo',//没有沟通信息
        'NoData',//没有数据
		'AUTOGRAPH',//签名
		'RESIGN',//重签
		'MAP',//地图
		'COMPLETE',//完成
		'REWRITE',//重写
		'REPLY',//回复
        'NotObtained',//未获取
        'ObtainAuthorization',//获取授权
        'ClickObtainAuth',//
        'OrderRecordQuery',//订单记录查询
        'NoMoreData',//没有更多数据

        'Accounts',//客户
        'Contacts',//联系人
        'RegistrationNotAllowed',//客户已存在，不允许注册！
        'RegisterNewContact',//是否注册为新联系人
        'RegisterNewAccount',//是否注册为新客户
        'VerificationCodeNotCompleted',//请完成滑动验证
        'VerificationPass',//验证成功
        'SlidingVerification',//请按住滑块，拖动到最右边
        
        'HaveReadAgree',//已阅读并同意
        'PleaseReadAgree',//请阅读并同意
        'PRIVACYPOLICY',//隐私政策
        'AND',//和
        'UserServiceAgreement',//用户服务协议

    );

    if (is_array($labelbol_arr) && !empty($labelbol_arr)){
        $all_label_arr = array_merge($all_label_arr,$labelbol_arr);
    }
    $all_label_arr = array_unique($all_label_arr);

    foreach($all_label_arr as $tmp_label){
//        $all_arr['arrFuWuLabel'][$tmp_label] = getFuWuLabel($tmp_label);//初始进来都是默认中文的，但是如果上次是英文，就会返回英文
        $all_arr['arrFuWuLabel'][$tmp_label] = getFuWuLabelBylanguage($tmp_label,'zh');
        if($enorzh == 'yes'){
            $all_arr['arrFuWuLabel_en'][$tmp_label] = getFuWuLabelBylanguage($tmp_label,'en');
        }
    }
    return $all_arr;
}

/*
处理数据 20230607 刘帅
*/
function addslashes_recursive($input) {
    if (is_array($input)) {
        foreach ($input as &$value) {
            $value = addslashes_recursive($value);
        }
    } 
    else {
        $input = addslashes($input);
        $input = htmlspecialchars($input);
    }
    return $input;
}

?>