<?php
//editor:gyq_167 reason:小程序图片上传及文件预览，基于腾讯COS的优化   2020/1/10 10:34
require globalStatic::$root_directory . 'WeiXinApp/lib/qcloud/cos_sdk/vendor/autoload.php';
require_once globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php';
//ls 20220919 cos对象存储允许客户自定义
require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
$sts = new QcloudSTS();

$cosClient = new Qcloud\Cos\Client(
    array(
        'region' => $sts->region,
        'schema' => 'https', //协议头部，默认为http
        'credentials' => array(
            'secretId' => $sts->secretId,
            'secretKey' => $sts->secretKey
        )
    )
);
try {
    //对象在存储桶中的位置，即称对象键
    //$key = "regauto-5100000000180/2020/01/wx67393d56c3ac9170.o6zAJs0noMqcSpYT0-qWuMU0GgP0.hPsfstu4Q6cX3b561c14d5e2c9fd94745386ad51d4d4.jpg";
    $filePath = $_REQUEST['file_path'];
    $fileName = $_REQUEST['file_name'];
    $upload_file_path = decideFilePath();
    $fileType = strrchr($fileName, '.');
    $imagetype = 'image/jpeg';
    $save_path = globalStatic::$root_directory . $upload_file_path . $fileName;
    mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);

    $localPath = @$save_path;//下载到本地指定路径
    $result = $cosClient->getObject(array(
        'Bucket' => $sts->bucket,
        'Key' => $filePath . $fileName,
        'SaveAs' => $localPath));
    $cosContent = $result->toArray();
    $response = array(
        'filename' => $fileName,
        'filepath' => $upload_file_path,
        'filesize' => $cosContent['ContentLength'],
        'filetype' => $cosContent['ContentType'],
        'filesuffixes' => $fileType,
        'newfile_name' => $fileName
    );
    ConvertTojsonString(1, array('list' => $response), '');
} catch (\Exception $e) {
    // 请求失败
    ConvertTojsonString(-1, array(), "$e\n");
}
