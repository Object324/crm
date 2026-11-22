<?php

global $adb;
global $current_user;
if(!is_admin($current_user))
{
    dump("please admin login");
    
}
$deploy_value=322;
$deploy_arr=getSys_deploy($deploy_value);//设置系统登陆时密码连续输错次数
$time=$deploy_arr['deploy_value'];
$sql="select last_name,user_name,ld_users.id,wx_userid from ld_users inner join (
select userid from ld_loginerror group by userid having count(*)>=$time) as tmp 
on tmp.userid=ld_users.id ORDER BY  convert(last_name USING 'utf8')  ";
$result=$adb->pquery($sql,array());


$rows=$adb->num_rows($result);
$last_namefieldlabel=$current_user->fieldobj->getFieldInfoBykeyValue("columnname",'last_name','fieldlabel');
$user_namefieldlabel=$current_user->fieldobj->getFieldInfoBykeyValue("columnname",'user_name','fieldlabel');

$tablehtml="<div class='ld-pop-container ld-table-container ld-table-container-lines'>";
$tablehtml.="<div class='divPopOverflow'><table name='unlockuser_table' class='' border='0' cellpadding='0' cellspacing='0' width='100%'>";
$tablehtml.="<thead><tr><th>$last_namefieldlabel</th><th>$user_namefieldlabel</th><th>".getFixedLabel('OPERATING').'</th></tr></thead>';
$tablehtml.="<tbody>";
for($i=0;$i<$rows;$i++)
{
    $tablehtml.='<tr>';
    $userobj=new Users();
    $userobj->wx_userid=$adb->query_result($result,$i,'wx_userid');
    $userobj->last_name=$adb->query_result($result,$i,'last_name');
    
   $last_name=getUserlastName($userobj);
   $user_name=$adb->query_result($result,$i,'user_name');
   $userid=$adb->query_result($result,$i,'id');
   $tablehtml.="<td>$last_name</td><td>$user_name</td><td><a tag='$userid' name='btn_unlock' href='#'>".getFixedLabel('UnLock').'</a></td>';
   
   $tablehtml.='</tr>';
}
$tablehtml.='</tbody></table></div></div>';
$arr=[];
$arr['title']=getFixedLabel('UnLockTheAccount');
$arr['content']=$tablehtml;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

?>