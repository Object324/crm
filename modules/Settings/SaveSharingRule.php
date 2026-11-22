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

require_once('include/database/PearDatabase.php');
global $adb;

//$sharing_module=$_REQUEST['sharing_module'];
$sharing_module=getTranLabelTabName($_REQUEST['sharing_module'],'ld_tab',1);
$tabid=getTranLabelTabName($_REQUEST['sharing_module'],'ld_tab',0);
$sharedby = explode('::',$_REQUEST[$sharing_module.'_share']);
$sharedto = explode('::',$_REQUEST[$sharing_module.'_access']);
$share_entity_type = $sharedby[0];
$to_entity_type = $sharedto[0];

$share_entity_id= $sharedby[1];
$to_entity_id=$sharedto[1];

$module_sharing_access=$_REQUEST['share_memberType'];

$mode=$_REQUEST['mode'];

$relatedShareModuleArr=getRelatedSharingModules($tabid);
if($mode == 'create')
{
	$shareId=addSharingRule($tabid,$share_entity_type,$to_entity_type,$share_entity_id,$to_entity_id,$module_sharing_access);

	//Adding the Related ModulePermission Sharing
	foreach($relatedShareModuleArr as $reltabid=>$ds_rm_id)
	{
		$reltabname=getTabModuleName($reltabid);
		$relSharePermission=$_REQUEST[$reltabname.'_accessopt'];	
		addRelatedModuleSharingPermission($shareId,$tabid,$reltabid,$relSharePermission);	
	}
	
}
elseif($mode == 'edit')
{
	$shareId=$_REQUEST['shareId'];
	updateSharingRule($shareId,$tabid,$share_entity_type,$to_entity_type,$share_entity_id,$to_entity_id,$module_sharing_access);
	//Adding the Related ModulePermission Sharing
	foreach($relatedShareModuleArr as $reltabid=>$ds_rm_id)
	{
		$reltabname=getTabModuleName($reltabid);
		$relSharePermission=$_REQUEST[$reltabname.'_accessopt'];	
		updateRelatedModuleSharingPermission($shareId,$tabid,$reltabid,$relSharePermission);	
	}	
}
/** This function is to retreive the Related Module Sharing Id
  * It takes the following input parameters:
  *     $tabid -- The module tabid:: Type Integer
  *     $related_tabid -- The related module tabid:: Type Integer
  * This function returns the Related Module Sharing Id
  */

function getRelatedModuleSharingId($tabid,$related_tabid)
{

	global $adb;
	$query="select datashare_relatedmodule_id from ld_datashare_relatedmodules where tabid=? and relatedto_tabid=?";
	$result=$adb->pquery($query, array($tabid, $related_tabid));
	$relatedModuleSharingId=$adb->query_result($result,0,'datashare_relatedmodule_id');
	return $relatedModuleSharingId;

}

/** This function is to update the related module sharing permission for a particulare Sharing Rule
  * It takes the following input parameters:
  *     $shareid -- The Sharing Rule Id:: Type Integer
  *     $tabid -- The module tabid:: Type Integer
  *     $relatedtabid -- The related module tabid:: Type Integer
  * 	$sharePermisson -- This can have the following values:
  *                       0 - Read Only
  *                       1 - Read/Write
  */

function updateRelatedModuleSharingPermission($shareid,$tabid,$relatedtabid,$sharePermission)
{
	
	global $adb;
	$relatedModuleSharingId=getRelatedModuleSharingId($tabid,$relatedtabid);
	$query="update ld_datashare_relatedmodule_permission set permission=? where shareid=? and datashare_relatedmodule_id=?";
	$result=$adb->pquery($query, array($sharePermission, $shareid, $relatedModuleSharingId));
	
}
/** This function is to add the related module sharing permission for a particulare Sharing Rule
  * It takes the following input parameters:
  *     $shareid -- The Sharing Rule Id:: Type Integer
  *     $tabid -- The module tabid:: Type Integer
  *     $relatedtabid -- The related module tabid:: Type Integer
  * 	$sharePermisson -- This can have the following values:
  *                       0 - Read Only
  *                       1 - Read/Write
  */

function addRelatedModuleSharingPermission($shareid,$tabid,$relatedtabid,$sharePermission)
{

	global $adb;
	$relatedModuleSharingId=getRelatedModuleSharingId($tabid,$relatedtabid);
	$query="insert into ld_datashare_relatedmodule_permission values(?,?,?)" ;
	$result=$adb->pquery($query, array($shareid, $relatedModuleSharingId, $sharePermission));

}
/** This function is to retreive the list of related sharing modules for the specifed module
  * It takes the following input parameters:
  *     $tabid -- The module tabid:: Type Integer
  */

function getRelatedSharingModules($tabid)
{

	global $adb;
	$relatedSharingModuleArray=Array();
	$query="select * from ld_datashare_relatedmodules where tabid=?";
	$result=$adb->pquery($query, array($tabid));
	$num_rows=$adb->num_rows($result);
	for($i=0;$i<$num_rows;$i++)
	{
		$ds_relmod_id=$adb->query_result($result,$i,'datashare_relatedmodule_id');
		$rel_tabid=$adb->query_result($result,$i,'relatedto_tabid');
		$relatedSharingModuleArray[$rel_tabid]=$ds_relmod_id;

	}

	return $relatedSharingModuleArray;

}

/** This function is to update the organisation level sharing rule
  * It takes the following input parameters:
  *     $shareid -- Id of the Sharing Rule to be updated
  * 	$tabid -- Module tabid - Datatype::Integer
  * 	$shareEntityType -- The Entity Type may be ld_groups,roles,rs and ld_users - Datatype::String
  * 	$toEntityType -- The Entity Type may be ld_groups,roles,rs and ld_users - Datatype::String
  * 	$shareEntityId -- The id of the group,role,rs,user to be shared
  * 	$toEntityId -- The id of the group,role,rs,user to which the specified entity is to be shared
  * 	$sharePermisson -- This can have the following values:
  *                       0 - Read Only
  *                       1 - Read/Write
  * This function will return the shareid as output
  */
function updateSharingRule($shareid,$tabid,$shareEntityType,$toEntityType,$shareEntityId,$toEntityId,$sharePermission)
{

	global $adb;
	$query2="select * from ld_datashare_module_rel where shareid=?";
	$res=$adb->pquery($query2, array($shareid));
	$typestr=$adb->query_result($res,0,'relationtype');
	$tabname=getDSTableNameForType($typestr);
	$query3="delete from ".$tabname." where shareid=?";
	$adb->pquery($query3, array($shareid));



	$query1 = "update ld_datashare_module_rel set relationtype=? where shareid=?";
	$adb->pquery($query1, array($type_string, $shareid));

	$params = array($shareid, $shareEntityId, $toEntityId, $sharePermission);
	$adb->pquery($query, $params);
	
	return $shareid;

}


/** This function adds a organisation level sharing rule for the specified Module
  * It takes the following input parameters:
  * 	$tabid -- Module tabid - Datatype::Integer
  * 	$shareEntityType -- The Entity Type may be ld_groups,roles,rs and ld_users - Datatype::String
  * 	$toEntityType -- The Entity Type may be ld_groups,roles,rs and ld_users - Datatype::String
  * 	$shareEntityId -- The id of the group,role,rs,user to be shared
  * 	$toEntityId -- The id of the group,role,rs,user to which the specified entity is to be shared
  * 	$sharePermisson -- This can have the following values:
  *                       0 - Read Only
  *                       1 - Read/Write
  * This function will return the shareid as output
  */
function addSharingRule($tabid,$shareEntityType,$toEntityType,$shareEntityId,$toEntityId,$sharePermission)
{

	global $adb;
	$shareid=$adb->getUniqueId("ld_datashare_module_rel");


	$query1 = "insert into ld_datashare_module_rel values(?,?,?)";
	$adb->pquery($query1, array($shareid, $tabid, $type_string));
	$params = array($shareid, $shareEntityId, $toEntityId, $sharePermission);
	$adb->pquery($query, $params);
	
	return $shareid;

}

$loc = "Location: index.php?action=OrgSharingDetailView&module=Settings&parenttab=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting'];
header($loc);
?>