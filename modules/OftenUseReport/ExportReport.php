<?php
$modulelabel = $_REQUEST['modulelabel'];
$modulelabel=getFixedLabel($modulelabel);
$file_name = 'OftenUseReport.xls';
$file_dir = './storage/';

$modulelabel=iconv('utf-8','gb2312',$modulelabel);
//обтьнд╪Ч
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir.$file_name));
Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
Header("pragma: no-cache");
ob_clean();
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
?>