<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
global $adb;


if(isset($_REQUEST['type']))
{
    $type=$_REQUEST['type'];
    if($type=='smslist')
    {
        $sqldelsmslist = "delete from ld_smssend where 1=1 ";
        $adb->pquery($sqldelsmslist);
    }
    else if($type=='smswork')
    {            
        $sqldelsmswork = "delete from ld_smssend where 1=1 ";
        $adb->pquery($sqldelsmswork);
    }
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

/*
if($type=='smslist')
{
    header("Location: index.php?module=CommunicationLog&action=index&parenttab=Marketing&type=smslist");
}
else if($type=='smswork')
{
    header("Location: index.php?module=CommunicationLog&action=index&parenttab=Marketing&type=smswork");
}*/
        
    


?>