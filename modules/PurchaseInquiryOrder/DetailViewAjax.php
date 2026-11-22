<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
/*
模块明细界面"更多信息"页面
*/
/*
*新增操作，收款单、服务单、联系记录、入库单、盘点增减更多信息 附件功能
*by andy 20131225
*/

//require_once('include/database/PearDatabase.php');
require_once('modules/Reminds/Reminds.php');
global $adb,$mod_strings;
global $current_user;

global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);
$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
     crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
   
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
     //$crmid = $_REQUEST["recordid"];
//     $tablename = $_REQUEST["tableName"];
//     $fieldname = $_REQUEST["fldName"];
//     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
//     if($crmid != "")
//	 {
//	     $modObj->retrieve_entity_info($crmid,"PurchaseInquiryOrder");
//         
//	     $modObj->column_fields[$fieldname] = $fieldvalue;
//	    /* if($fieldname=='accountname'){
//	     	$value = $fieldvalue;
//			$query = "SELECT accountname FROM ld_account,ld_crmentity WHERE accountname =? and ld_account.accountid = ld_crmentity.crmid and ld_crmentity.deleted != 1";
//			$params = array($value);
//			if(isset($crmid) && $crmid !='') {
//				$query .= " and ld_account.accountid != ?";
//				array_push($params, $crmid);
//			}
//			$result = $adb->pquery($query, $params);
//		    if($adb->num_rows($result) > 0)
//			{
//				echo ":#:ERR".$mod_strings['LBL_ACCOUNT_EXIST'];
//				return false;
//			}
//	     }
//	     if($fieldname=='accountname'){
//	     	$value = $fieldvalue;
//			$query = "SELECT accountname FROM ld_account,ld_crmentity WHERE accountname =? and ld_account.accountid = ld_crmentity.crmid and ld_crmentity.deleted != 1";
//			$params = array($value);
//			if(isset($crmid) && $crmid !='') {
//				$query .= " and ld_account.accountid != ?";
//				array_push($params, $crmid);
//			}
//			$result = $adb->pquery($query, $params);
//		    if($adb->num_rows($result) > 0)
//			{
//				echo ":#:ERR".$mod_strings['LBL_ACCOUNT_EXIST'];
//				eturn false;
//			}
//	     }   */
//         
//	     $modObj->id = $crmid;
//  	     $modObj->mode = "edit";
//       	 $modObj->save("PurchaseInquiryOrder");
//         
//         if($modObj->id != "")
//	     {
//			echo ":#:SUCCESS".$focus->column_fields['assigned_user_id'].'######id';
//	     }else
//	     {
//			echo ":#:FAILURE";
//	     }   
//	}else
//	{
//         echo ":#:FAILURE";
//    }
}elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}

?>