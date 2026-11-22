<?php
include(globalStatic::$root_directory."include/mail/MailDb.php");

global $adb;
$_REQUEST['diony']='yes';
$idstring=$_REQUEST['idstring'];
$ids=explode(',',$idstring);
$ids=array_filter($ids);

$idstring=implode(',',$ids);
$mailseen=$_REQUEST['mailseen'];

$MailDbobj=new MailDb('');
if($_REQUEST['selectallrecord']=='yes')
{
    //$_SESSION['emails_list']
    $sql=$_SESSION['emails_list'];
    //$sql.= ' inner join ld_mail_accounts  on ld_mail_accounts.mail_username=ld_mailmanager_mailrecord.mailaccountname '
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    
    for($i=0;$i<$rows;$i++)
    {
        $mailrecorid=$adb->query_result($result,$i,'mailrecordid');
        
        $MailDbobj->updateMailSeen($mailrecorid,$mailseen);
    }
    
}
else
    foreach($ids as $mailrecorid)
    {
        $rows=$MailDbobj->updateMailSeen($mailrecorid,$mailseen);
        if($rows<=0)//无法标记已读/未读
        {
            ConverttojsonString(-1,array(),'无权限操作');
            
        }
        
    }
ConvertTojsonString(1,array(),'success');


?>