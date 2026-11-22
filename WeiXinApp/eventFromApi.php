<?php
/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/9/21 0021
 * Time: 下午 5:36
 */
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");
$root_dir = dirname(dirname(__FILE__));
date_default_timezone_set("PRC");
include_once($root_dir . '/WeiXinApp/WeiXin_common/StaticConst.php');
include($root_dir . '/includefile.php');
include_once($root_dir . '/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
include_once($root_dir . '/WeiXinApp/lib/EventFromApiModel.php');
include_once($root_dir . '/WeiXinApp/WeiXin_common/cls_WeixinPort.php');
include_once($root_dir . '/appCommon/appCommon.php');
require_once($root_dir.'/Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
require_once($root_dir.'/Register/cls_MyCRMcrypt.php');//gyqCom0309 reason:软件过期不可用 date:20170309
include($root_dir . '/WeiXinApp/lib/cls_dandian.php');
//企业微信消息通送接收事件
$o_event_api = new EventFromApiModel();
$_REQUEST['weixin_mark'] = 'txl';//gyqxs

switch ($_REQUEST['action']) {


    case "get_crmtoken":

        $user_name="get_crmtoken";

        $objdandian = new cls_dandian("get_crmtoken");


         echo json_encode($objdandian->getnewgenerateToken());

        break;
        //注册定制化获取用户部门信息
    case 'get_groupanduser':
        include_once($root_dir . '/WeiXinApp/modules/Home/WorkReportControllerWX.php');
        $workreportmoduleobj = new WorkReportControllerWX();
        $groupinfo = $workreportmoduleobj->getGroupAndUserList();//系统部门信息
        echo json_encode($groupinfo);
        exit;
        break;
        //获取微信版本号
    case 'get_version'://微信多版本
      //  require_once($root_dir . '/include/Zend/Json.php');
        cls_StaticCommonFun::websaas_multi_version();
        break;
        //扫码或前往服务商后台的单点登录
    case 'crm_login':
        if(!isset($_REQUEST['lingdangcode']))
        {
            exit('ldcode error');
        }
      
        $portobj=new cls_WeixinPort();
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
       	$weixininfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams),true);
        //echo StaticConst::$server_api."?code=".$_REQUEST['lingdangcode']."&action=checkldcode&corpindex=".$weixininfo_arr['crm']['corpindex'];
         $jsonstr=  $portobj->primary_get(StaticConst::$server_api."?code=".$_REQUEST['lingdangcode']
            ."&action=checkldcode&corpindex=".$weixininfo_arr['crm']['corpindex'].'&wxuserid='.$_GET['wx_userid']);
      $tmp_arr=json_decode($jsonstr,true);
    
      if(empty($tmp_arr)|| $tmp_arr['code']==-1)
      {
        exit('ldcode error');
      }
        if (empty($_REQUEST['error'])) {
            global $adb;
            $o_event_api->setAdb($adb);
            $o_event_api->crmLogin($_GET['wx_userid']);
        } else {
            $current_url = $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];//'&language='.$language
            $deal_url = 'http://' . substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=' . $_REQUEST['error'];
            header('location:' . $deal_url);
        }
        break;
        //取消授权
    case 'cancel_auth'://gyq_33
        if(!isset($_REQUEST['crmapicode']))
        {
            file_put_contents($root_dir."/storage/eventfromapierror.txt","datea:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action']."\n\n",FILE_APPEND);

            exit('ldcode error');
        }
        $portobj=new cls_WeixinPort();
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $weixininfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams),true);
        $crmapicode=$_REQUEST['crmapicode'];
        $mycryptobj=new cls_MyCRMcrypt();
        $strcode=$mycryptobj->encode($crmapicode);
        $codetype=$_REQUEST['action'];
        $jsonstr=  $portobj->primary_get(StaticConst::$server_api."?code=".$strcode
            ."&action=checkapicode&corpindex=".$weixininfo_arr['crm']['corpindex'].'&codetype='.$codetype);
        $tmp_arr=json_decode($jsonstr,true);

        if($tmp_arr['code']==-1)
        {
            file_put_contents($root_dir."/storage/eventfromapi.txt","dateb:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action'].
                "code:".$_REQUEST['crmapicode']."strCode:".$strcode."\n\n",FILE_APPEND);
            ConvertTojsonString(-1,[],'');
        }
        $suitename = $_REQUEST['suitename'];
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $exist_auth_info = getWeiXinAuthInfo($getWeiXinAuthInfoParams);

        $exist_auth_arr = json_decode($exist_auth_info, true);

        if (empty($exist_auth_arr)) {
            $exist_auth_arr = array();
        }
        unset($exist_auth_arr[$suitename]);

        if (empty($exist_auth_arr)) {
            file_put_contents($root_dir . '/dataCache/weixin/weixinapp_corpindex.php', '');
        }
        file_put_contents($root_dir . '/dataCache/weixin/auth_info.txt', encryptStringByLabel(json_encode($exist_auth_arr),'auth_info'));

        break;
        //更新auth_info.txt事件
    case 'update_auth_cache':
        //editor:gyq_111 reason:企业微信/小程序授权HTML优化  2019/5/15 16:52
        $exist_auth_arr[StaticConst::$suite_crm] = $_POST['auth_info'];
        file_put_contents($root_dir . '/dataCache/weixin/auth_info.txt', encryptStringByLabel(json_encode($exist_auth_arr),'auth_info'));
        if (!empty($_POST['info_type'])) {
            $o_event_api->setInfoType($_POST['info_type'], $auth_info);
        }
        echo 'update_auth_cache success';exit;

        //成员/部门变更
    case 'change_contact':


        if(!isset($_REQUEST['crmapicode']))
        {
            file_put_contents($root_dir."/storage/eventfromapierror.txt","datea:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action']."\n\n",FILE_APPEND);

            exit('ldcode error');
        }

        $portobj=new cls_WeixinPort();
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $weixininfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams),true);

        $crmapicode=$_REQUEST['crmapicode'];
        $mycryptobj=new cls_MyCRMcrypt();
        $strcode=$mycryptobj->encode($crmapicode);
        $codetype="change_contact_".$_REQUEST['changetype'];
        if(isset($_REQUEST['fromurl']))
        {
            $codetype.=$_REQUEST['fromurl'];

        }
        $jsonstr=  $portobj->primary_get(StaticConst::$server_api."?code=".$strcode
            ."&action=checkapicode&corpindex=".$weixininfo_arr['crm']['corpindex'].'&codetype='.$codetype);
        $tmp_arr=json_decode($jsonstr,true);

        if(empty($tmp_arr)|| $tmp_arr['code']==-1)
        {
            file_put_contents($root_dir."/storage/eventfromapi.txt","dateb:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action'].
                "code:".$_REQUEST['crmapicode']."strCode:".$strcode.":codetype:".$codetype."\n\n",FILE_APPEND);
            ConvertTojsonString(-1,[],'');
        }
        file_put_contents($root_dir."/storage/eventfromapi.txt","datec:change_contact\n\n",FILE_APPEND);
        switch ($_REQUEST['changetype']) {
            case 'create_user':
//保存用户
                $_POST['user_list'] = $_REQUEST['weixin_callback']['user_list'];
                //清楚公海缓存，方便邀请或变更得来的新用户，不手动清缓存序时簿也可以显示出公海标签
                $cache_account_setting = Cache('account_set');
                if(!empty($cache_account_setting) && isset($cache_account_setting['usersaccount'])){
                    unset($cache_account_setting['usersaccount']);
                    Cache('account_set',$cache_account_setting);
                }
                $_REQUEST["module"] = "Cloud_Users";
                $_REQUEST["func"] = "saveMultiUser";
                require($root_dir ."/crmapi/ApiAuthenKey.php");
                $apikeyobj=new ApiAuthenKey();
                $keyToken_arr=  $apikeyobj->getnewToken("change_contact");
                $_REQUEST['apikey']=$keyToken_arr['apikey'];
                $_REQUEST['token']=$keyToken_arr['token'];
                include($root_dir . '/crmapi/crmoperation.php');
                break;
            case 'update_user':
                $_POST['user_list'] = $_REQUEST['weixin_callback']['user_list'];
                $_REQUEST["module"] = "Cloud_Users";
                $_REQUEST["func"] = "saveMultiUser";
                require($root_dir ."/crmapi/ApiAuthenKey.php");
                $apikeyobj=new ApiAuthenKey();
                $keyToken_arr=  $apikeyobj->getnewToken("change_contact");
                $_REQUEST['apikey']=$keyToken_arr['apikey'];
                $_REQUEST['token']=$keyToken_arr['token'];
                include($root_dir . '/crmapi/crmoperation.php');
                ConvertTojsonString(1,array(),'update_user');
                break;
            case 'delete_user'://kehu001.com/weixin/wx17018/WeiXinApp/eventFromApi.php?action=change_contact&changetype=delete_user&wx_userid=lilili
                if(judgeCorpInfo('kehu001')) {
                    //0032177: 企业微信：自动分配账套，企业微信测删除用户，CRM系统的用户没有更改为“停用
                    // require_once($root_dir . '/include/Zend/Json.php');
                    global $adb;
                    $userinfo = $_REQUEST['userinfo'];
                    if(empty($userinfo['userid'])) break;
                    //0033122: 企业微信通讯录删除用户后，CRM系统后台数据不同步 Eidtor:gyq  Date:2018/3/2 0002 下午 3:28
                    // $userid = $adb->query_result($result, 0, 'id');
                    $sql="update ld_users set status='Inactive' where wx_userid=?";
                    $adb->pquery($sql, array($userinfo['userid']));

                    ConvertTojsonString(1, array(), 'success');
                }
                break;

            case 'create_party':
                require_once($root_dir . '/modules/Users/Group.class.php');
                global $adb;
                $group_focus = new Group();
                $grouparr = json_decode($_REQUEST['groupinfo'], true);
                $grouparr_tr['wxgroupid'] = $grouparr['groupid'][0];
                $grouparr_tr['parentid'] = $grouparr['parentid'][0];
                $grouparr_tr['groupname'] = $grouparr['groupname'][0];
                $entityid = $group_focus->save($grouparr_tr);

                break;
            case 'update_party':
                require_once($root_dir . '/modules/Users/Group.class.php');
                global $adb;
                $group_focus = new Group();
                $grouparr = json_decode($_REQUEST['groupinfo'], true);
                $grouparr_tr['groupid'] = $grouparr['groupid'][0];
                if(!empty($grouparr['parentid'][0])){
                    $grouparr_tr['parentid'] = $grouparr['parentid'][0];
                }
                if(!empty($grouparr['groupname'][0])){
                    $grouparr_tr['groupname'] = $grouparr['groupname'][0];
                }
                if(empty($grouparr_tr['parentid'])){
                    $sql = 'select parentid from ld_groups where groupid=?';
                    $result = $adb->pquery($sql, array($grouparr_tr['groupid']));
                    $parentid = $adb->query_result($result, 0, 'parentid');
                    if (empty($parentid)) $parentid = 1;
                    $grouparr_tr['parentid'] = $parentid;
                }
                if(empty($grouparr_tr['groupname'])){
                    $sql = 'select groupname from ld_groups where groupid=?';
                    $result = $adb->pquery($sql, array($grouparr_tr['groupid']));
                    $groupname = $adb->query_result($result, 0, 'groupname');
                    $grouparr_tr['groupname'] = $groupname;
                }
                $entity = $group_focus->save($grouparr_tr);
                break;
            case 'delete_party':
                require_once($root_dir . '/modules/Users/Group.class.php');
                $group_focus = new Group();
                $grouparr = json_decode($_REQUEST['groupinfo'], true);
                $grouparr_tr['del_id'] = $grouparr['groupid'][0];
                $grouparr_tr['userto'] = 1;
                $entity = $group_focus->deleted($grouparr_tr);

                break;
        }
        break;
        //第三方应用市场授权成功事件
    case 'market_auth':
        global $adb;
        $o_event_api->setAdb($adb);

        if(!isset($_REQUEST['crmapicode']))
        {
            file_put_contents($root_dir."/storage/eventfromapi.txt","datea:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action']."\n\n",FILE_APPEND);

            exit('ldcode error');
        }

        $portobj=new cls_WeixinPort();
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $weixininfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams),true);
        //echo StaticConst::$server_api."?code=".$_REQUEST['lingdangcode']."&action=checkldcode&corpindex=".$weixininfo_arr['crm']['corpindex'];
        $crmapicode=$_REQUEST['crmapicode'];
        $mycryptobj=new cls_MyCRMcrypt();
        $strcode=$mycryptobj->encode($crmapicode);
        $codetype=$_REQUEST['action'];
        $jsonstr=  $portobj->primary_get(StaticConst::$server_api."?code=".$strcode
            ."&action=checkapicode&corpindex=".$weixininfo_arr['crm']['corpindex'].'&codetype='.$codetype);
        $tmp_arr=json_decode($jsonstr,true);

        if(empty($tmp_arr)||  $tmp_arr['code']==-1)
        {
            file_put_contents($root_dir."/storage/eventfromapi.txt","dateb:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action'].
                "code:".$_REQUEST['crmapicode']."strCode:".$strcode."\n\n",FILE_APPEND);
            ConvertTojsonString(-1,[],'');
        }
        file_put_contents($root_dir."/storage/eventfromapi.txt","datec:marketAuth\n\n",FILE_APPEND);
        $o_event_api->marketAuth();
        break;
        //应用变更可见范围事件
    case 'change_auth':
        //授权可见范围变更
        global $adb;
        $o_event_api->setAdb($adb);



        if(!isset($_REQUEST['crmapicode']))
        {
            file_put_contents($root_dir."/storage/eventfromapierror.txt","datea:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action']."\n\n",FILE_APPEND);

            exit('ldcode error');
        }

        $portobj=new cls_WeixinPort();
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $weixininfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams),true);
        //echo StaticConst::$server_api."?code=".$_REQUEST['lingdangcode']."&action=checkldcode&corpindex=".$weixininfo_arr['crm']['corpindex'];
        $crmapicode=$_REQUEST['crmapicode'];
        $mycryptobj=new cls_MyCRMcrypt();
        $strcode=$mycryptobj->encode($crmapicode);
        $codetype=$_REQUEST['action'];
        $jsonstr=  $portobj->primary_get(StaticConst::$server_api."?code=".$strcode
            ."&action=checkapicode&corpindex=".$weixininfo_arr['crm']['corpindex'].'&codetype='.$codetype);
        $tmp_arr=json_decode($jsonstr,true);
       // file_put_contents($root_dir."/storage/eventfromapi.txt","datec:change_authcode:".$tmp_arr['code']."\n\n",FILE_APPEND);
        if(empty($tmp_arr)||  $tmp_arr['code']==-1)
        {
            file_put_contents($root_dir."/storage/eventfromapierror.txt","dateb:".date("Y-m-d H:i:s").'action:'.$_REQUEST['action'].
                "code:".$_REQUEST['crmapicode']."strCode:".$strcode."\n\n",FILE_APPEND);
            ConvertTojsonString(-1,[],'');
        }
        $o_event_api->changeAuth($_POST['result']);
        ConvertTojsonString(1,array(),$_POST['result']);
        break;

    case 'change_external_contact'://【客户联系】回调通知
        //ls 240614 XUQIU20240516-05 渠道码升级优化
        //file_put_contents("change_external_contact.txt",  date('Y-m-d H:i:s') ." ". json_encode($_REQUEST) . PHP_EOL, FILE_APPEND);
        switch ($_REQUEST['changetype']) {
            case 'add_external_contact':
                /* {"SuiteId":"ww5f5c0ef1599c398c","AuthCorpId":"wpKcoAEgAAlH72KlQ4ikra1VzDhaLrig","InfoType":"change_external_contact","TimeStamp":"1718258975","ChangeType":"add_external_contact","UserID":"woKcoAEgAAgR1p-_29oBqIPpC7qzBwhg","ExternalUserID":"wmKcoAEgAA0SMTFsBXpa-yZWCOeHlUcA","State":"qudaoma_33","WelcomeCode":"TN0QR0RzdcQFqF4RWqkbPvtSVz9gpZ7-jAh2th84n0I"}*/
                if (isset($_REQUEST['qudaoma']) && $_REQUEST['qudaoma'] == 'yes') {
                    $rMessageObject = json_decode($_REQUEST['weixin_callback']);
                    $o_event_api->qudaomaCallBack($rMessageObject);
                }

                break 2;
        }
        break;
}






