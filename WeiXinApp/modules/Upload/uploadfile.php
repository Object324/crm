<?php
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");
	//判断表单传值方式
	if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
		exit;
	}
    //zkt 20240705 BUG20240705-49 客户服务单明细界面，手写签名，保存时，-100
    global $weixin_user;
    $tmpfilename = $_FILES['file']['name'];
    if($weixin_user->environment=='weixin'
    || $weixin_user->environment=='weixin_self_help'
    ||  $weixin_user->environment=='weixinh5'){
        $tmpfileinfo = json_decode($_REQUEST['file_info'],true);
        $tmpfilename = $tmpfileinfo["name"];
    }
    //zkt 20231011 XUQIU1001341 SQL注入  -- 附件上传只判断部分参数
    $filejudgepramkeyarr =['module','action','frommodule','filerand','filename'];//这里不能修改,不然小程序端的加密参数就错误了
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->setJudgeparamkeyarr($filejudgepramkeyarr);
    $JudgeUrlstringbyarr = array_merge($_REQUEST,array('filename'=>$tmpfilename));
    $cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($JudgeUrlstringbyarr);
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
	if ( !empty($_REQUEST[ 'debug' ]) ) {
		$random = rand(0, intval($_REQUEST[ 'debug' ]) );
		if ( $random === 0 ) {
			header("HTTP/1.0 500 Internal Server Error");
			exit;
		}
	}
	@set_time_limit(5 * 60);
    //editor:gyq_152 reason:签到考情图片上传  2019/10/17 17:12
    global $weixin_user;
    if($_REQUEST['related_module'] == 'Singin' || $weixin_user->environment=='dingtalk'||$weixin_user->environment=='yunzhijia'
    ||$weixin_user->environment == 'app'){
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
        cls_StaticCommonFun::upload_save_file($_FILES['file']);
        exit;
    }
    $root_directory = globalStatic::$root_directory;
	$targetDir = $root_directory . 'storage/file_material_tmp/';	//文件分片存储目录
	//文件合并、下载目录   $uploadDir
	$related_record = $_REQUEST['related_record'];
    $related_module = $_REQUEST['related_module'];
	//目前只用于附件管理，如果相关对象不为空，则根据相关对象模块，单据id创建文件目录
    if(!empty($related_record) && !empty($related_module)){
        $uploadDir = $root_directory.'storage/'.$related_module.'/'.$related_record.'/';
        if(!file_exists($root_directory.'storage/'.$related_module)){
            mkdir($root_directory.'storage/'.$related_module,0777);
        } 
		if(!file_exists($uploadDir)){
			mkdir($uploadDir,0777);
		}
		$targetFolder = 'storage/'.$related_module.'/'.$related_record.'/';
    }else{
        // ljj 2024-11-21 XUQIU20241113-07 week目录改成day目录
        //小程序 拍名片/客户服务单签名图片
        $fyear=date("Y");
        $fmonth=date('F');
        $fday=date('j');//获取当前月份第几天
        $fweek='week'.ceil($fday/7);//获取当前日期所属月份的第几周
        if(!file_exists($root_directory.'storage/'.$fyear)){
             mkdir($root_directory.'storage/'.$fyear,0777);
        }
        if(!file_exists($root_directory.'storage/'.$fyear.'/'.$fmonth)){
             mkdir($root_directory.'storage/'.$fyear.'/'.$fmonth,0777);
        }
		if(!file_exists($root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday)){
             mkdir($root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday,0777);
        }
        $uploadDir=$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		$targetFolder = 'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
    }
	$cleanupTargetDir = true;	//删除分片文件  true false
    $maxFileAge = 5 * 3600;
	if (!file_exists($targetDir)) {
		@mkdir($targetDir);
	}
    //获取文件名称
    $fileinfo = json_decode($_REQUEST['file_info'],true);
    $fileName = $fileinfo["name"];
    $fileName= FileFileterString($fileName);//edit:can 20200824 文件特殊字符串过滤，安全性检测
    //editor:gyq_97 reason:小程序附件上传  2019/1/11 16:19
    $file_type = strrchr($fileName,'.');
    $time = time();
    $rand = mt_rand(1, 100000);
    $fileName = $time . $rand.$file_type;

	$fileName=str_replace(" ","_",$fileName);
    
	if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
	{
	}else{
		$arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
		$encode=mb_detect_encoding($fileName, $arr); 
		if($encode=='UTF-8'){
			$fileName=iconv('UTF-8','gbk',$fileName);
		}
	}
	$oldName = $fileName;
	$filePath = $targetDir . DIRECTORY_SEPARATOR . $fileName;//文件路径

	$chunk = isset($_REQUEST["chunk"]) ? intval($_REQUEST["chunk"]) : 0;//当前上传片数
	$chunks = isset($_REQUEST["chunks"]) ? intval($_REQUEST["chunks"]) : 1;//总片数
	if ($cleanupTargetDir) {
		if (!is_dir($targetDir) || !$dir = opendir($targetDir)) {
			ConvertTojsonString(-1,'fail',getFixedLabel('PARTITIONFILENOTEXIST'));
		}
		while (($file = readdir($dir)) !== false) {
			$tmpfilePath = $targetDir . DIRECTORY_SEPARATOR . $file;
			// 如果临时文件是当前文件，则继续进行下一个
			if ($tmpfilePath == "{$filePath}_{$chunk}.part" || $tmpfilePath == "{$filePath}_{$chunk}.parttmp") {
				continue;
			}
			//filemtime 返回文件内容上次的修改时间
			if (preg_match('/\.(part|parttmp)$/', $file) && (@filemtime($tmpfilePath) < time() - $maxFileAge)) {
				@unlink($tmpfilePath);
			}
		}
		closedir($dir);
	}
	// 创建分片文件
	if (!$out = @fopen("{$filePath}_{$chunk}.parttmp", "wb")) {
		ConvertTojsonString(-1,'fail',getFixedLabel('CANNOTOPENSHARDFILE'));
	}
	if (!empty($_FILES)) {
		if ($_FILES["file"]["error"] || !is_uploaded_file($_FILES["file"]["tmp_name"])) {
			ConvertTojsonString(-1,'fail',getFixedLabel('UPLOADEDFILESCANNOTBEMOVED'));
		}
		// 只读方式打开一个二进制的文件
		if (!$in = @fopen($_FILES["file"]["tmp_name"], "rb")) {
			ConvertTojsonString(-1,'fail',getFixedLabel('FAILEDTOOPENFILE'));
		}
	} else {
		if (!$in = @fopen("php://input", "rb")) {
			ConvertTojsonString(-1,'fail',getFixedLabel('FAILEDTOOPENFILE'));
		}
	}
	//fread(file,length) file 读取打开的文件  length 要读取的最大字节数
	while ($buff = fread($in, 4096)) {
		fwrite($out, $buff);
	}
	@fclose($out);
	@fclose($in);
	rename("{$filePath}_{$chunk}.parttmp", "{$filePath}_{$chunk}.part");
	$index = 0;
	$done = true;
	//判断附件的分片是否已传输完毕
	for( $index = 0; $index < $chunks; $index++ ) {
		if ( !file_exists("{$filePath}_{$index}.part") ) {
			$done = false;
			break;
		}
	}
	if ( $done ) {
		$pathInfo = pathinfo($fileName);
		$hashStr = substr(md5($pathInfo['basename']),8,16);
		//$hashName = time() . $hashStr . '.' .$pathInfo['extension'];
		//合并 - 附件名称
		$hashName = $oldName;
		$hashName = str_replace('"', '', $hashName);
		$hashName = str_replace("'", '', $hashName);
       
		$uploadPath = $uploadDir . DIRECTORY_SEPARATOR .$hashName;
        
		if (!$out = @fopen($uploadPath, "wb")) {
			ConvertTojsonString(-1,'fail','{"jsonrpc" : "2.0", "error" : {"code": 102, "message": "Failed to open output stream."}, "id" : "id"}');
		}
		if ( flock($out, LOCK_EX) ) {
			for( $index = 0; $index < $chunks; $index++ ) {
				if (!$in = @fopen("{$filePath}_{$index}.part", "rb")) {
					break;
				}
				while ($buff = fread($in, 4096)) {
					fwrite($out, $buff);
				}
				@fclose($in);
				@unlink("{$filePath}_{$index}.part");
			}
			flock($out, LOCK_UN);
		}
		@fclose($out);
		$filename = iconv('gb2312','UTF-8',$oldName);
		$response =array (
			'filename'=>$filename,
			'filepath'=>$targetFolder,//$uploadDir
			'filesize'=>$fileinfo['size'],
			'filetype'=>$fileinfo['type'],
			'filesuffixes'=>$pathInfo['extension'],
			'newfile_name'=>$filename
		);
		ConvertTojsonString(1,array('list'=>$response),'');
	}
?>