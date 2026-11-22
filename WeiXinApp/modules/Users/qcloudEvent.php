<?php
// 临时密钥计算样例
//editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/20 15:00
// 这里获取 sts.php https://github.com/tencentyun/qcloud-cos-sts-sdk/blob/master/php/sts/sts.php\
require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
require_once globalStatic::$root_directory . 'include/cls_File.php';
$sts = new QcloudSTS();
$second_action = $_REQUEST['second_action'];
$_REQUEST['diony'] = 'yes';
$ldencrypt = $_REQUEST['ldencrypt'] ;
//获取临时密钥
if($second_action=='get_temp_keys'){
    $tempKeys = $sts->getCredentials();
    if($ldencrypt == 'yes'){
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $encrypt_key_arr = array('bucket', 'region');
        $tempKeys['encrypt_key_arr'] = $encrypt_key_arr;
        $tempKeys = $cls_AESencryptionbykeyobj->getencryption_arr($tempKeys,$encrypt_key_arr);
        $encrypt_key_arr = ['sessionToken','tmpSecretId','tmpSecretKey'];
        $tempKeys['credentials']['encrypt_key_arr'] = $encrypt_key_arr;
        $tempKeys['credentials'] = $cls_AESencryptionbykeyobj->getencryption_arr($tempKeys['credentials'],$encrypt_key_arr);
    }
    // 返回数据给前端
    ConvertTojsonString(1,array('content'=>$tempKeys),'success');
}elseif ($second_action == 'get_upload_type'){
    //获取文件上传类型
    $result = $sts->getUploadType();
    $bucket = $sts->bucket;
    $region = $sts->region;
    $returnarr = array(
        'upload_type'=>$result,
        'bucket' => $bucket,
        'region' => $region,
        'dirname' => cls_File::getCosUploadDir());
    if($ldencrypt == 'yes'){
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $encrypt_key_arr = array('bucket', 'region');
        $returnarr['encrypt_key_arr']=$encrypt_key_arr;
        $returnarr = $cls_AESencryptionbykeyobj->getencryption_arr($returnarr,$encrypt_key_arr);
    }
    ConvertTojsonString(1,$returnarr,'success');
}elseif ($second_action == 'save_into_temptable'){
    //将附件信息保存进文件临时表
    $result = $sts->saveIntoTemptable();
    ConvertTojsonString(1,$result,'success');
}



