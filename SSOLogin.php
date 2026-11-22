<?php
//消息提醒 单点登录到PC端公共入口
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');

if (isset($_REQUEST['ssotype'])) {
    switch ($_REQUEST['ssotype']) {
        case 'tongda'://通达OA
            require_once("Register/cls_TongdaLogin.php");
            break;
        default:
            header("Location: index.php?languageType=zh");
            break;
    }
    exit;
}else{
    header("Location: index.php?languageType=zh");
}

?>