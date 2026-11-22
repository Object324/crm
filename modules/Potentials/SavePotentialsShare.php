<?php
/**
 * 更新操作
 * edit:lmx
 * date:20140220
 * reason:销售机会共享保存(V5.3)
 * */
 global $adb,$current_user;
$potentialid=$_REQUEST['potentialid'];
$allviewids=$_REQUEST['owners'];
$sql='delete from ld_potential2userview  where potentialid=?';
$adb->pquery($sql,array($potentialid));
if($allviewids!="")
{
    /*
    更新操作
    edit:lmx
    date:20140220
    reason:销售机会查看界面，点击”共享“按钮，在“共享”窗口中，若没有勾选任何用户或角色，应该也可以保存。
    */
    $sql='insert into ld_potential2userview(potentialid,AllViewUsers,shareuserid)values(?,?,?)';
    $allviewids=implode(',',$allviewids);
    $result=$adb->pquery($sql,array($potentialid,$allviewids,$current_user->id));
}
header("Location:index.php?module=Potentials&parenttab=Sales&action=DetailView&record=".$potentialid);
?>