<?php

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
//	     $modObj->retrieve_entity_info($crmid,$modObj->module_name);
//         $be_currency_id = $modObj->column_fields['currency_id'];//编辑前币种
//	     $modObj->column_fields[$fieldname] = $fieldvalue;
//  
//	     $modObj->id = $crmid;
//		 /*小编辑币种时，更改关联金额字段
//		if($fieldname == 'currency_id' &&  $fieldvalue != $be_currency_id)
//		{
//			$modObj = MassEditCurrency($be_currency_id,$modObj,$currentModule);
//		}*/
//  	     $modObj->mode = "edit";
//       	 $modObj->save($modObj->module_name);
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