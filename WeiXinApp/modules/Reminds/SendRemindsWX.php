<?php
header('Content-Type:text/html;charset=UTF-8');
//session_start();
$root_dir=dirname(dirname(dirname(dirname(__FILE__))));
include($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
include($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
include($root_dir.'/includefile.php');
session_start();
//gyq_50
if(empty($_REQUEST['userid'])){
    $userid = $_SESSION['authenticated_user_id'];
}else{
    $userid = $_REQUEST['userid'];
}

if(empty($userid)){
    exit;
}
exit();
global $current_user;

require_once($root_dir.'/WeiXinApp/modules/Reminds/cls_remindsWX.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
$remind = new cls_remindsWX();
$remindarr = $remind->time_interval();
if(empty($remindarr)){
    exit;
}
$url = StaticConst::$server_remindapi;

$data['news'] = json_encode($remindarr,JSON_UNESCAPED_UNICODE);
$result = push_news($url,$data);




function push_news($url,$data){
    $ch = curl_init ();
    curl_setopt ( $ch, CURLOPT_URL, $url );
    curl_setopt ( $ch, CURLOPT_POST, 1 );
    curl_setopt ( $ch, CURLOPT_HEADER, 0 );
    curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
     curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
    $output = curl_exec ( $ch );

    curl_close ( $ch );
}
/***************/
/*$access_token_url = StaticConst::$server_api . '?action=get_access_token_cache&corpindex=' . '632' . '&rediskey=' . 'wwd22028618dbf39e2' . 'crm';

$url_result_json = primary_get($access_token_url);
$token = json_decode($url_result_json, true)['result'];

$content = json_decode( file_get_contents('AMD.txt'),true);*/
function primary_get($url){

    //访问数据接口
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $output = curl_exec($ch);
    curl_close($ch);

    return $output;
}
/***************/
exit;

?>