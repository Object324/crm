<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
require_once('modules/Users/Profile.class.php');
global $currentModule;
$smarty = new lingdangCRM_Smarty();
if(isset($_REQUEST['profileid']) && $_REQUEST['profileid']!='')
{
	$profile = new Profile();
	$profileId = $_REQUEST['profileid'];
	$profileinfo = $profile->getProfileinfo($profileId);
	$smarty->assign("PROFILE_NAME", $profileinfo['profilename']);
	$smarty->assign("PROFILE_DESCRIPTION", $profileinfo['description']);
	//已选择的成员
	$roleUserArr=$profile->getProfileOfUsers($profileId);
}
//所有可用成员
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
$selected_roleuser = array();
//去除已选择的成员
if(!empty($roleUserArr))
{
	foreach($roleUserArr as $userid => $user_name){
		$selected_roleuser[] = $userid;
	}
	foreach($MergeSmowner['UserCombo'] as $user_id => $userarr)
	{
		if(array_key_exists($user_id,$roleUserArr))
		{
			unset($MergeSmowner['UserCombo'][$user_id]);
		}
	}	
}
$smarty->assign('RoleUserArr',$roleUserArr);
$smarty->assign('PROFILEID',$profileId);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
//ksort($MergeSmowner['UserCombo']);//0014462: 控制面板>权限管理.关于角色设置成员中角色排序的问题

$smarty->assign('Merge_SmOwner',$MergeSmowner['UserCombo']);
$_REQUEST['diony']='diony';
$arr['sel_role_userid'] = implode(',',$selected_roleuser);
ConvertTojsonString(1,$arr,"success");
exit();
?>