<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * Indirect 2张报表增加导出 2016-10-31

 * Description: Liver

 ********************************************************************************/
$file_name = $_REQUEST['frommodule'].".xls";
$file_dir = 'storage/';

//下载文件
if   (!file_exists($file_dir.$file_name))   {   //检查文件是否存在 
  echo   "文件找不到"; 
  exit;   
  } 
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir.$file_name));
//Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
Header("Content-Disposition: attachment; filename=".$file_name );

Header("pragma: no-cache");
ob_clean();
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
?>