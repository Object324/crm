<?php
header("Content-type: text/html; charset=utf-8");
include_once('./include/utils/CacheInfo.php');
$cachekey = 'cache_delete_backup_dumpsql';
$delbackup = MemoryCache($cachekey);
$cachekey = 'cache_delete_backup_backuppath';
$backuppath = MemoryCache($cachekey);
$backupfile = 'dbbackup';


if(empty($delbackup)) die;
$delbackday = explode('beforedays_',$delbackup);
$delbackday = $delbackday[1];
$cachepath = $backuppath;
chmod($cachepath, 0777);
$folder = @opendir($cachepath);
if($cachepath{strlen($cachepath)-1} != '/')
	$cachepath .= '/';
if ($folder == false) die;
$count = 0;
$isfile = array('.'=>'1','..'=>'1','index.html'=>'1','index.htm'=>'1');
$backdate = '';$nowdate = date('Y-m-d',time());$countday = '';
while(false !== ($file = readdir($folder))){
	if(isset($isfile[$file])) continue;//不可删除
	if(is_file($cachepath.$file)){
		$filearr = explode('.',$file);
		if(count($filearr) != 2 || $filearr[1] != 'sql') continue;//必须是sql类型
		$filearr = explode('_',$filearr[0]);
		if(count($filearr) != 2 || $filearr[0] != $backupfile) continue;//格式不标准
		$backdate = $filearr[1];
		$countday = count_days($backdate,$nowdate);
		if($countday > 0 && $countday > $delbackday){//相差天数大于设置天数，则删除
			chmod($cachepath.$file, 0777);
			if (@unlink($cachepath.$file)) ++$count;
		}
	}
}
closedir($folder);

/**
 * 计算两个时间相差天数
 * @author Tujt 2014-10-27
 */
function count_days($date1,$date2) {
	$d1 = strtotime($date1);
	$d2 = strtotime($date2);
	$days = round(($d2-$d1)/3600/24);
	return $days;
}
?>