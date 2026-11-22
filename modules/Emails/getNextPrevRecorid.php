<?php

include(globalStatic::$root_directory."include/mail/MailDb.php");

include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");
$mailrecorid=$_REQUEST['mailrecordid'];
$type=$_REQUEST['type'];
$MailDbobj=new MailDb('');
if($type=='next')
{
   $mailrecorid= $MailDbobj->getNextRecord($_REQUEST['pagestart'],$mailrecorid);
}
else if($type=='prev')
{
   
    $mailrecorid= $MailDbobj->getPrevRecord($_REQUEST['pagestart'],$mailrecorid);
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array('mailrecordid'=>$mailrecorid),'success');
?>