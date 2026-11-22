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


global $adb,$roleId;
$copyRoleId=0;
$profilename = from_html(decode_html($_REQUEST['profilename']));
$description= from_html(decode_html($_REQUEST['description']));
$profile_id = $adb->getUniqueID("ld_profile");
$profile = new Profile();
//Inserting values into Profile Table
$profileseq_result = $adb->pquery("select MAX(profileseq) as profileseq from ld_profile");
$rows = $adb->num_rows($profileseq_result);
if($rows > 0 ){
    $newprofileseq = $adb->query_result($profileseq_result,0,'profileseq');
    ++ $newprofileseq;
}
else{
    $newprofileseq = 1;
}
$insert_profile = "insert into ld_profile(profileid, profilename, description,profileseq) values(?,?,?,?)";
$adb->pquery($insert_profile, array($profile_id,$profilename, $description,$newprofileseq));


$query = 'select tabid from ld_profileallpermission group by tabid';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
if(isset($_REQUEST['copyRoleId']) && $_REQUEST['copyRoleId'] > 0){
	$copyRoleId = $_REQUEST['copyRoleId'];
}
$oftenusereportid=getTabid('OftenUseReport');
	//获取操作权限actionname
$actionArr = $profile->getActionMappingNum();
for($i = 0; $i<$num_rows; $i++)
{
	$tabid = $adb->query_result($result,$i,'tabid');
	//日程管理特殊控制
	if($tabid == 9){
		$tabid = 16;
	}
    
 
	$permissions = getPermissionValue($_REQUEST[$tabid.'_tab']);
	if($permissions == 0)
	{
	   
       if($tabid==-2)
       {
            crm_load_class_file('cls_StaticCommonFun','WeiXinApp/WeiXin_common');
         

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
              $insert_profilepermissions="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence,relatednames) values(?,?,?,?,?,?)";
            $adb->pquery($insert_profilepermissions, array($profile_id, $tabid, 3,$permissions,0,implode(',',$permissionname)));
       }
       else if($tabid==$oftenusereportid)
       {
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
            $insert_profilepermissions="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence,relatednames) values(?,?,?,?,?,?)";
            $adb->pquery($insert_profilepermissions, array($profile_id, $tabid, 3,$permissions,0,implode(',',$permissionname)));
       }
       else
       {
		//3 代表模块权限
		$insert_profilepermissions="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) values(?,?,?,?,?)";
        $adb->pquery($insert_profilepermissions, array($profile_id, $tabid, 3,$permissions,0));
         saveprofileField(getTabModuleName($tabid),$profile_id,$copyRoleId);
        }
	
		$sequence = 1;
		//duan 20221214 角色权限保存太慢，改为批量插入
        $insert_profilepermissions_batch="insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) values ";
		$sql_arr = array();
		foreach($actionArr as $actionid => $actionname)
		{
			$permission_value = getPermissionValue($_REQUEST[$tabid.'_'.$actionname]);
			if($permission_value == 0)
			{	
				$tmp_sql = "($profile_id, $tabid, $actionid, $permission_value, $sequence)";
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

//saveprofileField($module,$profile_id);
//$sql="insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly)
//select  $profile_id,tabid,fieldid,0,0 from ld_field where presence in(0,2) ";
//$adb->pquery($sql,array());
if(isset($_REQUEST['parentrole']) && $_REQUEST['parentrole']!='')
	$parent=$_REQUEST['parentrole'];
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != '')
	$return_action=vtlib_purify($_REQUEST['return_action']);
if(isset($_REQUEST['return_module']) && $_REQUEST['return_action'] !='')
	$return_module=vtlib_purify($_REQUEST['return_module']);
 $_REQUEST['diony']='yes';
ConvertTojsonString(1,array('profileid'=>$profile_id,'profilename'=>$profilename),'success');


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
 * edit:can
 * reason:保存字段权限
 * */
 function saveprofileField($module,$profileid,$copyRoleId){
	global $adb,$current_user;
	require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
	$tabid = getTabid($module);
	if($copyRoleId > 0){
		$query = 'select tabid,fieldid,visible,readonly,editreadonly from ld_profile2field where profileid = ? and tabid = ?';
		$result = $adb->pquery($query,array($copyRoleId,$tabid));
        
        $sql11_batch = "INSERT INTO ld_profile2field VALUES ";
        $sql_arr = array();
		for($i=0; $i<$adb->num_rows($result); $i++) {
			$fieldid = $adb->query_result($result,$i,"fieldid");
			$visible = $adb->query_result($result,$i,"visible");
			$readonly = $adb->query_result($result,$i,"readonly");
            $editreadonly = $adb->query_result($result,$i,"editreadonly");
			$checkentry = $adb->pquery("SELECT 1 FROM ld_profile2field WHERE profileid=? AND tabid=? AND fieldid =?",array($profileid,$tabid,$fieldid));
			if($adb->num_rows($checkentry) == 0) {
                $tmp_sql = "($profileid, $tabid, $fieldid,$visible, $readonly,$editreadonly)";
                $sql_arr[] = $tmp_sql;
                
                if(sizeof($sql_arr)>=20){
                    $sql11_batch .= implode(',',$sql_arr);
				    $adb->pquery($sql11_batch, array());
                    //重置保存参数
                    $sql11_batch = "INSERT INTO ld_profile2field VALUES ";
                    $sql_arr = array();
                }
			}	
		}
        if(sizeof($sql_arr)>=0){
            $sql11_batch .= implode(',',$sql_arr);
		    $adb->pquery($sql11_batch, array());
        }
	}else{
		$query = "SELECT 
		ld_field.fieldid, ld_field.displaytype, ld_field.typeofdata
		FROM ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
		where ld_tranlabel.languagetype=? and ld_tranlabel.trantable=? and  ld_tranlabel.tabid=? AND ld_field.presence in (0,2) GROUP BY ld_field.fieldid";
		$qparams = array($languageType,'ld_field', $tabid);
		$result = $adb->pquery($query, $qparams);
        
        $sql11_batch = "INSERT INTO ld_profile2field VALUES ";
        $sql_arr = array();
		for($i=0; $i<$adb->num_rows($result); $i++) {
			$fieldid = $adb->query_result($result,$i,"fieldid");
			$checkentry = $adb->pquery("SELECT 1 FROM ld_profile2field WHERE profileid=? AND tabid=? AND fieldid =?",array($profileid,$tabid,$fieldid));
			$visible_value = 0;
			$readOnlyValue = 0;
            $editreadonlyValue=0;
			if($adb->num_rows($checkentry) == 0) {
                $tmp_sql = "($profileid, $tabid, $fieldid,$visible_value, $readOnlyValue,$editreadonlyValue)";
                $sql_arr[] = $tmp_sql;
                
                if(sizeof($sql_arr)>=20){
                    $sql11_batch .= implode(',',$sql_arr);
				    $adb->pquery($sql11_batch, array());
                    //重置保存参数
                    $sql11_batch = "INSERT INTO ld_profile2field VALUES ";
                    $sql_arr = array();
                }
			}	
		}
        if(sizeof($sql_arr)>=0){
            $sql11_batch .= implode(',',$sql_arr);
		    $adb->pquery($sql11_batch, array());
        }
	}
}
?>