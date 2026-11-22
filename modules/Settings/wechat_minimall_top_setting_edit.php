<?php
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'WeiXinApp/minipro/const_mini.php';
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
$smarty =new  lingdangCRM_Smarty();
$needArr = array('miniprogram_title','top_nav_text_color','top_nav_background_color');
$sql = "SELECT
	name,value
FROM
	ld_wxshoppingmall_config
WHERE
	name IN ( 'miniprogram_title', 'top_nav_text_color', 'top_nav_background_color' )
	";
$result = $adb->pquery($sql);
if($num_row = $adb->num_rows($result)){
    for ($i=0;$i<$num_row;$i++){
        $name =$adb->query_result($result,$i,'name');
        $$name = $adb->query_result($result,$i,'value');
    }
    foreach ($needArr as $value){
        $smarty->assign($value,$$value);
    }
}
if($_REQUEST['mode']=='save'){
    foreach ($needArr as $value){
        $$value = $_REQUEST[$value];
        $sql = 'UPDATE ld_wxshoppingmall_config SET value=?,createdtime=? WHERE name=?';
        $a =$$value;
        $result = $adb->pquery($sql,array($$value,date('Y-m-d H:i:s',time()),$value));
    }
    ConvertTojsonString(1,array(),'小程序设置更新成功');
}

$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("LBL_APPLET_TOP_SETTINGS");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/wechat_minimall_top_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

?>