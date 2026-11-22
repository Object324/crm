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
global $adb,$currentModule;
$focus = CRMEntity::getInstance($currentModule);
$record = vtlib_purify($_REQUEST['record']);
//$parenttab = getParentTab();
$focus->id = $record;
global $mod_strings;
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
        /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select salesorderid from ld_salesorder where salesorderid in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
       $srt = getFixedLabel('Thisrecordisdeleted');
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
         $json = new Zend_Json();
         $jsonentity = $json->encode($entity);
	     echo $jsonentity;die;
    }
/**
 * edit:kevin
 * date:2013-07-23
 * reason:删除单据时,更新公海客户
 */ 
/*$account=CRMEntity::getInstance("Accounts");
               
$account->updateAccountInfo($_REQUEST['module'],'',2,$_REQUEST['record']);*/

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

/*
 * editor : gyq_02
 * explian : 删除前给当前对象赋值
 * date   : 2016  1  22
 * */
if(!empty($record))
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,
            entitytypeid,ld_salesorderdetail.entitytype,lineitem_id,batchtext
                    from ld_salesorderdetail 
                    left join ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));

$num_rows = $adb->num_rows($result);

//审批流程end
$arr = DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id'],"yes");
crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
crm_load_class_file('cls_OutSale_InverseCompute','include/OptionModule');

for($i = 0; $i<$num_rows; $i++){
	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
	$productid = $adb->query_result($result,$i,'productid');
	$qty = $adb->query_result($result,$i,'quantity');
	$entitytype = $adb->query_result($result,$i,'entitytype');

  
	//更新报价单的已下单数量和未下单数量
	if($entitytypeid > 0){
	  
		cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
		
	}
}
/*
 * editor : gyq_02
 * reason : 新增，删除联系记录更新对应客户最新进度和最新联系日期，销售机会最新联系日期
 * date   : 2016  1  22
 * */

if($focus->column_fields['account_id']>0)
{
  
    $focus->updateRelatedTableInfo('ld_account',array($focus->column_fields['account_id']));
 

}
if($focus->column_fields['potential_id']>0){


    $focus->updateRelatedTableInfo('ld_potential',array($focus->column_fields['potential_id']));
   
}


$trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
$tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。
if(!empty($tradename)&&file_exists('include/trade/'.$tradename.'/'.$tradename.'_SalesOrder.php'))
 {
        require_once('include/trade/'.$tradename.'/'.$tradename.'_SalesOrder.php');
        $trade_class_name=$tradename.'_SalesOrder';   
        if(class_exists($trade_class_name))     
        {
            $trade_focus=new $trade_class_name($focus);  
            if(method_exists($trade_focus,"Delete")){
                $trade_focus->Delete($record,$currentModule);//合同订单删除时，生成产品购买交易记录。(金融/基金行业)
            }
        }
  }
ConvertTojsonString('1',$arr,'');
/**********订单接口 end************/
echo "##YES##";

/*
$parenttab = getParentTab();
header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".
		vtlib_purify($_REQUEST['return_action'])."&record=".
		vtlib_purify($_REQUEST['return_id']).$url);*/
?>