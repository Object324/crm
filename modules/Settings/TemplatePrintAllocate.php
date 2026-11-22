<?php

global $adb,$current_user;
$smarty=new lingdangCRM_Smarty();
$userid=$current_user->id;

$usersinfo=array();
$query="select T3.id,T3.last_name,t1.roleid,T1.rolename from ld_role AS T1 LEFT JOIN
ld_user2role AS T2 ON t2.roleid=T1.roleid  LEFT JOIN
ld_users AS T3 ON T3.id=T2.userid 
where t1.roleid<>'H1' order by roleid asc";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
    
$query="select roleid,rolename from ld_role where roleid<>'H1' order by roleid asc";
$roleresult=$adb->query($query);
$num_rows_role=$adb->num_rows($roleresult);
$sql='select * from  ld_templateprint  where templateprintid=?';
$templateprintresult=$adb->pquery($sql,array($_REQUEST['templateprintid']));
if($adb->num_rows($templateprintresult)>0)
{
    $templateprintname=$adb->query_result($templateprintresult,0,'templateprintname');
}
//$chkbox=0;
if($num_rows_role)
{
    for($j=0;$j<$num_rows_role;$j++)
        {
            $role=$adb->query_result($roleresult,$j,'roleid');
            $rolename=$adb->query_result($roleresult,$j,'rolename');
            for($i=0;$i<$num_rows;$i++){
                $userid=$adb->query_result($result,$i,'id');
                $username=$adb->query_result($result,$i,'last_name');
                $roleid=$adb->query_result($result,$i,'roleid');
              // $chkbox=0;
                if($role==$roleid){
                    if($userid!=''){
                       /*if(in_array($userid,$userviewids))
                        {
                            $chkbox=1;
                        }
                        */
                        $userInfo[]=array(
                        'userid'=>$userid,
                        'username'=>$username
                        //'chkbox'=>$chkbox
                        );
                    }                        
                }
            }
            $roleInfo=array('$role'=>$roleid,
                            'rolename'=>$rolename);
            $count=count($userInfo);  
            $usersinfo[]=array($roleInfo,$userInfo,$count);
            $userInfo=array();
     }
}

$sql='select *  from ld_templateprint2user where templateprintid=?';
$useridresult=$adb->pquery($sql,array($_REQUEST['templateprintid']));
for($i=0;$i<$adb->num_rows($useridresult);$i++)
{
        $printInfo=Array();
        $useridlist[]=$adb->query_result($useridresult,$i,'userid');
}
//exit(printtab);
$smarty->assign('USERINFO',$usersinfo);
$smarty->assign('useridlist',$useridlist);
$smarty->assign('printtabid',$_REQUEST['printtabid']);
$smarty->assign('templateprintname',$templateprintname);
$smarty->assign('templateprintid',$_REQUEST['templateprintid']);
echo '##SUCCESS##';
require_once('SetmenuControl.php');
$smarty->display("TemplatePrintAllocate.tpl");
exit();
?>