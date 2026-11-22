<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

require_once('include/logging.php');
$log = LoggerManager::getLogger('note_delete');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();
//审批流程begin
//判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    //require_once('modules/Approve/Approve.php');
    //$approve=new Approve();
	$approve = Approve::getInstance($currentModule);
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}
if(!isset($_REQUEST['record']))
	die("A record number must be specified to delete the note.");
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
$deploy_values=getSys_deploy("69");
if($deploy_values['deploy_value']==1&&Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    $entity['log']['value'] = $srt1;
    $entity['title']['value'] = getFixedLabel('DELETE');
    $json = new Zend_Json();
    $jsonentity = $json->encode($entity);
    echo $jsonentity;die;
}
DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);

echo '##YES##';
exit();
$parenttab = getParentTab();

header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
?>