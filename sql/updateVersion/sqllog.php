<?php
  //下载文件
  $file_name="updatelog.txt";
  $file_dir="../../storage/";
  $file = fopen($file_dir.$file_name,"r"); 
  Header("Content-type: application/octet-stream");
  Header("Accept-Ranges: bytes");
  Header("Accept-Length: ".filesize($file_dir . $file_name));
  $strDate= "错误详情.txt";
  Header("Content-Disposition: attachment; filename=" . $strDate);
  echo fread($file, filesize($file_dir.$file_name));
?>