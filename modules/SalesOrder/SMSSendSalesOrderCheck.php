<?php
/*
合同订单序时簿群发短信验证
*/ 

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;


//判断是否设置通讯账户
$SMSarray = GetSMSAutograph();
$autograph = $SMSarray['autograph'];
if(empty($autograph))
{
    echo "####:###";
    echo "没有设置通讯账户，请使用管理员用户到控制面板中设置！";
    exit();
}

//判断是否设置接收人手机字段
$smstype = $_REQUEST['smstype'];
$checkPhonesetSql = "select count(1) as count from ld_sendphoneset where type = ? ";
$checkPhonesetResult = $adb->pquery($checkPhonesetSql,array($smstype));
if($adb->query_result($checkPhonesetResult,0,"count") == "0")
{
    echo "####:###";
    echo "短信".$smstype."接收人手机字段没有设置！";
    exit();
}


//判断是否设置短信内容
if($smstype=="1")
{
    $type = 2;
}
else if($smstype=="2")
{
    $type = 3;
}
else if($smstype=="3")
{
    $type = 4;
}
$checkInfoSql = "select content from ld_sendinformcontent where type = ? ";
$checkInfoResult = $adb->pquery($checkInfoSql,array($type));
$content = $adb->query_result($checkInfoResult,0,"content");
if(empty($content))
{
    echo "####:###";
    echo "短信".$smstype."短信内容没有设置！";
    exit();
}

exit();

?>