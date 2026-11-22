<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

require_once('modules/Users/Profile.class.php');

global $adb;
$profileid = vtlib_purify($_REQUEST['profileid']);

$profile = new Profile();
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action']!= '')
	$return_action =vtlib_purify($_REQUEST['return_action']);
else
	$return_action = 'ListProfiles';
//更新角色信息
$update_query="update ld_profile set profilename=?,description=? where profileid=?";
$adb->pquery($update_query,array($_REQUEST['profilename'],$_REQUEST['description'],$_REQUEST['profileid']));
$oftenusereporttabid=getTabid("OftenUseReport");//常用报表
//删除角色原有的操作信息
deleteProfilePermissions($profileid);
//重新插入角色操作权限
$query = 'select tabid from ld_profileallpermission group by tabid';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
		//获取操作权限actionname
		$actionArr = $profile->getActionMappingNum();
for($i = 0; $i<$num_rows; $i++)
{
	$tabid = $adb->query_result($result,$i,'tabid');
    if($tabid == 16) continue;//16的就不要写入了,否则sql组合键重复报错
	if($tabid == 9)$tabid=16;

	$permissions = getPermissionValue($_REQUEST[$tabid.'_tab']);
   
	if($permissions == 0)
	{
		//3 代表模块权限
		$insert_profilepermissions="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) values(?,?,?,?,?)";
        $adb->pquery($insert_profilepermissions, array($profileid, $tabid, 3,$permissions,0));

		$sequence = 1;
        $insert_profilepermissions_batch="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) values ";
		$sql_arr = array();
        foreach($actionArr as $actionid => $actionname)
		{
			$permission_value = getPermissionValue($_REQUEST[$tabid.'_'.$actionname]);
			if($permission_value == 0)
			{	
                $tmp_sql = "($profileid,$tabid,$actionid,$permission_value,$sequence)";
                $sql_arr[] = $tmp_sql;
				$sequence++;
			}
		}
        if(sizeof($sql_arr)>0){
            $insert_profilepermissions_batch .= implode(',',$sql_arr);
            $adb->pquery($insert_profilepermissions_batch, array());
        }
	}
}
$oftenusereportnames=$profile->getOfenUseReportNames();
$permissionname=array();
if(sizeof($oftenusereportnames)>0&&$oftenusereportnames[0]!='')
{
      foreach($oftenusereportnames as $reportname )
      {
            if($_REQUEST['oftenusereport_'.$reportname])
            {
                $permissionname[]=  $reportname;
            }
      }  
}
$sql='update ld_profile2standardpermissions set relatednames=? where profileid=? and  tabid=?  ';
if(sizeof($permissionname)>0&&$permissionname[0]!='')
    $adb->pquery($sql,array(implode(",",$permissionname),$profileid,$oftenusereporttabid));
else
    $adb->pquery($sql,array('',$profileid,$oftenusereporttabid));
//移动端报表
$reportnames= $profile->getMobileReportNames();
$permissionname=array();
if(sizeof($reportnames)>0)
{
      foreach($reportnames as $reportinfo )
      {
        $reportname=$reportinfo['name'];
        
            if($_REQUEST['mobilereport_'.$reportname])
            {
                $permissionname[]=  $reportname;
            }
      }  
}
$sql='update ld_profile2standardpermissions set relatednames=? where profileid=? and  tabid=?  ';
if(sizeof($permissionname)>0&&$permissionname[0]!='')
    $adb->pquery($sql,array(implode(",",$permissionname),$profileid,-2));
else
    $adb->pquery($sql,array('',$profileid,-2));
    
$cachekey = 'cache_getProfileAction_Used_profileid'.$profileid;
unsetCache($cachekey);
//手机端相关信息显示模块缓存
unsetCache('cache_mobileispresentrelated');
/**
 * 没有清除缓存的原因
 * @reason 0015412: 控制面板>权限管理,关于设置权限的问题
 * @author Tujt 2015-06-15
 */
global $languageType;
if(empty($languageType)){
	global $current_user;
	require('./user_privileges/user_language_'.$current_user->id.'.php');
}
unsetCacheDirectory('profile');
//微信端审批模块缓存
unsetCacheDirectory('wxapprovemodules');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array('profileid'=>$profileid,'profilename'=>$_REQUEST['profilename']),'success');



 /** returns value 0 if request permission is on else returns value 1
  * @param $req_per -- Request Permission:: Type varchar
  * @returns $permission - can have value 0 or 1:: Type integer
  *
 */
function getPermissionValue($req_per)
{
	if($req_per == 'on')
	{
		$permission_value = 0;
	}
	else
	{
		$permission_value = 1;
	}
	return $permission_value;
}
	/**
	 * @version:6.0 角色权限改进
	 * @reason 删除操作权限
	 * @author Chj 
	 */
	 function deleteProfilePermissions($profileid)
	{
		global $adb;
		if(!empty($profileid) && $profileid >= 1)
		{
			$adb->pquery('delete from ld_profile2standardpermissions where profileid=?',array($profileid));
		}
	}
?>