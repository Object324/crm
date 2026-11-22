<?php
/**
 * 更新操作
 * edit:can
 * date:20131119
 * reason:客户共享(V3.1)
 * */
 global $adb,$current_user;
$accountid=$_REQUEST['accountid'];
$allviewids=$_REQUEST['owners'];
$sql='delete from ld_account2userview where accountid=?';
$adb->pquery($sql,array($accountid));
if($allviewids!="")
{
    /*
    更新操作
    edit:can
    date:20131130
    reason:5785: 客户单据查看界面，点击”共享“按钮，在“共享”窗口中，若没有勾选任何用户或角色，应该也可以保存。
    */
    $sql='insert into ld_Account2userview(accountid,AllViewUsers,shareuserid)values(?,?,?)';
    $allviewids=implode(',',$allviewids);
    $result=$adb->pquery($sql,array($accountid,$allviewids,$current_user->id));
}


header("Location:index.php?module=Accounts&action=DetailView&record=".$accountid);
?>