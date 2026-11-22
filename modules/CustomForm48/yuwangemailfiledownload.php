<?php
/********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/


global $adb;

$record = $_REQUEST['record'];
$name = $_REQUEST['filename'];
$filePath = $root_dir."storage/mail/yuwangEmail/"; //eml目录  文件名为record.eml
$attachPath = $root_dir."storage/mail/yuwangEmail/attach/"; //附件目录

$fileContent = file_get_contents($attachPath.$name);


header("Content-type: $fileType");
header("Pragma: public");
header("Cache-Control: private");
/*
EDIT:cAN
DATE:20130426
REASON;解决中文文件名称乱码
*/
//iconv("UTF-8",'gb2312',$name)

if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix' || strtolower(PHP_OS) == 'macos') {
    header("Content-Disposition: attachment; filename=" . $name);
} else {
    header("Content-Disposition: attachment; filename=" . mb_convert_encoding($name, 'GB2312', 'UTF-8'));
}
//header("Content-Disposition: attachment; filename=\"".$name."\"");
header("Content-Description: PHP Generated Data");
header('Content-Encoding: none');
header("Content-Transfer-Encoding: binary");
//**********************************
/*
edit:can
date:20130424
reason:0003461: "知识管理"上传word作为附件后，再下载，下载完成后，无法打开，希望修改。
*/
ob_clean();
flush();
//*********************************
echo $fileContent;


?>