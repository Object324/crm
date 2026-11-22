<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//布局规则的停用和启用
global $adb;
$status=$_REQUEST['status'];
$ruleid=$_REQUEST['ruleid'];

if($status=='yes')
{
    $update='update ld_fieldrule set enablestatus=? where id=?';
    $adb->pquery($update,array('yes',$ruleid));
}
else
{
    $update='update ld_fieldrule set enablestatus=? where id=?';
    $adb->pquery($update,array('no',$ruleid));
}
unsetCacheDirectory('fields');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>