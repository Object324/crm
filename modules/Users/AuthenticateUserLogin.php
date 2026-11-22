<?php
//登录界面和注册登录界面使用该文件
if(isset($_REQUEST['encode_login_user_name_value']))
    $_REQUEST['login_user_name'] = ld_login_secret($_REQUEST['encode_login_user_name_value'],$_REQUEST['login_user_password'],true);
if(isset($_REQUEST['login_user_name']))
{
    $tmp_username=addslashes($_REQUEST['login_user_name']);
    $tmp_username=htmlspecialchars($tmp_username);
}
if(isset($_REQUEST['login_user_password']))
    $_REQUEST['login_user_password'] = ld_login_secret($_REQUEST['login_user_password'],$_REQUEST['login_user_name'],true);
//edit: xll 2024/02/22 特殊字符处理统一到 encrypt_password 这个方法中，'&'经过 htmlspecialchars 后长度会变为5
//$tmp_pwd=addslashes($_REQUEST['login_user_password']);
//$tmp_pwd=htmlspecialchars($tmp_pwd);
$tmp_pwd = $_REQUEST['login_user_password'];
//zkt 20241017 账号、密码两边空格去除
if($_REQUEST['login_user_name'])
{
    $_REQUEST['user_name']=trim($tmp_username);

}
if(isset($_REQUEST['login_user_password']))
{

    $_REQUEST['user_password']=trim($tmp_pwd);

}

function ld_login_secret($string,$code,$operation=false){
    $code = md5($code);
    $iv = substr($code,0,16);
    $key = substr($code,16);
    if($operation){
        return openssl_decrypt(base64_decode($string),"AES-128-CBC",$key,OPENSSL_RAW_DATA,$iv);
    }
    return base64_encode(openssl_encrypt($string,"AES-128-CBC",$key,OPENSSL_RAW_DATA,$iv));
}