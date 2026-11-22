<?php
global $adb;
//editor:gyq_167 reason:小程序图片上传及文件预览，基于腾讯COS的优化   2020/1/10 10:34
require globalStatic::$root_directory . 'WeiXinApp/lib/qcloud/cos_sdk/vendor/autoload.php';
require_once globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php';
require_once globalStatic::$root_directory . 'include/cls_File.php';
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
    $fileId=$_REQUEST['fileid'];
    if(!empty($fileId)){
        $frommodule=$_REQUEST['frommodule'];
        if($frommodule=='Attachment'){
            $sql='select cloud_path,storage_location,path,newfile_name,id from ld_attachmentsforbillsdetails
             where id=?';
            
        }
        else if($frommodule=='CooperativeWork')
        {
            $sql='select cloud_path,storage_location,path,newfile_name,achmentid from ld_workachments
             where achmentid=?';
        }
        else{
            if($_REQUEST['isentry'] && $_REQUEST['isentry']=='entry'){
                $sql="select * from ld_detailattachments where id = ?";
            }else{
                $sql="select * from ld_attachments where attachmentsid=? ";
            }
        }
        $result=$adb->pquery($sql,array($fileId));
        $storage_location=$adb->query_result($result,0,'storage_location');
        $cloud_path=$adb->query_result($result,0,'cloud_path');
        
        if($storage_location=='cos'){
            ConvertTojsonString(1, array($cloud_path), getFixedLabel('FILEREADSUCCESSFULLY'));
        }
    }
    $fileName = urldecode($_REQUEST['file_name']);
    if($_REQUEST['attlocation'] && $_REQUEST['attlocation'] == cos && !empty($_REQUEST['atthttppath'])){
        $localPath = $_REQUEST['atthttppath'];
    }
    else{
        $localPath = globalStatic::$root_directory . urldecode($_REQUEST['file_url']) . $fileName;
    }
    //editor:gyq_20200212 reason:kfbcrm服务器，中文名文件可直接读取；但客户http://47.92.37.42:85/crm/的服务器需要额外处理
    $exist = file_exists( $localPath);
    if($exist){
        $fileBody = fopen($localPath, 'rb');
    }else{
        $fileBody = fopen(iconv ( 'UTF-8', 'GBK', $localPath), 'rb');
    }
    $dirName = cls_File::getCosDirName();
    $dirNameMonth = $dirName . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
    $result = $cosClient->putObject(array(
        'Bucket' => $sts->bucket,
        'Key' => $dirNameMonth . $fileName,
        'Body' => $fileBody,
        'ACL' => 'public-read'
    ));
    $cosContent = $result->toArray();
    ConvertTojsonString(1, array($cosContent['ObjectURL']), getFixedLabel('FILEREADSUCCESSFULLY'));
} catch (\Exception $e) {
    // 请求失败
    ConvertTojsonString(-1, array($localPath, $_REQUEST), "$e\n");
}
