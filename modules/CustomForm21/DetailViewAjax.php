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
**/
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
     //
//     $crmid = $_REQUEST["recordid"];
//     $tablename = $_REQUEST["tableName"];
//     $fieldname = $_REQUEST["fldName"];
//     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
//     if($crmid != "")
//	 {
//		$modObj->retrieve_entity_info($crmid,"CustomForm21");
//
//		$be_currency_id = $modObj->column_fields['currency_id'];//编辑前币�?
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;
//		/*小编辑币种时，更改关联金额字�?
//		if($fieldname == 'currency_id' &&  $fieldvalue != $be_currency_id)
//		{
//			$modObj = MassEditCurrency($be_currency_id,$modObj,$currentModule);
//		}*/
//        //$modObj->massEdit_save_before($currentModule);
//		$modObj->mode = 'edit';
//		$modObj->save("CustomForm21");
//         
//       
//        if($crmid!=''){
//          
//        }
//		 if($modObj->id != "")
//	     {
//			echo ":#:SUCCESS";
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