<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
global $adb;
global $current_user;
$focus = CRMEntity::getInstance($currentModule);
$focusContact=CRMEntity::getInstance('Contacts');
$idlist= vtlib_purify($_REQUEST['massedit_recordids']);
$viewid = vtlib_purify($_REQUEST['viewname']);
$return_module = vtlib_purify($_REQUEST['massedit_module']);
$return_action = 'index';
$parenttab = getParentTab();
$SearchScope=$_REQUEST['SearchScope'];
if(isset($idlist)) 
{
	$recordids = explode(';', $idlist);
	for($i = 0; $i < count($recordids); $i++) 
    {
		$recordid = $recordids[$i];
		if($recordid == '') continue;
		if(isPermitted($currentModule,'EditView',$recordid) == 'yes') 
        {
			$focus->retrieve_entity_info($recordid, $currentModule);
			$focus->mode = 'edit';		
			$focus->id = $recordid;                          
            $Value = $_REQUEST['assigned_user_id'];			
            $focus->column_fields['assigned_user_id']=$Value;
            $focus->save($currentModule); 
        }
	}
}
header("Location: index.php?module=$return_module&action=$return_action&parenttab=$parenttab&SearchScope=$SearchScope");
?>