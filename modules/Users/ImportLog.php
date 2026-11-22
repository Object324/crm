<?php



global $adb;
global $fileId, $default_charset;
global $current_user;
if(!globalStatic::$root_directory)
{
    exit();
}
$module= $_REQUEST['module'];
$stri='storage';
$modulelabel=getTranstab($module).'导入日志.txt';
$saved_filename='importlog_'.$module.'_'.$current_user->id.'.txt';
$stri.='/'.$saved_filename;
$disk_file_size = filesize($stri);
  /*  }*/
  
$diskfilesize = $disk_file_size + ($disk_file_size % 1024);

$fileContent = fread(fopen($stri, "r"), $diskfilesize);


header("Content-type: application/ocet-stream");
header("Pragma: public");
header("Cache-Control: private");
 //iE:下载中文乱码
header("Content-Disposition: attachment; filename=".$modulelabel);//iconv ( 'UTF-8', 'GBK', $name )
header("Content-Description: PHP Generated Data");
header('Content-Encoding: none');       
header("Content-Transfer-Encoding: binary" );
ob_clean();   
flush(); 
      //********************************* 
echo $fileContent;
exit();
     


?>

