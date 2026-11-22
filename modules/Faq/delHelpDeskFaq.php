<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header$
 * Description:  Deletes an Account record and then redirects the browser to the 
 * defined return URL.
 ********************************************************************************/

global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings,$adb;

require_once('include/logging.php');
$log = LoggerManager::getLogger('contact_delete');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();
if(isset($_REQUEST['return_id'])){
	$ticketid = $_REQUEST['return_id'];
}
if(isset($_REQUEST['record'])){
	$record = $_REQUEST['record'];
}
//相关信息删除
if(!empty($_REQUEST['relatedid'])){
	$query="SELECT questionid FROM ld_troubletickets WHERE ticketid = ".$ticketid." limit 1";
	$result = $adb->pquery($query,array());
}else{//列表 详情页删除
	$query="SELECT questionid,ticketid FROM ld_troubletickets WHERE questionid like '%".$record."%'";
	$result = $adb->pquery($query,array());
}
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	for($i = 0; $i<$num_rows; $i++){
		$questionid= $adb->query_result($result,$i,'questionid');
		if(empty($_REQUEST['relatedid'])){
			$ticketid = $adb->query_result($result,$i,'ticketid');
		}
		if(!empty($questionid)){
			$questionid_arr = explode(',',$questionid); 
			unset($questionid_arr[array_search($record,$questionid_arr)]);
			$newquestionid=implode(',',$questionid_arr);
			$query="UPDATE ld_troubletickets SET questionid = '$newquestionid' WHERE ticketid =". $ticketid;
			$adb->pquery($query);
		}
	}
}

header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id']).$url);
?>