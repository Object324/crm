<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/
global $adb;

if(isset($_REQUEST['records']))
{   
    $record=$_REQUEST['records'];
    if(isset($_REQUEST['type']))
    {
        $type=$_REQUEST['type'];
        if($type=='smslist')
        {
            $sqldelsmslist = "delete from ld_smssend where taskid = ".$record;
            $adb->pquery($sqldelsmslist);
        }
        else if($type=='smswork')
        {            
            $sqldelsmswork = "delete from ld_smssend where batchno = '".$record."'";
            $adb->pquery($sqldelsmswork);
        }
    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),'success');
/*if($type=='smslist')
{
    header("Location: index.php?module=CommunicationLog&action=index&type=smslist");
}
else if($type=='smswork')
{
    header("Location: index.php?module=CommunicationLog&action=index&type=smswork");
}*/
        
    


?>