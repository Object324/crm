<?php

//删除邮件账号
global $adb;
global $current_user;
$accountid=trim($_REQUEST['idstring'],',');
$accountids=explode(',',$accountid);

foreach($accountids as $accountid)
{
    $sql='select mail_username from ld_mail_accounts where account_id=? and user_id=?';
    $result=$adb->pquery($sql,array($accountid,$current_user->id));
  
    if($adb->num_rows($result)>0)
    {
        $mail_username=$adb->query_result($result,0,0);
        deleteDir(globalStatic::$root_directory."storage/mail/".$mail_username);
        $sql='delete from ld_mail_accounts where account_id=? and user_id=?';
        $adb->pquery($sql,array($accountid,$current_user->id));
        
        $sql='delete from ld_mailmanager_history where mailaccountname=? and userid=?';
        $adb->pquery($sql,array($mail_username,$current_user->id));
        
        $sql='delete from ld_mailmanager_mailattachments where mailrecordid
         in( select mailrecordid from ld_mailmanager_mailrecord where mailaccountname=? and userid=?)';
        $adb->pquery($sql,array($mail_username,$current_user->id));
        
        
        $sql='delete from ld_mailmanager_mailrecord where mailaccountname=? and userid=?';
        $adb->pquery($sql,array($mail_username,$current_user->id));
    
        $ids[]=$accountid;
    }
   
    
     
   
}

function deleteDir($dir)
{
              if (!$handle = @opendir($dir)) {
                  return false;
              }
              while (false !== ($file = readdir($handle))) {
                  if ($file !== "." && $file !== "..") {       //排除当前目录与父级目录
                      $file = $dir . '/' . $file;
                    if (is_dir($file)) {
                        deleteDir($file);
                     } else {
                         @unlink($file);
                     }
                 }
    
             }
             @rmdir($dir);
}
 $_REQUEST['diony']='yes';
    
     ConvertTojsonString(1,array('ids'=>$ids),'success');
?>