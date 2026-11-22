<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

require_once('include/logging.php');
$log = LoggerManager::getLogger('task_delete');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);

/**
 * 有审批的模块，会用url调用一次delete文件，判断删除状态，传递ajax=ture参数，
 * 日程安排添加了审批功能，但没有添加ajax判断删除 语句，所以就调用了两次删除，因而报错
 * @reason 0009098 日程安排删除报已删除错误
 * @author Tujt 2014-05-28
 */
//判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
	//require_once('modules/Approve/Approve.php');
	//$approve = new Approve();
	$approve = Approve::getInstance($currentModule);
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
	echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
	exit();
}
/**
 * edit:kevin
 * date:2013-07-23
 * reason:删除单据时,更新公海客户
 */
/*
$account=CRMEntity::getInstance('Accounts');               
$account->updateAccountInfo($_REQUEST['module'],'',2,$_REQUEST['record']); */

DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);
echo '##YES##';

//$parenttab=getParentTab();
//header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
?>