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
$menufont = '#'.$_REQUEST['menufont'];	//自定义 字体颜色
$background = '#'.$_REQUEST['background'];	//背景颜色
setUsersettingByLabel('notbymodule',$current_user->id,'Menuback_color',$menuback);
setUsersettingByLabel('notbymodule',$current_user->id,'Menuhover_color',$menuhover);
setUsersettingByLabel('notbymodule',$current_user->id,'Menustyle',$menustyle);
setUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color',$menufont);
setUsersettingByLabel('notbymodule',$current_user->id,'Background_color',$background);

$cachekey = 'updateMenuStyleinfo';
$menustyleinfo = CacheDirectory($cachekey,'MenuStyleinfo');
if(empty($menustyleinfo)){
    $menustyleinfo = array();
}
$menustyleinfo[$current_user->id] = array(
    'Menuback_color'=>$menuback,
    'Menuhover_color'=>$menuhover,
    'Menufont_color'=>$menufont,
    'Menustyle'=>$menustyle,
    'Background_color'=>$background
);
CacheDirectory($cachekey,'MenuStyleinfo',$menustyleinfo);


$query = 'INSERT INTO 00_stylechangelog(userid,changetime,menuback_color,menuhover_color,menustyle,menufont,background_color) SELECT ?,NOW(),?,?,?,?,?';
$adb->pquery($query,array($current_user->id,$menuback,$menuhover,$menustyle,$menufont,$background));

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");
?>