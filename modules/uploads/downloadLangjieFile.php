<?php
/**
 * 特殊备注，朗捷服务器不支持GBK，和GB2312编码 默认中文是EUC-CN  文件名需要特殊转换
 */
ob_get_clean();
global $current_user;
$from_module = $_REQUEST['frommodule'];
unset($_SESSION[$from_module][$current_user->id]['export']);
$modulelabel = getTranstab($from_module);
$fileName =$_REQUEST['fileName'];
$pathname = 'storage/downCacheFile/' . $fileName;
$pathname = iconv('UTF-8','EUC-CN',$pathname);
$disk_file_size = filesize($pathname);
$diskfilesize = $disk_file_size + ($disk_file_size % 1024);

$fp = fopen($pathname, "r");
//$fileContent = fread(fopen($pathname, "r"), $diskfilesize);
if ($_REQUEST['exportformat'] == 'exportxls') {
    header("Content-type:application/vnd.ms-excel");
} else {
    header("Content-type:application/octet-stream");
}

header("Pragma: public");
header("Cache-Control: private");
file_put_contents("storage/agent.txt", $_SERVER['HTTP_USER_AGENT']);
if (stripos($_SERVER['HTTP_USER_AGENT'], 'edge') !== false)//edge浏览器(win10自带)
    if ($_REQUEST['exportformat'] == 'exportxls') {
        header("Content-Disposition: attachment; filename=" . urlencode($fileName));
    } else {
        header("Content-Disposition: attachment; filename=" . urlencode($fileName));
    }


if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix' || strtolower(PHP_OS) == 'macos') {
    if ($_REQUEST['exportformat'] == 'exportxls') {
        header("Content-Disposition: attachment; filename=" . $fileName);
    } else
        header("Content-Disposition: attachment; filename=" . $fileName);
} else {
    if (isIE() !== false) {
        if ($_REQUEST['exportformat'] == 'exportzip') {
            header("Content-Disposition: attachment; filename=" . mb_convert_encoding($fileName, 'GB2312', 'UTF-8'));
        } else {
            header("Content-Disposition: attachment; filename=" . mb_convert_encoding($fileName, 'GB2312', 'UTF-8'));
        }

    } else {
        if ($_REQUEST['exportformat'] == 'exportzip') {
            header("Content-Disposition: attachment; filename=" . $fileName );
        } else
            header("Content-Disposition: attachment; filename=" . $fileName );
    }
}

//header("Content-Disposition: attachment; filename=".iconv("UTF-8",'gbk',$modulelabels).'.xlsx');
header("Content-Description: PHP Generated Data");
header('Content-Encoding: none');
header("Content-Transfer-Encoding: binary");
ob_clean();
flush();
//echo $fileContent;
$buffer = 1024;
$file_count = 0;
//向浏览器返回数据
while (!feof($fp) && $file_count < $diskfilesize) {
    $file_con = fread($fp, $buffer);
    $file_count += $buffer;
    echo $file_con;
}
fclose($fp);
exit();
function isIE()
{
    $isIE = strpos($_SERVER['HTTP_USER_AGENT'], "Triden");
    return $isIE;
}

?>