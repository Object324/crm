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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Accounts/Delete.php,v 1.5 2005/03/10 09:28:34 shaw Exp $
 * Description:  Deletes an Account record and then redirects the browser to the 
 * defined return URL.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
global $adb;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;

require_once('include/logging.php');
$log = LoggerManager::getLogger('sendcashBill');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();
if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);
    /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select cashbackid from ld_cashback where cashbackid in($record) and deleted=0";

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
/*$cashback_query = "select cashbackid,salesbackid,bankaccountsetid ,total from ld_cashback where cashbackid =?";
$cashback_result = $adb->pquery($cashback_query, array($_REQUEST['record']));
$result_total = $adb->query_result($cashback_result,0,'total');
$result_salesbackid = $adb->query_result($cashback_result,0,'salesbackid');
$bankaccountsetid = $adb->query_result($cashback_result,0,'bankaccountsetid');   

$update_query = "update ld_salesback set havebackamount=IFNULL(havebackamount,0)-$result_total where salesbackid=?";
$adb->pquery($update_query, array($result_salesbackid));

$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$result_total WHERE bankaccountsetid=$bankaccountsetid";
  $adb->pquery($usql,array()); */

//ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(删除销售退款单时重算金额)
$focus->resetAmount($_REQUEST['record']);
$focus->addBankMoney($_REQUEST['record']);

DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);

$parenttab = getParentTab();
echo '##YES##';
//header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
?>