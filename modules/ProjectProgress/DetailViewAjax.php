<?php

global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);

$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == 'DETAILVIEW')
{
    
    crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     $modObj->retrieve_entity_info($crmid, $currentModule);
     $modObj->id = $crmid;
	$modObj->mode = 'edit';
       //反写项目的工时和费用
        $modObj->UpdateProjectInfo($modObj);
     //反写项目任务的工时和费用
        $modObj->UpdateProjectTaskInfo($modObj);
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
	//$crmid = $_REQUEST['recordid'];
//	$tablename = $_REQUEST['tableName'];
//	$fieldname = $_REQUEST['fldName'];
//	$fieldvalue = utf8RawUrlDecode($_REQUEST['fieldValue']); 
//	if($crmid != '')
//	{
//		$modObj->retrieve_entity_info($crmid, $currentModule);
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;
//		$modObj->mode = 'edit';
//        //反写项目的工时和费用
//        $modObj->UpdateProjectInfo($modObj);
//        //反写项目任务的工时和费用
//        $modObj->UpdateProjectTaskInfo($modObj);
//		$modObj->save($currentModule);
//		if($modObj->id != '')
//		{
//			echo ':#:SUCCESS';
//		}else
//		{
//			echo ':#:FAILURE';
//		}   
//	}else
//	{
//		echo ':#:FAILURE';
//	}
} elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>