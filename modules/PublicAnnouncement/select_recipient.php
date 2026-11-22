<?php

/**
 * @author phpadmin
 * @copyright 2014
 */
 global $adb;
$smarty=new lingdangCRM_Smarty;
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'true')
{
    if(isset($_REQUEST['useridstr']) && $_REQUEST['useridstr'] != '')
        $sql="select id ,last_name  from ld_users where status = 'Active' "." and id not in (".$_REQUEST['useridstr']." )";
    else
        $sql="select id ,last_name  from ld_users where status = 'Active' ";
    $result=$adb->pquery($sql);
    $nums=$adb->num_rows($result);
    $user_arr=array();
    for($i=0;$i<$nums;$i++)
    {
        $user_arr[$adb->query_result($result,$i,'id')]=$adb->query_result($result,$i,'last_name');
    }

        
    $sql="select id ,last_name  from ld_users where id in  ( ".$_REQUEST['useridstr'].' )';
    $result=$adb->pquery($sql);
    $nums=$adb->num_rows($result);
    $bechoseduser=array();
    for($i=0;$i<$nums;$i++)
    {
        $bechoseduser[$adb->query_result($result,$i,'id')]=$adb->query_result($result,$i,'last_name');
    }
    $smarty->assign('BECHOSEDUSER',$bechoseduser);

    $smarty->assign('USER_ARR',$user_arr);
    echo '###SUCCESS###';
    $smarty->display('recipient_name.tpl');
}

?>