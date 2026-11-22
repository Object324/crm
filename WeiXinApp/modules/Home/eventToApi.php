<?php
/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/12/14 0021
 * Time: 下午 5:36
 */
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
require_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
require_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
switch ($_REQUEST['method']) {
    case 'update_expired_time'://客户001自动分配账套是否到期  gyq_54 20171214
        //$exist_auth_info = file_get_contents(globalStatic::$root_directory. 'dataCache/weixin/auth_gyq_info.txt');
        $exist_auth_info = doCorpInfo('get_auth_info');
        $exist_auth_arr = json_decode($exist_auth_info, true);
        if(isset($exist_auth_arr[StaticConst::$suite_crm])){
            $corpid = $exist_auth_arr[StaticConst::$suite_crm]['auth_corp_info']['corpid'];
        }
        global $current_user;  //0033019: 企业微信试用+5 在API wx_corp增加字段记录再次体验人姓名
        $url = StaticConst::$server_api . '?action=update_expired_time&corpid=' .$corpid . '&suitename=crm&renew_name='.$current_user->last_name;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($ch);
        curl_close($ch);
        global $dbconfig;
        require_once(globalStatic::$root_directory.'config.inc.php');
        //35983: 企业微信试用到期，进入企业微信端，提示试用到期是否继续使用，确定后可进入，但是退出再进入就不行了
        $url = 'http://51mis.cn/webapi/api/delredis.php?databasename='.$dbconfig['db_name'];
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($ch);
        curl_close($ch);
        ConvertTojsonString(1,'','success');

}






