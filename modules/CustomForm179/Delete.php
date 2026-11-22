<?php
/*********************************************************************************
 *{*淇敼缂栫爜鏍煎�?缁熶竴缂栫爜锛歎TF-8*}
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
global $adb,$currentModule;
$focus = CRMEntity::getInstance($currentModule);
$record = vtlib_purify($_REQUEST['record']);
//$parenttab = getParentTab();
$focus->id = $record;
global $mod_strings;

require_once('modules/Accounts/Accounts.php');
require_once('include/logging.php');
$log = LoggerManager::getLogger('CustomForm179_delete');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);
        /**
*@andrew
* @time:20140903
*0011046: 骞跺彂鍒犻櫎鍗曟嵁鏃讹紝缁撴灉寮瑰嚭鎻愮ず鈥渦ndefined�?*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select customform179id from ld_customform179 where customform179id in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
       $srt = getFixedLabel('Thisrecordisdeleted');
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//褰撳墠椤垫暟
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


if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    //require_once('modules/Approve/Approve.php');
	//$approve=new Approve();
	$approve = Approve::getInstance($currentModule);
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}

/*
 * editor : gyq_02
 * explian : 鍒犻櫎鍓嶇粰褰撳墠瀵硅薄璧嬪€? * date   : 2016  1  22
 * */
if(!empty($record))
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);


DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);




/**********璁㈠崟鎺ュ彛 end************/
echo "##YES##";

/*
$parenttab = getParentTab();
header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".
		vtlib_purify($_REQUEST['return_action'])."&record=".
		vtlib_purify($_REQUEST['return_id']).$url);*/
?>