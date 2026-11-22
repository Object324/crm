<?php
/*
editor：cxl
date:2015-4-27
reason:保存客户设置的日，周，月报告模板
*/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;
$reporttemplet=fck_from_html($_POST['reporttemplet']); //把编辑器中的数据和格式都获取到
$ReportLogType=$_REQUEST['ReportLogType'];
$reporttempletarr = array(
    '0'=>'dailyreporttemplet',
    '1'=>'weekreporttemplet',
    '2'=>'monthtypetemplet'
);
$field = $reporttempletarr[$ReportLogType];
$sql = 'update ld_users set '.$field.' = ? where id= ? ';           
$adb->pquery($sql,array($reporttemplet,$current_user->id));
die;//防止ajax执行无用的代码
?>

