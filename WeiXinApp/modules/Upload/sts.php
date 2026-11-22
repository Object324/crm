<?php

//zkt 20231031 XUQIU1001341 SQL注入  -- 附件上传只判断部分参数
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_167 reason:获取临时密钥，计算签名   2020/1/9 10:15
require_once globalStatic::$root_directory . 'include/cls_File.php';
require_once globalStatic::$root_directory . 'WeiXinApp/lib/qcloud/qcloud-sts-sdk.php';
require_once globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php';
$sts = new STS();
$tempKeys = $sts->getCredentials();

// 返回数据给前端
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: http://127.0.0.1'); // 这里修改允许跨域访问的网站
header('Access-Control-Allow-Headers: origin,accept,content-type');

$dirName = cls_File::getCosDirName();
$tempKeys['dir_name'] = $dirName . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
$ldencrypt= $_REQUEST['ldencrypt'];
if($ldencrypt == 'yes'){
    $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
    $encrypt_key_arr = array('bucket', 'region');
    $tempKeys['encrypt_key_arr'] = $encrypt_key_arr;
    $tempKeys = $cls_AESencryptionbykeyobj->getencryption_arr($tempKeys,$encrypt_key_arr);
    $encrypt_key_arr = ['sessionToken','tmpSecretId','tmpSecretKey'];
    $tempKeys['credentials']['encrypt_key_arr'] = $encrypt_key_arr;
    $tempKeys['credentials'] = $cls_AESencryptionbykeyobj->getencryption_arr($tempKeys['credentials'],$encrypt_key_arr);
}
ob_clean();
echo json_encode($tempKeys);