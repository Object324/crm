<?php

//角色权限
$permit=isPermitted("Users","RoleProfile");
if($permit=='no')
{
    exit('没有权限');
}
global $adb;
$selectids=$_REQUEST['selectids'];
if($selectids!='all')
{
    $selectids=trim($selectids,";");
    $selectids=explode(";",$selectids);
}
else
{
    $selectids = getSelectedRecords($_REQUEST,"Users",'all',$excludedRecords);
}


$sql="update ld_users set profileid=?  where id  in( ".implode(",",$selectids).")";
$adb->pquery($sql,array($_REQUEST['profileid']));

$permit=isPermitted("Users",'AllowSetRoleDataProfile');
if($permit=='yes')
{
    $viewothers=$_REQUEST['viewothers'];
    $editothers=$_REQUEST['editothers'];
    $delothers=$_REQUEST['delothers'];
    $viewselfbills=$_REQUEST['viewselfbills'];
    $edit_other_mobile=$_REQUEST['edit_other_mobile'];
    $is_mobile_style=$_REQUEST['is_mobile_style'];
    
    $sql=" update ld_users set viewothers=?,editothers=?,delothers=?,viewselfbills=?,edit_other_mobile=?,is_mobile_style=?
        where id  in( ".implode(",",$selectids).") ";
     $adb->pquery($sql,array($viewothers,$editothers,$delothers,$viewselfbills,$edit_other_mobile,$is_mobile_style));   
        
}
crm_load_function_file('createUserPrivilegesfile',"modules/Users","CreateUserPrivilegeFile");
foreach($selectids as $userid)
{
    createUserPrivilegesfile($userid);
}

echo '##success##';


?>