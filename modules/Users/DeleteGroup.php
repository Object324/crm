<?php
global $adb;
$smarty=new lingdangCRM_Smarty();
$record=$_REQUEST['record'];
$_REQUEST['diony']='diony';
global $current_user;
require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.".php");
$sql='select parentgroup from ld_groups where groupid=?';
$result=$adb->pquery($sql,array($record));
$parentgroup=$adb->query_result($result,0,'parentgroup');
$parentgroups=explode("::",$parentgroup);
if(sizeof($parentgroups)<=1||$parentgroups[1]<=0||$parentgroups[1]=='')
{
    if($languageType=='zh')
         ConvertTojsonString(-1,$arr,"不允许删除根部门");
    else
        ConvertTojsonString(-1,$arr,"The root department is not allowed to delete");
}
$sql=" SELECt ld_users2group.groupid from ld_groups
LEFT JOIN ld_users2group  on ld_groups.groupid=ld_users2group.groupid  where parentid=? or ld_users2group.groupid=? limit 1 ";
$result=$adb->pquery($sql,array($record,$record));
if($adb->num_rows($result)<=0)
{
    ConvertTojsonString("-2",array(),getFixedLabel("SUREWANTDELETE"));
}

$sql='select * from ld_groups   where groupid=?';
$result=$adb->pquery($sql,array($record));
$groupname=$adb->query_result($result,0,'groupname');
$groupid=$adb->query_result($result,0,'groupid');
$smarty->assign("GROUPNAME",$groupname);
$smarty->assign("GROUPID",$groupid);
$sql='select groupid from ld_groups   where parentid=?';
$result=$adb->pquery($sql,array($record));
if($adb->num_rows($result)>0)
    $smarty->assign('HAVECHILD','yes');

$content=$smarty->fetch("deleteGroup.tpl");

$arr['title']=getFixedLabel('DELETEGROUP');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");

?>