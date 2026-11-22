<?php

include(globalStatic::$root_directory."include/mail/Protocol/Base.php");
include(globalStatic::$root_directory."include/mail/Protocol/POP3.php");
include(globalStatic::$root_directory."include/mail/MailDb.php");
include(globalStatic::$root_directory."include/mail/MailAccount.php");
include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");


global $adb;
$account_id=$_REQUEST['account_id'];
/*
$accdata['popserver']="pop.ismail.cn";
$accdata['popport']="110";
$accdata['popsec']='none';
$accdata['popuser']='can@51mis.com';
$accdata['poppass']='can123';*/
$mailaccount=new MailAccount();
$mailaccounts=$mailaccount->getMailAccountInfo();
foreach($mailaccounts as $accdata)
{
    if($accdata['account_id']==$account_id)
    {
        break;
    }
}
$path=globalStatic::$root_directory."storage/mail";
if(!file_exists($path))
{
    mkdir($path,0777);
    chmod($path,0777);
}
$path.="/".$accdata['popuser'];
if(!file_exists($path))
{
    mkdir($path,0777);
    chmod($path,0777);
}




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

$seqno=$_REQUEST['emailseqno'];

 $uidl=$CONN->uidl($seqno) ; 

$tempmailfile=$path."/".$uidl.'.eml';
$success = $CONN->retrieve_to_file($seqno, $tempmailfile);


$CONN->close();

$MailDbobj=new MailDb($accdata['popuser']);
$mr = new MailRead();
$contents=$mr->readfromfile($tempmailfile, false, false);
$headerinfo=$contents['header'];
  
$mailInfoobj=new MailInfo();
$mailInfoobj->uidl=$uidl;
$mailInfoobj->mdate=$headerinfo['Date'];
$mailInfoobj->msubject=$headerinfo['Subject'];
$mailInfoobj->mfrom=$headerinfo['From'];
$mailInfoobj->mto=$headerinfo['To'];

$id=$MailDbobj->insertIntoMailRecord($mailInfoobj);
  //  @unlink($tempmailfile);

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),'success');

?>