<?php
global $adb;
global $current_user;
$sql='select * from ld_mail_accounts where user_id =?
 order by createdtime desc';
 $result=$adb->pquery($sql,array($current_user->id));
$rows=$adb->num_rows($result);
for($i=0;$i<$rows;$i++)
{
    $mailaccounts[]=array("mailaccountname"=>$adb->query_result($result,$i,'mail_username'),
    'accountid'=>$adb->query_result($result,$i,'account_id'),
    'type'=>$adb->query_result($result,$i,'mail_protocol'),
        'createdtime'=>$adb->query_result($result,$i,'createdtime'));
}
$smarty=new lingdangCRM_Smarty();
$smarty->assign("MAILACCOUNTS",$mailaccounts);
$arr['content']=$smarty->fetch("mailboxlist.tpl");
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

?>