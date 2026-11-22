<?php
/**
 * 更新操作
 * edit:can
 * date:20140102
 * reason:获取知识管理模板内容
 * */
 
global $adb;
$sql='select body from ld_documenttemplates where templateid=?';
$result=$adb->pquery($sql,array($_REQUEST['id']));
if($adb->num_rows($result)>0)
{
   echo '###SUCCESS###';
   echo $adb->query_result($result,0,0);
}
exit();


?>