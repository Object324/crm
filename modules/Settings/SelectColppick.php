<?php
/***************************************************
**更新操作
**edit:chj
**date:2019-05-29
**reason:选择颜色
***************************************************/

global $adb,$theme,$mod_strings,$current_user;
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty;

$smarty->assign('APP',$app_strings);

 $_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('SELECTCOLOR');
$str=$smarty->fetch("SelectColppick.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>