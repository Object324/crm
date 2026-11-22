<?php
global $adb,$current_user,$currentModule;
$smarty=new lingdangCRM_Smarty();
$userid=$current_user->id;
require("user_privileges/user_privileges_".$userid.".php");
$usersinfo=array();
$query="select ld_users.id,ld_users.last_name,ld_profile.profileid,ld_profile.profilename from ld_profile 
LEFT JOIN ld_users ON ld_users.profileid=ld_profile.profileid 
where ld_users.is_admin !='on' order by ld_profile.profileid asc;";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
    
$query="select profileid,profilename from ld_profile order by profileid asc";
$roleresult=$adb->query($query);
$num_rows_role=$adb->num_rows($roleresult);
$sql='select DISTINCT(userid) as userid from ld_bankaccountprofile where bankaccountsetid=?';
$userviewresult=$adb->pquery($sql,array($_REQUEST['id']));
$userviewids=array();

if($adb->num_rows($userviewresult)>0)
{   for($i=0;$i<$adb->num_rows($userviewresult);$i++){
    $userviewids[$i]=$adb->query_result($userviewresult,$i,'userid');
    }
}

//print_r($userviewids);die();
$chkbox=0;
if($num_rows_role)
{
    for($j=0;$j<$num_rows_role;$j++)
        {
            $role=$adb->query_result($roleresult,$j,'profileid');
            $rolename=$adb->query_result($roleresult,$j,'profilename');
            for($i=0;$i<$num_rows;$i++){
                $userid=$adb->query_result($result,$i,'id');
                $username=$adb->query_result($result,$i,'last_name');
                $roleid=$adb->query_result($result,$i,'profileid');
               $chkbox=0;
                if($role==$roleid){
                    if($userid!=''){
                        if(in_array($userid,$userviewids))
                        {
                            $chkbox=1;
                        }elseif($userviewids[0]=='-1'){
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

$uids = implode(',',$userviewids);

if($userviewids[0]=='-1'){
    $smarty->assign('ALLUSER','checked="checked"');
}else{
    $smarty->assign('SELECTUSER','checked="checked"');
}
$sql='SELECT * FROM ld_bankaccountset WHERE Bankaccountsetid=?;';
$result=$adb->pquery($sql,array($_REQUEST['id']));

$smarty->assign('SMOWNERNAME',$adb->query_result($result,0,'accountname')) ;
$smarty->assign('USERINFO',$usersinfo);
$smarty->assign('POTENTIALSID',$_REQUEST['id']);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('UIDS',$uids);
echo '##SUCCESS##';

$_REQUEST['diony']='yes';
$arr=array();
$arr['title']=getFixedLabel('Corporate_Account_permissions').'-'.$adb->query_result($result,0,'accountname');
$arr['oktext']=getFixedLabel('CONFIRMED');
$arr['canceltext']=getFixedLabel('CANCEL');

$arr['content']=$smarty->fetch("BanAccountProfile.tpl");
ConvertTojsonString(1,$arr,'success');

?>