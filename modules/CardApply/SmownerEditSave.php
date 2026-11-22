<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

/**
 * @author andy
 * @copyright 2014
 */
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
global $currentModule;
global $adb;

$focus = CRMEntity::getInstance($currentModule);
$focusContact=CRMEntity::getInstance('Contacts');

$idlist= vtlib_purify($_REQUEST['massedit_recordids']);
$viewid = vtlib_purify($_REQUEST['viewname']);

$return_module = vtlib_purify($_REQUEST['massedit_module']);
$return_action = 'index';

global $rstart;
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
	$rstart = "&start=".vtlib_purify($_REQUEST['start']);
}

if(isset($idlist)) {
	$recordids = explode(';', $idlist);
	for($index = 0; $index < count($recordids); ++$index) {
		$recordid = $recordids[$index];
		if($recordid == '') continue;
		if(isPermitted($currentModule,'EditView',$recordid) == 'yes') {
			$focus->retrieve_entity_info($recordid, $currentModule);
			$focus->mode = 'edit';		
			$focus->id = $recordid;            
        
            $Value = $_REQUEST['assigned_user_id'];
		
            $focus->column_fields['assigned_user_id']=$Value;//修改负责人字段
           
            $focus->save($currentModule);        

		}
	}
}
$parenttab = getParentTab();

$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
unset($currentModule);unset($adb);
if(isset($_REQUEST['return_action']))
{
    $return_action = $_REQUEST['return_action'];
    header("Location: index.php?module=$return_module&action=$return_action&parenttab=$parenttab$rstart&record=$recordids[0]");
}else{  
    header("Location: index.php?module=$return_module&action=$return_action&parenttab=$parenttab$rstart&SearchScope=$SearchScope&query_session=1");
}



?>