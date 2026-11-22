<?php
//商城小程序端 入口文件
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
global $corpurl,$ldcrm_name;
$corpurl = $_REQUEST['corpurl'];//crm地址
$ldcrm_name = $_REQUEST['ldcrm_name'];//xiaoshouzhushou文件夹名称
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录

include($root_dir.'/includefile.php');
//zkt 20231027 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
require_once($root_dir."/include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
include($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
include($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
require_once($root_dir.'/appCommon/appCommon.php');
include($root_dir.'/WeiXinApp/WeiXin_common/cls_Instance.php');


include(globalStatic::$root_directory.'WeiXinApp/ldmall/modules/LdMall.php');

$_REQUEST['diony'] = 'yes';
//请求哪个模块就加载哪个模块的文件
$module = $_REQUEST['module'];
if (empty($module)){
    ConvertTojsonString(-1,[],'模块名称不能为空');
}
$action  = $_REQUEST['action'];
if (empty($action)){
    ConvertTojsonString(-1,[],'请求方法不能为空');
}
$moduleaction = $module.$action;
$open_id = $_REQUEST['open_id'];
if($module!='Auth'){
    include_once (globalStatic::$root_directory.'WeiXinApp/ldmall/modules/LdMallAuth.php');
    $authObj = new LdMallAuth();
    if(empty($open_id)){
    //首页、购物车、我的三个tab页需要解析code登录--不太可行
    //if(in_array($moduleaction,['ProductsListView','ProductscartList','SalesOrderPersonalInfo'])||empty($open_id)){
        $authInfo = $authObj->Login();
        if($authInfo[0]!=1){
            ConvertTojsonString($authInfo[0],$authInfo[1],$authInfo[2]);
        }else {
            $authInfoData = $authInfo[1]['data'];
        }
    }else{
        $authInfoData = $authObj->getAccountInfo($open_id);
        $_REQUEST['accountid'] = $authInfoData['accountid'];//获取最新的客户id  不使用前端传过来的accountid
    }
}

include_once (globalStatic::$root_directory.'WeiXinApp/ldmall/modules/LdMall'.$module.'.php');
$moduleClassName = 'LdMall'.$module;
$moduleObj = new $moduleClassName();
//请求哪个方法就调用哪个方法
$res = $moduleObj->$action();
if(!empty($authInfoData)){
    $res[1]['data'] = $authInfoData;
}

//获取所所有ld_shop_phones的数据
$cnt = $moduleObj->phoneArr['phone_nums'];
$res[1]['kefuTels'] = $moduleObj->phoneArr['kefuTels'];
// 联系客服电话  分享标题   分享图
$otherInfo =  [];
$otherInfo['sharedescription'] = isset($moduleObj->configArr['sharedescription'])&&!empty($moduleObj->configArr['sharedescription'])?$moduleObj->configArr['sharedescription']:'';
$otherInfo['sharepicture'] = isset($moduleObj->configArr['sharepicture'])&&!empty($moduleObj->configArr['sharepicture'])?$corpurl.$moduleObj->configArr['sharepicture']:'';
$otherInfo['displayinvoice'] = isset($moduleObj->configArr['displayinvoice'])&&!empty($moduleObj->configArr['displayinvoice'])?$moduleObj->configArr['displayinvoice']:'yes';
$res[1]['otherInfo'] = $otherInfo;
if($cnt == 0)
{
    $otherInfo['kefuTel'] = isset($moduleObj->configArr['custelno'])&&!empty($moduleObj->configArr['custelno'])?$moduleObj->configArr['custelno']:$moduleClassName::KEFUTEL;
}else{
    $otherInfo['kefuTel'] = isset($moduleObj->phoneArr['phones'][0]['custelno'])&&!empty($moduleObj->phoneArr['phones'][0]['custelno'])?$moduleObj->phoneArr['phones'][0]['custelno']:$moduleClassName::KEFUTEL;
    //$res[1]['all_phones'] = $moduleObj->phoneArr['phones'];  //暂时不需要
}
$res[1]['kefuTel'] = $otherInfo['kefuTel'];
$res[1]['lingdangencryptykey']=$cls_UrlEncryptyJudgeobj->getlingdangencryptykey();
ConvertTojsonString($res[0],$res[1],$res[2]);
