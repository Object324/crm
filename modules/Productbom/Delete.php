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

require_once('include/logging.php');
$log = LoggerManager::getLogger('productbom_delete');

/**
 * @andrew
 * @time:20140903
 * 0011046: 并发删除单据时，结果弹出提示“undefined”
 */
$record = $_REQUEST['record'];
$checkdeletesql="select productbomid from ld_productbom where productbomid in($record) and deleted=0";

$dresult=$adb->query($checkdeletesql);
$dnum_rows=$adb->num_rows($dresult);

if($dnum_rows==0){
	$hurl = 'index.php?module='.vtlib_purify($_REQUEST['return_module']).'&action='.vtlib_purify($_REQUEST['return_action']).'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;
	$srt = getFixedLabel('Thisrecordisdeleted');
	echo "<script>alert('$srt');top.location='$hurl';</script>";
	exit();
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
$focus->id=$_REQUEST['record'];
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);

//require_once('modules/Approve/Approve.php');
/*$approve=new Approve();
$approve = Approve::getInstance($currentModule);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){//点击删除按钮判断当前单据是否已经删除
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}else{直接进入当前文件时，判断当前单据是否已经审批，或者处于审批中*
	$blockbuttons = $approve->blocksButton($focus->column_fields['assigned_user_id'],$focus->id);
	$isdelete=$blockbuttons[3];
	$approvestatus=$blockbuttons[4];
	if($isdelete !=0){
		$alertstr = '';
		switch($approvestatus){
			case 1:
				$alertstr = getFixedLabel('Approvalof');
				break;
			case 2:
				$alertstr = getFixedLabel('Approved');
				break;
		}
		if(!empty($alertstr)){
			echo '<script type="text/javascript">alert("'.$alertstr.'");history.go(-1);</script>';exit();
		}
	}
}*/

DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);
echo '##YES##';
exit();
$parenttab = getParentTab();

header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".
		vtlib_purify($_REQUEST['return_action'])."&&parenttab=$parenttab&record=".
		vtlib_purify($_REQUEST['return_id']).$url);
?>