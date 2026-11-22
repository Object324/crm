<?php

/*********************************************************************************
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
$uploaddir = $root_directory ."/dataCache/test/logo/" ;

$file_name = from_html($_REQUEST['imgname_big']);
$imgurl = from_html($_REQUEST['imgurl_big']);
$prev_file = from_html($_REQUEST['prev_file_big']);
//判断是否有修改图片
if ($imgurl !=""){
    if ($prev_file != "logo_big_white.png" && $prev_file != "logo_mini_1.png" ){
        unlink($uploaddir.$prev_file); // 删除之前的文件，但不能删除默认logo
    }
    $pathInfo = pathinfo($file_name);
    $name = $pathInfo['filename'];
    $file_name = $name. '.png';
    $file_counter = 1;
    while(file_exists($uploaddir . '/' . $file_name)){
        //防止与已有文件冲突
        $file_name = $name . '('.$file_counter.').png';
        $file_counter++;
    }

    $prmlogoname = $file_name;

    $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
    $encode=mb_detect_encoding($file_name, $arr);
    if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
    {
        //获取系统类型，如果是非windows系统则不用修改编码格式
    }
    else if($encode!=='UTF-8')
    {
        $file_name=mb_convert_encoding($file_name,'UTF-8',$encode);
    }
    //将base64转为文件存入文件夹
    $Imgbase64 = str_replace('data:image/png;base64,', '', $imgurl);
    $file = fopen($uploaddir.$file_name,"wb");
    $decodeFile = base64_decode($Imgbase64);
    $bytes_written = fwrite($file, $decodeFile);
    fclose($file);
}else{
    $prmlogoname = $prev_file;
}

$sql = 'update ld_organizationdetails set prmlogoname = ?;';
$adb->pquery($sql,array($prmlogoname));

ConvertTojsonString(1,array('prmlogoname'=>$prmlogoname),"success");

?>