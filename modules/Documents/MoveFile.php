<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

require_once('include/logging.php');
require_once('include/database/PearDatabase.php');
global $current_user;
if($current_user->is_admin != 'on')
{
	echo 'NOT_PERMITTED';
	die;	
}
else
{
	$new_folderid = $_REQUEST['folderid'];
	$idlist = vtlib_purify($_REQUEST['idlist']);
	$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
	//批量操作数上线
	$deployarray=getSys_deploy(67);
	$batchnum = $deployarray['deploy_value'];
	if(isset($_REQUEST['idlist']) && $_REQUEST['idlist']!= '')
	{
		$id_array = Array();
		$id_array = getSelectedRecords($_REQUEST,'Documents',$idlist,$excludedRecords);//explode(';',$_REQUEST['idlist']);
		$id_array = array_filter($id_array);
		for($i = 0;$i < count($id_array);$i++) {
			if($i < $batchnum){
				ChangeFolder($id_array[$i],$new_folderid);
			}
		}
		header("Location: index.php?action=DocumentsAjax&file=ListView&mode=ajax&module=Documents");
	}
}

/** To Change the Documents to another folder
  * @param $recordid -- The file id
  * @param $new_folderid -- The folderid to which the file to be moved
  * @returns nothing 
 */
function ChangeFolder($recordid,$new_folderid)
{
	global $adb;
	$sql="update ld_notes set folderid=".$new_folderid." where notesid in (".$recordid.")";
	$res=$adb->pquery($sql,array());
}
?>