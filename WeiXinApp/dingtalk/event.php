<?php
//editor:gyq_144 reason:钉钉登陆绑定  2019/9/11 16:32
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录

require_once($root_dir . '/includefile.php');
require_once($root_dir . '/appCommon/appCommon.php');
// require_once($root_dir . '/include/Zend/Json.php');
require_once $root_dir . '/WeiXinApp/dingtalk/model/event_model.php';
include_once($root_dir . '/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
define('NONCESTR','ldcrm_abcdefg');
define('H5HTML','WeiXinApp/dingtalk/websaas/ldcrm/index.html');
//新版钉钉，前端访问同一个
/*
if(isset($_REQUEST['corpurl_new'])&&!empty($_REQUEST['corpurl_new'])&&$_REQUEST['corpurl_new']=='selfbuildSass'){
    define('H5HTML','WeiXinApp/selfbuildSass/ldcrm/index.html');
}
else{
    define('H5HTML','WeiXinApp/dingtalk/websaas/ldcrm/index.html');
}
*/

$model_obj = new event_model();
//初始化配置参数
//file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/action.txt',$_REQUEST['action']."\n",FILE_APPEND);
$model_obj->init_config();
//file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/action1.txt',$_REQUEST['action']."\n",FILE_APPEND);
switch ($_REQUEST['action']) {
    //获取钉钉成员ID
    case 'get_userid':
        $result = $model_obj->get_userid($_REQUEST['code']);
        ConvertToJsonString(1,array('userid'=>$result) ,'sucess');
        break;
        //JSAPI调用鉴权参数
    case 'isvConfig':
        $result = $model_obj->isvConfig($_REQUEST['corpurl']);
        ConvertToJsonString(1,$result ,'sucess');
        break;
    case 'get_custom_space':
        $spaceid = $model_obj->get_custom_space();
        ConvertToJsonString(1,array('spaceid'=>$spaceid) ,'sucess');
        break;
    case 'upload_single':
        $_REQUEST['file_path'] = 'storage/2019/September/17/Contacts_123_643174806.docx';
        $result = $model_obj->upload_single();
        ConvertToJsonString(1,$result ,'sucess');
        break;
    case 'crm_login':
        //editor:gyq_163 reason:钉钉内免登第三方网站   2019/12/13 13:54
       // file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/a1.txt','assss');
        if (empty($_REQUEST['error'])) {
            if($_GET['state'])
            $userid = $model_obj->getUserId($_GET['code'],$_GET['state']);
            $model_obj->crmLogin($userid);
        } else {
            file_put_contents(globalStatic::$root_directory.'WeiXinApp/dingtalk/a2.txt','assss');
            $http='http';
            if(strtolower($_SERVER['REQUEST_SCHEME'])=='https')
            {    
                $http='https';
            }
            $current_url = $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];//'&language='.$language
            $deal_url = $http.'://' . substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=' . $_REQUEST['error'];
            header('location:' . $deal_url);
        }
        break;
}

?>
