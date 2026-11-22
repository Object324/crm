<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//删除布局规则
global $adb;
$ruleid=$_REQUEST['ruleid'];
$sql='delete from ld_fieldrule where id=?';
$adb->pquery($sql,array($ruleid));

$sql='delete from ld_fieldruleadvancesearch where basicsearchid in(select id from ld_fieldrulebasicsearch where ruleid=?)';
$adb->pquery($sql,array($ruleid));
$sql='delete from ld_fieldrule_operate where basicsearchid in(select id from ld_fieldrulebasicsearch where ruleid=?)';
$adb->pquery($sql,array($ruleid));
$sql='delete from ld_fieldrulebasicsearch where ruleid=?';
$adb->pquery($sql,array($ruleid));
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');



?>