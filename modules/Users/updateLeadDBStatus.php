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

require_once('include/utils/utils.php');

$idlist= $_REQUEST['idlist'];
$leadstatusval = $_REQUEST['leadval'];
$viewid = vtlib_purify($_REQUEST['viewname']);
$return_module = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
$focus = CRMEntity::getInstance('Calendar');
global $rstart;
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(isset($_REQUEST['start']) && $_REQUEST['start']!='') {
	$rstart="&start=".vtlib_purify($_REQUEST['start']);
}

global $current_user;
global $adb, $log;
$storearray = getSelectedRecords($_REQUEST,$return_module,$idlist,$excludedRecords);//explode(";",trim($idlist,';'));
$fieldobj=Field::getInstance('Calendar',$adb);
$smowner =$fieldobj->getWhereSmowner();
$query = 'select '.$smowner[0]['columnname'].' as smownerid,activityid from ld_activity where activityid in ('.implode(',',$storearray).')';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
    $crmid = $adb->query_result($result,$i,'activityid');
	$subject[$crmid]['smownerid'] = $adb->query_result($result,$i,'smownerid');
}
$date_var = date('Y-m-d H:i:s');
$columname=$focus->getSmownerColumName();
$assigned = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columname,'fieldname');
if(isset($_REQUEST['owner_id']) && $_REQUEST['owner_id']!='')
{
	foreach($storearray as $id)
	{
		if(isPermitted($return_module,'EditView',$id) == 'yes')
		{
			$idval = $_REQUEST['owner_id'];
			//Inserting changed owner information to salesmanactivityrel table
			if($return_module == "Calendar"){
				$del_act = "delete from ld_salesmanactivityrel where smid=(select smownerid from ld_activity where crmid=?) and activityid=?";
				$adb->pquery($del_act,array($id, $id));
				if($_REQUEST['owner_type'] == 'User') {
					$count_r = $adb->pquery("select * from ld_salesmanactivityrel where smid=? and activityid=?",array($idval, $id));
					if($adb->num_rows($count_r) == 0) {
						$insert = "insert into ld_salesmanactivityrel values(?,?)";
						$result = $adb->pquery($insert, array($idval, $id));
					}
				}
			}	
			//Now we have to update the smownerid
			$sql = "update ld_activity set modifiedby=?, smownerid=?, modifiedtime=? where activityid=?";
			if($idval != $subject[$id]['smownerid']){
				$focus->getModuleStatic('ModTracker');//字段修改日志
                $focus->modstatic->saveFieldLogOne('Calendar',$assigned,$id,
						$subject[$id]['smownerid'], $idval);
			}
			$result = $adb->pquery($sql, array($current_user->id, $idval, $adb->formatDate($date_var, true), $id));
		}
		else
		{
			$ids_list[] = $id;
		}
	}
}
elseif(isset($_REQUEST['leadval']) && $_REQUEST['leadval']!='')
{

	foreach($storearray as $id)
	{
		if(isPermitted($return_module,'EditView',$id) == 'yes')
		{
			if($id != '') {
				$sql = "update lingdang_leaddetails set leadstatus=? where leadid=?";
				$result = $adb->pquery($sql, array($leadstatusval, $id));
				$query = "update ld_activity set modifiedby=?, modifiedtime=? where activityid=?";
				$result1 = $adb->pquery($query, array($current_user->id, $adb->formatDate($date_var, true), $id));
			}
		}
		else
		{
			$ids_list[] = $id;
		}

	}
}
if(count($ids_list) > 0) {
	$ret_owner = getEntityName($return_module,$ids_list);
	$errormsg = implode(',',$ret_owner);
} else {
	$errormsg = '';
}
if($return_action == 'ActivityAjax') {
	$view       = vtlib_purify($_REQUEST['view']);
	$day        = vtlib_purify($_REQUEST['day']);
	$month      = vtlib_purify($_REQUEST['month']);
	$year       = vtlib_purify($_REQUEST['year']);
	$type       = vtlib_purify($_REQUEST['type']);
	$viewOption = vtlib_purify($_REQUEST['viewOption']);
	$subtab     = vtlib_purify($_REQUEST['subtab']);
	
	header("Location: index.php?module=$return_module&action=".$return_action."&type=".$type.$rstart."&view=".$view."&day=".$day."&month=".$month."&year=".$year."&viewOption=".$viewOption."&subtab=".$subtab.$url);
} else {
	header("Location: index.php?module=$return_module&action=".$return_module."Ajax&file=ListView&ajax=changestate".$rstart."&viewname=".$viewid."&errormsg=".$errormsg.$url);
}

?>