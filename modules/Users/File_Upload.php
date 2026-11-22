<?php
    header("Content-type: text/html; charset=utf-8");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");
    global  $adb;
    if(!isset($adb))
    {
       die('Login please');
    }

    //zkt 20231011 XUQIU1001341 SQL注入  -- 附件上传只判断部分参数
    $filejudgepramkeyarr =['module','action','frommodule','filerand','filename'];
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->setJudgeparamkeyarr($filejudgepramkeyarr);
    $JudgeUrlstringbyarr = array_merge($_REQUEST,array('filename'=>$_FILES['file']['name']));
    $cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($JudgeUrlstringbyarr);
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

    function myTrim($str)
{
 $search = array(" ","　","\n","\r","\t");
 $replace = array("_","_","_","_","_");
 return str_replace($search, $replace, $str);
}
$_REQUEST['diony']='diony';

require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
$cls_MyCRMcrypt = new cls_MyCRMcrypt();

	//判断表单传值方式
	if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
		exit;
	}
	if ( !empty($_REQUEST[ 'debug' ]) ) {
		$random = rand(0, intval($_REQUEST[ 'debug' ]) );
		if ( $random === 0 ) {
			header("HTTP/1.0 500 Internal Server Error");
			exit;
		}
	}
	@set_time_limit(5 * 60);
	$root_directory=str_replace("\\", '/', $root_directory);
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
	
        if(!file_exists($root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday))
        {
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
	if (isset($_REQUEST["name"])) {
		$fileName = $_REQUEST["name"];
	} elseif (!empty($_FILES)) {
		$fileName = $_FILES["file"]["name"];
	} else {
		$fileName = uniqid("file_");
	}
//酮  字替换
//$fileName = preg_replace('/酮/','tong',$fileName);
//    $fileName = iconv('UTF-8', 'GBK', $fileName);//解决中文名错误问题
    $fileParts = pathinfo($fileName);
   /* global $global_forbiddenext;
    
    if (in_array(strtolower($fileParts['extension']),$global_forbiddenext))
    {
        unset($_SESSION['fileuploadrand'.$current_user->id]);
        die('为了安全考虑，禁止上传该文件');
    }*/
    global $current_user;
    //43170: （本地crm）附件管理-附件-预览；版本8.2.9；图片带字符‘“·&%#无法预览；带或者不带特殊字符的doc，xlsx，xls的文件都无法预览；下载正常 带中文符号……的文件，预览丢失。
    $fileName=ChangeUploadFilename($fileName);
    //zkt 20240819 BUG20240814-59 客户反馈CRM上传的附件内容，点击预览提示文件丢失，请排查具体原因
    if(strpos($fileName,'\'')!==false){
        $fileName = str_replace('\'', '', $fileName);
    }
   $fileName= FileFileterString($fileName);//edit:can 20200824 文件特殊字符串过滤，安全性检测

   
   
	if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
	{
	}else{
		$arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
		$encode=mb_detect_encoding($fileName, $arr);

//        if($encode=='UTF-8'){
//			$fileName=iconv('UTF-8','gbk',$fileName);
//		}

        //ls 2022-03-02 0050221: （http://106.52.254.73:85/crm/index.php [^]）（客户问题）产品资料》编码42001.03.1020.04 编辑上传图片,文件名含“双支装”的图片上传错误(同一位utf-8格式)
        //	0050251: （http://47.100.0.33:88 [^]）（客户问题-徐燕男）附件上传，附件ppt“北京¥35,000.00合同”上传卡到100%，（需修改编码为utf8，gbk某些字符不支持，同时下载功能downloadfileself.php也应该保持使用utf8，否则下载的文件内容为空）
        if($encode != 'UTF-8'){
            if (function_exists("mb_convert_encoding")) {
                $fileName = @mb_convert_encoding($fileName, "UTF-8", $encode);
            } else {
                if (function_exists("iconv")) {
                    $fileName = @iconv($encode, "UTF-8" . "//IGNORE", $fileName);
                }
            }
        }
	}
	$oldName = $fileName;

if(!empty($_REQUEST['CooperativeWork']) && $_REQUEST['CooperativeWork']=='yes')
    {
        $newfile_name=getUploadFileName($fileName,"CooperativeWork");
    }
    else
    {
         //$newfile_name=getUploadFileName($fileName,$_REQUEST['frommodule']);
           $arr = explode('.',$fileName);
           $fileextname= array_pop($arr);//文件后缀名

        $tmpfileName=substr($fileName,0,strlen($fileName)-1-strlen($fileextname));
        $newfile_name=$_REQUEST['frommodule'].'_'.$tmpfileName.'_'.$_REQUEST['filerand'].'_'.$current_user->id.'.'.$fileextname;
        
    }
   //$newfile_name= FileFileterString($newfile_name);//edit:can 20200824 文件特殊字符串过滤，安全性检测

	$filePath = $targetDir . DIRECTORY_SEPARATOR . $newfile_name;//文件路径

	$chunk = isset($_REQUEST["chunk"]) ? intval($_REQUEST["chunk"]) : 0;//当前上传片数
	$chunks = isset($_REQUEST["chunks"]) ? intval($_REQUEST["chunks"]) : 1;//总片数
	if ($cleanupTargetDir) {
		if (!is_dir($targetDir) || !$dir = opendir($targetDir)) {
		 unset($_SESSION['fileuploadrand'.$current_user->id]);
			die('分片文件存储路径不存在或者无法打开！');
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
	   unset($_SESSION['fileuploadrand'.$current_user->id]);
		die('无法打开分片文件');
	}
	if (!empty($_FILES)) {
		if ($_FILES["file"]["error"] || !is_uploaded_file($_FILES["file"]["tmp_name"])) {
		 unset($_SESSION['fileuploadrand'.$current_user->id]);
			die('无法移动上传的文件');
		}
		// 只读方式打开一个二进制的文件
		if (!$in = @fopen($_FILES["file"]["tmp_name"], "rb")) {
		    unset($_SESSION['fileuploadrand'.$current_user->id]);
			die('打开、读取分片零时文件失败');
		}
	} else {
		if (!$in = @fopen("php://input", "rb")) {
		  unset($_SESSION['fileuploadrand'.$current_user->id]);
			die('打开、读取分片零时文件失败');
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
		$hashName = $newfile_name;
		$hashName = str_replace('"', '', $hashName);
		$hashName = str_replace("'", '', $hashName);
		$uploadPath = $uploadDir . DIRECTORY_SEPARATOR .$hashName;
		if (!$out = @fopen($uploadPath, "wb")) {
		 unset($_SESSION['fileuploadrand'.$current_user->id]);
			die('{"jsonrpc" : "2.0", "error" : {"code": 102, "message": "Failed to open output stream."}, "id" : "id"}');
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
       
		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
			
		}else{
		//	if(!empty($_REQUEST['CooperativeWork']) && $_REQUEST['CooperativeWork'] == 'yes'){
//				$oldName = iconv('gbk','UTF-8',$oldName);
//                $newfile_name = iconv('gbk','UTF-8',$newfile_name);
				/*$encode = mb_detect_encoding($newfile_name, 'GBK, gb2312, GB18030, ISO-8859-1, ASCII, UTF-8', true);
				//$oldName = iconv('gb2312','UTF-8',$oldName);
                //$newfile_name = iconv('gb2312','UTF-8',$newfile_name);
				$oldName = mb_convert_encoding($oldName, 'UTF-8', $encode);
                $newfile_name = mb_convert_encoding($newfile_name, 'UTF-8', $encode);*/
			//}
		}
        //edit: xll BUG0064357 周计划、任务中图片无法正常显示
        $isEncrypt = (isset($_REQUEST['isEncrypt']) && !empty($_REQUEST['isEncrypt'])) ? $_REQUEST['isEncrypt'] : 'yes';

		$response =array (
        'newfile_name'=>($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> encode($newfile_name) : $newfile_name,//$newfile_name,
		  'success'=>true,
			'oldName'=>$oldName,
			'filePaht'=>($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> encode($targetFolder) : $targetFolder,//$targetFolder,
            'isEncrypt'=> $isEncrypt,
			'fileSize'=>$_FILES["file"]['size'],
			'fileType'=>$_FILES["file"]['type'],
			'fileSuffixes'=>$pathInfo['extension']
		);
		if(!empty($_REQUEST['CooperativeWork']) && $_REQUEST['CooperativeWork'] == 'yes'){
			global $adb;
            if($_REQUEST['uitype']==69)
            {
                $type='image';
                
            }
            else
            {
                 $type='att';
            }
			//$response['filePaht'] = $targetFolder;// = substr($targetFolder, 3);
            $response['filePaht'] = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> encode($targetFolder) : $targetFolder;
			$query = 'insert into ld_workachments(newfile_name,name,type,path,size) 
						values("'.$newfile_name.'", "'.$_FILES["file"]['name'].'","'.$type.'","'.$targetFolder.'","'.$_FILES["file"]['size'].'");';
		
            $adb->pquery($query,array());
			$response['record'] = $adb->getLastInsertID();
            $response['fileid'] = $adb->getLastInsertID();
		}
        $size = $_FILES["file"]['size'];
        if ($size < 1024)
            $size = $size . ' B';
        else if ($size > 1024 && $size < 1048576)
            $size = round($size / 1024, 2) . ' KB';
        else if ($size > 1048576)
            $size = round($size / 1024, 2) . ' MB';
        $file = array('id'=>$_REQUEST['id'] . '_','storage_location'=>'local','httppath'=>''
            ,'pre_path'=>$targetFolder.$newfile_name,'name'=>$oldName,'type'=>$_REQUEST['type']
            ,'size'=>$size,'isEncrypt'=>'yes','path'=>$response['filePaht']
            ,'newfile_name'=>$response['newfile_name']);
        crm_load_class_file('AttachmentUtils','modules/Attachment');
        $response['pre_button'] = AttachmentUtils::getPreviewButton($file);

        //unset($_SESSION['fileuploadrand'.$current_user->id]);
		die(json_encode($response));
	}
  // Return Success JSON-RPC response
	die('分片'.$filePath.'_'.$chunk.'.part'.' 上传成功');
    
  
?>