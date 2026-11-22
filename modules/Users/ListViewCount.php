<?php
/* 
 *{*修改编码格式:统一编码：UTF-8*}
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
*/



$idlist = vtlib_purify($_REQUEST['idlist']);
$viewid = vtlib_purify($_REQUEST['viewname']);
$module = vtlib_purify($_REQUEST['module']);
$related_module = vtlib_purify($_REQUEST['related_module']);

global $adb;

$result = getSelectAllQuery($_REQUEST,$module);
	
$numRows = $adb->num_rows($result);



echo $numRows;
?>
