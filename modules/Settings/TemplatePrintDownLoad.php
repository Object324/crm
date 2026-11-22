<?php


$file_dir='modules/Settings/';
$file_name='templateprint.pdf';
        // 输入文件标签
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));
Header("Content-Disposition: attachment; filename=" . "templateprint.pdf");
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);

?>