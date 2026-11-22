<?php
/**
* @edit:dong
* @data:2020/08/26
* @reason:小程序商城顶部设置
* @description:
*/
global $adb;
$type =$_REQUEST['type'];
$_REQUEST['diony']='yes';
if($type =='save'){
    $path ="/storage/minimallBanner/";
    $uploaddir = $root_directory .$path;

    if(!file_exists($uploaddir)){
        mkdirs($uploaddir);
    }
    $filetype= $_FILES['wxmall_banner_path']['type'];
    $ffilesize = $_FILES['wxmall_banner_path']['size'];
    $filetype_array=explode("/",$filetype);
    $file_type_val=strtolower($filetype_array[1]);
    $errorCode =  $_FILES['wxmall_banner_path']['error'];

    if($ffilesize != 0 && $errorCode ==0)
    {
        if (($file_type_val == "jpeg" ) || ($file_type_val == "png") || ($file_type_val == "jpg" ) ||  ($file_type_val == "gif" ) || ($file_type_val == "bmp")|| ($file_type_val == "ico") ) //Checking whether the file is an image or not
        {
            $imgStatus="true";
        }
        else
        {
            $imgStatus="false";
            $error_flag ="上传正确格式";
        }
    }
    else
    {
        $imgStatus="false";
        $error_flag ="图片上传错误";
    }

    if($imgStatus!="true")
    {
        ConvertTojsonString(0,array('error_flag'=>$error_flag),"fail");
    }

    $newfilename= uniqid().'.'.$file_type_val;
    move_uploaded_file($_FILES['wxmall_banner_path']["tmp_name"],$uploaddir.$newfilename);

    $url = $_REQUEST['wxmall_banner_url'];
    $sequence = $adb->pquery('SELECT max(sequence) as sequence FROM ld_wxshoppingmall_banner');
    $sequence =$adb->query_result($sequence,0,'sequence');
    $sql ='insert into ld_wxshoppingmall_banner (filename,path,url,createdtime,sequence) value (?,?,?,?,?)';
    $adb->pquery($sql,array($newfilename,$path,$url,date('Y-m-d H:i:s'),$sequence+1));

}
if($type=='delete'){
    $id =$_REQUEST['id'];
    $sql ='DELETE FROM ld_wxshoppingmall_banner WHERE  id=?';
    $adb->pquery($sql,array($id));
}
ConvertTojsonString(1,$arr,"success");
?>