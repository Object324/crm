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
require_once('include/logging.php');
require_once('include/database/PearDatabase.php');

global $adb,$mod_strings;
global $current_user;

$local_log =& LoggerManager::getLogger('RateAjax');
global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);
$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     if($crmid != "")
	 {
		$modObj->retrieve_entity_info($crmid,"Rate");
		$modObj->column_fields[$fieldname] = $fieldvalue;
		$modObj->id = $crmid;
		//小编辑币种时，更改关联金额字段
		$modObj->mode = 'edit';
		$modObj->save("Rate");
         
       
        if($crmid!=''){
          
        }
		 if($modObj->id != "")
	     {
			echo ":#:SUCCESS";
	     }else
	     {
			echo ":#:FAILURE";
	     }   
	}else
	{
         echo ":#:FAILURE";
    }
}elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}

?>