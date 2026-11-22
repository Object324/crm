<?php
//上传文件删除
global $adb;
if(!empty($_REQUEST['fileName']) && !empty($_REQUEST['filePath'])){
	$root_directory=str_replace("\\", '/', $root_directory);
	$targetDir = $root_directory . $_REQUEST['filePath'];
	$file_name=str_replace(" ","_",urldecode($_REQUEST['fileName']));
//	$file_name=mysql_real_escape_string($file_name);
  //  echo $targetDir;
//	if (!is_dir($targetDir) || !$dir = opendir($targetDir)) {
	//	echo 'error';die;
//	}else{
    if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
			
    }else{
            $file_name= iconv('utf-8', 'gbk',$file_name);
    }
    $filePath = $targetDir . $file_name;//文件路径
   	unlink($filePath);
    echo 'success';die;
		
//	}
}
?>