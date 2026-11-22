<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //下载文件
require_once('config.php');

global $adb,$current_user;
$attachmentsid=$_REQUEST['fildid'];

$dbQuery = "SELECT name,path,newfile_name,storage_location,cloud_path FROM ld_workachments WHERE achmentid = ?" ;

$result = $adb->pquery($dbQuery, array($attachmentsid));
if($adb->num_rows($result) == 1)
{
	$file_name = $adb->query_result($result, 0, "name");
	$file_dir = $adb->query_result($result, 0, "path");
    $newfile_name = $adb->query_result($result, 0, "newfile_name");
    $cloud_path=$adb->query_result($result,0,'cloud_path');
    $storage_location=$adb->query_result($result,0,'storage_location');
    $rigin_cloud_path=$cloud_path;
}

if($storage_location=='cos')
{
    //editor:gyq_169 reason:下载云端文件   2020/3/3 16:49
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $filepath = $cloud_path;
        $rigin_cloud_path=$cloud_path;
        $paths=explode("/",$cloud_path);
        $cloud_path='';
        for($i=0;$i<sizeof($paths)-1;$i++)
        {
            $cloud_path.=$paths[$i].'/';
        }
       $cloud_path.=urlencode($paths[$i]);
  
        $header_response = get_headers($cloud_path, 1);
      
        //61mis.com/kfbcrm)客户问题（四方光电）附件管理模块>选择编号为“ATT99”单据详情界面：附件名称含“+不能法预览和下载（需要补丁
        if(strpos( $header_response[0], "404" ) !== false)
        {
          
            $header_response = get_headers($rigin_cloud_path, 1);
            $cloud_path=$rigin_cloud_path;
              dump($rigin_cloud_path);
        }
          
        if ( strpos( $header_response[0], "404" ) !== false ){
            exit('文件丢失');
        }
        
        
            
        if ( strpos( $header_response[0], "404" ) === false ){
            $_GET['temp_saved_filename'] = $tmpsaved_filename;
            
            downloadCloudFile($cloud_path);
        }
        
        ob_flush();
        ob_clean();
        exit;
}
if(strstr(PHP_OS,'WIN')){
    $newfile_name=iconv ( 'UTF-8', 'GBK', $newfile_name );
}else{
     $newfile_name= $newfile_name;
}
$file = fopen($file_dir.$newfile_name,"r"); 

Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir.$newfile_name));
header("Pragma: public");
header("Cache-Control: private");
if(strstr(PHP_OS,'WIN')){
    Header("Content-Disposition: attachment; filename=".$file_name);
}else{
    Header("Content-Disposition: attachment; filename=".iconv("UTF-8",'gb2312',$file_name));
}


header('Content-Encoding: none');       
header("Content-Transfer-Encoding: binary" );
ob_get_clean();
ob_clean();   
flush(); 

echo fread($file, filesize($file_dir.$newfile_name));
fclose($file);
exit();

?>