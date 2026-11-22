<?php
//自建应用
//租赁账套该文件位于kehu001上，如果是本地部署账套，该文件位于客户本地账套
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');


$corpurl = $_REQUEST['corpurl'];
$isPC = $_REQUEST['isPC'];
$code = $_REQUEST['code'];
$state = $_REQUEST['state'];

$location = $corpurl. 'wxSelfbuiltApplicationLogin.php?code='.$code.'&state='.$state.'&isPC='.$isPC;
header('location:' . $location);

?>

