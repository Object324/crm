<?php
/***************************************************
**更新操作
**edit:chj
**date:2019-05-29
**reason:选择、更改颜色
***************************************************/

global $adb,$theme,$mod_strings,$current_user;
$menuback = '#'.$_REQUEST['menuback'];	//菜单背景色
$menuhover = '#'.$_REQUEST['menuhover'];	//菜单选中背景色
$menustyle = $_REQUEST['menustyle'];
$query = 'update ld_organizationdetails set menuback_color = ?,menuhover_color = ?,menustyle = ?';
$adb->pquery($query,array($menuback,$menuhover,$menustyle));

$query = 'INSERT INTO 00_stylechangelog(userid,changetime,menuback_color,menuhover_color,menustyle) SELECT ?,NOW(),?,?,?';
$adb->pquery($query,array($current_user->id,$menuback,$menuhover,$menustyle));

create_parent_language();
if(function_exists('opcache_invalidate')){
	opcache_invalidate(globalStatic::$root_directory.'dataCache/tabdatas/parent_language.php',true);
}
unsetCacheDirectory('MenuColor');
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");

?>