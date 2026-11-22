<?php

global $adb,$current_user;
$smarty=new lingdangCRM_Smarty();
$userid=$current_user->id;
require("user_privileges/user_privileges_".$userid.".php");
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
$sql='select * from ld_Account2userView where accountid=?';
$userviewresult=$adb->pquery($sql,array($_REQUEST['id']));
$userviewids='';
if($adb->num_rows($userviewresult)>0)
{
    $userviewids=$adb->query_result($userviewresult,0,'allviewusers');
}
$userviewids=explode(',',$userviewids);

$chkbox=0;
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
               $chkbox=0;
                if($role==$roleid){
                    if($userid!=''){
                        if(in_array($userid,$userviewids))
                        {
                            $chkbox=1;
                        }
                        $userInfo[]=array(
                        'userid'=>$userid,
                        'username'=>$username,
                        'chkbox'=>$chkbox
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

$sql='select ld_users.last_name from ld_crmentity inner join ld_users on ld_crmentity.smownerid=ld_users.id where crmid=?';
$result=$adb->pquery($sql,array($_REQUEST['id']));
if($adb->num_rows($result)>0)
{
   $smarty->assign('SMOWNERNAME',$adb->query_result($result,0,0)) ;
}
$smarty->assign('USERINFO',$usersinfo);
$smarty->assign('ACCOUNTID',$_REQUEST['id']);
echo '##SUCCESS##';

/**
 * @project 是否仅允许管理员取消共享
 * @author Tujt 2014-05-22
 */
//$sqldeploy = "select deploy_value from ld_systems_deploy where deploy_type = 33 limit 1 ";
//$sqldeployresult=$adb->pquery($sqldeploy,array());
//$sharingsettings = $adb->query_result($sqldeployresult,0,'deploy_value');
$deployarray=getSys_deploy(33);
$shareingsettings = $deployarray['deploy_value'];
//var_dump($shareingsettings);
if($shareingsettings == 0){
    if( $current_user->is_admin == 'on')
    {
        $disabled='';
    }
    else
    {
       $disabled='disabled'; 
    }
    
}else{
    if( $current_user->is_admin == 'on')
    {
        $disabled='';
    }
    else
    {
       $disabled=''; 
    }
}
$smarty->assign('SHARINGSETTINGS',$disabled);

$smarty->display("AccountAllView.tpl");
exit();
?>