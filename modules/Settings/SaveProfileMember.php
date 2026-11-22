<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
require_once('modules/Users/Profile.class.php');
require_once('modules/Users/CreateUserPrivilegeFile.php');
global $adb;
$smarty = new lingdangCRM_Smarty();
$selectmember = $_REQUEST['selectmember'];
if(!empty($selectmember) && !empty($_REQUEST['profileid']))
{
	$profileid = $_REQUEST['profileid'];
	$profile = new Profile();
	//已选择的成员
	$roleUserArr=$profile->getProfileOfUsers($profileid);
	if(is_array($roleUserArr) && count($roleUserArr) >= 0)
	{
		foreach($roleUserArr as $userid => $username)
		{
			$userId[]=$userid;
		}
		$useridAll = implode(',',$userId);
		$adb->pquery('update ld_users set profileid = 0 where id in ('.$useridAll.')');
	}
	$member = explode(',',$selectmember);
	for($i = 0; $i<count($member); $i++)
	{
		if(!empty($member[$i]))
		{
			$adb->pquery('update ld_users set profileid = ? where id = ?', array($profileid,$member[$i]));
		}
		createUserPrivilegesfile($member[$i]);
	}
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>