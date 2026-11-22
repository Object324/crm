<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Potentials/Delete.php,v 1.9 2005/03/16 10:31:13 rank Exp $
 * Description:  TODO: To be written.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

require_once('include/logging.php');
$log = LoggerManager::getLogger('contact_delete');
/**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select potentialid from ld_potential where potentialid in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
        $hurl = 'index.php?module='.vtlib_purify($_REQUEST['return_module']).'&action='.vtlib_purify($_REQUEST['return_action']).'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;
       $srt = getFixedLabel('Thisrecordisdeleted');
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
         $json = new Zend_Json();
         $jsonentity = $json->encode($entity);
	     echo $jsonentity;die;
    }
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
    die("A record number must be specified to delete the opportunity.");
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
/*
 * editor : gyq_02
 * explian : 删除前给当前对象赋值
 * date   : 2016  1  22
 * */
if(!empty($record))
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
//删除单据时,更新公海客户
/*
$account=CRMEntity::getInstance('Accounts');               
$account->updateAccountInfo($currentModule,'',2,$_REQUEST['record']);*/

$arr = DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id'],"yes");

/*
 * editor : gyq_02
 * reason : 新增，删除联系记录更新对应客户最新进度和最新联系日期，销售机会最新联系日期
 * date   : 2016  1  22
 * */
if($focus->column_fields['account_id']>0)
{
    $focus->updateRelatedTableInfo('ld_account',array($focus->column_fields['account_id']));

}
ConvertTojsonString('1',$arr,'');
echo '##YES##';
//header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
?>