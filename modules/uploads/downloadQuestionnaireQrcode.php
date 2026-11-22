<?php
ob_get_clean();
global $current_user;
$pathfile=$_REQUEST['pathfile'];    //带路径的文件名
$userName =$_REQUEST['username'];

$disk_file_size = filesize($pathfile);
$diskfilesize = $disk_file_size + ($disk_file_size % 1024); //文件大小
$imgType = array(
    'gif'=>'image/gif',
    'jpg'=>'image/jpeg',
    'png'=>'image/png'
);
$filename= $userName.'_'.getTranstab('Questionnaire').getFixedLabel('SOCIALPROMOTIONQRCODE').'.png';
$contentType = $imgType['png'];
@ob_flush();
 //设置头信息
 header('Content-Disposition:attachment;filename=' . basename($filename));
header('Content-Length:' . filesize($filename));
//读取文件并写入到输出缓冲
@readfile($pathfile);
// @readfile(globalStatic::$root_directory.$pathfile);
?>