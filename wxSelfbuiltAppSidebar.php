<?php
//自建应用侧边栏
//租赁账套该文件位于kehu001上，如果是本地部署账套，该文件位于客户本地账套
//可信域名的回调中转
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');


$corpurl = $_REQUEST['corpurl'];
$code = $_REQUEST['code'];
$state = $_REQUEST['state'];

$location = $corpurl. 'getChatUserInfoSelfBuilt.php?code='.$code.'&state='.$state;
header('location:' . $location);

?>

