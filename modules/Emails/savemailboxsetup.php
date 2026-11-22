<?php
include("include/mail/Protocol/Base.php");
include("include/mail/Protocol/POP3.php");
include("include/mail/MailDb.php");
include("include/mail/MailAccount.php");
include("include/mail/MailRead.php");
include("include/mail/MailInfo.php");

set_time_limit(0);

global $adb;
$accdata['popserver']=$_REQUEST['mailaccountname'];
if($_REQUEST['chk_pop3_ssl']=='yes')
{
      $accdata['popport']=$_REQUEST['pop3_ssl_port'];
    $accdata['popsec']='SSL';
}
else
{
      $accdata['popport']="110";
    $accdata['popsec']='none';
}
$accdata['popuser']=$_REQUEST['mail_username'];
$accdata['poppass']=$_REQUEST['mailpwd'];

$mailaccount=new MailAccount($accdata['popuser']);

$CONN = new Protocol_Client_POP3($accdata['popserver'], $accdata['popport'], 0, $accdata['popsec']);
$_REQUEST['diony']='yes';


if ($CONN->check_connected() !== true) { 
            ConvertTojsonString(-1,array(),'服务器：'.$accdata['popserver']."连接失败");
      
 }

 $status = $CONN->login($accdata['popuser'], $accdata['poppass']);
 
 if (!$status['login']) { // Login failed
            $error = $CONN->get_last_error();
            $CONN->close();
            $JSON['done'] = 1;
            $JSON['error'] = 'Login to '.$accdata['popserver'].' as '.$accdata['popuser'].' failed'.($error ? ' ('.$error.')' : '');
            
            ConvertTojsonString(-1,array(),'账号：'.$accdata['popuser']."登录失败".$error);
}
$accdata['smtpport']=$_REQUEST['smtp_ssl_port'];
if($_REQUEST['chk_smtp_ssl']=='yes')
{
     
    $accdata['smtpsec']='SSL';
}
else
{
      
    $accdata['smtpsec']='';
}
$accdata['smtpserver']=$_REQUEST['smtp_mailaccountname'];
$id=$mailaccount->saveMailAccount($accdata);
$accdata['id']=$id;
$accdata['type']=$mailaccount->type;
ConvertTojsonString(1,$accdata,'success');
?>