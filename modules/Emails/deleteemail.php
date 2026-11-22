<?php
include(globalStatic::$root_directory."include/mail/MailDb.php");

global $adb,$current_user;
$_REQUEST['diony']='yes';
if($_REQUEST['type']=='clear'&$_REQUEST['email_deleted']==2)
{
    $sql='select muniqueid,mailaccountname  from ld_mailmanager_mailrecord
            inner join ld_mail_accounts  on ld_mail_accounts.mail_username=ld_mailmanager_mailrecord.mailaccountname
              where  deleted=1 and ld_mail_accounts.user_id=?';
    $result=$adb->pquery($sql,array($current_user->id));
   for($i=0;$i<$adb->num_rows($result);$i++)
   {
       $uidl=$adb->query_result($result,$i,'muniqueid');
       $mailaccount=$adb->query_result($result,$i,'mailaccountname');
       $path=globalStatic::$root_directory."storage/mail/".$mailaccount.'/'.$uidl.'eml';
       @unlink($path);
   }        
    //清空
   $sql="delete   from  ld_mailmanager_mailrecord
      where   deleted=1 and mailaccountname in(select mail_username
      from  ld_mail_accounts
     where  ld_mail_accounts.user_id=? )";
   $adb->pquery($sql,array($current_user->id));
     ConvertTojsonString(1,array(),'success');
}
$idstring=$_REQUEST['idstring'];
$ids=explode(',',$idstring);
$ids=array_filter($ids);

$idstring=implode(',',$ids);
$deleted=$_REQUEST['email_deleted'];

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
        
        $MailDbobj->deleteMail($mailrecorid,$deleted);
    }
    
}
else
    foreach($ids as $mailrecorid)
    {
        $rows=$MailDbobj->deleteMail($mailrecorid,$deleted);
        if($rows<=0)//无法删除
        {
            ConverttojsonString(-1,array(),'无权限删除');
            
        }
        
    }
ConvertTojsonString(1,array(),'success');


?>