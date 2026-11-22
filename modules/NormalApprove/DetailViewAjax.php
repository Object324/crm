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


global $adb;

//$local_log =& LoggerManager::getLogger('HelpDeskAjax');
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
//	$tablename = $_REQUEST["tableName"];
//	$fieldname = $_REQUEST["fldName"];
//	$fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]);
//	if($crmid != ""){
//	       $uitype=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'uitype');
//            if($uitype==1101)
//            {
//                   
//                        $value=fieldValueUitype::SetMobileStyle($crmid,$fieldvalue,$currentModule);
//                         echo  "##mobile##".$value."##mobile##";
//                    
//            }
//		$modObj->retrieve_entity_info($crmid,"HelpDesk");
//		
//		//Added to avoid the comment save, when we edit other fields through ajax edit
//		if($fieldname != 'comments')
//			$modObj->column_fields['comments'] = '';
//
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;
//		$modObj->mode = "edit";
//
//		//Added to construct the update log for Ticket history
//		//$assigned_group_name = getGroupName($_REQUEST['assigned_group_id']);
//		$assigntype = $_REQUEST['assigntype'];
//
//		//$fldvalue = $modObj->constructUpdateLog($modObj, $modObj->mode, $assigned_group_name, $assigntype);
//        $fldvalue = from_html($fldvalue,($modObj->mode == 'edit')?true:false);
//        $modObj->save("NormalApprove");
//		//update the log information for ticket history
//        /*
//        *time:2015-03-16
//        *edit:diony
//        *reason:0014022: 客户服务单--明细：编辑，保存后，修改日志显示错误。
//        *先把修改语句给注销掉
//        */
//		//$adb->pquery("update ld_troubletickets set update_log=? where ticketid=?", array($fldvalue, $modObj->id));
//		
//		if($modObj->id != ""){
//			if($fieldname == "comments"){
//				$comments = $modObj->getCommentInformation($modObj->id);
//				echo ":#:SUCCESS".$comments;
//			}else{
//				echo ":#:SUCCESS";
//			}
//		}else{
//			echo ":#:FAILURE";
//		}   
//	}else{
//		echo ":#:FAILURE";
//	}
} elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>