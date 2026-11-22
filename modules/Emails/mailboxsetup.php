<?php

$smarty=new lingdangCRM_Smarty();
$mailaccountid=$_REQUEST['mailaccountid'];
global $adb;
if($mailaccountid>0)
{
    $sql='select * from ld_mail_accounts  where account_id=?';
    $result=$adb->pquery($sql,array($mailaccountid));
    $smarty->assign('mailaccountname',$adb->query_result($result,0,'mail_username'));
    $smarty->assign('mailpwd',$adb->query_result($result,0,'mail_password'));
    $smarty->assign('ssltype',$adb->query_result($result,0,'ssltype'));
    $smarty->assign('mailservername',$adb->query_result($result,0,'mail_servername'));
    $smarty->assign('PORT',$adb->query_result($result,0,'mail_serverport'));
    $smarty->assign('SMTPPORT',$adb->query_result($result,0,'smtp_port'));
    $smarty->assign('smtp_servername',$adb->query_result($result,0,'smtp_servername'));
    $smarty->assign('smtp_ssltype',$adb->query_result($result,0,'smtp_ssltype'));
}
else
{
    $smarty->assign('PORT',110);
    $smarty->assign('SMTPPORT',25);
}
$arr['content']=$smarty->fetch("mailboxSetup.tpl");
$_REQUEST['diony']='yes';
$arr['title']=getFixedLabel('MAILBOXSETUP');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");

ConvertTojsonString(1,$arr,"success");

?>