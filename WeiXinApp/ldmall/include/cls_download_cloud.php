<?php
require globalStatic::$root_directory . 'WeiXinApp/lib/qcloud/cos_sdk/vendor/autoload.php';
require_once globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php';
class cls_download_cloud
{
	public function __construct(){
		global $adb;
        //ls 20220919 cos对象存储允许客户自定义
        require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
        $sts = new QcloudSTS();
        $this->bucket = $sts->bucket;
		$this->cosClient = new Qcloud\Cos\Client(
			array(
				'region' => $sts->region,
				'schema' => 'https', //协议头部，默认为http
				'credentials' => array(
					'secretId' => $sts->secretId,
					'secretKey' => $sts->secretKey
				)
			)
		);
	}
	
	public function download(){
		$filePath = $_REQUEST['file_path'];
		$fileName = $_REQUEST['file_name'];
		$upload_file_path = decideFilePath();
		$fileType = strrchr($fileName, '.');
		$save_path = globalStatic::$root_directory . $upload_file_path . $fileName;
		mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
		$localPath = @$save_path;//下载到本地指定路径
		$result = $this->cosClient->getObject(array(
			'Bucket' => $this->bucket,
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
	}
	
}
?>