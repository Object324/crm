<?php
/*********************************************
 *{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:2013021
**DESCRIPTION:删除组件模板
*********************************************/

require_once('include/database/PearDatabase.php');
global $current_user;
$templateid=vtlib_purify($_REQUEST['templateid']);
deleteTemplate($templateid);
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),"success");
function deleteTemplate($templateid){
    global $adb;
   //BUG20240826-21  	首页数据看板，对于管理旧看板，给一下删除旧看板权限
    $query='delete from ld_templates where templateid=?';
    $adb->pquery($query,array($templateid));
    $query='delete from ld_templatesstuff where templateid=?';
    $adb->pquery($query,array($templateid));
	$query='delete from ld_templatesrole where templateid=?';
	$adb->pquery($query,array($templateid));
}
?>