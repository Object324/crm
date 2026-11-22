<?php
ob_get_clean();
global $current_user;
$from_module=$_REQUEST['frommodule'];
unset($_SESSION[$from_module][$current_user->id]['export']); 
if($_REQUEST['exportformat']=='exportcsv')
{
    $pathname='storage/'.$current_user->id.'_'.$from_module.'.csv';
} else
    $pathname='storage/'.$current_user->id.'_'.$from_module.'.xls';

if($_REQUEST['fromtype']=='operationlogs'){
    $pathname = $_REQUEST['pathname'];
}

$modulelabel=getTranstab($from_module);
//$modulelabel = mb_convert_encoding($modulelabel, 'UTF-8', 'gbk');

preg_match_all('/[\s\x{4e00}-\x{9fff}a-zA-Z0-9#\[\]\{\}\'\"=+\-\(\)*&%$@]+/iu', $modulelabel, $matches);
$modulelabels = join('', $matches[0]);
$modulelabels=str_replace(" ",'_',$modulelabels);
//chj  2022/6/15  浩辰特殊开发， 合同拆分 xls命名 文件名称为：“拆分报表_2022-01_2022-02
$version_info = getVersionInfo();
if($version_info['account'] == 'haochen'){
	$modulelabels = '拆分报表_' . $_SESSION[$from_module][$current_user->id]['haochen_export']['start_date'].'_'.$_SESSION[$from_module][$current_user->id]['haochen_export']['end_date'];
}
//首页穿透导出,文件名与路径名与其他不同(目前只有导出xls)
if($_REQUEST['export_chuantou']=='yes'){
    $pathname='storage/'.$current_user->id.'_'.$from_module.'_chuantou.xls';
    $modulelabels=str_replace(">", "_",$_REQUEST['title']);
}
//详情页导出,文件名与路径名与其他不同(目前只有导出xls)
if($_REQUEST['export_related']=='yes'){
    $pathname='storage/'.$current_user->id.'_'.$from_module.'_related.xls';
    $modulelabels='“映射模块”统计表';
}
// sql、模块报表导出
if($_REQUEST['export_type']=='report'){
    $report_name = $_REQUEST['report_name'];

    if($_REQUEST['exportformat']=='exportcsv')
    {
        $pathname='storage/'.$current_user->id.'_'.$report_name.'.csv';
    } else
        $pathname='storage/'.$current_user->id.'_'.$report_name.'.xls';
    $modulelabels=$report_name;
}

$disk_file_size = filesize($pathname);
$diskfilesize = $disk_file_size + ($disk_file_size % 1024);

$fp=fopen($pathname, "r");
//$fileContent = fread(fopen($pathname, "r"), $diskfilesize);

header("Content-type:application/vnd.ms-excel");
header("Pragma: public");
header("Cache-Control: private");
file_put_contents("storage/agent.txt",$_SERVER['HTTP_USER_AGENT']);
if(stripos($_SERVER['HTTP_USER_AGENT'],'edge')!==false)//edge浏览器(win10自带)
    header("Content-Disposition: attachment; filename=".urlencode($modulelabels).".xls");
else


if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'||strtolower(PHP_OS)=='macos'){
    if($_REQUEST['exportformat']=='exportcsv') {
        header("Content-Disposition: attachment; filename=".$modulelabels.'.csv');
    } else
        header("Content-Disposition: attachment; filename=".$modulelabels.'.xls');
}else{
    if(isIE()!==false) {
         if($_REQUEST['exportformat']=='exportcsv') {
            header("Content-Disposition: attachment; filename=".mb_convert_encoding($modulelabels,'GB2312','UTF-8').".csv");
        } else
            header("Content-Disposition: attachment; filename=".mb_convert_encoding($modulelabels,'GB2312','UTF-8').".xls");
    } else {
         if($_REQUEST['exportformat']=='exportcsv') {
            header("Content-Disposition: attachment; filename=".$modulelabels.".csv");
        } else
            header("Content-Disposition: attachment; filename=".$modulelabels.".xls");
    }
}
//header("Content-Disposition: attachment; filename=".iconv("UTF-8",'gbk',$modulelabels).'.xls');
header("Content-Description: PHP Generated Data");
header('Content-Encoding: none');       
header("Content-Transfer-Encoding: binary" );
ob_clean();   
flush(); 
//echo $fileContent;
$buffer=1024;
$file_count=0;
//向浏览器返回数据
while(!feof($fp) && $file_count<$diskfilesize){
    $file_con=fread($fp,$buffer);
    $file_count+=$buffer;
    echo $file_con;
}
fclose($fp); 
exit();
function isIE() {
    $isIE = strpos($_SERVER['HTTP_USER_AGENT'],"Triden");
    return $isIE;   
}
?>