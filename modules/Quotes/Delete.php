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
 * $Header$
 * Description:  Deletes an Account record and then redirects the browser to the 
 * defined return URL.
 ********************************************************************************/

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;


    /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select quoteid,accountid from ld_quotes where quoteid in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0) {
        $srt = getFixedLabel('Thisrecordisdeleted');
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
         $json = new Zend_Json();
         $jsonentity = $json->encode($entity);
	     echo $jsonentity;die;
    }else{
		$accountid = $adb->query_result($dresult,0,'accountid');
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
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    //require_once('modules/Approve/Approve.php');
	//$approve=new Approve();
	$approve = Approve::getInstance($currentModule);
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}
$arr = DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id'],"yes");

//更新客户的最新报价日期
$focus->updateAccountsLastQuotesDate($accountid);
$parenttab = getParentTab();
$focus->massDelete_after($_REQUEST['return_module'],array($focus->id));
echo '##YES##';
ConvertTojsonString('1',$arr,'');
?>