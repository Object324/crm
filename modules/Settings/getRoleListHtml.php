<?php
/**
 * edit:can 20200825
 * 单据分录数据权限控制，支持按照“角色控制”
 * */
global $adb;
$profile_focus = new Profile();
$allProfile = $profile_focus->getProfileArray();

$selectroleid=$_REQUEST['selectid'];
$selectrole_arr=explode(",",$selectroleid);

$leftroleinfo=array();
$rightroleinfo=array();
foreach($allProfile as $tmpprofileid=>$profilename)
{
     if(!in_array($tmpprofileid,$selectrole_arr))
     {
        $leftroleinfo[$tmpprofileid]=$profilename;
     }
     else{
        $rightroleinfo[$tmpprofileid]=$profilename;
     }
}
$smarty=new lingdangCRM_Smarty();
$smarty->assign("left_profileinfo",$leftroleinfo);
$smarty->assign("right_profileinfo",$rightroleinfo);

$arr=array();
$arr['content']=$smarty->fetch("getRoleListHtml.tpl");
$arr['title']=getFixedLabel('RolesSetting');
$arr['oktext']=getFixedLabel('CONFIRMED');
$arr['canceltext']=getFixedLabel("CANCEL");

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');
?>