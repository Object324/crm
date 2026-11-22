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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Potentials/Save.php,v 1.6 2005/03/15 10:02:12 shaw Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Potentials/Potentials.php');
global $current_user,$adb;

$focus = CRMEntity::getInstance("Potentials");
//2020-1228 zxm 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
$versionInfo = getVersionInfo();
if($versionInfo['account'] == "moyuan"){
    $mode='create';
    if($focus->mode == 'edit' || $_REQUEST['mode'] == 'edit')
    {
        $mode='edit';
    }
    include_once globalStatic::$root_directory.'modules/Home/CustomMade/MoyuanUtils.php';
    $moyuanObj = new MoyuanUtils();
    $judge = $moyuanObj->judgePotentials($mode,$_REQUEST['assigned_user_id'],$_REQUEST['record']);
    if($judge['code'] == -1){
        $_REQUEST['diony'] = "yes";
        ConvertTojsonString($judge['code'], [], $judge['msg']);
    }
}

//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
$mode='create';
if($focus->mode == 'edit' || $_REQUEST['mode'] == 'edit')
{
    $focus->id = $_REQUEST['record'];
    $currency_id = $focus->column_fields['currency_id'];
	//编辑单据时,更新客户
	/*$account=CRMEntity::getInstance('Accounts');
    $account->updateAccountInfo($currentModule,'',1,$focus->id);*/
    $mode='edit';
    $focus->mode='edit';
    $focus->retrieve_entity_info($focus->id,'Potentials');
    $before_columnfieldvalue=$focus->column_fields;
    
}
setObjectValuesFromRequest($focus);

if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//chj:如果币种改变，则更改单据中原单的币种类型 和 汇率
$deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否

if($deployarray['deploy_value']==0)
{
    if($currency_id != $_REQUEST['inventory_currency'])
    $focus->currency_status = true;
    else
        $focus->currency_status = false;
    if($focus->currency_status === true)
    {
        
    	$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
    	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
    	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
      
    }
    $focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];
}
else{
    
    
    if($currency_id != $_REQUEST['currency_id'])
         $focus->currency_status = true;
    else
        $focus->currency_status = false;
    
    if($focus->currency_status === true)
    {
        $focus->column_fields['currency_id'] = $_REQUEST['currency_id'];
    	$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
    	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
    	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
    }
}
$focus->save("Potentials");
$pot_id = $return_id = $focus->id;
//2021-0118 zxm 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量  商机状态字段无权限无法更新的问题
if($versionInfo['account'] == "moyuan"){
    $update_sql = "update ld_potentialscf set cf_3329='".$_REQUEST['cf_3329']."' where potentialid=".$focus->id;
    $adb->pquery($update_sql,[]);
}


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
//传用户以前的负责人id
$assign_user_id = $focus->smoldOwnerID;
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    
    $focus->ReturnAfterSave($before_columnfieldvalue);
    
     /*  $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
    $record=$focus->id;
    if($mode=='create')
    {
       $sys_deploy= getSys_deploy(54);
       if($sys_deploy['deploy_value']==0)
       {
          $arr['loc_url']='index.php?action=DetailView&Create=true&module=Potentials&parenttab=Sales&record='.$record.'&pot_id='.$record.'&salestype=yes&viewname=0&start=';
       }
        
    }
    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{

    header("Location: index.php?action=$return_action&Create=true&module=$return_module&parenttab=$parenttab&record=$return_id&pot_id=$pot_id&salestype=yes&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}
else
{
	$_REQUEST['id']=$focus->id;
    $_REQUEST['sendSms']=$assign_user_id;
	include("modules/Potentials/Potentialsalertmsg.php");
    header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&pot_id=$pot_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
	
}

?>