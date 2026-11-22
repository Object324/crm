<?php
global $adb;

if(!$adb)
{
    exit();
}
if(isLoginCrm()=='no')
{
    return ;
}
ob_get_clean();
$pathfile=$_REQUEST['pathfile'];//带路径的文件名


crm_load_class_file("cls_MyCRMcrypt",'Register');
$crptobj=new cls_MyCRMcrypt();

$pathfile=$crptobj->decode($pathfile);

$rand=substr($pathfile,-7);//获取随机数
 
$pathfile=substr($pathfile,0,-7);
 
if($_SESSION["ziprand"]!=$rand||$_SESSION["ziprand"]=='')
{
      echo 'sorry  rand session';
     die;
}

if(!file_exists(globalStatic::$root_directory.$pathfile)){
    echo '文件不存在';
    die;
}
 
unset($_SESSION["ziprand"]);
//设置区域否则basename不支持中文
setlocale(LC_ALL, 'zh_CN.GBK');
$fileName = basename($pathfile);
/*$disk_file_size = filesize($pathfile);
$diskfilesize = $disk_file_size + ($disk_file_size % 1024); //文件大小

$fp=fopen($pathfile,'r');//只读方式打开
$filesize=filesize($pathfile);//文件大小

//返回的文件(流形式)
header("Content-type: application/octet-stream");
//按照字节大小返回
header("Accept-Ranges: bytes");
//返回文件大小
header("Accept-Length: $filesize");
//这里客户端的弹出对话框，对应的文件名
header("Content-Disposition: attachment; filename=".$fileName);

//================重点====================
ob_clean();
flush();

echo file_get_contents($pathfile);*/


//BUG0076909 ls 20231208 售合同/协议管理模块>批量勾选（勾选第一页100条）>更多>下载全部附件>解压下载的压缩包的时候报错。原来的方式无法下载大文件(715MB)
// 设置响应头，告诉浏览器这是一个文件下载
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="' . $fileName . '"');
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');
header('Content-Length: ' . filesize($pathfile));

// 打开文件进行读取
$file = fopen($pathfile, 'rb');

// 输出文件内容
while (!feof($file)) {
    echo fread($file, 1024);
    ob_flush(); // 刷新输出缓冲
    flush();    // 强制将缓冲区的内容发送到浏览器
}

// 关闭文件
fclose($file);

// 退出脚本
exit;

//或者(都测试过,下载成功)

/*ob_clean();// 清空输出缓冲区
header('Content-Type: application/zip');//设置响应头，告诉浏览器这是一个zip文件下载
header('Content-Disposition: attachment; filename="' . $fileName . '"');
header('Content-Length: ' . filesize($pathfile));
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');

// 直接输出文件内容
readfile($pathfile);
// 退出脚本
exit;*/
?>

