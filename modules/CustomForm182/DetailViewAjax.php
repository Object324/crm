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
     //
//     $crmid = $_REQUEST["recordid"];
//     $tablename = $_REQUEST["tableName"];
//     $fieldname = $_REQUEST["fldName"];
//     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
//     if($crmid != "")
//	 {
//		$modObj->retrieve_entity_info($crmid,"CustomForm21");
//
//		$be_currency_id = $modObj->column_fields['currency_id'];
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;

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