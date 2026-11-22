<?php
global $current_user;
global $adb;
if(!is_admin($current_user))
{
    exit('非管理员不能操作');
}

$workflowid=$_REQUEST['workflowid'];

?>

